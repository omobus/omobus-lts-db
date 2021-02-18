/* Copyright (c) 2006 - 2021 omobus-lts-db authors, see the included COPYRIGHT file. */

update sysparams set param_value='3.5.7' where param_id='db:vstamp';

#ifdef MSSQL
go
#endif //MSSQL
