#!/bin/bash

# installion script

cmd=$1

user=`grep dbuser service.conf | cut -f2 -d' '`
pswd=`grep dbpswd service.conf | cut -f2 -d' '`

target_dir='/var/www/html'
#target_dir=$HOME/public_html



case $cmd in

install)
	echo "Installing..."
	pwd
	echo "  Creating database schema"
	mysql -u $user -p$pswd < db/schema.sql
	echo "  Loading data..."
	mysql -u $user -p$pswd < db/load_data.sql
	echo "  Cleaning data..."
	mysql -u $user -p$pswd < db/cleanup_data.sql
	echo "  Creating routines..."
	mysql -u $user -p$pswd < db/routines.sql

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
