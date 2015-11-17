
setwd("C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\data")

# Load user and review data.
user <- read.csv("user.csv")
review <- read.csv("review.csv")

# Produce new data frames grouped by UserID, with functions mean and sd applied
# to all other columns, even though that only makes sense for stars.
m = aggregate(review, by=list(review$UserID), mean)
s = aggregate(review, by=list(review$UserID), sd)

# Sort both data frames by user ID.
m <- m[order(m$UserID),]
s <- s[order(s$UserID),]

# Since the data was well normalized, all user IDs referenced in the review
# data frame exist in the user data frame.  And all users have at least one
# review in the user table.  Therefore, we can assign the output of our
# aggregation of the review data directly into the user data (but only because
# we have sorted both by user ID first).
user$NewAverageStars <- m$Stars
user$StDevStars <- s$Stars

# Save the new user table.
write.csv(user, "user2.csv")
