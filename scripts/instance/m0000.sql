
drop table if exists gdj;
drop table if exists gdi;
drop table if exists gcl;
drop table if exists gpr;

drop table if exists gpb;
drop table if exists gtz;
drop table if exists gpa;

drop table if exists usi;

-------------------------------------------------
-- Usuario de instancia

create table usi (
    usiusrid    bigint primary key,
    usicod      varchar(80) not null default '',
    usinom      varchar(80) not null default '',
    usieml      text not null default ''
);

comment on table usi is             'Timezones';
comment on column usi.usiusrid is   'Id. de usuario';
comment on column usi.usinom is     'Nombre';
comment on column usi.usieml is     'Correo electrónico';

create unique index usi_ix_01 on usi(usicod);

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

-------------------------------------------------
-- Clientes

create table gcl (
    gclid       bigserial primary key,
    gcleid      varchar(20) not null default '',
    gclnom      varchar(80) not null default '',
    gcldir      varchar(200) not null default '',
    gclcpo      varchar(20) not null default '',
    gclpob      varchar(80) not null default '',
    gclgpacod   varchar(2) not null,
    gclgtzid    bigint not null,
    gcllat      varchar(20) not null default '',
    gcllon      varchar(20) not null default '',
    gcltlf      varchar(20) not null default '',
    gclpdc      varchar(80) not null default '',
    gcleml      text not null default '',
    gclact      smallint not null default 0
);

comment on table gcl is         	'Clientes';
comment on column gcl.gclid is		'Id. de cliente';
comment on column gcl.gcleid is		'Código externo';
comment on column gcl.gclnom is		'Nombre';
comment on column gcl.gcldir is		'Dirección';
comment on column gcl.gclcpo is		'Código postal';
comment on column gcl.gclpob is		'Población';
comment on column gcl.gclgpacod is  'Código de país';
comment on column gcl.gclgtzid is	'Id. de timezone';
comment on column gcl.gcllat is		'Latitud';
comment on column gcl.gcllon is		'Longitud';
comment on column gcl.gcltlf is		'Teléfono';
comment on column gcl.gclpdc is		'Persona de contacto';
comment on column gcl.gcleml is		'Correo electrónico';
comment on column gcl.gclact is		'Activo/inactivo';

create index gcl_ix_01 on gcl(gclgpacod);
create index gcl_ix_02 on gcl(gclgtzid);

alter table gcl add constraint gcl_fk_01 foreign key(gclgpacod) references gpa(gpacod);
alter table gcl add constraint gcl_fk_02 foreign key(gclgtzid) references gtz(gtzid);

-------------------------------------------------
-- Proveedores

create table gpr (
    gprid       bigserial primary key,
    gpreid      varchar(20) not null default '',
    gprnom      varchar(80) not null default '',
    gprdir      varchar(200) not null default '',
    gprcpo      varchar(20) not null default '',
    gprpob      varchar(80) not null default '',
    gprgpacod   varchar(2) not null,
    gprgtzid    bigint not null,
    gprlat      varchar(20) not null default '',
    gprlon      varchar(20) not null default '',
    gprtlf      varchar(20) not null default '',
    gprpdc      varchar(80) not null default '',
    gpreml      text not null default '',
    gpract      smallint not null default 0
);

comment on table gpr is         	'Clientes';
comment on column gpr.gprid is		'Id. de cliente';
comment on column gpr.gpreid is		'Código externo';
comment on column gpr.gprnom is		'Nombre';
comment on column gpr.gprdir is		'Dirección';
comment on column gpr.gprcpo is		'Código postal';
comment on column gpr.gprpob is		'Población';
comment on column gpr.gprgpacod is  'Código de país';
comment on column gpr.gprgtzid is	'Id. de timezone';
comment on column gpr.gprlat is		'Latitud';
comment on column gpr.gprlon is		'Longitud';
comment on column gpr.gprtlf is		'Teléfono';
comment on column gpr.gprpdc is		'Persona de contacto';
comment on column gpr.gpreml is		'Correo electrónico';
comment on column gpr.gpract is		'Activo/inactivo';

create index gpr_ix_01 on gpr(gprgpacod);
create index gpr_ix_02 on gpr(gprgtzid);

alter table gpr add constraint gpr_fk_01 foreign key(gprgpacod) references gpa(gpacod);
alter table gpr add constraint gpr_fk_02 foreign key(gprgtzid) references gtz(gtzid);

-------------------------------------------------
-- Direcciones

create table gdi (
    gdiid       bigserial primary key,
    gdieid      varchar(20) not null default '',
    gdinom      varchar(80) not null default '',
    gdidir      varchar(200) not null default '',
    gdicpo      varchar(20) not null default '',
    gdipob      varchar(80) not null default '',
    gdigpacod   varchar(2) not null,
    gdigtzid    bigint not null,
    gdilat      varchar(20) not null default '',
    gdilon      varchar(20) not null default '',
    gditlf      varchar(20) not null default '',
    gdipdc      varchar(80) not null default '',
    gdieml      text not null default '',
    gdioea      smallint not null default 0,
    gdiact      smallint not null default 0
);

comment on table gdi is             'Direcciones';
comment on column gdi.gdiid is		'Id. de dirección';
comment on column gdi.gdieid is		'Código externo';
comment on column gdi.gdinom is		'Nombre';
comment on column gdi.gdidir is		'Dirección';
comment on column gdi.gdicpo is		'Código postal';
comment on column gdi.gdipob is		'Población';
comment on column gdi.gdigpacod is  'Código de país';
comment on column gdi.gdigtzid is	'Id. de timezone';
comment on column gdi.gdilat is		'Latitud';
comment on column gdi.gdilon is		'Longitud';
comment on column gdi.gditlf is		'Teléfono';
comment on column gdi.gdipdc is		'Persona de contacto';
comment on column gdi.gdieml is		'Correo electrónico';
comment on column gdi.gdioea is		'Operador económico';
comment on column gdi.gdiact is		'Activo/inactivo';

create index gdi_ix_01 on gdi(gdigpacod);
create index gdi_ix_02 on gdi(gdigtzid);

alter table gdi add constraint gdi_fk_01 foreign key(gdigpacod) references gpa(gpacod);
alter table gdi add constraint gdi_fk_02 foreign key(gdigtzid) references gtz(gtzid);

-------------------------------------------------
-- Direcciones por cliente

create table gdj (
    gdjid       bigserial primary key,
    gdjgdiid    bigint not null,
    gdjgclid    bigint not null,
    gdjeid      varchar(20) not null,
    gdjobs      varchar(80) not null default ''
);

comment on table gdj is             'Direcciones por cliente';
comment on column gdj.gdjid is		'Id. de entrada';
comment on column gdj.gdjgdiid is	'Id. de dirección';
comment on column gdj.gdjgclid is	'Id. de cliente';
comment on column gdj.gdjeid is     'Código externo';
comment on column gdj.gdjobs is     'Observaciones';

create index gdj_ix_01 on gdj(gdjgdiid);
create index gdj_ix_02 on gdj(gdjgclid);

alter table gdj add constraint gdj_fk_01 foreign key(gdjgdiid) references gdi(gdiid);
alter table gdj add constraint gdj_fk_02 foreign key(gdjgclid) references gcl(gclid);

