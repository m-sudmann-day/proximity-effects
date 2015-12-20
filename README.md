# PROXIMITY EFFECTS ON CONSUMER SENTIMENT
### Group 1, Barcelona GSE Master in Data Science

Nick Halliwell, Denitsa Panova, Matthew Sudmann-Day

### Overview

This github repository contains the source code for a dashboard which allows researchers to explore proximity effects among competitive businesses.  It is based on data obtained from Yelp.com as part of the Yelp Dataset Challenge, then scrubbed, filtered, normalized, and analyzed for display on this dashboard.

### Structure

The dashboard consists of a PHP website and a MySql database and runs realtime analysis in R.  A setup script allows the dashboard to be installed on Ubuntu.

### R

The runtime analysis requires at least version 3.7 of R to be installed.  The installation script assumes some previous version has already been installed, and then upgrades to the latest if needed.

The R analysis relies on the following packages which are installed automatically by the installation script:

- ggplot2
- RMySql
- fossil
- labeling
- DBI
- sp
- maps
- shapefiles

(dplyr was used in the pre-runtime analysis, but is not required at runtime.)

### Acknowledgements

The installation script and general outline for this project came from the github repository 'ctbrownlees/bgse-dashboard-project' with original contributions from Guglielmo Bartolozzi, Gaston Besanson, Christian Brownlees, Stefano Costantini, Laura Cozma, and Jordi Zamora Munt.
