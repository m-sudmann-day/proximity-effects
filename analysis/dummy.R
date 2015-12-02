#rm(list=ls(all=TRUE))

is.win = (Sys.info()['sysname'] == "Windows")

if (is.win) {
  require(ggplot2)
  require(ggmap)
  require(RMySQL)
  require(fossil)
} else {
  lib.loc = ifelse(is.win, "", "/home/ubuntu/projects/Rlibs")
  require(ggplot2, lib.loc=lib.loc)
  require(RMySQL, lib.loc=lib.loc)
  require(fossil, lib.loc=lib.loc)
  require(ggmap, lib.loc=lib.loc)
}

mysql.user      <- "root"
mysql.pwd       <- "root"
mysql.server    <- "localhost"
mysql.database  <- "proximity_effects"
args            <- commandArgs(TRUE)
charts.root     <- args[1]
ts              <- args[2]
area.id         <- args[3]
category.id     <- args[4]

# if (is.win) {
#   charts.root     <- "C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\web\\charts\\"
# } else {
#   charts.root     <- "/var/www/html/MyApp/charts"
# }
# ts <- "blah"

dir <- paste0(charts.root, ts, sep="")
dir.create(dir)

fetch.data.from.sql <- function(sql)
{
  conn <- dbConnect(MySQL(), user=mysql.user, password=mysql.pwd, host=mysql.server, dbname=mysql.database)
  rs <- dbSendQuery(conn, sql)
  results <- fetch(rs, n=-1)
  dbClearResult(rs) -> sink
  dbDisconnect(conn) -> sink
  return(results) 
}

load.categories <- function()
{
  return(fetch.data.from.sql("call GetAllActiveCategories();"))
}

load.data <- function(area, cat)
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

calculate.distances <- function(B)
{
  N <- nrow(B)
  D <- earth.dist(matrix(c(B$Longitude, B$Latitude), N, 2), FALSE)
  for (d in 1:N) { D[d,d] <- NA }
  return(D)
}

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

process <- function()
{
  cats <- load.categories()
  results <- data.frame("Area","Cat","Biz","Rev",
                        "YS", "YSt", "ST1", "ST1t", "MLD1", "MLD1t", "MLD3", "MLD3t", "ST1.sd", "ST1.sdt", "ML1.sd", "ML1.sdt",
                        stringsAsFactors=FALSE)
  
  B <- generate.more.columns(B, D, "YS", "YS1", "YS3", "YSD1", "YSD3")
  B <- generate.more.columns(B, D, "ST", "ST1", "ST3", "STD1", "STD3")
  B <- generate.more.columns(B, D, "ST.sd", "ST1.sd", "ST3.sd", "STD1.sd", "STD3.sd")
  B <- generate.more.columns(B, D, "ML", "ML1", "ML3", "MLD1", "MLD3")
  B <- generate.more.columns(B, D, "ML.sd", "ML1.sd", "ML3.sd", "MLD1.sd", "MLD3.sd")

  #cats <-data.frame(1)
  #cats$ID=c(21984)

  for (catindex in 1:nrow(cats))
  {
    #print(c("CATEGORY ", catindex))
    for (area in 1:10)
    {
      if (!(catindex==70 && area==4))
      {
        cat <- cats$ID[catindex]
        v <- process.one(area,cat)
        if (!is.null(v))
        {
          results <- rbind(results, v)
        }
      }
    }
  }
  
  return(results)
}

process.one <- function(area,cat)
{
  B <- process.one.B(area, cat)
  if (nrow(B)>10)
  {
    results <- data.frame("Area","Cat","Biz","Rev",
                          "YS", "YSt", "ST1", "ST1t", "MLD1", "MLD1t", "MLD3", "MLD3t", "ST1.sd", "ST1.sdt", "ML1.sd", "ML1.sdt")
                          
    v <- c(area,cat,nrow(B),sum(B$ReviewCount))
    v <- c(v, extract.regression.info(lm(data=B, formula=YS ~ Dist)))
    v <- c(v, extract.regression.info(lm(data=B, formula=ST1 ~ Dist)))
    v <- c(v, extract.regression.info(lm(data=B, formula=MLD1 ~ Dist)))
    v <- c(v, extract.regression.info(lm(data=B, formula=MLD3 ~ Dist)))
    v <- c(v, extract.regression.info(lm(data=B, formula=ST1.sd ~ Dist)))
    v <- c(v, extract.regression.info(lm(data=B, formula=ML1.sd ~ Dist)))
    v <- c(v, 99999)
    return (v)
  }
  return(NULL)
}

process.one.B <- function(area,cat)
{
  B <- load.data(area, cat)
  #print(c(789, cat,area,nrow(B)))

  D <- NA
  if (nrow(B) > 0)
  {
    D <- calculate.distances(B)
   
    B$YS1 <- B$YS3 <- B$YSD1 <- B$YSD3 <- NA
    B$ST1 <- B$ST3 <- B$STD1 <- B$STD3 <- B$ST1.sd <- B$ST3.sd <- B$STD1.sd <- B$STD3.sd <- NA
    B$ML1 <- B$ML3 <- B$MLD1 <- B$MLD3 <- B$ML1.sd <- B$ML3.sd <- B$MLD1.sd <- B$MLD3.sd <- NA
    
    B <- generate.more.columns(B, D, "YS", "YS1", "YS3", "YSD1", "YSD3")
    B <- generate.more.columns(B, D, "ST", "ST1", "ST3", "STD1", "STD3")
    B <- generate.more.columns(B, D, "ST.sd", "ST1.sd", "ST3.sd", "STD1.sd", "STD3.sd")
    B <- generate.more.columns(B, D, "ML", "ML1", "ML3", "MLD1", "MLD3")
    B <- generate.more.columns(B, D, "ML.sd", "ML1.sd", "ML3.sd", "MLD1.sd", "MLD3.sd")
  }  
  
  return(B)
}

extract.regression.info <- function(reg)
{
  summ <- summary(reg)
  if (nrow(summ$coefficients) > 1)
    t <- summ$coefficients[2, "t value"]
  else
    t <- 0

  return(c(reg$coef[2], t))
}

display <-function(B,x,y,run.reg,caption,index)
{
  colnames(B)[colnames(B)==x] <- "X"
  colnames(B)[colnames(B)==y] <- "Y"

  xlabel<-paste0("N = ", nrow(B))

  plot <- ggplot(B)
  plot <- plot + ggtitle(paste0(caption, "  (N=", nrow(B), ")"))
  #plot <- plot + ylim(0, 10) + xlim(0,2)
  plot <- plot + geom_point(aes(x=X,y=Y), colour="blue")
  plot <- plot + geom_abline(intercept=0, slope=0, colour="gray")
  
  if (run.reg)
  {
    reg <- lm(formula=B$Y ~ B$X)
    summ <- summary(reg)
    t <- summ$coefficients[2, "t value"]
    xlabel <- paste0(xlabel, "t-value: ", t)
    plot <- plot + geom_abline(intercept=reg$coefficients[1],slope=reg$coefficients[2],colour="red")
  }
  
  plot <- plot + labs(x=xlabel, y="Y")

  if (index == 0)
  {
    return(plot)
  }
  else
  {
    filename = paste0(dir, "/chart", index, ".png", sep="")
    ggsave(filename=filename, width=8, height=6, units="in", dpi=72, plot=plot)
  }
}


map <- function(data)
{
  coordinates<-as.numeric(geocode("pittsburgh"))
  myLocation <- c(lon= round(coordinates[1],2), lat=round(coordinates[2],2))
  myMap <- get_map(location=myLocation, source="stamen", maptype = "watercolor", crop = F, zoom = 13)

  map <- ggmap(myMap, extent = "panel", maprange=FALSE)
  map <- map + geom_density2d(data = data, aes(x = Longitude, y = Latitude))
  map <- map + stat_density2d(data = data, aes(x = Longitude, y = Latitude, fill = ..level.., alpha = ..level..), size = 0.01, bins = 16, geom = 'polygon')
  map <- map + scale_fill_gradient(low = "green", high = "red")
  map <- map + scale_alpha(range = c(0.00, 0.25), guide = FALSE)
  map <- map + theme(legend.position = "none", axis.title = element_blank(), text = element_text(size = 12))
  map <- map + geom_point(aes(x = Longitude, y = Latitude), data = data, alpha = .5, color="black", size = data$Density*3)
  map
}
#options(warn=10)

#results <- process()
#write.csv(results, "C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\web\\charts\\results8.csv")

# #Restaurants, Phoenix, Highly significant, upward sloping
# area.id <-7
# category.id<-21931
# B<-process.one.B(area.id,category.id)
# display(B,"Dist","ML1",TRUE,"Multinomial Logit Rating vs. Distance",1)
# #Pizza, Phoenix, Highly significant, upward sloping
# area.id <-6
# category.id<-21954
# B<-process.one.B(area.id,category.id)
# display(B,"Dist","ML1.sd",TRUE,"Multinomial Logit Rating vs. Distance",2)
# #Coffee and Tea, Montreal, Highly significant, upward sloping ML1.sd
# area.id <-4
# category.id<-21938
# B<-process.one.B(area.id,category.id)
# display(B,"Dist","ML1.sd",TRUE,"Multinomial Logit Rating vs. Distance",3)



area.id=4;category.id=21984
B<-process.one.B(area.id,category.id)



display(B,"Dist","YS1",FALSE,"Yelp Business Ratings vs. Distance",1)
display(B,"Dist","YSD1",FALSE,"Difference Between Ratings vs. Distance",2)
display(B,"Dist","MLD1",TRUE,"Multinomial Logit Rating vs. Distance",3)
display(B,"Dist","MLD3",TRUE,"Multinomial Logit Rating vs. Distance",4)
#display(B,"Dist","STD1",TRUE,"Multinomial Logit Rating vs. Distance")
#display(B,"Dist","STD3",TRUE,"Multinomial Logit Rating vs. Distance")
display(B,"Dist","ML1.sd",TRUE,"Multinomial Logit Rating vs. Distance",5)
#display(B,"Dist","ML3.sd",TRUE,"Multinomial Logit Rating vs. Distance")
#display(B,"Dist","ST1.sd",TRUE,"Multinomial Logit Rating vs. Distance")
#display(B,"Dist","ST3.sd",TRUE,"Multinomial Logit Rating vs. Distance")

