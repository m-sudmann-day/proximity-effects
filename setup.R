
# Install R packages used by the application at runtime.
# This can require more memory than the smallest AWS instance provides.

install.packages("ggplot2", repos="http://cran.r-project.org", lib="/home/ubuntu/projects/Rlibs/")
install.packages("ggmap", repos="http://cran.r-project.org", lib="/home/ubuntu/projects/Rlibs/")
install.packages("fossil", repos="http://cran.r-project.org", lib="/home/ubuntu/projects/Rlibs/")
install.packages("RMySQL", repos="http://cran.r-project.org", lib="/home/ubuntu/projects/Rlibs/")
install.packages("labeling", repos="http://cran.r-project.org", lib="/home/ubuntu/projects/Rlibs/")
