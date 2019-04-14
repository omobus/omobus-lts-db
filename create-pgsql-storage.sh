#!/bin/sh

# Copyright (c) 2006 - 2019 omobus-lts-db authors, see the included COPYRIGHT file.

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

psql -d $dbname -f ./$dbname.pgsql.sql
psql -d $dbname -f ./version.pgsql.sql

exit 0
# The end of the script.
