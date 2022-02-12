#!/bin/sh

if [[ "$(curl -s -o /dev/null -I -w '%{http_code}' http://localhost:8080)" != '200' ]]
then 
	echo 1
else 
	echo 0
fi
