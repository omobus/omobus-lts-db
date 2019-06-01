# Copyright (c) 2006 - 2019 omobus-lts-db authors, see the included COPYRIGHT file.

PACKAGE_NAME 	= omobus-lts-db
PACKAGE_VERSION = 3.4.21
COPYRIGHT 	= Copyright (c) 2006 - 2019 ak obs, ltd. <info@omobus.net>
SUPPORT 	= Support and bug reports: <support@omobus.net>
AUTHOR		= Author: Igor Artemov <i_artemov@ak-obs.ru>
BUGREPORT	= support@omobus.net

RM		= rm -f
PP		= unifdef
MKDIR 		= mkdir -p
XMLLINT 	= xmllint --noxincludenode --nofixup-base-uris
SED 		= sed -i -e

DISTR_NAME	= $(PACKAGE_NAME)-$(PACKAGE_VERSION)

.PHONY: all clean
all: pgsql mssql

clean:
	@$(MKDIR) .build/mssql/
	@$(RM) -v .build/mssql/*.sql .build/mssql/*.xconf
	@$(MKDIR) .build/pgsql/
	@$(RM) -v .build/pgsql/*.sql .build/pgsql/*.xconf

pgsql:
	@$(MKDIR) .build/pgsql/
	@$(PP) -D PGSQL -U MSSQL $(PACKAGE_NAME).sql > .build/pgsql/$(PACKAGE_NAME).sql; true
	@$(PP) -D PGSQL -U MSSQL version.sql >> .build/pgsql/$(PACKAGE_NAME).sql; true
	@echo "Compiled SQL script for the PostgreSQL."
	@$(XMLLINT) data.xconf > .build/pgsql/data.xconf
	@$(XMLLINT) health.xconf > .build/pgsql/health.xconf
	@echo "Compiled omobusd server configuration for the PostgreSQL."

mssql:
	@$(MKDIR) .build/
	@$(MKDIR) .build/mssql/
	@$(PP) -U PGSQL -D MSSQL $(PACKAGE_NAME).sql > .build/mssql/$(PACKAGE_NAME).sql; true
	@$(PP) -U PGSQL -D MSSQL version.sql >> .build/mssql/$(PACKAGE_NAME).sql; true
	@echo "Compiled SQL script for the Microsoft SQL Server."
	@$(XMLLINT) data.xconf > .build/mssql/data.xconf
	@$(XMLLINT) health.xconf > .build/mssql/health.xconf
	@$(SED) 's/string_to_array/dbo.string_to_array/g' .build/mssql/data.xconf
	@$(SED) 's/array_length/dbo.array_length/g' .build/mssql/data.xconf
	@$(SED) 's/bool_in/dbo.bool_in/g' .build/mssql/data.xconf
	@$(SED) 's/currency_in/dbo.currency_in/g' .build/mssql/data.xconf
	@$(SED) 's/datetime_in/dbo.datetime_in/g' .build/mssql/data.xconf
	@$(SED) 's/ean13_in/dbo.ean13_in/g' .build/mssql/data.xconf
	@$(SED) 's/ean13ar_in/dbo.ean13ar_in/g' .build/mssql/data.xconf
	@$(SED) 's/gps_in/dbo.gps_in/g' .build/mssql/data.xconf
	@$(SED) 's/int32_in/dbo.int32_in/g' .build/mssql/data.xconf
	@$(SED) 's/note_in/dbo.note_in/g' .build/mssql/data.xconf
	@$(SED) 's/uid_in/dbo.uid_in/g' .build/mssql/data.xconf
	@$(SED) 's/uids_in/dbo.uids_in/g' .build/mssql/data.xconf
	@$(SED) 's/wf_in/dbo.wf_in/g' .build/mssql/data.xconf
	@$(SED) 's/resolve_blob_stream/dbo.resolve_blob_stream/g' .build/mssql/data.xconf
	@$(SED) 's/^select stor_data_stream/--select stor_data_stream/g' .build/mssql/data.xconf
	@$(SED) 's/^--exec stor_data_stream/exec stor_data_stream/g' .build/mssql/data.xconf
	@$(SED) 's/^select stor_blob_stream/--select stor_blob_stream/g' .build/mssql/data.xconf
	@$(SED) 's/^--exec stor_blob_stream/exec stor_blob_stream/g' .build/mssql/data.xconf
	@echo "Compiled omobusd server configuration for the Microsoft SQL Server."
