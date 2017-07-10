# This file is a part of the omobus-lts-db project.
# Copyright (c) 2006 - 2017 ak-obs, Ltd. <info@omobus.net>.
# All rights reserved.
#
# This program is a free software. Redistribution and use in source
# and binary forms, with or without modification, are permitted provided
# that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. The origin of this software must not be misrepresented; you must
#    not claim that you wrote the original software.
#
# 3. Altered source versions must be plainly marked as such, and must
#    not be misrepresented as being the original software.
#
# 4. The name of the author may not be used to endorse or promote
#    products derived from this software without specific prior written
#    permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
# OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

PACKAGE_NAME 	= omobus-lts-db
PACKAGE_VERSION = 3.3.20
COPYRIGHT 	= Copyright (c) 2006 - 2017 ak obs, ltd. <info@omobus.net>
SUPPORT 	= Support and bug reports: <support@omobus.net>
AUTHOR		= Author: Igor Artemov <i_artemov@ak-obs.ru>
BUGREPORT	= support@omobus.net

INSTALL		= install
RM		= rm -f
CP		= cp
TAR		= tar -cf
BZIP		= bzip2
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

distr:
	$(INSTALL) -d $(DISTR_NAME)
	$(INSTALL) -m 0644 *.xconf *.sql *.sh *.ldif *.default *.conf Makefile* ChangeLog AUTHO* COPY* README* ./$(DISTR_NAME)
	$(CP) -r connections/ ./$(DISTR_NAME)/connections
	$(CP) -r transactions/ ./$(DISTR_NAME)/transactions
	$(CP) -r kernels/ ./$(DISTR_NAME)/kernels
	$(CP) -r queries/ ./$(DISTR_NAME)/queries
	$(TAR) ./$(DISTR_NAME).tar ./$(DISTR_NAME)
	$(BZIP) ./$(DISTR_NAME).tar
	$(RM) -f -r ./$(DISTR_NAME)
