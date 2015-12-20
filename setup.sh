#!/bin/bash

#######################################
# Proximity Effects installion script #
#######################################

cmd=$1

# Get the database user/password from a config file.
user=`grep dbuser service.conf | cut -f2 -d' '`
pswd=`grep dbpswd service.conf | cut -f2 -d' '`

# Set some variables relating to directories.
target_dir='/var/www/html'
current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
db_dir="$current_dir/db"
data_dir="$current_dir/data"

# Switch based on the command passed to this script.
case $cmd in

install)
	echo "Installing..."
	pwd
	sudo chmod 777 $db_dir
	sudo chmod 777 $db_dir/*
	sudo chmod 777 $data_dir
	sudo chmod 777 $data_dir/*
	sudo chmod 777 $target_dir

	echo 'Installing the most recent version of R...'
	ubuntu_r_blog/installing-r.html
	sudo add-apt-repository ppa:marutter/rrutter  --yes
	sudo apt-get update 
	sudo apt-get --yes --force-yes install r-base r-base-dev 
	echo 'local({r <- getOption("repos"); r["CRAN"] <- "https://cran.rstudio.com"; options(repos=r)})' > ~/.Rprofile

	echo 'Configuring the folder for installing R libraries...'
	mkdir /home/ubuntu/projects/Rlibs
	chmod 777 /home/ubuntu/projects/Rlibs
	echo R_LIBS=/home/ubuntu/projects/Rlibs > ~/.Renviron 
	echo R_LIBS_USER=/home/ubuntu/projects/Rlibs > ~/.Renviron 

	echo 'Running the R setup script...'
	sudo Rscript --vanilla setup.R

	echo "  Creating database schema..."
	mysql -u $user < $db_dir/schema.sql
	echo "  Loading data..."
	mysql -u $user < $db_dir/load.sql
	echo "  Creating indexes..."
	mysql -u $user < $db_dir/indexes.sql
	echo "  Creating routines..."
	mysql -u $user < $db_dir/routines.sql

	echo 'Copying the web files...'
	mkdir -p "$target_dir/MyApp"
	cp -rf web/* "$target_dir/MyApp"

	echo 'Creating the folder for chart creation...'
	sudo mkdir $target_dir/MyApp/charts
	sudo chmod 777 $target_dir/MyApp/charts

	echo "done!"
	;;

uninstall)
	echo "Uninstalling"

	mysql -u $user -e "DROP DATABASE proximity_effects;" 
	rm -rf "$target_dir/MyApp"

	echo "done!"
	;;

run)
	echo "The application is already running."
	;;
	
*)
	echo "Unknown Command!"

esac
