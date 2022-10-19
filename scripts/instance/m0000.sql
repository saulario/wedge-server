
drop table if exists gpb;
drop table if exists gtz;
drop table if exists gpa;

-------------------------------------------------
-- Timezones

create table gtz (
    gtzid       bigserial primary key,
    gtznom      varchar(200) not null default ''
);

comment on table gtz is         'Timezones';
comment on column gtz.gtzid is  'Id. de timezone';
comment on column gtz.gtznom is 'Nombre';

create unique index gtz_ix_01 on gtz(gtznom);

-------------------------------------------------
-- Países

create table gpa (
    gpacod      varchar(2) primary key,
    gpanom      varchar(200) not null default ''
);

comment on table gpa is         'Países';
comment on column gpa.gpacod is 'Código';
comment on column gpa.gpanom is 'Nombre';

create table gpb (
    gpbid       bigserial primary key,
    gpbgpacod   varchar(2) not null default '',
    gpbgtzid    bigint not null default 0
);

comment on table gpb is         'Países, zonas horarias';
comment on column gpb.gpbgpacod is 'Código de país';
comment on column gpb.gpbgtzid  is 'Código de timezone';

create index gpb_ix_01 on gpb(gpbgpacod);
create index gpb_ix_02 on gpb(gpbgpacod);

alter table gpb add constraint gpb_fk_01 foreign key(gpbgpacod) references gpa(gpacod);
alter table gpb add constraint gpb_fk_02 foreign key(gpbgtzid) references gtz(gtzid);
