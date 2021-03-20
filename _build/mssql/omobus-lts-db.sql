/* Copyright (c) 2006 - 2021 omobus-lts-db authors, see the included COPYRIGHT file. */


set QUOTED_IDENTIFIER on
go
create login omobus with password = '0'
go
create user omobus for login omobus
go
create database "omobus-lts-db"
go
use "omobus-lts-db"
go
sp_changedbowner 'omobus'
go
alter database "omobus-lts-db" set ANSI_NULL_DEFAULT on
alter database "omobus-lts-db" set ANSI_NULLS on
alter database "omobus-lts-db" set ANSI_PADDING on
alter database "omobus-lts-db" set QUOTED_IDENTIFIER on 
alter database "omobus-lts-db" set concat_null_yields_null on
go
-- **** mssql 2005 and higher ****
alter database "omobus-lts-db" SET ALLOW_SNAPSHOT_ISOLATION on
go


-- **** domains ****

execute sp_addtype address_t, 'varchar(256)'
execute sp_addtype art_t, 'varchar(24)'
execute sp_addtype blob_t, 'varchar(32)'
execute sp_addtype bool_t, 'smallint'
execute sp_addtype code_t, 'varchar(24)'
execute sp_addtype codes_t, 'varchar(2048)'
execute sp_addtype country_t, 'varchar(2)'
execute sp_addtype countries_t, 'varchar(256)'
execute sp_addtype currency_t, 'numeric(18,4)'
execute sp_addtype date_t, 'varchar(10)'
execute sp_addtype datetime_t, 'varchar(19)'
execute sp_addtype datetimetz_t, 'varchar(32)'
execute sp_addtype descr_t, 'varchar(256)'
execute sp_addtype doctype_t, 'varchar(24)'
execute sp_addtype double_t, 'float'
execute sp_addtype discount_t, 'numeric(5,2)'
execute sp_addtype ean13_t, 'varchar(13)'
execute sp_addtype ean13s_t, 'varchar(280)'
execute sp_addtype email_t, 'varchar(254)'
execute sp_addtype emails_t, 'varchar(4096)'
execute sp_addtype ftype_t, 'smallint'
execute sp_addtype gps_t, 'numeric(10,6)'
execute sp_addtype hstore_t, 'varchar(1024)'
execute sp_addtype hostname_t, 'varchar(255)'
execute sp_addtype int32_t, 'int'
execute sp_addtype int64_t, 'bigint'
execute sp_addtype message_t, 'varchar(4096)'
execute sp_addtype month_t, 'varchar(7)'
execute sp_addtype note_t, 'varchar(1024)'
execute sp_addtype numeric_t, 'numeric(16,4)'
execute sp_addtype percent_t, 'smallint'
execute sp_addtype phone_t, 'varchar(32)'
execute sp_addtype state_t, 'varchar(8)'
execute sp_addtype time_t, 'char(5)'
execute sp_addtype ts_auto_t, 'datetime'
execute sp_addtype ts_t, 'datetime'
execute sp_addtype uid_t, 'varchar(48)'
execute sp_addtype uids_t, 'varchar(2048)'
execute sp_addtype volume_t, 'numeric(10,6)'
execute sp_addtype weight_t, 'numeric(12,6)'
execute sp_addtype wf_t, 'numeric(3,2)'
go
create default D_ts_auto_t as current_timestamp
go
execute sp_bindefault D_ts_auto_t, 'ts_auto_t'
go


-- **** core functions & procedures ****



-- **** general streams ****

create table accounts (
    db_id 		uid_t 		not null,
    account_id 		uid_t 		not null,
    pid 		uid_t 		null,
    code 		code_t 		null,
    ftype 		ftype_t 	not null,
    descr 		descr_t 	not null,
    address 		address_t 	not null,
    region_id 		uid_t		null,
    city_id 		uid_t		null,
    rc_id 		uid_t		null, 		/* -> retail_chains */
    chan_id 		uid_t 		null,
    poten_id 		uid_t 		null,
    cash_register 	int32_t 	null,
    latitude 		gps_t 		null,
    longitude 		gps_t 		null,
    attr_ids 		uids_t 		null,
    locked 		bool_t 		null default 0,
    approved 		bool_t 		null default 0,
    props 		hstore_t 	null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, account_id)
);


create table activity_types (
    db_id 		uid_t 		not null,
    activity_type_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    strict 		bool_t 		not null default 0, /* sets to 1 (true) for direct visits to the accounts */
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, activity_type_id)
);


create table addition_types (
    db_id 		uid_t 		not null,
    addition_type_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, addition_type_id)
);


create table agencies (
    db_id 		uid_t 		not null,
    agency_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, agency_id)
);


create table agreements1 (
    db_id 		uid_t 		not null,
    account_id		uid_t		not null,
    placement_id 	uid_t 		not null,
    posm_id 		uid_t 		not null,
    b_date 		date_t 		not null,
    e_date 		date_t 		not null,
    strict 		bool_t 		not null default 1,
    cookie 		uid_t 		null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, account_id, placement_id, posm_id, b_date)
);


create table agreements2 (
    db_id 		uid_t 		not null,
    account_id		uid_t		not null,
    prod_id 		uid_t 		not null,
    b_date 		date_t 		not null,
    e_date 		date_t 		not null,
    facing 		int32_t 	not null check(facing > 0),
    strict 		bool_t 		not null default 1,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, account_id, prod_id, b_date)
);


create table asp_types (
    db_id 		uid_t 		not null,
    asp_type_id 	uid_t		not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, asp_type_id)
);


create table attributes (
    db_id 		uid_t 		not null,
    attr_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, attr_id)
);


create table audit_criterias (
    db_id 		uid_t 		not null,
    audit_criteria_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, audit_criteria_id)
);


create table audit_scores (
    db_id 		uid_t 		not null,
    audit_score_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    score 		int32_t 	not null /*check(score >= 0)*/,
    row_no 		int32_t 	null, -- ordering,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, audit_score_id)
);


create table brands (
    db_id 		uid_t 		not null,
    brand_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    manuf_id 		uid_t 		not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, brand_id)
);


create table canceling_types (
    db_id 		uid_t 		not null,
    canceling_type_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, canceling_type_id)
);


create table categories (
    db_id 		uid_t 		not null,
    categ_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, categ_id)
);


create table channels (
    db_id 		uid_t 		not null,
    chan_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, chan_id)
);


create table cities (
    db_id 		uid_t 		not null,
    city_id 		uid_t 		not null,
    pid 		uid_t 		null,
    ftype 		ftype_t 	not null,
    descr 		descr_t 	not null,
    country_id 		uid_t 		not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, city_id)
);


create table comment_types (
    db_id 		uid_t 		not null,
    comment_type_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, comment_type_id)
);


create table confirmation_types (
    db_id 		uid_t 		not null,
    confirmation_type_id uid_t 		not null,
    descr 		descr_t 	not null,
    target_type_ids 	uids_t 		not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, confirmation_type_id)
);


create table contacts (
    db_id 		uid_t 		not null,
    contact_id 		uid_t 		not null,
    account_id 		uid_t 		not null,
    name 		descr_t 	not null,
    surname 		descr_t 	null,
    patronymic 		descr_t 	null,
    job_title_id 	uid_t 		not null,
    loyalty_level_id 	uid_t		null,
    phone 		phone_t 	null,
    mobile 		phone_t 	null,
    email 		email_t 	null,
    locked 		bool_t 		not null default 0,
    extra_info 		note_t 		null,
    consent 		uid_t 		null, /* consent to the processing of personal data */
    author_id 		uid_t 		not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, contact_id)
);

create index i_account_id_contacts on contacts(account_id);


create table countries (
    db_id 		uid_t 		not null,
    country_id 		country_t 	not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, country_id)
);


create table delivery_types (
    db_id 		uid_t 		not null,
    delivery_type_id	uid_t		not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, delivery_type_id)
);


create table departments (
    db_id 		uid_t 		not null,
    dep_id		uid_t		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, dep_id)
);


create table discard_types (
    db_id 		uid_t 		not null,
    discard_type_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, discard_type_id)
);


create table distributors (
    db_id 		uid_t 		not null,
    distr_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    country_id 		uid_t 		not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, distr_id)
);


create table equipment_types (
    db_id 		uid_t 		not null,
    equipment_type_id 	uid_t		not null,
    descr 		descr_t		not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, equipment_type_id)
);


create table equipments (
    db_id 		uid_t 		not null,
    equipment_id 	uid_t 		not null,
    account_id 		uid_t 		null,
    serial_number 	code_t 		not null,
    equipment_type_id 	uid_t 		not null,
    ownership_type_id 	uid_t 		null,
    extra_info 		note_t 		null,
    author_id 		uid_t 		not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, equipment_id)
);


create table job_titles (
    db_id 		uid_t 		not null,
    job_title_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, job_title_id)
);


create table kinds (
    db_id 		uid_t 		not null,
    kind_id 		uid_t		not null,
    descr 		descr_t		not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, kind_id)
);


create table loyalty_levels (
    db_id 		uid_t 		not null,
    loyalty_level_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, loyalty_level_id)
);


create table manufacturers (
    db_id 		uid_t 		not null,
    manuf_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    competitor		bool_t 		null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, manuf_id)
);


create table matrices (
    db_id 		uid_t 		not null,
    account_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    placement_ids 	uids_t 		null,
    row_no 		int32_t 	null, -- ordering
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, account_id, prod_id)
);


create table my_accounts (
    db_id 		uid_t 		not null,
    user_id 		uid_t 		not null,
    account_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, user_id, account_id)
);


create table my_cities (
    db_id 		uid_t 		not null,
    user_id 		uid_t 		not null,
    city_id 		uid_t 		not null,
    chan_id 		uid_t 		not null default '',
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, user_id, city_id, chan_id)
);


create table my_regions (
    db_id 		uid_t 		not null,
    user_id 		uid_t 		not null,
    region_id 		uid_t 		not null,
    chan_id 		uid_t 		not null default '',
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, user_id, region_id, chan_id)
);


create table my_retail_chains (
    db_id 		uid_t 		not null,
    user_id 		uid_t 		not null,
    rc_id 		uid_t 		not null,
    region_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, user_id, rc_id, region_id)
);


create table my_routes (
    db_id 		uid_t 		not null,
    user_id		uid_t		not null,
    account_id		uid_t		not null,
    activity_type_id	uid_t		not null,
    p_date		date_t		not null,
    row_no 		int32_t 	null,
    duration		int32_t 	null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, user_id, account_id, activity_type_id, p_date)
);

create index i_user_id_p_date_my_routes on my_routes(user_id, p_date);


create table oos_types (
    db_id 		uid_t 		not null,
    oos_type_id		uid_t		not null,
    descr		descr_t		not null,
    row_no 		int32_t 	null, -- ordering
    hidden		bool_t		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, oos_type_id)
);


create table order_params (
    db_id 		uid_t 		not null,
    distr_id 		uid_t 		not null,
    order_param_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, distr_id, order_param_id)
);


create table order_types (
    db_id 		uid_t 		not null,
    order_type_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, order_type_id)
);


create table ownership_types (
    db_id 		uid_t 		not null,
    ownership_type_id 	uid_t		not null,
    descr 		descr_t		not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, ownership_type_id)
);


create table packs (
    db_id 		uid_t 		not null,
    pack_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    pack 		numeric_t 	not null default 1.0 check (pack >= 0.01),
    weight 		weight_t 	null,
    volume 		volume_t 	null,
    "precision" 	int32_t 	null check ("precision" is null or ("precision" >= 0)),
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, pack_id, prod_id)
);


create table payment_methods (
    db_id 		uid_t 		not null,
    payment_method_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    encashment 		bool_t 		null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, payment_method_id)
);


create table pending_types (
    db_id 		uid_t 		not null,
    pending_type_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, pending_type_id)
);


create table photo_params (
    db_id 		uid_t 		not null,
    photo_param_id	uid_t		not null,
    descr		descr_t		not null,
    row_no 		int32_t 	null, -- ordering,
    hidden		bool_t		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, photo_param_id)
);


create table photo_types (
    db_id 		uid_t 		not null,
    photo_type_id	uid_t		not null,
    descr		descr_t		not null,
    row_no 		int32_t 	null, -- ordering,
    hidden		bool_t		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, photo_type_id)
);


create table placements (
    db_id 		uid_t 		not null,
    placement_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, placement_id)
);


create table pos_materials (
    db_id 		uid_t 		not null,
    posm_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    brand_ids 		uids_t 		not null,
    placement_ids 	uids_t 		null,
    chan_id 		uids_t 		null,
    country_id		country_t 	not null,
    dep_ids 		uids_t 		null,
    b_date 		date_t 		null,
    e_date 		date_t 		null,
    author_id 		uid_t 		not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, posm_id)
);


create table potentials (
    db_id 		uid_t 		not null,
    poten_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, poten_id)
);


create table priorities (
    db_id 		uid_t 		not null,
    brand_id 		uid_t 		not null,
    b_date 		date_t 		not null,
    e_date 		date_t 		not null,
    country_id 		uid_t 		not null,
    primary key (db_id, brand_id, b_date, country_id)
);


create table products (
    db_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    pid 		uid_t 		null,
    ftype 		ftype_t 	not null,
    kind_id 		uid_t 		null,
    brand_id 		uid_t 		null,
    categ_id 		uid_t 		null,
    shelf_life_id 	uid_t 		null,
    code 		code_t 		null,
    descr 		descr_t 	not null,
    art 		art_t 		null,
    obsolete 		bool_t 		null,
    novelty 		bool_t 		null,
    promo 		bool_t 		null,
    barcodes 		ean13s_t 	null,
    country_ids 	countries_t 	null,
    dep_ids 		uids_t 		null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, prod_id)
);


create table quest_names (
    db_id 		uid_t 		not null,
    qname_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, qname_id)
);


create table quest_rows (
    db_id 		uid_t 		not null,
    qname_id 		uid_t 		not null,
    qrow_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    country_ids 	countries_t 	null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, qname_id, qrow_id)
);


create table rating_criterias (
    db_id 		uid_t 		not null,
    rating_criteria_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, rating_criteria_id)
);


create table rating_scores (
    db_id 		uid_t 		not null,
    rating_score_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    score 		int32_t 	not null /*check(score >= 0)*/,
    row_no 		int32_t 	null, -- ordering,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, rating_score_id)
);


create table reclamation_types (
    db_id 		uid_t 		not null,
    reclamation_type_id uid_t 		not null,
    descr 		descr_t 	null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, reclamation_type_id)
);


create table regions (
    db_id 		uid_t 		not null,
    region_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    country_id 		country_t 	null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, region_id)
);


create table remark_types (
    db_id 		uid_t 		not null,
    remark_type_id 	uid_t		not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, remark_type_id)
);


create table retail_chains (
    db_id 		uid_t 		not null,
    rc_id		uid_t		not null,
    descr 		descr_t 	not null,
    ka_type		code_t		null,	/* Key Account: NKA, KA, ... */
    country_id 		uid_t 		not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, rc_id)
);


create table shelf_lifes (
    db_id 		uid_t 		not null,
    shelf_life_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    days 		int32_t 	null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, shelf_life_id)
);


create table targets (
    db_id 		uid_t 		not null,
    target_id 		uid_t 		not null,
    target_type_id 	uid_t 		not null,
    subject 		descr_t 	not null,
    body 		varchar(4096)	not null,
    b_date 		date_t 		not null,
    e_date 		date_t 		not null,
    image 		uid_t 		null,
    author_id 		uid_t 		null,
    myself 		bool_t 		not null default 0,
    hidden 		bool_t 		not null default 0,
    props 		hstore_t 	null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, target_id)
);


create table target_types (
    db_id 		uid_t 		not null,
    target_type_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, target_type_id)
);


create table training_materials (
    db_id 		uid_t 		not null,
    tm_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    brand_ids 		uids_t 		null,
    country_id 		country_t 	not null,
    dep_ids 		uids_t 		null,
    b_date 		date_t 		null,
    e_date 		date_t 		null,
    author_id 		uid_t 		not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, tm_id)
);


create table training_types (
    db_id 		uid_t 		not null,
    training_type_id	uid_t		not null,
    descr		descr_t		not null,
    row_no 		int32_t 	null, -- ordering,
    hidden		bool_t		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, training_type_id)
);


create table unsched_types (
    db_id 		uid_t 		not null,
    unsched_type_id	uid_t		not null,
    descr		descr_t		not null,
    row_no 		int32_t 	null, -- ordering
    hidden		bool_t		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, unsched_type_id)
);


create table users (
    db_id 		uid_t 		not null,
    user_id		uid_t		not null,
    pids		uids_t		null,
    descr		descr_t		not null,
    role 		code_t 		null, -- check (role in ('merch','sr','mr','sv','ise','cde','asm','rsm') and role = lower(role)),
    country_id 		country_t 	not null default 'RU',
    dep_ids		uids_t		null,
    distr_ids		uids_t		null,
    agency_id 		uid_t 		null,
    mobile 		phone_t 	null,
    email 		email_t 	null,
    area 		descr_t 	null,
    executivehead_id 	uid_t 		null,
    props 		hstore_t 	null,
    "rules:wd_begin" 	time_t 		null,
    "rules:wd_end" 	time_t 		null,
    hidden		bool_t		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, user_id)
);


create table warehouses (
    db_id 		uid_t 		not null,
    distr_id 		uid_t 		not null,
    wareh_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, distr_id, wareh_id)
);


go


-- **** proxy-db specific streams ****

create table additions (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    user_id		uid_t 		not null,
    fix_dt		datetime_t 	not null,
    account 		descr_t 	null,
    address 		address_t 	null,
    legal_address 	address_t 	null,
    number 		code_t 		null,
    addition_type_id 	uid_t 		null,
    note 		note_t 		null,
    chan_id 		uid_t 		null,
    photos 		uids_t 		null,
    attr_ids 		uids_t 		null,
    account_id 		uid_t 		not null,
    validator_id 	uid_t		null,
    validated 		bool_t 		not null default 0,
    hidden 		bool_t 		not null default 0,
    geo_address 	address_t 	null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key(db_id, doc_id)
);


create table cancellations (
    db_id 		uid_t 		not null,
    user_id		uid_t 		not null,
    route_date		date_t 		not null,
    canceling_type_id	uid_t 		null,
    note 		note_t 		null,
    hidden		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key (db_id, user_id, route_date)
);


create table comments (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    fix_dt 		datetime_t 	not null,
    user_id 		uid_t 		not null,
    account_id 		uid_t 		not null,
    comment_type_id 	uid_t 		not null,
    doc_note 		note_t 		null,
    photo		uid_t		null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key(db_id, doc_id)
);


create table confirmations (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    fix_dt 		datetime_t 	not null,
    user_id 		uid_t 		not null,
    account_id 		uid_t 		not null,
    target_id 		uid_t 		not null,
    confirmation_type_id uid_t 		not null,
    doc_note 		note_t 		null,
    photos		uids_t		null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key(db_id, doc_id)
);


create table deletions (
    db_id 		uid_t 		not null,
    account_id  	uid_t 		not null,
    user_id		uid_t 		not null,
    fix_dt		datetime_t 	not null,
    note		note_t		null,
    photo		uid_t		null,
    validator_id 	uid_t		null,
    validated 		bool_t 		not null default 0,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key(db_id, account_id)
);


create table discards (
    db_id 		uid_t 		not null,
    account_id  	uid_t 		not null,
    user_id		uid_t 		not null,
    fix_dt		datetime_t 	not null,
    activity_type_id 	uid_t 		not null,
    discard_type_id 	uid_t 		null,
    route_date 		date_t 		not null,
    note		note_t		null,
    validator_id 	uid_t		null,
    validated 		bool_t 		not null default 0,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key(db_id, account_id, user_id, activity_type_id, route_date)
);


create table dyn_advt (
    db_id 		uid_t 		not null,
    fix_date		date_t 		not null,
    account_id 		uid_t 		not null,
    placement_id 	uid_t 		not null,
    posm_id 		uid_t 		not null,
    qty 		int32_t 	not null check (qty >= 0),
    fix_dt		datetime_t 	not null,
    user_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, account_id, placement_id, posm_id)
);


create table dyn_audits (
    db_id 		uid_t 		not null,
    fix_date		date_t 		not null,
    account_id 		uid_t 		not null,
    categ_id 		uid_t 		not null,
    audit_criteria_id 	uid_t 		not null,
    audit_score_id 	uid_t 		null,
    criteria_wf 	wf_t 		not null check(criteria_wf between 0.01 and 1.00),
    score_wf 		wf_t 		null check(score_wf between 0.00 and 1.00),
    score 		int32_t 	null check (score >= 0),
    note 		note_t 		null,
    wf 			wf_t 		not null check(wf between 0.01 and 1.00),
    sla 		numeric(6,5) 	not null check(sla between 0.0 and 1.0),
    photos		uids_t		null,
    fix_dt 		datetime_t 	not null,
    user_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, account_id, categ_id, audit_criteria_id)
);


create table dyn_checkups (
    db_id 		uid_t 		not null,
    fix_date		date_t 		not null,
    account_id 		uid_t 		not null,
    placement_id 	uid_t 		not null,
    prod_id 		uid_t 		not null,
    exist 		int32_t 	not null,
    fix_dt		datetime_t 	not null,
    user_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, account_id, placement_id, prod_id)
);


create table dyn_oos (
    db_id 		uid_t 		not null,
    fix_date		date_t 		not null,
    account_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    oos_type_id 	uid_t 		not null,
    note 		note_t 		null,
    fix_dt		datetime_t 	not null,
    user_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, account_id, prod_id)
);


create table dyn_presences (
    db_id 		uid_t 		not null,
    fix_date		date_t 		not null,
    account_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    facing 		int32_t 	not null,
    stock 		int32_t 	not null,
    fix_dt		datetime_t 	not null,
    user_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, account_id, prod_id)
);


create table dyn_prices (
    db_id 		uid_t 		not null,
    fix_date		date_t 		not null,
    account_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    price 		currency_t 	not null,
    promo 		bool_t 		not null,
    rrp 		currency_t 	null,
    fix_dt		datetime_t 	not null,
    user_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, account_id, prod_id)
);


create table dyn_quests (
    db_id 		uid_t 		not null,
    fix_date		date_t 		not null,
    account_id 		uid_t 		not null,
    qname_id 		uid_t 		not null,
    qrow_id 		uid_t		not null,
    "value" 		varchar(64) 	not null,
    fix_dt 		datetime_t 	not null,
    user_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, account_id, qname_id, qrow_id)
);


create table dyn_ratings (
    db_id 		uid_t 		not null,
    fix_date		date_t 		not null,
    account_id 		uid_t 		not null,
    employee_id 	uid_t 		not null,
    rating_criteria_id 	uid_t 		not null,
    rating_score_id 	uid_t 		null,
    criteria_wf 	wf_t 		not null check(criteria_wf between 0.01 and 1.00),
    score_wf 		wf_t 		null check(score_wf between 0.00 and 1.00),
    score 		int32_t 	null check (score >= 0),
    note 		note_t 		null,
    fix_dt		datetime_t 	not null,
    user_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, account_id, employee_id, rating_criteria_id)
);


create table dyn_reviews (
    db_id 		uid_t 		not null,
    fix_date		date_t 		not null,
    employee_id 	uid_t 		not null,
    sla 		numeric(6,5)	not null check(sla between 0.0 and 1.0),
    assessment 		numeric(5,3)    not null check(assessment >= 0),
    note0 		note_t 		null,
    note1 		note_t 		null,
    note2 		note_t 		null,
    fix_dt		datetime_t 	not null,
    user_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, employee_id)
);


create table dyn_shelfs (
    db_id 		uid_t 		not null,
    fix_date		date_t 		not null,
    account_id 		uid_t 		not null,
    categ_id 		uid_t 		not null,
    brand_id 		uid_t 		not null,
    facing 		int32_t 	null check (facing >= 0),
    assortment 		int32_t 	null check (assortment >= 0),
    sos 		numeric(6,5) 	null check(sos between 0.0 and 1.0),
    soa 		numeric(6,5) 	null check(soa between 0.0 and 1.0),
    photos		uids_t		null,
    sos_target 		wf_t 		null check(sos_target between 0.01 and 1.00),
    soa_target 		wf_t 		null check(soa_target between 0.01 and 1.00),
    fix_dt 		datetime_t 	not null,
    user_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, account_id, categ_id, brand_id)
);


create table dyn_stocks (
    db_id 		uid_t 		not null,
    fix_date		date_t 		not null,
    account_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    stock 		int32_t 	not null,
    fix_dt 		datetime_t 	not null,
    user_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, account_id, prod_id)
);


create table holidays (
    db_id 		uid_t 		not null,
    h_date 		date_t 		not null,
    country_id 		country_t 	not null,
    note 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, h_date, country_id)
);


create table orders (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    fix_dt 		datetime_t 	not null,
    distr_id		uid_t 		not null,
    user_id 		uid_t 		not null,
    account_id 		uid_t 		not null,
    order_type_id 	uid_t 		null,
    group_price_id 	uid_t 		null,
    wareh_id 		uid_t 		null,
    delivery_date 	date_t 		not null,
    delivery_type_id 	uid_t 		null,
    delivery_note 	note_t 		null,
    doc_note 		note_t 		null,
    payment_method_id 	uid_t 		null,
    payment_delay 	int32_t 	null check (payment_delay is null or (payment_delay >= 0)),
    bonus 		currency_t 	null check (bonus is null or (bonus >= 0)),
    encashment 		currency_t 	null check (encashment is null or (encashment >= 0)),
    order_param_ids 	uids_t		null, /* attributes array; delimiter ',' */
    rows 		int32_t 	not null,
    prod_id 		uid_t 		not null,
    row_no 		int32_t 	not null check (row_no >= 0),
    pack_id 		uid_t 		not null,
    pack 		numeric_t 	not null,
    qty 		numeric_t 	not null,
    unit_price 		currency_t 	not null check (unit_price >= 0),
    discount 		discount_t 	not null,
    amount 		currency_t 	not null,
    weight 		weight_t 	not null,
    volume 		volume_t 	not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key (db_id, doc_id, prod_id)
);


create table photos (
    db_id 		uid_t 		not null,
    doc_id		uid_t		not null,
    fix_dt		datetime_t	not null,
    user_id		uid_t		not null,
    account_id		uid_t		not null,
    placement_id	uid_t		not null,
    brand_id		uid_t		null,
    asp_type_id 	uid_t		null,
    photo_type_id	uid_t		null,
    photo		uid_t		not null,
    doc_note		note_t		null,
    photo_param_ids	uids_t		null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    fix_year 		int32_t 	not null,
    fix_month 		int32_t 	not null,
    primary key(db_id, doc_id)
);

create index i_year_photos1 on photos(db_id, fix_year);
create index i_year_photos2 on photos(db_id, fix_year, account_id);


create table presentations (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    fix_dt 		datetime_t 	not null,
    user_id 		uid_t 		not null,
    account_id 		uid_t 		not null,
    participants 	int32_t 	not null,
    tm_ids 		uids_t 		null,
    doc_note 		note_t 		null,
    photos		uids_t		null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key(db_id, doc_id)
);


create table reclamations (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    fix_dt 		datetime_t 	not null,
    distr_id		uid_t 		not null,
    user_id 		uid_t 		not null,
    account_id 		uid_t 		not null,
    return_date 	date_t 		not null,
    doc_note 		note_t 		null,
    rows 		int32_t 	not null,
    prod_id 		uid_t 		not null,
    row_no 		int32_t 	not null check (row_no >= 0),
    reclamation_type_id uid_t 		null,
    pack_id 		uid_t 		not null,
    pack 		numeric_t 	not null,
    qty 		numeric_t 	not null,
    unit_price 		currency_t 	not null check (unit_price >= 0),
    amount 		currency_t 	not null,
    weight 		weight_t 	not null,
    volume 		volume_t 	not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key (db_id, doc_id, prod_id)
);


create table remarks (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    status 		varchar(8) 	not null,
    remark_type_id 	uid_t 		null,
    note 		note_t 		null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key(db_id, doc_id)
);


create table revocations (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    doc_type 		doctype_t 	not null,
    hidden		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key (db_id, doc_id)
);


create table trainings (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    user_id 		uid_t 		not null,
    account_id 		uid_t 		not null,
    fix_dt 		datetime_t 	not null,
    doc_note 		note_t 		null,
    training_type_id	uid_t		null,
    contact_ids 	uids_t 		not null,
    tm_ids 		uids_t 		not null,
    photos		uids_t		null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key(db_id, doc_id)
);


create table thumbnails (
    db_id 		uid_t 		not null,
    ref_id 		uid_t 		not null,
    photo 		blob_t 		not null,
    thumb 		blob_t 		null,
    thumb_width 	int32_t 	null check(thumb_width > 0),
    thumb_height 	int32_t 	null check(thumb_height > 0),
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key (db_id, ref_id)
);

create function photo_get(@arg0 /*db_id*/ uid_t, @arg1 /*ref_id*/ uid_t) returns varbinary(max)
as
begin
    declare @rv varbinary(max)
    select @rv = ptr from large_objects where blob_id = (select photo from thumbnails where db_id = @arg0 and ref_id = @arg1)
    return @rv
end

create function thumb_get(@arg0 /*db_id*/ uid_t, @arg1 /*ref_id*/ uid_t) returns varbinary(max)
as
begin
    declare @rv varbinary(max)
    select @rv = ptr from large_objects where blob_id = (select thumb from thumbnails where db_id = @arg0 and ref_id = @arg1)
    return @rv
end
go

create table unsched (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    fix_dt 		datetime_t 	not null,
    user_id 		uid_t 		not null,
    unsched_type_id 	uid_t 		null,
    doc_note 		note_t 		null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key(db_id, doc_id)
);


create table user_activities (
    db_id 		uid_t 		not null,
    user_id 		uid_t 		not null,
    account_id 		uid_t 		not null,
    w_cookie 		uid_t 		not null,
    a_cookie 		uid_t 		not null,
    activity_type_id 	uid_t 		not null,
    fix_date 		date_t 		not null,
    route_date 		date_t 		null,
    b_dt 		datetime_t 	not null,
    b_la 		gps_t 		null,
    b_lo 		gps_t 		null,
    b_sat_dt 		datetime_t 	null,
    e_dt 		datetime_t 	null,
    e_la 		gps_t 		null,
    e_lo 		gps_t 		null,
    e_sat_dt 		datetime_t 	null,
    employee_id 	uid_t 		null,
    extra_info 		note_t 		null,
    docs 		int32_t 	null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key (db_id, user_id, account_id, activity_type_id, w_cookie, a_cookie)
);

create index i_user_id_user_activities on user_activities (user_id);
create index i_fix_date_user_activities on user_activities (fix_date);
create index i_daily_user_activities on user_activities (user_id, fix_date);
create index i_route_date_user_activities on user_activities(route_date);


create table user_documents (
    db_id 		uid_t 		not null,
    act_id 		uid_t 		not null,
    user_id 		uid_t 		not null,
    w_cookie 		uid_t 		null,
    fix_date 		date_t 		not null,
    doc_type 		doctype_t 	not null,
    doc_id 		uid_t 		null,
    doc_no 		uid_t 		not null,
    duration 		int32_t 	not null,
    rows 		int32_t 	null,
    fix_dt 		datetime_t 	not null,
    latitude 		gps_t 		null,
    longitude 		gps_t 		null,
    satellite_dt 	datetime_t 	null,
    /* activity to the account: */
    a_cookie 		uid_t 		null,
    account_id 		uid_t 		null,
    activity_type_id 	uid_t 		null,
    employee_id 	uid_t 		null,
    /* */
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key(db_id, act_id)
);

create index i_user_id_user_documents on user_documents (user_id);
create index i_fix_date_user_documents on user_documents (fix_date);
create index i_daily_user_documents on user_documents (user_id, fix_date);


create table user_locations (
    db_id 		uid_t 		not null,
    act_id 		uid_t 		not null,
    row_no 		int32_t 	not null,
    user_id 		uid_t 		not null,
    fix_date 		date_t 		not null,
    latitude 		gps_t 		not null,
    longitude 		gps_t 		not null,
    satellite_dt 	datetime_t 	not null,
    fix_dt 		datetime_t 	not null,
    accuracy 		double_t 	not null,
    altitude 		double_t 	not null,
    bearing 		double_t 	not null,
    speed 		double_t 	not null,
    seconds 		int32_t 	null,
    provider 		varchar(8) 	null check (provider in ('gps','network') and provider = lower(provider)),
    satellites 		int32_t 	null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key(db_id, act_id, row_no)
);

create index i_user_id_user_locations on user_locations (user_id);
create index i_fix_date_user_locations on user_locations (fix_date);
create index i_daily_user_locations on user_locations (user_id, fix_date);


create table user_reports (
    db_id 		uid_t 		not null,
    act_id 		uid_t 		not null,
    user_id 		uid_t 		not null,
    w_cookie 		uid_t 		null,
    fix_date 		date_t 		not null,
    doc_type 		doctype_t 	not null,
    duration 		int32_t 	not null,
    fix_dt 		datetime_t 	not null,
    latitude 		gps_t 		null,
    longitude 		gps_t 		null,
    satellite_dt 	datetime_t 	null,
    /* activity to the account: */
    a_cookie 		uid_t 		null,
    account_id 		uid_t 		null,
    activity_type_id 	uid_t 		null,
    employee_id 	uid_t 		null,
    /* */
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key(db_id, act_id)
);

create index i_user_id_user_reports on user_reports (user_id);
create index i_fix_date_user_reports on user_reports (fix_date);
create index i_daily_user_reports on user_reports (user_id, fix_date);


create table user_works (
    db_id 		uid_t 		not null,
    user_id 		uid_t 		not null,
    w_cookie 		uid_t 		not null,
    fix_date 		date_t 		not null,
    b_dt 		datetime_t 	not null,
    b_la 		gps_t 		null,
    b_lo 		gps_t 		null,
    b_sat_dt 		datetime_t 	null,
    e_dt 		datetime_t 	null,
    e_la 		gps_t 		null,
    e_lo 		gps_t 		null,
    e_sat_dt 		datetime_t 	null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key (db_id, user_id, w_cookie)
);

create index i_user_id_user_works on user_works (user_id);
create index i_fix_date_user_works on user_works (fix_date);
create index i_daily_user_works on user_works (user_id, fix_date);


create table wishes (
    db_id 		uid_t 		not null,
    account_id  	uid_t 		not null,
    user_id		uid_t 		not null,
    fix_dt		datetime_t 	not null,
    weeks 		char(7) 	not null default '0,0,0,0',
    days 		char(13) 	not null default '0,0,0,0,0,0,0',
    note		note_t		null,
    validator_id 	uid_t		null,
    validated 		bool_t 		not null default 0,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key(db_id, account_id, user_id)
);


go


-- **** system stream ****

create table large_objects (
    blob_id blob_t not null primary key,
    ptr image not null 
);
go

create procedure createLO
    @blob_id blob_t
as
begin
    declare @c int
    select @c = count(*) from large_objects where blob_id=@blob_id
    if @c = 0
	begin
	    insert into large_objects values(@blob_id, 0x0)
	    select 'dbwritetext' method, 'large_objects.ptr' destination, ptr from large_objects where blob_id=@blob_id
	end
    else
	begin
	    select 'exist' method, null destination, null ptr
	end
end
go

create function string_to_array(@arg0 varchar(2048), @arg1 char(1)) returns varchar(2048)
as
begin
    return @arg0
end
go

create function array_length(@arg0 varchar(2048), @arg1 int) returns int
as
begin
    return case when @arg0 is null then null when ltrim(rtrim(@arg0)) <> '' then 1 else 0 end
end
go

create function uids_unnest(@string varchar(2048))
    returns @output table(ar_value varchar(48))
begin
    declare @start int, @end int, @delimiter char(1)
    set @delimiter = ','
    select @start = 1, @end = CHARINDEX(@delimiter, @string)
    while @start < LEN(@string) + 1 begin
	if @end = 0
	    set @end = LEN(@string) + 1

	insert into @output (ar_value)
	    values(SUBSTRING(@string, @start, @end - @start))
	set @start = @end + 1
	set @end = CHARINDEX(@delimiter, @string, @start)
    end
    return
end
go


create table data_stream ( /* data streams, that imported to the stogage */
    s_id 		varchar(256) 	not null primary key,
    digest 		varchar(32) 	not null,
    inserted_ts 	ts_auto_t 	not null,
    inserted_node	hostname_t 	not null,
    updated_ts 		ts_auto_t 	not null
);

create table blob_stream ( /* blob packages, that imported to the storage */
    s_id 		varchar(256) 	not null primary key,
    blob_id 		blob_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    inserted_node	hostname_t 	not null,
    updated_ts 		ts_auto_t 	not null
);


go

create procedure stor_data_stream
   @p_id varchar(256), @p_digest varchar(32), @hostname hostname_t
as
begin
    if (select count(*) from data_stream where s_id=@p_id) > 0
	begin
	    update data_stream set digest=@p_digest, inserted_node=@hostname
		where s_id=@p_id
	end
    else
	begin
	    insert into data_stream(s_id, digest, inserted_node)
		values(@p_id, @p_digest, @hostname)
	end
end
go

create procedure stor_blob_stream
   @p_id varchar(256), @b_id blob_t, @hostname hostname_t
as
begin
    if (select count(*) from blob_stream where s_id=@p_id) > 0 
	begin
	    update blob_stream set blob_id=@b_id, inserted_node=@hostname
		where s_id=@p_id
	end
    else
	begin
	    insert into blob_stream(s_id, blob_id, inserted_node)
		values(@p_id, @b_id, @hostname);
	end
end
go

create function resolve_blob_stream(@arg varchar(256)) returns blob_t
as
begin
   return case when @arg is null then null when @arg = '' then null else (select blob_id from blob_stream where s_id=@arg) end
end
go

create function bool_in(@arg0 varchar(1)) returns bool_t
as
begin
    return case when @arg0 = '' then null else @arg0 end
end
go

create function currency_in(@arg0 varchar(20)) returns currency_t
as
begin
    return case when @arg0 = '' then null else @arg0 end
end
go

create function date_in(@arg0 varchar(10)) returns date_t
as
begin
    return case when @arg0 = '' then null else @arg0 end
end
go

create function datetime_in(@arg0 varchar(19)) returns datetime_t
as
begin
    return case when @arg0 = '' then null else @arg0 end
end
go

create function descr_in(@arg0 varchar(1024)) returns descr_t
as
begin
    return case when @arg0 = '' then null else @arg0 end
end
go

create function ean13_in(@arg0 varchar(280)) returns varchar(280)
as
begin
    return @arg0
end
go

create function ean13ar_in(@arg0 varchar(2048)) returns codes_t
as
begin
    return case when @arg0 = '' then null else @arg0 end
end
go

create function gps_in(@arg0 varchar(12)) returns gps_t
as
begin
    return case when @arg0 = '' then null else @arg0 end
end
go

create function hstore_in(@arg0 varchar(1024)) returns hstore_t
as
begin
    return case when @arg0 = '' then null else @arg0 end
end
go

create function int32_in(@arg0 varchar(11)) returns int32_t
as
begin
    return case when @arg0 = '' then null else @arg0 end
end
go

create function note_in(@arg0 uid_t) returns note_t
as
begin
    return case when @arg0 = '' then null else @arg0 end
end
go

create function uid_in(@arg0 uid_t) returns uid_t
as
begin
    return case when @arg0 = '' then null else @arg0 end
end
go

create function uids_in(@arg0 varchar(2048)) returns uids_t
as
begin
    return case when @arg0 = '' then null else @arg0 end
end
go

create function uids_out(@arg0 uids_t) returns varchar(2048)
as
begin
    return @arg0
end
go

create function wf_in(@arg0 varchar(5)) returns wf_t
as
begin
    return case when @arg0 = '' then null else @arg0 end
end
go

create table sysparams (
    param_id 		uid_t 		not null primary key,
    param_value 	uid_t 		null,
    descr 		descr_t 	null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null
);


insert into sysparams(param_id, param_value, descr) values('db:created_ts', current_timestamp, 'Database creation datetime.');
insert into sysparams(param_id, param_value, descr) values('db:id', 'LTS', 'Database unique ID.');
insert into sysparams(param_id, param_value, descr) values('db:vstamp', '', 'Database version number.');

go
/* Copyright (c) 2006 - 2021 omobus-lts-db authors, see the included COPYRIGHT file. */

update sysparams set param_value='3.5.9' where param_id='db:vstamp';

go
