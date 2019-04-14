#!/bin/sh

# Copyright (c) 2006 - 2019 omobus-lts-db authors, see the included COPYRIGHT file.

dbname=omobus-lts-db
srv=srv1
uname=omobus
passwd=omobus

fisql -I freetds.conf -S $srv -U $uname -P $passwd -D $dbname -i omobus-lts-db.mssql.sql
fisql -I freetds.conf -S $srv -U $uname -P $passwd -D $dbname -i version.mssql.sql

#sed -i -e 's/string_to_array/dbo.string_to_array/g' queries/data/*.xconf
#sed -i -e 's/array_length/dbo.array_length/g' queries/data/*.xconf
#sed -i -e 's/ean13_in/dbo.ean13_in/g' queries/data/*.xconf
#sed -i -e 's/resolve_blob_stream/dbo.resolve_blob_stream/g' queries/data/*.xconf
#sed -i -e 's/^select stor_data_stream/--select stor_data_stream/g' queries/data/*.xconf
#sed -i -e 's/^--exec stor_data_stream/exec stor_data_stream/g' queries/data/*.xconf
#sed -i -e 's/^select stor_blob_stream/--select stor_blob_stream/g' queries/data/*.xconf
#sed -i -e 's/^--exec stor_blob_stream/exec stor_blob_stream/g' queries/data/*.xconf

exit 0
# The end of the script.
