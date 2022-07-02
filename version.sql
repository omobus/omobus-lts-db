/* Copyright (c) 2006 - 2022 omobus-lts-db authors, see the included COPYRIGHT file. */

update sysparams set param_value='3.5.22' where param_id='db:vstamp';

#ifdef MSSQL
go
#endif //MSSQL
