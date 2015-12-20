
######################################################################################
# calculate.densities.R
#
# This R script calculates and associates approximate population densitities for each business.
# Input: business.csv, zip-code-info.csv.
# Output: business2.csv.
######################################################################################

rm(list=ls(all=TRUE))

library(dplyr)

setwd("C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\data")

# Calculate the Euclidean distance between two x-y points.
dist <- function(x1,y1,x2,y2)
{
  return(sqrt((x1-x2)^2+(y1-y2)^2))
}

# Define a function to calculate the approximate population density at a given point.
# The pwr property is the power constant that we choose for inverse distance weighting.
# The wide property is only true when the function calls itself, something it only does if an inadequate
# number of reference points were found within a more narrow scan.
calculate.one.density <- function(lat, long, pwr, wide=FALSE)
{
  if (wide)
  {
    # Find candidate zip codes that are within 0.5 degrees (~55km) in each direction
    candidate.zips <- filter(Z, Latitude > (lat-0.5), Latitude < (lat+0.5), Longitude > (long-0.5), Longitude < (long+0.5))
  }
  else
  {
    # Find candidate zip codes that are within 0.1 degrees (~11km) in each direction
    candidate.zips <- filter(Z, Latitude > (lat-0.1), Latitude < (lat+0.1), Longitude > (long-0.1), Longitude < (long+0.1))
  }

  # Beyond half a degree, the distance is too far to be useful
  if (nrow(candidate.zips) == 0)
  {
    return(NA)
  }
  
  # Calculate the distances of all candidate zip codes
  candidate.zips$Distance = 0
  for (cz in 1:nrow(candidate.zips))
  {
    lat. <- candidate.zips[cz,]$Latitude
    long. <- candidate.zips[cz,]$Longitude
    candidate.zips[cz,]$Distance <- dist(lat, long, lat., long.)
  }
  
  # Get the closest zip code in each of the four quadrants: top-left, etc.
  z1 <- arrange(filter(candidate.zips, Latitude < lat, Longitude < long), Distance)[1,]
  z2 <- arrange(filter(candidate.zips, Latitude < lat, Longitude >= long), Distance)[1,]
  z3 <- arrange(filter(candidate.zips, Latitude >= lat, Longitude < long), Distance)[1,]
  z4 <- arrange(filter(candidate.zips, Latitude >= lat, Longitude >= long), Distance)[1,]

  # Calculate inverse weight based on distance.
  numer <- 0
  denom <- 0
  for (z in list(z1,z2,z3,z4))
  {
    if (!is.na(z$Distance) && !is.na(z$Density))
    {
      w. <- 1/(z$Distance^pwr)
      numer <- numer + (w. * z$Density)
      denom <- denom + w.
    }
    else if (!wide)
    {
      # We failed to get enough good matches with a narrow search so bail out
      # and instead use the result of a wide search.
      return (calculate.one.density(lat, long, pwr, TRUE))
    }
  }
  
  if (denom == 0)
  {
    return(NA)
  }
  
  return(numer/denom)
}

# Define a function to calculate all population densities for all businesses.
calculate.densities <- function(pwr=3, missing.value=-1)
{
  # any 'pwr' value greater than 2 emphasizes points that are closer over those that are further
  
  B$Density <- 0

  for (row in 1:nrow(B))
  {
    density <- calculate.one.density(B[row,]$Latitude, B[row,]$Longitude, pwr)
    
    if (is.na(density))
    {
      density <- missing.value
    }
    
    B[row,]$Density <- round(density)

    if(row %% 100 == 0)
    {
      print(B[row,])
    }
  }
  
  return(B)
}

# Load...

print("Loading zip code info...")
Z <- read.csv("zip-code-info.csv")

print("Loading businesses...")
B <- read.csv("business.csv")

# Calculate...

new.B <- calculate.densities()

# Write...

write.csv(new.B, "C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\data\\business2.csv", row.names=FALSE, eol="\n")
