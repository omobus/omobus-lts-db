# Copyright (c) 2006 - 2022 omobus-lts-db authors, see the included COPYRIGHT file.

PACKAGE_NAME 	= omobus-lts-db
PACKAGE_VERSION = 3.5.26
COPYRIGHT 	= Copyright (c) 2006 - 2022 ak obs, ltd. <info@omobus.net>
SUPPORT 	= Support and bug reports: <support@omobus.net>
AUTHOR		= Author: Igor Artemov <i_artemov@ak-obs.ru>
BUGREPORT	= support@omobus.net

RM		= rm -f
PP		= unifdef
MKDIR 		= mkdir -p
SED 		= sed -i -e
CP 		= cp
MV 		= mv

DISTR_NAME	= $(PACKAGE_NAME)-$(PACKAGE_VERSION)

.PHONY: all clean
all: pgsql mssql

clean:
	@$(MKDIR) _build/mssql/
	@$(RM) -v _build/mssql/*.sql _build/mssql/*.xconf
	@$(MKDIR) _build/pgsql/
	@$(RM) -v _build/pgsql/*.sql _build/pgsql/*.xconf

pgsql:
	@$(MKDIR) _build/pgsql/
	@$(PP) -D PGSQL -U MSSQL $(PACKAGE_NAME).sql > _build/pgsql/$(PACKAGE_NAME).sql; true
	@$(PP) -D PGSQL -U MSSQL version.sql >> _build/pgsql/$(PACKAGE_NAME).sql; true
	@echo "Compiled SQL script for the PostgreSQL."
	@$(CP) *.xconf _build/pgsql/
	@$(CP) -r connections/ _build/pgsql/
	@$(CP) -r kernels/ _build/pgsql/
	@$(CP) -r queries/ _build/pgsql/
	@$(CP) -r transactions/ _build/pgsql/
	@for i in _build/pgsql/queries/lts-data/*.xconf; do $(PP) -D PGSQL -U MSSQL $$i > $$i.1; $(MV) $$i.1 $$i; done
	@echo "Compiled omobusd server configuration for the PostgreSQL."

mssql:
	@$(MKDIR) _build/
	@$(MKDIR) _build/mssql/
	@$(PP) -U PGSQL -D MSSQL $(PACKAGE_NAME).sql > _build/mssql/$(PACKAGE_NAME).sql; true
	@$(PP) -U PGSQL -D MSSQL version.sql >> _build/mssql/$(PACKAGE_NAME).sql; true
	@echo "Compiled SQL script for the Microsoft SQL Server."
	@$(CP) lts-data.xconf _build/mssql/
	@$(CP) lts-health.xconf _build/mssql/
	@$(CP) -r connections/ _build/mssql/
	@$(MKDIR) _build/mssql/kernels/
	@$(CP) -r kernels/lts-data.xconf _build/mssql/kernels/
	@$(CP) -r kernels/lts-health.xconf _build/mssql/kernels/
	@$(CP) -r queries/ _build/mssql/
	@$(CP) -r transactions/ _build/mssql/
	@$(SED) 's/string_to_array/dbo.string_to_array/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/array_length/dbo.array_length/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/bool_in/dbo.bool_in/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/currency_in/dbo.currency_in/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/date_in/dbo.date_in/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/datetime_in/dbo.datetime_in/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/descr_in/dbo.descr_in/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/double_in/dbo.double_in/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/ean13_in/dbo.ean13_in/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/ean13ar_in/dbo.ean13ar_in/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/hstore_in/dbo.hstore_in/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/gps_in/dbo.gps_in/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/int32_in/dbo.int32_in/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/note_in/dbo.note_in/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/phone_in/dbo.phone_in/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/time_in/dbo.time_in/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/uid_in/dbo.uid_in/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/uids_in/dbo.uids_in/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/wf_in/dbo.wf_in/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/resolve_blob_stream/dbo.resolve_blob_stream/g' _build/mssql/queries/lts-data/*.xconf
	@$(SED) 's/exist_data_stream/dbo.exist_data_stream/g' _build/mssql/queries/lts-data/*.xconf
	@for i in _build/mssql/queries/lts-data/*.xconf; do $(PP) -U PGSQL -D MSSQL $$i > $$i.1; $(MV) $$i.1 $$i; done
	@echo "Compiled omobusd server configuration for the Microsoft SQL Server."
