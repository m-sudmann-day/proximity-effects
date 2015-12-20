
######################################################################################
# calculate.business.scores.R
#
# This R script standardizes business scores based on previously standardized review scores.
# Input: business2.csv, review2.csv
# Output: business3.csv
######################################################################################

rm(list=ls(all=TRUE))

setwd("C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\data")

# Load business and review data.
business <- read.csv("business2.csv")
review <- read.csv("review2.csv")

# Sort everything by business ID.
business <- business[order(business$ID),]
review <- review[order(review$BusinessID),]

# Produce new data frames grouped by BusinessID, with functions mean and sd
# applied to all other columns, even though that only makes sense for Stars1,2,3.
agg.mean <- aggregate(review, by=list(review$BusinessID), mean)
agg.sd <- aggregate(review, by=list(review$BusinessID), sd)

# Find the minimum non-missing standard deviations for each stars type.
agg.sd.min.1 <- min(filter(agg.sd, !is.na(Stars1), Stars1 > 1e-10)$Stars1)
agg.sd.min.2 <- min(filter(agg.sd, !is.na(Stars2), Stars2 > 1e-10)$Stars2)
agg.sd.min.3 <- min(filter(agg.sd, !is.na(Stars3), Stars3 > 1e-10)$Stars3)

# Replace the missing standard deviations with the minimum of the other values.
agg.sd[is.na(agg.sd$Stars1),]$Stars1 <- agg.sd.min.1
agg.sd[agg.sd$Stars1 < 1e-10,]$Stars1 <- agg.sd.min.1
agg.sd[is.na(agg.sd$Stars2),]$Stars2 <- agg.sd.min.2
agg.sd[agg.sd$Stars2 < 1e-10,]$Stars2 <- agg.sd.min.2
agg.sd[is.na(agg.sd$Stars3),]$Stars3 <- agg.sd.min.3
agg.sd[agg.sd$Stars3 < 1e-10,]$Stars3 <- agg.sd.min.3

# Put the BusinessID back where it belongs in the aggregated data.
agg.mean$BusinessID <- agg.mean$Group.1
agg.sd$BusinessID <- agg.sd$Group.1

# Make sure our aggregations are sorted by business ID.
agg.mean <- agg.mean[order(agg.mean$BusinessID),]
agg.sd <- agg.sd[order(agg.sd$BusinessID),]

# Join (merge) aggregated information about reviews into the business
# data frame.  First, the means:
merged <- merge(x=business, y=agg.mean, by.x="ID", by.y="BusinessID")
names(merged)[names(merged)=="Stars1"] <- "Stars1Mean"
names(merged)[names(merged)=="Stars2"] <- "Stars2Mean"
names(merged)[names(merged)=="Stars3"] <- "Stars3Mean"

# Second, the standard deviations:
merged <- merge(x=merged, y=agg.sd, by.x="ID", by.y="BusinessID")
names(merged)[names(merged)=="Stars1"] <- "Stars1StDev"
names(merged)[names(merged)=="Stars2"] <- "Stars2StDev"
names(merged)[names(merged)=="Stars3"] <- "Stars3StDev"

# Delete unneeded columns.
merged$Group.1.x <- NULL
merged$Stars.x <- NULL
merged$Group.1.y <- NULL
merged$Stars.y <- NULL

# Save the augmented business information back to the file system.
write.csv(merged, "business3.csv", row.names=FALSE)
