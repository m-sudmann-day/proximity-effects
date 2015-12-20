
######################################################################################
# analysis.R (RUNTIME ANALYSIS SCRIPT)
#
# This is the R script that is called from the website at runtime when a user
# submits a request to analyze an area/category combination for proximity effects.
# Final analysis of a subset of businesses are performed and charts are written
# to the file system for retrieval by the website.
######################################################################################

# Define some global variables, including those passed in as command line parameters.
is.win               <- (Sys.info()['sysname'] == "Windows")
mysql.user           <- "root"
mysql.pwd            <- ""
mysql.server         <- "localhost"
mysql.database       <- "proximity_effects"
args                 <- commandArgs(TRUE)
charts.partial.path  <- args[1]
area.id              <- args[2]
category.id          <- args[3]

# Load the R packages used by this script.
if (is.win) {
  require(ggplot2)
  require(RMySQL)
  require(fossil)
} else {
  lib.loc <- "/home/ubuntu/projects/Rlibs"
  require(DBI, lib.loc=lib.loc)
  require(sp, lib.loc=lib.loc)
  require(maps, lib.loc=lib.loc)
  require(shapefiles, lib.loc=lib.loc)
  require(labeling, lib.loc=lib.loc)
  require(ggplot2, lib.loc=lib.loc)
  require(RMySQL, lib.loc=lib.loc)
  require(fossil, lib.loc=lib.loc)
}

# Define a generic function for fetching data from our MySQL database.
fetch.data.from.sql <- function(sql)
{
  conn <- dbConnect(MySQL(), user=mysql.user, host=mysql.server, dbname=mysql.database)
  rs <- dbSendQuery(conn, sql)
  results <- fetch(rs, n=-1)
  dbClearResult(rs) -> sink
  dbDisconnect(conn) -> sink
  return(results)
}

# Load data about all the businesses in the given area/category combination.  These
# data contains a number of columns containing pre-calculated portions of our analysis.
load.businesses <- function(area, cat)
{
  sql <- paste0("call GetBusinesses(", area, ", ", cat, ");")
  B <- fetch.data.from.sql(sql)

  B$Stars3Mean <- NULL
  B$Stars3StDev <- NULL
  colnames(B)[colnames(B)=="YelpStars"] <- "YS"
  colnames(B)[colnames(B)=="Stars1Mean"] <- "ST"
  colnames(B)[colnames(B)=="Stars1StDev"] <- "ST.sd"
  colnames(B)[colnames(B)=="Stars2Mean"] <- "ML"
  colnames(B)[colnames(B)=="Stars2StDev"] <- "ML.sd"

  return(B)
}

# Using the Fossil package, obtain the distances between all businesses in our
# area/category combination.
calculate.distances <- function(B)
{
  N <- nrow(B)
  D <- earth.dist(matrix(c(B$Longitude, B$Latitude), N, 2), FALSE)
  for (d in 1:N) { D[d,d] <- NA }
  return(D)
}

# This function augments the data about each business by incorporating data from each business's nearest
# competitor and each business's three nearest copmetitors, using inverse distance weighting.  It is called
# multiple times, each time incorporating different sets of data, as per the parameters which tell it which
# columns to read and write. 
generate.more.columns <- function(B, D, read.col, write.col.1, write.col.3, write.col.1.diff, write.col.3.diff)
{
  read.col <- which(colnames(B)==read.col)
  write.col.1 <- which(colnames(B)==write.col.1)
  write.col.3 <- which(colnames(B)==write.col.3)
  write.col.1.diff <- which(colnames(B)==write.col.1.diff)
  write.col.3.diff <- which(colnames(B)==write.col.3.diff)
  N <- nrow(B)
  
  for (b1 in 1:N)
  {
    v <- D[b1,]
    if (sum(!is.na(v)) > 0)
    {
      B$Dist[b1] <- closestDist1 <- min(v, na.rm=TRUE)
      b2 <- which.min(v)
      rating1 <- B[b1,write.col.1] <- B[b2,read.col]
      w1 <- (1/closestDist1^2.5)
      v[b2] <- NA
    
      if (N > 2)
      {
        closestDist2 <- min(v, na.rm=TRUE)
        b2 <- which.min(v)
        rating2 <- B[b2,read.col]
        w2 <- (1/closestDist2^2.5)
        v[b2] <- NA
      }
      else
      {
        rating2 <- 0
        w2 <- 0
      }
      
      if (N > 3)
      {
        closestDist3 <- min(v, na.rm=TRUE)
        b2 <- which.min(v)
        rating3 <- B[b2,read.col]
        w3 <- (1/closestDist3^2.5)
      }
      else
      {
        rating3 <- 0
        w3 <- 0
      }
      
      numer <- w1*rating1 + w2*rating2 + w3*rating3
      denom <- w1+w2+w3
      if (denom < 1e-3)
        B[b1,write.col.3] <- NA
      else
        B[b1,write.col.3] <- numer/denom
      
      B[b1,write.col.1.diff] <- abs(rating1 - B[b1,read.col])
      B[b1,write.col.3.diff] <- abs(rating3 - B[b1,read.col])
    }
  }
  
  return(B)
}

# This function oversees the data processing of the businesses in the area/category combination.
# It loads all businesses, calculates distances, derives additional information from nearby
# competitors, and returns a data frame containing all businesses.
process <- function(area,cat)
{
  # Load all businesses.
  B <- load.businesses(area, cat)
  # Initialize the distances matrix.
  D <- NA

  if (nrow(B) > 0)
  {
    # Populate the distances matrix.
    D <- calculate.distances(B)

    # Initialize all columns that we calculate after the businesses data has been loaded.
    B$YS1 <- B$YS3 <- B$YSD1 <- B$YSD3 <- NA
    B$ST1 <- B$ST3 <- B$STD1 <- B$STD3 <- B$ST1.sd <- B$ST3.sd <- B$STD1.sd <- B$STD3.sd <- NA
    B$ML1 <- B$ML3 <- B$MLD1 <- B$MLD3 <- B$ML1.sd <- B$ML3.sd <- B$MLD1.sd <- B$MLD3.sd <- NA
    
    # Calculate additional columns by incorporating competitor information into each business row.
    B <- generate.more.columns(B, D, "YS", "YS1", "YS3", "YSD1", "YSD3")
    B <- generate.more.columns(B, D, "ST", "ST1", "ST3", "STD1", "STD3")
    B <- generate.more.columns(B, D, "ST.sd", "ST1.sd", "ST3.sd", "STD1.sd", "STD3.sd")
    B <- generate.more.columns(B, D, "ML", "ML1", "ML3", "MLD1", "MLD3")
    B <- generate.more.columns(B, D, "ML.sd", "ML1.sd", "ML3.sd", "MLD1.sd", "MLD3.sd")

    # For those areas outside the US, where we do not have population density information,
    # simply use the same constant for all businesses, thereby causing population density to have
    # no effect.
    if (area %in% c(1,2,9,10))
    {
      B$Density <- 1000
    }
    # If there are null distances, ignore density and set our Dist*Density term to actually ignore density.
    else if (sum(is.null(B$Dist))>0)
    {
      B$DistDensity = B$Dist
    }
    # For the remaining vast majority of cases, calculate the Dist*Density term to be distance times
    # population densit.  Divide the result by 1000 to bring the value back down to a conceptual range
    # that approximates kilometers.
    else
    {
      B$DistDensity <- B$Dist * B$Density / 1000
    }
  }

  return(B)
}

# This function performs a generic action, receiving the output of a regression (calculated by
# calling the lm() function) and then extracting the coefficient and t value and returning them
# in a vector.
extract.regression.info <- function(reg)
{
  summ <- summary(reg)
  if (nrow(summ$coefficients) > 1)
    t <- summ$coefficients[2, "t value"]
  else
    t <- 0

  return(c(reg$coef[2], t))
}

# This function takes a data frame of businesses and genearates a plot based on the parameters
# of interest that are passed into the function.
display <-function(B, area.id, y, run.reg, caption, xcaption, ycaption, index)
{
  if (nrow(B) > 0)
  {
    # Modify our copy of the businesses data frame so that the dependent variable of interest
    # is always called 'Y'.
    colnames(B)[colnames(B)==y] <- "Y"

    plot <- ggplot(B) + theme_bw()
    plot <- plot + theme(axis.text =  element_text(face = "bold", size = 14))
    plot <- plot + theme(axis.title =  element_text(face = "bold", size = 14))
    plot <- plot + theme(plot.title =  element_text(face = "bold", size = 14))
    plot <- plot + ggtitle(paste0(caption, "  (N=", nrow(B), ")"))

    # Define the appropriate independent variable to appear on the X axis.
    if (area.id %in% c(1,2,9,10)) # no population density information available
    {
      plot <- plot + geom_point(aes(x=Dist,y=Y), colour="blue", size=3)
    }
    else
    {
      plot <- plot + geom_point(aes(x=DistDensity,y=Y), colour="blue", size=3)
    }
    
    # Add a gray line to visually identify mark the center of our standardization, at Y=0.
    plot <- plot + geom_abline(intercept=0, slope=0, colour="gray", size=1)
    
    if (run.reg)
    {
      # If requested by the caller, perform a regression to prepare for displaying a fit line.
      if (area.id %in% c(1,2,9,10)) # no population density information available
      {
        reg <- lm(formula=B$Y ~ B$Dist)
      }
      else
      {
        reg <- lm(formula=B$Y ~ B$DistDensity)
      }
      summ <- summary(reg)

      # Extract data about the regression for displaying on the X-axis label.
      slope <- summ$coefficients[2, "Estimate"]
      slope <- sprintf("%.2f", slope)
      conf <- summ$coefficients[2, "Pr(>|t|)"]
      conf <- sprintf("%.1f%%", (1-conf)*100)
      xcaption <- paste0(xcaption, "\n(Slope=", slope, ", Confidence=", conf, ")")
      
      # Add a red line to the plot to show the fit line calculated by the regression.
      plot <- plot + geom_abline(intercept=reg$coefficients[1],slope=reg$coefficients[2],
         colour="red",size=1)
    }
    
    plot <- plot + labs(x=xcaption, y=ycaption)
  
    # If an index was passed in, then this plot is intended to be written to the file system
    # and used by the website.  Otherwise, we are in an interactive development state and should
    # just return the plot object directly.
    if (index == 0)
    {
      return(plot)
    }
    else
    {
      filename = paste0(charts.partial.path, ".", index, ".png", sep="")
      ggsave(filename=filename, width=8, height=6, units="in", dpi=100, plot=plot)
      return(plot)
    }
  }
}

# Uncomment this for development purposes when there are no command line parameters.
# It will give us pizza restaurants in Pittsburgh.
# area.id=7;category.id=21984

# Call the process function to populate and manipulate a data frame of businesses.
B <- process(area.id, category.id)

# Call the display function to produce each of five charts.
display(B, area.id, "YS1", FALSE, "Yelp Stars vs. Distance", "Distance to Closest Competitor (KM)", "Yelp Rating (Stars)", 10)
display(B, area.id, "ML1", FALSE, "Standardized Median Absolute Deviation of Rating\nvs. Distance", "Distance to Closest Competitor (KM)", "Standardized MAD Rating", 20)
display(B, area.id, "MLD1", TRUE, "Difference Between Standardized MAD Rating of Closest Competitors\nvs. Distance", "Distance to Closest Competitor (KM)", "Standardized MAD Rating Difference", 30)
display(B, area.id, "MLD3", TRUE, "Difference Between Standardized MAD Rating Against 3 Closest Competitors\nvs. Distance", "Weighted Distance to 3 Closest Competitors (KM)","Standardized MAD Rating Difference (Against 3 Closest)", 40)
display(B, area.id, "ML1.sd", TRUE, "Standard Deviation of Standardized MAD Ratings vs. Distance", "Distance to Closest Competitor (KM)", "Standard Deviation of Standardized MAD Ratings", 50)
