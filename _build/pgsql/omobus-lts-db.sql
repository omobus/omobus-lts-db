/* Copyright (c) 2006 - 2022 omobus-lts-db authors, see the included COPYRIGHT file. */

create extension hstore;
create extension isn;



-- **** domains ****

create domain address_t as varchar(256);
create domain blob_t as OID;
create domain bool_t as int2 check (value is null or (value between 0 and 1));
create domain code_t as varchar(24);
create domain codes_t as varchar(24) array;
create domain country_t as varchar(2) check (value is null or (value = upper(value))); -- Country code, as described in the ISO 3166-1 alpha-2.
create domain countries_t as varchar(2) array; -- Country code, as described in the ISO 3166-1 alpha-2.
create domain currency_t as numeric(18,4);
create domain date_t as varchar(10);
create domain datetime_t as varchar(19);
create domain datetimetz_t as varchar(32);
create domain descr_t as varchar(256);
create domain doctype_t as varchar(24) check (value is null or (value = lower(value)));
create domain double_t as float8;
create domain discount_t as numeric(5,2) check (value is null or (value between -100 and 100));
create domain ean13_t as ean13;
create domain ean13s_t as ean13 array;
create domain email_t as varchar(254) /*check(value is null or (char_length(value)>=4 and position('@' in value)>1))*/;
create domain ftype_t as int2 default 0 not null check (value between 0 and 1);
create domain gps_t as numeric(10,6);
create domain hstore_t as hstore;
create domain hostname_t as varchar(255);
create domain int32_t as int4;
create domain int64_t as int8;
create domain message_t as varchar(4096);
create domain month_t as varchar(7);
create domain note_t as varchar(1024);
create domain numeric_t as numeric(16,4);
create domain percent_t as int2 check (value is null or (value between 0 and 100));
create domain phone_t as varchar(32);
create domain state_t as varchar(8) check (value is null or (value in ('begin','end') and value = lower(value)));
create domain time_t as char(5);
create domain ts_auto_t as timestamp with time zone default current_timestamp not null;
create domain ts_t as timestamp with time zone;
create domain uid_t as varchar(48);
create domain uids_t as varchar(48) array;
create domain volume_t as numeric(10,6);
create domain weight_t as numeric(12,6);
create domain wf_t as numeric(3,2);


-- **** core functions & procedures ****

create or replace function tf_updated_ts() returns trigger as
$body$
begin
    new.updated_ts = current_timestamp;
    return new;
end;
$body$
language 'plpgsql';


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
    latitude 		gps_t 		null,
    longitude 		gps_t 		null,
    phone 		phone_t 	null,
    workplaces 		int32_t 	null check(workplaces > 0),
    team 		int32_t 	null check(team > 0),
    interaction_type_id uid_t 		null,
    attr_ids 		uids_t 		null,
    locked 		bool_t 		null default 0,
    approved 		bool_t 		null default 0,
    props 		hstore_t 	null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, account_id)
);

create trigger trig_updated_ts before update on accounts for each row execute procedure tf_updated_ts();

create table activity_types (
    db_id 		uid_t 		not null,
    activity_type_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    strict 		bool_t 		not null default 0, /* sets to 1 (true) for direct visits to the accounts */
    joint 		bool_t 		not null default 0, /* sets to 1 (true) for joint visits to the accounts */
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, activity_type_id)
);

create trigger trig_updated_ts before update on activity_types for each row execute procedure tf_updated_ts();

create table addition_types (
    db_id 		uid_t 		not null,
    addition_type_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, addition_type_id)
);

create trigger trig_updated_ts before update on addition_types for each row execute procedure tf_updated_ts();

create table agencies (
    db_id 		uid_t 		not null,
    agency_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, agency_id)
);

create trigger trig_updated_ts before update on agencies for each row execute procedure tf_updated_ts();

create table agreements1 (
    db_id 		uid_t 		not null,
    slice_date 		date_t 		not null,
    account_id		uid_t		not null,
    placement_id 	uid_t 		not null,
    posm_id 		uid_t 		not null,
    strict 		bool_t 		not null default 1,
    cookie 		uid_t 		null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, slice_date, account_id, placement_id, posm_id)
);

create trigger trig_updated_ts before update on agreements1 for each row execute procedure tf_updated_ts();

create table agreements2 (
    db_id 		uid_t 		not null,
    slice_date 		date_t 		not null,
    account_id		uid_t		not null,
    prod_id 		uid_t 		not null,
    facing 		int32_t 	null check(facing > 0),
    strict 		bool_t 		not null default 1,
    cookie 		uid_t 		null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, slice_date, account_id, prod_id)
);

create trigger trig_updated_ts before update on agreements2 for each row execute procedure tf_updated_ts();

create table agreements3 (
    db_id 		uid_t 		not null,
    slice_date 		date_t 		not null,
    account_id		uid_t		not null,
    prod_id 		uid_t 		not null,
    stock 		int32_t 	not null check(stock > 0),
    strict 		bool_t 		not null default 1,
    cookie 		uid_t 		null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, slice_date, account_id, prod_id)
);

create trigger trig_updated_ts before update on agreements3 for each row execute procedure tf_updated_ts();

create table asp_types (
    db_id 		uid_t 		not null,
    asp_type_id 	uid_t		not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering
    props 		hstore_t 	null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, asp_type_id)
);

create trigger trig_updated_ts before update on asp_types for each row execute procedure tf_updated_ts();

create table attributes (
    db_id 		uid_t 		not null,
    attr_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, attr_id)
);

create trigger trig_updated_ts before update on attributes for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on audit_criterias for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on audit_scores for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on brands for each row execute procedure tf_updated_ts();

create table canceling_types (
    db_id 		uid_t 		not null,
    canceling_type_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, canceling_type_id)
);

create trigger trig_updated_ts before update on canceling_types for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on categories for each row execute procedure tf_updated_ts();

create table channels (
    db_id 		uid_t 		not null,
    chan_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, chan_id)
);

create trigger trig_updated_ts before update on channels for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on cities for each row execute procedure tf_updated_ts();

create table cohorts (
    db_id 		uid_t 		not null,
    cohort_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, cohort_id)
);

create trigger trig_updated_ts before update on cohorts for each row execute procedure tf_updated_ts();

create table comment_types (
    db_id 		uid_t 		not null,
    comment_type_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, comment_type_id)
);

create trigger trig_updated_ts before update on comment_types for each row execute procedure tf_updated_ts();

create table confirmation_types (
    db_id 		uid_t 		not null,
    confirmation_type_id uid_t		not null,
    descr 		descr_t 	not null,
    succeeded 		varchar(6) 	null check(succeeded in ('yes','no','partly')),
    row_no 		int32_t 	null, -- ordering
    props 		hstore_t 	null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, confirmation_type_id)
);

create trigger trig_updated_ts before update on confirmation_types for each row execute procedure tf_updated_ts();

create table contacts (
    db_id 		uid_t 		not null,
    contact_id 		uid_t 		not null,
    account_id 		uid_t 		not null,
    name 		descr_t 	not null,
    surname 		descr_t 	null,
    patronymic 		descr_t 	null,
    job_title_id 	uid_t 		not null,
    spec_id 		uid_t 		null,
    cohort_id 		uid_t		null,
    loyalty_level_id 	uid_t		null,
    influence_level_id 	uid_t		null,
    intensity_level_id 	uid_t		null,
    start_year 		int32_t 	null,
    mobile 		phone_t 	null,
    email 		email_t 	null,
    locked 		bool_t 		not null default 0,
    extra_info 		note_t 		null,
    consent_data 	blob_t 		null,
    consent_type 	varchar(32) 	null check(consent_type in ('application/pdf')),
    consent_status 	varchar(24) 	null check(consent_status in ('collecting','collecting_and_informing')),
    consent_dt 		datetime_t 	null,
    consent_country 	country_t 	null,
    author_id 		uid_t 		null,
    hidden 		bool_t 		not null default 0,
    cookie 		uid_t 		null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, contact_id)
);

create index i_account_id_contacts on contacts(account_id);

create trigger trig_updated_ts before update on contacts for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on countries for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on delivery_types for each row execute procedure tf_updated_ts();

create table departments (
    db_id 		uid_t 		not null,
    dep_id		uid_t		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, dep_id)
);

create trigger trig_updated_ts before update on departments for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on discard_types for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on distributors for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on equipment_types for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on equipments for each row execute procedure tf_updated_ts();

create table influence_levels (
    db_id 		uid_t 		not null,
    influence_level_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, influence_level_id)
);

create trigger trig_updated_ts before update on influence_levels for each row execute procedure tf_updated_ts();

create table intensity_levels (
    db_id 		uid_t 		not null,
    intensity_level_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, intensity_level_id)
);

create trigger trig_updated_ts before update on intensity_levels for each row execute procedure tf_updated_ts();

create table interaction_types (
    db_id 		uid_t 		not null,
    interaction_type_id uid_t 		not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, interaction_type_id)
);

create trigger trig_updated_ts before update on interaction_types for each row execute procedure tf_updated_ts();

create table job_titles (
    db_id 		uid_t 		not null,
    job_title_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, job_title_id)
);

create trigger trig_updated_ts before update on job_titles for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on kinds for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on loyalty_levels for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on manufacturers for each row execute procedure tf_updated_ts();

create table matrices (
    db_id 		uid_t 		not null,
    slice_date 		date_t 		not null,
    account_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    row_no 		int32_t 	null, -- ordering
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, slice_date, account_id, prod_id)
);

create trigger trig_updated_ts before update on matrices for each row execute procedure tf_updated_ts();

create table mileages (
    db_id 		uid_t 		not null,
    user_id 		uid_t 		not null,
    fix_date 		date_t 		not null,
    total 		int32_t 	not null,
    route 		int32_t 	null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, user_id, fix_date)
);

create trigger trig_updated_ts before update on mileages for each row execute procedure tf_updated_ts();

create table my_accounts (
    db_id 		uid_t 		not null,
    user_id 		uid_t 		not null,
    account_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, user_id, account_id)
);

create trigger trig_updated_ts before update on my_accounts for each row execute procedure tf_updated_ts();

create table my_cities (
    db_id 		uid_t 		not null,
    user_id 		uid_t 		not null,
    city_id 		uid_t 		not null,
    chan_id 		uid_t 		not null default '',
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, user_id, city_id, chan_id)
);

create trigger trig_updated_ts before update on my_cities for each row execute procedure tf_updated_ts();

create table my_habitats (
    db_id 		uid_t 		not null,
    user_id 		uid_t 		not null,
    account_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, user_id, account_id)
);

create trigger trig_updated_ts before update on my_habitats for each row execute procedure tf_updated_ts();

create table my_regions (
    db_id 		uid_t 		not null,
    user_id 		uid_t 		not null,
    region_id 		uid_t 		not null,
    chan_id 		uid_t 		not null default '',
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, user_id, region_id, chan_id)
);

create trigger trig_updated_ts before update on my_regions for each row execute procedure tf_updated_ts();

create table my_retail_chains (
    db_id 		uid_t 		not null,
    user_id 		uid_t 		not null,
    rc_id 		uid_t 		not null,
    region_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key (db_id, user_id, rc_id, region_id)
);

create trigger trig_updated_ts before update on my_retail_chains for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on my_routes for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on oos_types for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on order_params for each row execute procedure tf_updated_ts();

create table order_types (
    db_id 		uid_t 		not null,
    order_type_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, order_type_id)
);

create trigger trig_updated_ts before update on order_types for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on ownership_types for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on packs for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on payment_methods for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on pending_types for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on photo_params for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on photo_types for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on placements for each row execute procedure tf_updated_ts();

create table pos_materials (
    db_id 		uid_t 		not null,
    posm_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    brand_ids 		uids_t 		not null,
    placement_ids 	uids_t 		null,
    chan_ids 		uids_t 		null,
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

create trigger trig_updated_ts before update on pos_materials for each row execute procedure tf_updated_ts();

create table potentials (
    db_id 		uid_t 		not null,
    poten_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, poten_id)
);

create trigger trig_updated_ts before update on potentials for each row execute procedure tf_updated_ts();

create table priorities (
    db_id 		uid_t 		not null,
    brand_id 		uid_t 		not null,
    b_date 		date_t 		not null,
    e_date 		date_t 		not null,
    country_id 		uid_t 		not null,
    primary key (db_id, brand_id, b_date, country_id)
);

create trigger trig_updated_ts before update on priorities for each row execute procedure tf_updated_ts();

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
    obsolete 		bool_t 		null,
    novelty 		bool_t 		null,
    promo 		bool_t 		null,
    barcodes 		ean13s_t 	null,
    units 		int32_t 	not null default 1 check(units > 0),
    country_ids 	countries_t 	null,
    dep_ids 		uids_t 		null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, prod_id)
);

create trigger trig_updated_ts before update on products for each row execute procedure tf_updated_ts();

create table quest_items (
    db_id 		uid_t 		not null,
    qname_id 		uid_t 		not null,
    qrow_id 		uid_t 		not null,
    qitem_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, qname_id, qrow_id, qitem_id)
);

create trigger trig_updated_ts before update on quest_items for each row execute procedure tf_updated_ts();

create table quest_names (
    db_id 		uid_t 		not null,
    qname_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, qname_id)
);

create trigger trig_updated_ts before update on quest_names for each row execute procedure tf_updated_ts();

create table quest_rows (
    db_id 		uid_t 		not null,
    qname_id 		uid_t 		not null,
    qrow_id 		uid_t 		not null,
    pid 		uid_t 		null,
    ftype 		bool_t 		not null,
    descr 		descr_t 	not null,
    qtype 		varchar(10) 	null,
    country_ids 	countries_t 	null,
    dep_ids 		uids_t 		null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, qname_id, qrow_id)
);

create trigger trig_updated_ts before update on quest_rows for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on rating_criterias for each row execute procedure tf_updated_ts();

create table rating_scores (
    db_id 		uid_t 		not null,
    rating_score_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    score 		int32_t 	null check(score >= 0),
    rating_criteria_id 	uid_t 		null,
    row_no 		int32_t 	null, -- ordering,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, rating_score_id)
);

create trigger trig_updated_ts before update on rating_scores for each row execute procedure tf_updated_ts();

create table reclamation_types (
    db_id 		uid_t 		not null,
    reclamation_type_id uid_t 		not null,
    descr 		descr_t 	null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, reclamation_type_id)
);

create trigger trig_updated_ts before update on reclamation_types for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on regions for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on retail_chains for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on shelf_lifes for each row execute procedure tf_updated_ts();

create table specializations (
    db_id 		uid_t 		not null,
    spec_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, spec_id)
);

create trigger trig_updated_ts before update on specializations for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on targets for each row execute procedure tf_updated_ts();

create table target_types (
    db_id 		uid_t 		not null,
    target_type_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    row_no 		int32_t 	null, -- ordering
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, target_type_id)
);

create trigger trig_updated_ts before update on target_types for each row execute procedure tf_updated_ts();

create table training_materials (
    db_id 		uid_t 		not null,
    tm_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    brand_ids 		uids_t 		null,
    training_type_ids 	uids_t 		null,
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

create trigger trig_updated_ts before update on training_materials for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on training_types for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on unsched_types for each row execute procedure tf_updated_ts();

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
    "rules:wd_duration"	time_t 		null,
    "rules:timing" 	time_t 		null,
    hidden		bool_t		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    primary key(db_id, user_id)
);

create trigger trig_updated_ts before update on users for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on warehouses for each row execute procedure tf_updated_ts();



-- **** proxy-db specific streams ****

create table additions (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    user_id		uid_t 		not null,
    fix_dt		datetime_t 	not null,
    account 		descr_t 	null,
    address 		address_t 	null,
    tax_number 		code_t 		null,
    addition_type_id 	uid_t 		null,
    note 		note_t 		null,
    chan_id 		uid_t 		null,
    phone 		phone_t 	null,
    workplaces 		int32_t 	null check(workplaces > 0),
    team 		int32_t 	null check(team > 0),
    interaction_type_id uid_t 		null,
    attr_ids 		uids_t 		null,
    photos 		uids_t 		null,
    account_id 		uid_t 		not null,
    validator_id 	uid_t		null,
    validated 		bool_t 		not null default 0,
    hidden 		bool_t 		not null default 0,
    geo_address 	address_t 	null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key(db_id, doc_id)
);

create trigger trig_updated_ts before update on additions for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on cancellations for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on comments for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on confirmations for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on deletions for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on discards for each row execute procedure tf_updated_ts();

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
    doc_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, account_id, categ_id, audit_criteria_id)
);

create trigger trig_updated_ts before update on dyn_audits for each row execute procedure tf_updated_ts();

create table dyn_checkups (
    db_id 		uid_t 		not null,
    fix_date		date_t 		not null,
    account_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    exist 		int32_t 	not null,
    fix_dt		datetime_t 	not null,
    user_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, account_id, prod_id)
);

create trigger trig_updated_ts before update on dyn_checkups for each row execute procedure tf_updated_ts();

create table dyn_oos (
    db_id 		uid_t 		not null,
    fix_date		date_t 		not null,
    account_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    oos_type_id 	uid_t 		not null,
    note 		note_t 		null,
    fix_dt		datetime_t 	not null,
    user_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, account_id, prod_id)
);

create trigger trig_updated_ts before update on dyn_oos for each row execute procedure tf_updated_ts();

create table dyn_presences (
    db_id 		uid_t 		not null,
    fix_date		date_t 		not null,
    account_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    facing 		int32_t 	not null,
    stock 		int32_t 	null,
    fix_dt		datetime_t 	not null,
    user_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, account_id, prod_id)
);

create trigger trig_updated_ts before update on dyn_presences for each row execute procedure tf_updated_ts();

create table dyn_prices (
    db_id 		uid_t 		not null,
    fix_date		date_t 		not null,
    account_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    price 		currency_t 	null,
    promo 		currency_t 	null,
    discount 		bool_t 		not null,
    note 		note_t 		null,
    photo 		uid_t 		null,
    rrp 		currency_t 	null,
    fix_dt		datetime_t 	not null,
    user_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, account_id, prod_id),
    check(price is not null or promo is not null)
);

create trigger trig_updated_ts before update on dyn_prices for each row execute procedure tf_updated_ts();

create table dyn_quests (
    db_id 		uid_t 		not null,
    fix_date		date_t 		not null,
    account_id 		uid_t 		not null,
    qname_id 		uid_t 		not null,
    qrow_id 		uid_t		not null,
    "value" 		note_t 		not null,
    fix_dt 		datetime_t 	not null,
    user_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, account_id, qname_id, qrow_id)
);

create trigger trig_updated_ts before update on dyn_quests for each row execute procedure tf_updated_ts();

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
    doc_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, account_id, employee_id, rating_criteria_id)
);

create trigger trig_updated_ts before update on dyn_ratings for each row execute procedure tf_updated_ts();

create table dyn_reviews (
    db_id 		uid_t 		not null,
    fix_date		date_t 		not null,
    employee_id 	uid_t 		not null,
    sla 		numeric(6,5)	not null check(sla between 0.0 and 1.0),
    assessment 		numeric(5,3)    not null check(assessment >= 0),
    note0 		note_t 		null,
    note1 		note_t 		null,
    note2 		note_t 		null,
    unmarked 		uids_t 		null,
    fix_dt		datetime_t 	not null,
    user_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, employee_id)
);

create trigger trig_updated_ts before update on dyn_reviews for each row execute procedure tf_updated_ts();

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
    doc_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, account_id, categ_id, brand_id)
);

create trigger trig_updated_ts before update on dyn_shelfs for each row execute procedure tf_updated_ts();

create table dyn_stocks (
    db_id 		uid_t 		not null,
    fix_date		date_t 		not null,
    account_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    stock 		int32_t 	not null,
    fix_dt 		datetime_t 	not null,
    user_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null,
    "_isRecentData"	bool_t 		null,
    primary key(db_id, fix_date, account_id, prod_id)
);

create trigger trig_updated_ts before update on dyn_stocks for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on holidays for each row execute procedure tf_updated_ts();

create table locations (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    fix_dt 		datetime_t 	not null,
    user_id 		uid_t 		not null,
    account_id 		uid_t 		not null,
    latitude 		gps_t 		not null,
    longitude 		gps_t 		not null,
    accuracy 		double_t 	not null,
    dist 		double_t 	null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key(db_id, doc_id)
);

create trigger trig_updated_ts before update on locations for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on orders for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on photos for each row execute procedure tf_updated_ts();

create table posms (
    db_id 		uid_t 		not null,
    doc_id		uid_t		not null,
    fix_dt		datetime_t	not null,
    user_id		uid_t		not null,
    account_id		uid_t		not null,
    placement_id	uid_t		not null,
    posm_id		uid_t		not null,
    photo		uid_t		not null,
    doc_note		note_t		null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    fix_year 		int32_t 	not null,
    fix_month 		int32_t 	not null,
    primary key(db_id, doc_id)
);

create index i_year_posms1 on posms(db_id, fix_year);
create index i_year_posms2 on posms(db_id, fix_year, account_id);

create trigger trig_updated_ts before update on posms for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on presentations for each row execute procedure tf_updated_ts();

create table profiles (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    fix_dt 		datetime_t 	not null,
    user_id 		uid_t 		not null,
    account_id 		uid_t 		not null,
    chan_id 		uid_t 		null,
    poten_id 		uid_t 		null,
    phone 		phone_t 	null,
    workplaces 		int32_t 	null check(workplaces > 0),
    team 		int32_t 	null check(team > 0),
    interaction_type_id uid_t 		null,
    attr_ids 		uids_t 		null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key(db_id, doc_id)
);

create trigger trig_updated_ts before update on profiles for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on reclamations for each row execute procedure tf_updated_ts();

create table remarks (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    status 		varchar(8) 	not null,
    note 		note_t 		null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key(db_id, doc_id)
);

create trigger trig_updated_ts before update on remarks for each row execute procedure tf_updated_ts();

create table revocations (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    doc_type 		doctype_t 	not null,
    hidden		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key (db_id, doc_id)
);

create trigger trig_updated_ts before update on revocations for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on trainings for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on thumbnails for each row execute procedure tf_updated_ts();

create or replace function photo_get(arg0 /*db_id*/ uid_t, arg1 /*ref_id*/ uid_t) returns blob_t as
$body$
declare
    rv blob_t;
begin
    select photo from thumbnails where db_id = arg0 and ref_id = arg1
	into rv;
    return rv;
end;
$body$
language plpgsql STABLE;

create or replace function thumb_get(arg0 /*db_id*/ uid_t, arg1 /*ref_id*/ uid_t) returns blob_t as
$body$
declare
    rv blob_t;
begin
    select thumb from thumbnails where db_id = arg0 and ref_id = arg1
	into rv;
    return rv;
end;
$body$
language plpgsql STABLE;

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

create trigger trig_updated_ts before update on unsched for each row execute procedure tf_updated_ts();

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
    mileage 		int32_t 	null,
    zstatus 		varchar(8) 	null check(zstatus in ('accepted','rejected') and zstatus = lower(zstatus)),
    znote 		note_t 		null,
    zauthor_id 		uid_t 		null,
    zreq_dt 		datetime_t 	null,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key (db_id, user_id, account_id, activity_type_id, w_cookie, a_cookie)
);

create index i_user_id_user_activities on user_activities (user_id);
create index i_fix_date_user_activities on user_activities (fix_date);
create index i_daily_user_activities on user_activities (user_id, fix_date);
create index i_route_date_user_activities on user_activities(route_date);

create trigger trig_updated_ts before update on user_activities for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on user_documents for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on user_locations for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on user_reports for each row execute procedure tf_updated_ts();

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

create trigger trig_updated_ts before update on user_works for each row execute procedure tf_updated_ts();

create table wishes (
    db_id 		uid_t 		not null,
    account_id  	uid_t 		not null,
    user_id		uid_t 		not null,
    fix_dt		datetime_t 	not null,
    weeks 		smallint[] 	not null default array[0,0,0,0] check (array_length(weeks,1)=4),
    days 		smallint[] 	not null default array[0,0,0,0,0,0,0] check (array_length(days,1)=7),
    note		note_t		null,
    validator_id 	uid_t		null,
    validated 		bool_t 		not null default 0,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts		ts_auto_t 	not null,
    primary key(db_id, account_id, user_id)
);

create trigger trig_updated_ts before update on wishes for each row execute procedure tf_updated_ts();



-- **** system stream ****



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

create trigger trig_updated_ts before update on data_stream for each row execute procedure tf_updated_ts();
create trigger trig_updated_ts before update on blob_stream for each row execute procedure tf_updated_ts();

create or replace function stor_data_stream3(arg0 varchar(16), arg1 varchar(32), arg2 varchar(204), p_digest varchar(32), hostname hostname_t) 
    returns void
as $BODY$
declare
    p_id varchar(256);
begin
    p_id := format('//%s/%s/%s', arg0, arg1, arg2);

    if( (select count(*) from data_stream where s_id = p_id) > 0 ) then
	update data_stream set digest = p_digest, inserted_node = hostname
	    where s_id = p_id;
    else
	insert into data_stream(s_id, digest, inserted_node)
	    values(p_id, p_digest, hostname);
    end if;
end;
$BODY$ language plpgsql;

create or replace function stor_data_stream2(arg1 varchar(32), arg2 varchar(204), p_digest varchar(32), hostname hostname_t) 
    returns void
as $BODY$
declare
    p_id varchar(256);
begin
    perform stor_data_stream3('proxy', arg1, arg2, p_digest, hostname);
end;
$BODY$ language plpgsql;

create or replace function exist_data_stream3(arg0 varchar(16), arg1 varchar(32), arg2 varchar(204), p_digest varchar(32)) 
    returns int
as $BODY$
begin
    return (select count(s_id) from data_stream where s_id = format('//%s/%s/%s', arg0, arg1, arg2) and digest = p_digest);
end;
$BODY$ language plpgsql;

create or replace function exist_data_stream2(arg1 varchar(32), arg2 varchar(204), p_digest varchar(32)) 
    returns int
as $BODY$
begin
    return (exist_data_stream3('proxy', arg1, arg2, p_digest));
end;
$BODY$ language plpgsql;

create or replace function stor_blob_stream3(arg0 varchar(16), arg1 varchar(32), arg2 varchar(204), b_id blob_t, hostname hostname_t) 
    returns void
as $BODY$
declare
    p_id varchar(256);
begin
    p_id := format('//%s/%s/%s', arg0, arg1, arg2);

    if( (select count(*) from blob_stream where s_id=p_id) > 0 ) then
	update blob_stream set blob_id=b_id, inserted_node=hostname
	    where s_id=p_id;
    else
	insert into blob_stream(s_id, blob_id, inserted_node)
	    values(p_id, b_id, hostname);
    end if;
end;
$BODY$ language plpgsql;

create or replace function stor_blob_stream2(arg1 varchar(32), arg2 varchar(204), b_id blob_t, hostname hostname_t) 
    returns void
as $BODY$
begin
    perform stor_blob_stream3('proxy', arg1, arg2, b_id, hostname);
end;
$BODY$ language plpgsql;

create or replace function resolve_blob_stream3(arg0 varchar(16), arg1 varchar(32), arg2 varchar(204)) 
    returns blob_t
as $BODY$
begin
    if( arg0 is null or arg1 is null or arg2 is null or arg2 = '' ) then
	return null;
    end if;

    return (select blob_id from blob_stream where s_id = format('//%s/%s/%s', arg0, arg1, arg2));
end;
$BODY$ language plpgsql;

create or replace function resolve_blob_stream2(arg1 varchar(32), arg2 varchar(204)) 
    returns blob_t
as $BODY$
begin
    return resolve_blob_stream3('proxy', arg1, arg2);
end;
$BODY$ language plpgsql;


create or replace function bool_in(arg text) returns bool_t as
$body$
begin
    return case when arg = '' then null else arg::bool_t end;
end;
$body$
language plpgsql IMMUTABLE;

create or replace function currency_in(arg text) returns currency_t as
$body$
begin
    return case when arg = '' then null else arg::currency_t end;
end;
$body$
language plpgsql IMMUTABLE;

create or replace function date_in(arg text) returns date_t as
$body$
begin
    return case when arg = '' then null else arg end;
end;
$body$
language plpgsql IMMUTABLE;

create or replace function datetime_in(arg text) returns datetime_t as
$body$
begin
    return case when arg = '' then null else arg end;
end;
$body$
language plpgsql IMMUTABLE;

create or replace function descr_in(arg text) returns descr_t as
$body$
begin
    return case when arg = '' then null else arg end;
end;
$body$
language plpgsql IMMUTABLE;

create or replace function double_in(arg text) returns double_t as
$body$
begin
    return case when arg = '' then null else arg::double_t end;
end;
$body$
language plpgsql IMMUTABLE;

create or replace function ean13_in(ar text array) returns ean13 array
as $body$
declare
    m text;
    x ean13 array;
begin
    perform isn_weak(true);
    if ar is not null then
	foreach m in array ar
	loop
	    if m is not null and length(m) = 13 then
		x := array_append(x, ean13_in(m::cstring));
	    end if;
	end loop;
    end if;
    --perform isn_weak(false);
    return x;
end;
$body$ language plpgsql;

create or replace function ean13ar_in(arg text) returns ean13 array as
$body$
begin
    return case when arg = '' then null else ean13_in(string_to_array(arg, ',')) end;
end;
$body$
language plpgsql IMMUTABLE;

create or replace function email_in(arg text) returns email_t as
$body$
begin
    return case when arg = '' then null else arg end;
end;
$body$
language plpgsql IMMUTABLE;

create or replace function gps_in(arg text) returns gps_t as
$body$
begin
    return case when arg = '' then null else arg::gps_t end;
end;
$body$
language plpgsql IMMUTABLE;

create or replace function hstore_in(arg text) returns hstore_t as
$body$
begin
    return case when arg = '' then null else arg::hstore_t end;
end;
$body$
language plpgsql IMMUTABLE;

create or replace function int32_in(arg text) returns int32_t as
$body$
begin
    return case when arg = '' then null else arg::int32_t end;
end;
$body$
language plpgsql IMMUTABLE;

create or replace function note_in(arg text) returns note_t as
$body$
begin
    return case when arg = '' then null else arg end;
end;
$body$
language plpgsql IMMUTABLE;

create or replace function phone_in(arg text) returns phone_t as
$body$
begin
    return case when arg = '' then null else arg end;
end;
$body$
language plpgsql IMMUTABLE;

create or replace function time_in(arg text) returns time_t as
$body$
begin
    return case when arg = '' then null else arg end;
end;
$body$
language plpgsql IMMUTABLE;

create or replace function uid_in(arg text) returns uid_t as
$body$
begin
    return case when arg = '' then null else arg end;
end;
$body$
language plpgsql IMMUTABLE;

create or replace function uids_in(arg text) returns uids_t as
$body$
begin
    return case when arg = '' then null else string_to_array(arg, ',') end;
end;
$body$
language plpgsql IMMUTABLE;

create or replace function uids_out(arg uids_t) returns text as
$body$
begin
    return case when arg is null then null else array_to_string(arg, ',') end;
end;
$body$
language plpgsql IMMUTABLE;

create or replace function wf_in(arg text) returns wf_t as
$body$
begin
    return case when arg = '' then null else arg::wf_t end;
end;
$body$
language plpgsql IMMUTABLE;

create table sysparams (
    param_id 		uid_t 		not null primary key,
    param_value 	uid_t 		null,
    descr 		descr_t 	null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_auto_t 	not null,
    updated_ts 		ts_auto_t 	not null
);

create trigger trig_updated_ts before update on sysparams for each row execute procedure tf_updated_ts();

insert into sysparams(param_id, param_value, descr) values('db:created_ts', current_timestamp, 'Database creation datetime.');
insert into sysparams(param_id, param_value, descr) values('db:id', 'LTS', 'Database unique ID.');
insert into sysparams(param_id, param_value, descr) values('db:vstamp', '', 'Database version number.');

create or replace function year(arg timestamp with time zone) returns int as
$body$
begin
    return extract(year from arg);
end;
$body$
language plpgsql IMMUTABLE;

create or replace function year(arg timestamp) returns int as
$body$
begin
    return extract(year from arg);
end;
$body$
language plpgsql IMMUTABLE;

create or replace function year(arg date) returns int as
$body$
begin
    return extract(year from arg);
end;
$body$
language plpgsql IMMUTABLE;

create or replace function orphanLO() 
    returns setof blob_t
as $body$
declare
    b blob_t;
    schem name;
    rel name;
    attr name;
    categ char;
begin
    /*
     * Don't get fooled by any non-system catalogs
     */
--    set search_path = pg_catalog;

    /*
     * First we create and populate the LO temp table
     */
    create temp table  ".vacuumLO" as select oid as lo from pg_largeobject_metadata;

    /*
     * Analyze the temp table so that planner will generate decent plans for
     * the DELETEs below.
     */
    analyze  ".vacuumLO";

    /*
     * Now find any candidate tables that have columns of type oid.
     *
     * NOTE: we ignore system tables and temp tables by the expedient of
     * rejecting tables in schemas named 'pg_*'.  In particular, the temp
     * table formed above is ignored, and pg_largeobject will be too. If
     * either of these were scanned, obviously we'd end up with nothing to
     * delete...
     *
     * NOTE: the system oid column is ignored, as it has attnum < 1. This
     * shouldn't matter for correctness, but it saves time.
     */
    for schem, rel, attr, categ in
    select s.nspname, c.relname, a.attname, t.typcategory from pg_class c, pg_attribute a, pg_namespace s, pg_type t
        where a.attnum > 0 and not a.attisdropped
	and a.attrelid = c.oid
	and a.atttypid = t.oid
	and c.relnamespace = s.oid
	and t.typname in ('oid', 'lo', 'blob_t', 'blobs_t')
	and c.relkind in ('r', 'm')
	and s.nspname !~ '^pg_'
    loop
    if( categ = 'A' ) then /* array */
        execute 'DELETE FROM  ".vacuumLO" WHERE lo IN (SELECT unnest("' || attr || '") FROM ' || schem || '."' || rel || '" WHERE "' || attr || '" is not null);';
    else
        execute 'DELETE FROM  ".vacuumLO" WHERE lo IN (SELECT "' || attr ||'" FROM ' || schem || '."' || rel || '" WHERE "' || attr || '" is not null);';
    end if;
    end loop;

    /*
     * Now, those entries remaining in  ".vacuumLO" are orphans.
     */
    for b in select lo from ".vacuumLO"
    loop
    return next b;
    end loop;

    /*
     * Drop temporary table.
     */
    drop table if exists ".vacuumLO";
end;
$body$ language plpgsql;

/* Copyright (c) 2006 - 2022 omobus-lts-db authors, see the included COPYRIGHT file. */

update sysparams set param_value='3.5.26' where param_id='db:vstamp';

