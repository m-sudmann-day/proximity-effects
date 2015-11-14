#!/bin/bash

# installion script

cmd=$1

user=`grep dbuser service.conf | cut -f2 -d' '`
pswd=`grep dbpswd service.conf | cut -f2 -d' '`

target_dir='/var/www/html'
current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
db_dir="$current_dir/db"

echo $current_dir
echo $db_dir

case $cmd in

install)
	echo "Installing..."
	pwd
        sudo chmod 777 $target_dir
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
