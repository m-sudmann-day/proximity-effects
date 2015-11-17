
library(dplyr)

dist <- function(x1,y1,x2,y2)
{
  return(sqrt((x1-x2)^2+(y1-y2)^2))
}

calculate.one.density <- function(lat, long, pwr, wide=FALSE)
{
  if (wide)
  {
    # find candidate zip codes that are within 0.5 degrees (~55km) in each direction
    candidate.zips <- filter(Z, Latitude > (lat-0.5), Latitude < (lat+0.5), Longitude > (long-0.5), Longitude < (long+0.5))
  }
  else
  {
    # find candidate zip codes that are within 0.1 degrees (~11km) in each direction
    candidate.zips <- filter(Z, Latitude > (lat-0.1), Latitude < (lat+0.1), Longitude > (long-0.1), Longitude < (long+0.1))
  }

  # beyond half a degree, the distance is too far to be useful
  if (nrow(candidate.zips) == 0)
  {
    return(NA)
  }
  
  # calculate the distances of all candidate zip codes
  candidate.zips$Distance = 0
  for (cz in 1:nrow(candidate.zips))
  {
    lat. <- candidate.zips[cz,]$Latitude
    long. <- candidate.zips[cz,]$Longitude
    candidate.zips[cz,]$Distance <- dist(lat, long, lat., long.)
  }
  
  # get the closest zip code in each of the four quadrants: top-left, etc.
  z1 <- arrange(filter(candidate.zips, Latitude < lat, Longitude < long), Distance)[1,]
  z2 <- arrange(filter(candidate.zips, Latitude < lat, Longitude >= long), Distance)[1,]
  z3 <- arrange(filter(candidate.zips, Latitude >= lat, Longitude < long), Distance)[1,]
  z4 <- arrange(filter(candidate.zips, Latitude >= lat, Longitude >= long), Distance)[1,]

  # calculate inverse weight based on distance
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
      # we failed to get enough good matches with a narrow search so bail out
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

print("Loading zip code info...")
Z<-read.csv("C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\data\\zip-code-info.csv")

print("Loading businesses...")
B<-read.csv("C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\data\\business-raw.csv")

new.B <- calculate.densities()

write.csv(new.B, "C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\data\\business.csv", row.names=FALSE)


