#!/bin/sh
# Copyright (c) 2006 - 2019 omobus-lts-db authors, see the included COPYRIGHT file.

# mssql: isql -I freetds.conf -S $srv -U $uname -P $passwd -D $dbname -i omobus-lts-db.mssql.sql


dbname=omobus-lts-db

if [ `whoami` != "omobus" ]; then
    echo Please, execute tis stript from omobus system account.
    echo 
    exit 1
fi

if [ `psql -l | grep -c $dbname` != "0" ]; then
    echo $dbname already exist!
    echo Please, remove $dbname before executing this script.
    echo 
    exit 1
fi

psql -d postgres -c \
    "CREATE DATABASE \"$dbname\" WITH OWNER = omobus ENCODING = 'UTF8' TABLESPACE = pg_default CONNECTION LIMIT = 30"

psql -d $dbname -c \
    "CREATE LANGUAGE plpgsql"

psql -d $dbname -f /etc/omobus.d/.build/pgsql/$dbname.sql

exit 0
# The end of the script.
