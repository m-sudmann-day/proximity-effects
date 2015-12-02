#!/bin/bash

# installion script

cmd=$1

user=`grep dbuser service.conf | cut -f2 -d' '`
pswd=`grep dbpswd service.conf | cut -f2 -d' '`

target_dir='/var/www/html'
current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
db_dir="$current_dir/db"
data_dir="$current_dir/data"

case $cmd in

install)
	echo "Installing..."
	pwd
	sudo chmod 777 $db_dir
	sudo chmod 777 $db_dir/*
	sudo chmod 777 $data_dir
	sudo chmod 777 $data_dir/*
	sudo chmod 777 $target_dir
	sudo chmod 777 $target_dir/*

	### Installing the most recent version of R

	# http://cran.r-project.org/bin/linux/ubuntu/README.html
	# http://www.personal.psu.edu/mar36/blogs/the_ubuntu_r_blog/installing-r.html
	sudo add-apt-repository ppa:marutter/rrutter  --yes
	sudo apt-get update 
	sudo apt-get --yes --force-yes install r-base r-base-dev 

	# to set a custom directory where the packages will be installed
	# if you set it in a Dropbox or some other cloud synced folder and repeat the process below, all your computers will be synced in terms of packages R has
	mkdir /home/ubuntu/projects/Rlibs
	chmod 777 /home/ubuntu/projects/Rlibs
	echo R_LIBS=/home/ubuntu/projects/Rlibs > ~/.Renviron 
	echo R_LIBS_USER=/home/ubuntu/projects/Rlibs > ~/.Renviron 

	# to avoid being asked every time for a mirror when installing packages, you can set it up this way, of course you can use any CRAN mirror, not the UK one I used
	echo 'local({r <- getOption("repos"); r["CRAN"] <- "https://cran.rstudio.com"; options(repos=r)})' > ~/.Rprofile
	
	sudo Rscript --vanilla setup.R

	echo "  Creating database schema..."
	mysql -u $user -p$pswd < $db_dir/schema.sql
	echo "  Loading data..."
	mysql -u $user -p$pswd < $db_dir/load.sql
	echo "  Creating indexes..."
	mysql -u $user -p$pswd < $db_dir/indexes.sql
	echo "  Creating routines..."
	mysql -u $user -p$pswd < $db_dir/routines.sql

	mkdir -p "$target_dir/MyApp"
	cp -rf web/* "$target_dir/MyApp"

	echo "done!"
	;;

uninstall)
	echo "Uninstalling"

	mysql -u $user -p$pswd -e "DROP DATABASE ecommerce;" 
	rm -rf "target_dir/MyApp"

	echo "done!"
	;;

run)
	echo "Running"
	R CMD BATCH analysis/analysis.R 
	cat analysis.Rout
	rm analysis.Rout
	cp web/categories_network.png "$target_dir/MyApp"

	;;

*)
	echo "Unknown Command!"

esac
