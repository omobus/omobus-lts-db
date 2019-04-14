# Copyright (c) 2006 - 2019 omobus-lts-db authors, see the included COPYRIGHT file.

PACKAGE_NAME 	= omobus-lts-db
PACKAGE_VERSION = 3.4.19
COPYRIGHT 	= Copyright (c) 2006 - 2019 ak obs, ltd. <info@omobus.net>
SUPPORT 	= Support and bug reports: <support@omobus.net>
AUTHOR		= Author: Igor Artemov <i_artemov@ak-obs.ru>
BUGREPORT	= support@omobus.net

RM		= rm -f
PP		= unifdef

DISTR_NAME	= $(PACKAGE_NAME)-$(PACKAGE_VERSION)

.PHONY: all clean
all: pgsql mssql

clean:
	@$(RM) -v $(PACKAGE_NAME).?????.sql version.?????.sql

pgsql:
	@$(PP) -D PGSQL -U MSSQL $(PACKAGE_NAME).sql > $(PACKAGE_NAME).pgsql.sql; true
	@$(PP) -D PGSQL -U MSSQL version.sql > version.pgsql.sql; true
	@echo "Compiled SQL script for the PostgreSQL."

mssql:
	@$(PP) -U PGSQL -D MSSQL $(PACKAGE_NAME).sql > $(PACKAGE_NAME).mssql.sql; true
	@$(PP) -U PGSQL -D MSSQL version.sql > version.mssql.sql; true
	@echo "Compiled SQL script for the Microsoft SQL Server."
