
######################################################################################
# calculate.user.stats.and.reviews.R
#
# This R script standardizes review scores.
# Input: user.csv, review.csv
# Output: review2.csv
######################################################################################

rm(list=ls(all=TRUE))

setwd("C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\data")

library(dplyr)

# Load user and review data.
user <- read.csv("user.csv")
review <- read.csv("review.csv")

# Produce new data frames grouped by UserID, with functions mean and sd applied
# to all other columns, even though that only makes sense for stars.
agg.mean <- aggregate(review, by=list(review$UserID), mean)
agg.median <- aggregate(review, by=list(review$UserID), median)
agg.sd <- aggregate(review, by=list(review$UserID), sd)
agg.mad <- aggregate(review, by=list(review$UserID), mad)

just.stars <- data.frame(UserID=review$UserID, Stars=review$Stars)
just.stars <- just.stars[order(just.stars$UserID, just.stars$Stars),]
agg.star.strings <- aggregate(just.stars, by=list(just.stars$UserID), paste0, collapse="")

# Restore the user ID after aggregation messed it up.
agg.mean$UserID <- agg.mean$Group.1
agg.median$UserID <- agg.mean$Group.1
agg.sd$UserID <- agg.mean$Group.1
agg.mad$UserID <- agg.mean$Group.1
agg.star.strings$UserID <- agg.mean$Group.1

# Sort user-oriented data frames by user ID.
user <- user[order(user$ID),]
agg.mean <- agg.mean[order(agg.mean$UserID),]
agg.median <- agg.median[order(agg.median$UserID),]
agg.sd <- agg.sd[order(agg.sd$UserID),]
agg.mad <- agg.mad[order(agg.mad$UserID),]
agg.star.strings <- agg.star.strings[order(agg.star.strings$UserID),]

write.csv(review, "agg.mean.csv", row.names=FALSE)
write.csv(review, "agg.median.csv", row.names=FALSE)
write.csv(review, "agg.sd.csv", row.names=FALSE)
write.csv(review, "agg.mad.csv", row.names=FALSE)
write.csv(review, "agg.star.strings.csv", row.names=FALSE)

# Recognize that deviations of zero are unusable.
# But we need to make use of this data so if we have very few
# ratings, let's calculate the minimum non-zero deviations.
agg.sd.min <- min(filter(agg.sd, !is.na(Stars), Stars > 1e-10)$Stars)
agg.mad.min <- min(filter(agg.mad, !is.na(Stars), Stars > 1e-10)$Stars)

# Then apply those minimums to the gaps.  We do not see any NA results from
# the mad function so we do not attempt to replace those.  Doing so errors.
agg.sd[is.na(agg.sd$Stars),]$Stars <- agg.sd.min
agg.sd[agg.sd$Stars < 1e-10,]$Stars <- agg.sd.min
agg.mad[agg.mad$Stars < 1e-10,]$Stars <- agg.mad.min

# Since the data was well normalized, all user IDs referenced in the review
# data frame exist in the user data frame.  And all users have at least one
# review in the user data frame  Therefore, we can assign the output of our
# aggregation of the review data directly into the user data (but only because
# we have sorted both by user ID first).
user$NewAverageStars <- agg.mean$Stars
user$MedianStars <- agg.median$Stars
user$StDevStars <- agg.sd$Stars
user$MadStars <- agg.mad$Stars
user$StarStrings <- agg.star.strings$Stars

# Join (merge) user information into a copy of the review data frame.
merged <- merge(x=user, y=review, by.x="ID", by.y="UserID")

# Sort review-oriented data frames by review ID so that we know that
# the same row in each data frame corresponds to the same review.
review <- review[order(review$UserID, review$BusinessID),]
merged <- merged[order(review$UserID, review$BusinessID),]

# Calculate new ratings for these reviews.
review$Stars1 <- ifelse(merged$StDevStars == 0, 0, (merged$Stars - merged$NewAverageStars) / merged$StDevStars)
review$Stars2 <- ifelse(merged$MadStars == 0, 0, (merged$Stars - merged$MedianStars) / merged$MadStars)
review$StarStrings <- merged$StarStrings

# Eliminate columns we no longer need.
review$UserID <- NULL
review$Date <- NULL

# Eliminate useless rows.
review <- filter(review, !is.na(Stars1), !is.na(Stars2))

# Save the new review table.
write.csv(review, "review2.csv", row.names=FALSE)
