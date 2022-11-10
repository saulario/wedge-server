

drop table if exists tca;
drop table if exists tpa;
drop table if exists tta;

drop table if exists gxx;
drop table if exists gdj;
drop table if exists gdi;
drop table if exists gcl;
drop table if exists gpr;
drop table if exists gcv;
drop table if exists gcu;

drop table if exists gpb;
drop table if exists gtz;
drop table if exists gpa;

drop table if exists ttc;
drop table if exists ttm;
drop table if exists ttp;
drop table if exists usi;

-------------------------------------------------
-- Divisa (currency)

create table gcu (
    gcucod      varchar(5) not null primary key,
    gcunom      varchar(80) not null
);

comment on table gcu is             'Divisa';
comment on column gcu.gcucod is     'Código';
comment on column gcu.gcunom is     'Descripción';

insert into gcu values ('EUR', 'EURO');
insert into gcu values ('USD', 'US DOLAR');

create table gcv (
    gcvid       bigserial primary key,
    gcvgcucod   varchar(5) not null default '',
    gcvcer      numeric(13, 6) not null default 0
);

comment on table gcv is             'Divisa, tipo de cambio';
comment on column gcv.gcvid is      'Id. interno';
comment on column gcv.gcvgcucod is  'Código de divisa';
comment on column gcv.gcvcer is     'Tipo de cambio';

insert into gcv(gcvgcucod, gcvcer) values('USD', 1);

-------------------------------------------------
-- Configuración general

create table gxx (
    gxxcod      smallint primary key,
    gxxgcucod   varchar(5) not null
);

comment on table gxx is             'Configuración general';
comment on column gxx.gxxcod is     'Código cero';
comment on column gxx.gxxgcucod is  'Divisa del sistema';

alter table gxx add constraint gxx_fk_01 foreign key(gxxgcucod) references gcu(gcucod);

insert into gxx values(0, 'EUR');

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
    gclraz      varchar(80) not null default '',
    gclnom      varchar(80) not null default '',
    gclnif      varchar(20) not null default '',
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
    gclgcucod   varchar(5) not null default '',
    gclact      smallint not null default 0
);

comment on table gcl is         	'Clientes';
comment on column gcl.gclid is		'Id. de cliente';
comment on column gcl.gcleid is		'Código externo';
comment on column gcl.gclraz is		'Razón social';
comment on column gcl.gclnom is		'Nombre comercial';
comment on column gcl.gclnif is		'NIF';
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
comment on column gcl.gclgcucod is  'Divisa';
comment on column gcl.gclact is		'Activo/inactivo';

create index gcl_ix_01 on gcl(gclgpacod);
create index gcl_ix_02 on gcl(gclgtzid);
create index gcl_ix_03 on gcl(gclgcucod);

alter table gcl add constraint gcl_fk_01 foreign key(gclgpacod) references gpa(gpacod);
alter table gcl add constraint gcl_fk_02 foreign key(gclgtzid) references gtz(gtzid);
alter table gcl add constraint gcl_fk_03 foreign key(gclgcucod) references gcu(gcucod);

-------------------------------------------------
-- Proveedores

create table gpr (
    gprid       bigserial primary key,
    gpreid      varchar(20) not null default '',
    gprraz      varchar(80) not null default '',
    gprnom      varchar(80) not null default '',
    gprnif      varchar(20) not null default '',
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
    gprgcucod   varchar(5) not null default '',
    gpract      smallint not null default 0
);

comment on table gpr is         	'Clientes';
comment on column gpr.gprid is		'Id. de cliente';
comment on column gpr.gpreid is		'Código externo';
comment on column gpr.gprraz is		'Razón social';
comment on column gpr.gprnom is		'Nombre comercial';
comment on column gpr.gprnif is		'NIF';
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
comment on column gpr.gprgcucod is  'Divisa';
comment on column gpr.gpract is		'Activo/inactivo';

create index gpr_ix_01 on gpr(gprgpacod);
create index gpr_ix_02 on gpr(gprgtzid);
create index gpr_ix_03 on gpr(gprgcucod);


alter table gpr add constraint gpr_fk_01 foreign key(gprgpacod) references gpa(gpacod);
alter table gpr add constraint gpr_fk_02 foreign key(gprgtzid) references gtz(gtzid);
alter table gpr add constraint gpr_fk_03 foreign key(gprgcucod) references gcu(gcucod);

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
    gdirmr      smallint not null default 0,
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
comment on column gdi.gdirmr is		'Reserva de muelle requerida';
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

-------------------------------------------------
-- Tipos de contenedores

create table ttc (
    ttccod      varchar(10) not null primary key,
    ttcnom      varchar(80) not null default '',
	ttclar		int not null default 0,
	ttctar		numeric(9,3) not null default 0,
	ttcpes		numeric(9,3) not null default 0,
	ttccub		numeric(9,3) not null default 0,
	ttclai		numeric(5,2) not null default 0,
	ttcani		numeric(5,2) not null default 0,
	ttcali		numeric(5,2) not null default 0,
	ttcana		numeric(5,2) not null default 0,
	ttcala		numeric(5,2) not null default 0
);

comment on table ttc is             'Tipos de contenedores';
comment on column ttc.ttccod is     'Código';
comment on column ttc.ttcnom is     'Descripción';
comment on column ttc.ttclar is     'Largo en pies';
comment on column ttc.ttctar is		'Tara';
comment on column ttc.ttcpes is		'Peso carga útil';
comment on column ttc.ttccub is		'Capacidad cúbica';
comment on column ttc.ttclai is		'Largo interno';
comment on column ttc.ttcani is 	'Ancho interno';
comment on column ttc.ttcali is		'Alto interno';
comment on column ttc.ttcana is		'Ancho apertura de puerta';
comment on column ttc.ttcala is		'Alto apertura de puerta';

insert into ttc values ('DRY20', 'DRY 20 PIES', 2300, 25000, 33.2, 5.9, 2.35, 2.39, 2.34, 2.28);
insert into ttc values ('DRY40', 'DRY 40 PIES', 3750, 27600, 67.7, 12.03, 2.35, 2.39, 2.34, 2.28);

-------------------------------------------------
-- Tipos de mercancía

create table ttm (
    ttmcod      varchar(20) not null primary key,
    ttmnom      varchar(80) not null default '',
    ttmadr      smallint not null default 0,
    ttmadrcls   varchar(10) not null default '',
    ttmadrund   int not null default 0,
    ttmadrflp   numeric(5,2) not null default 0,
    ttmtmp      smallint not null default 0,
    ttmtmpstp   numeric(5,2) not null default 0,
    ttmtmpmin   numeric(5,2) not null default 0,
    ttmtmpmax   numeric(5,2) not null default 0
);

comment on table ttm is             'Tipos de mercancías';
comment on column ttm.ttmcod is     'Código';
comment on column ttm.ttmnom is     'Descripción';
comment on column ttm.ttmadr is     'ADR, mercancía peligrosa';
comment on column ttm.ttmadrcls is  'ADR, clase';
comment on column ttm.ttmadrund is  'ADR, número UN';
comment on column ttm.ttmadrflp is  'ADR, punto inflamabilidad';
comment on column ttm.ttmtmp is     'TMP, temperatura controlada';
comment on column ttm.ttmtmpstp is  'TMP, set point';
comment on column ttm.ttmtmpmin is  'TMP, mínimo';
comment on column ttm.ttmtmpmax is  'TMP, máximo';

-------------------------------------------------
-- Tipos de paradas

create table ttp (
    ttpcod      varchar(5) not null primary key,
    ttpnom      varchar(80) not null default '',
	ttpcls		smallint not null default 0,
	ttpsgn		smallint not null default 0,
	ttpmin		smallint not null default 0,
	ttpmax		smallint not null default 0
);

comment on table ttp is             'Tipos de paradas';
comment on column ttp.ttpcod is     'Código';
comment on column ttp.ttpnom is     'Descripción';
comment on column ttp.ttpcls is     'Clase 0=Principal, 1=Auxiliar entrega, -1=Auxiliar retorno';
comment on column ttp.ttpsgn is     'Signo 0=Neutral, 1=Incrementa, -1=Decrementa';
comment on column ttp.ttpmin is     'Posición inicial válida [1,998]';
comment on column ttp.ttpmax is     'Posición final válida [2,999]';

-------------------------------------------------
-- Cargas

create table tca (
    tcaid       bigserial primary key,

    -- estado operativo y administrativo

    -- datos identificativos
    tcagclid    bigint not null default 0,
    tcagcleid   varchar(20) not null default '',
    tcagclraz   varchar(80) not null default '',
    tcagclnom   varchar(80) not null default '',
    tcagclnif   varchar(20) not null default '',
    tcare1      varchar(20) not null default '',
    tcare2      varchar(20) not null default '',
    tcare3      varchar(20) not null default '',
    tcare4      varchar(20) not null default '',

    -- divisa
    tcagcucod   varchar(5) not null default '',
    tcagcufec   date not null default '0001-01-01',    
    tcagcucer   numeric(13, 6) not null default 0,

    -- tipo de mercancía
    tcattmcod   varchar(20) not null default '',
    tcaadr      smallint not null default 0,
    tcaadrcls   varchar(10) not null default '',
    tcaadrund   int not null default 0,
    tcaadrflp   numeric(5,2) not null default 0,
    tcatmp      smallint not null default 0,
    tcatmpstp   numeric(5,2) not null default 0,
    tcatmpmin   numeric(5,2) not null default 0,
    tcatmpmax   numeric(5,2) not null default 0,

    -- contenedor
    tcatcocod   varchar(20) not null default '',
    tcattccod   varchar(10),

    -- origen
    tcaorgfec   date not null default '0001-01-01',
    tcaorgeid   varchar(20) not null default '',
    tcaorgnom   varchar(80) not null default '',
    tcaorgpcp   varchar(20) not null default '',
    tcaprgpob   varchar(80) not null default '',

    -- destino
    tcadesfec   date not null default '0001-01-01',
    tcadeseid   varchar(20) not null default '',
    tcadesnom   varchar(80) not null default '',
    tcadespcp   varchar(20) not null default '',
    tcadespob   varchar(80) not null default '',

    -- dimensiones logísticas
    tcadimpes   numeric(7, 3) not null default 0,
    tcadimcub   numeric(7, 3) not null default 0,
    tcadimplt   int not null default 0,
    tcadimlar   numeric(7, 3) not null default 0,
    tcadimalt   numeric(7, 3) not null default 0,
    tcadimanc   numeric(7, 3) not null default 0,

    -- ingreso
    

    -- estadísticas
    tcatpatot   smallint not null default 0,
    tcatpapdt   smallint not null default 0,
    tcaing      numeric(13, 2) not null default 0,
    tcakmt      int not null default 0,
    tcaeuk      numeric(13, 2) not null default 0

);

create index tca_ix_01 on tca(tcagclid);
create index tca_ix_02 on tca(tcagcleid);
create index tca_ix_03 on tca(tcagclraz);
create index tca_ix_04 on tca(tcagclnom);
create index tca_ix_05 on tca(tcagclnif);
create index tca_ix_06 on tca(tcatcocod);
create index tca_ix_07 on tca(tcagcucod);

alter table tca add constraint tca_fk_01 foreign key(tcagclid) references gcl(gclid);
alter table tca add constraint tca_fk_06 foreign key(tcattccod) references ttc(ttccod);
alter table tca add constraint tca_fk_07 foreign key(tcagcucod) references gcu(gcucod);




-------------------------------------------------
-- Transportes
