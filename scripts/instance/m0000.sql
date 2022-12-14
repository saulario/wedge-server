
-- FALTAN
--      CONTROL DE AUTORIZACIÓN (AHORA TODOS PUEDEN VER TODO)
--      ESTADO OPERATIVO
--      AUDITORÍA
--      INCIDENCIAS

-- FUTURO
--      ADJUNTOS Y NOTAS
--      TARIFAS DE CLIENTE
--      TARIFA DE FLOTA PROPIA
--      TARIFA DE PROVEEDOR
--      FACTURACIÓN DE CLIENTE
--      FACTURACIÓN DE PROVEEDOR

drop table if exists tpa;
drop table if exists tcb;
drop table if exists tca;
drop table if exists ttb;
drop table if exists tta;
drop table if exists tdi;

drop table if exists ttc;
drop table if exists ttm;
drop table if exists ttp;

drop table if exists tco;
drop table if exists ttr;
drop table if exists tre;
drop table if exists tcn;

drop table if exists tup;
drop table if exists tuo;

drop table if exists gxx;
drop table if exists gcf;
drop table if exists gcl;
drop table if exists gpr;
drop table if exists gcv;
drop table if exists gcu;

drop table if exists gdi;
drop table if exists gpb;
drop table if exists gtz;
drop table if exists gpa;

drop table if exists usi;



-------------------------------------------------
-- Divisa (currency)

create table gcu (
    gcucod      varchar(5) not null primary key,
    gcunom      varchar(80) not null
);

comment on table gcu is             'Divisas';
comment on column gcu.gcucod is     'Código';
comment on column gcu.gcunom is     'Descripción';

insert into gcu values ('EUR', 'EURO');
insert into gcu values ('USD', 'US DOLAR');

create table gcv (
    gcvid       bigserial primary key,
    gcvgcucod   varchar(5) not null default '',
    gcvexr      numeric(13, 6) not null default 0
);

comment on table gcv is             'Divisas, tipo de cambio';
comment on column gcv.gcvid is      'Id. interno';
comment on column gcv.gcvgcucod is  'Código de divisa';
comment on column gcv.gcvexr is     'Tipo de cambio';

insert into gcv(gcvgcucod, gcvexr) values('USD', 1);

-------------------------------------------------
-- Conceptos de facturación

create table gcf (
    gcfcod      varchar(10) primary key,
    gcfnom      varchar(80) not null default '',
    gcfact      smallint not null default 0
);

comment on table gcf is             'Conceptos de facturación';
comment on column gcf.gcfcod is     'Código de concepto';
comment on column gcf.gcfnom is     'Descripción';
comment on column gcf.gcfact is     'Activo/inactivo';

insert into gcf values ('FLETE', 'FLETE');
insert into gcf values ('DETENCION', 'DETENCIÓN');
insert into gcf values ('DEMURRAGE', 'SOBREESTADÍA');

-------------------------------------------------
-- Configuración general

create table gxx (
    gxxcod      smallint primary key,
    gxxgcucod   varchar(5) not null,
    gxxgcfcod   varchar(10) not null
);

comment on table gxx is             'Configuración general';
comment on column gxx.gxxcod is     'Código cero';
comment on column gxx.gxxgcucod is  'Divisa del sistema';
comment on column gxx.gxxgcfcod is  'Código para facturación de flete';

alter table gxx add constraint gxx_fk_01 foreign key(gxxgcucod) references gcu(gcucod);

insert into gxx values(0, 'EUR', 'FLETE');

-------------------------------------------------
-- Usuario de instancia

create table usi (
    usiusrid    bigint primary key,
    usicod      varchar(80) not null default '',
    usinom      varchar(80) not null default '',
    usieml      text not null default ''
);

comment on table usi is             'Usuario de instancia';
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

insert into gtz(gtznom) values('Europe/Madrid');
insert into gtz(gtznom) values('Atlantic/Canary');

-------------------------------------------------
-- Países

create table gpa (
    gpacod      varchar(2) primary key,
    gpanom      varchar(200) not null default ''
);

comment on table gpa is         'Países';
comment on column gpa.gpacod is 'Código';
comment on column gpa.gpanom is 'Nombre';

insert into gpa values ('ES', 'ESPAÑA');

create table gpb (
    gpbid       bigserial primary key,
    gpbgpacod   varchar(2) not null default '',
    gpbgtzid    bigint not null default 0
);

comment on table gpb is             'Países, zonas horarias';
comment on column gpb.gpbid is      'Id. interno';
comment on column gpb.gpbgpacod is  'Código de país';
comment on column gpb.gpbgtzid is   'Código de timezone';

create index gpb_ix_01 on gpb(gpbgpacod);
create index gpb_ix_02 on gpb(gpbgpacod);

alter table gpb add constraint gpb_fk_01 foreign key(gpbgpacod) references gpa(gpacod);
alter table gpb add constraint gpb_fk_02 foreign key(gpbgtzid) references gtz(gtzid);

insert into gpb(gpbgpacod, gpbgtzid) values('ES', 1);
insert into gpb(gpbgpacod, gpbgtzid) values('ES', 2);

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
-- Unidades operativas

create table tuo (
    tuocod      varchar(10) primary key,
    tuonom      varchar(80) not null default '',
    tuodft      smallint not null default 0,
    tuoact      smallint not null default 0
);

comment on table tuo is             'Unidades operativas';
comment on column tuo.tuocod is     'Código de unidad';
comment on column tuo.tuonom is     'Descripción';
comment on column tuo.tuodft is     'Unidad por defecto';
comment on column tuo.tuoact is     'Activo/inactivo';

insert into tuo values ('CENTRAL', 'OFICINAS CENTRALES', 1, 1);
insert into tuo values ('ESCAT', 'CATALUÑA', 1, 1);

create table tup (
    tupid       bigserial primary key,
    tuprgl      varchar(20) not null default '',
    tuppri      int not null default 0,
    tuptuocod   varchar(10) not null default ''
);

comment on table tup is             'Unidades operativas, reglas';
comment on column tup.tupid is      'Id. interno';
comment on column tup.tuprgl is     'Regla de aplicación';
comment on column tup.tuppri is     'Prioridad de regla';
comment on column tup.tuptuocod is  'Código de unidad operativa';

create index tup_ix_01 on tup(tuptuocod);

alter table tup add constraint tup_fk_01 foreign key (tuptuocod) references tuo(tuocod);

insert into tup(tuprgl, tuppri, tuptuocod) values('ES08', 4, 'ESCAT');
insert into tup(tuprgl, tuppri, tuptuocod) values('ES17', 4, 'ESCAT');
insert into tup(tuprgl, tuppri, tuptuocod) values('ES25', 4, 'ESCAT');
insert into tup(tuprgl, tuppri, tuptuocod) values('ES43', 4, 'ESCAT');

-------------------------------------------------
-- Conductores

create table tco (
    tcoid       bigserial primary key,
    tconom      varchar(80) not null,
	tconif      varchar(20) not null,
	
	tcofe0		date not null default '0001-01-01',
	tcofe1		date not null default '0001-01-01',

	tcogprid	bigint not null,
    tcotuocod   varchar(10) not null default ''

);

comment on table tco is             'Conductores';
comment on column tco.tcoid is      'Id. interno';
comment on column tco.tconom is     'Nombre';
comment on column tco.tconif is     'Identificación fiscal';
comment on column tco.tcofe0 is     'Fecha desde';
comment on column tco.tcofe1 is     'Fecha hasta';
comment on column tco.tcogprid is 	'Código de proveedor';
comment on column tco.tcotuocod is  'Unidad operativa';

create index tco_ix_01 on tco(tcotuocod);
create index tco_ix_02 on tco(tcogprid);

alter table tco add constraint tco_fk_01 foreign key (tcotuocod) references tuo(tuocod);
alter table tco add constraint tco_fk_02 foreign key (tcogprid) references gpr(gprid);

-------------------------------------------------
-- Tractoras

create table ttr (
    ttrid       bigserial primary key,
    ttrmat      varchar(20) not null default '',
	ttrnfl		varchar(20) not null default '',
	
	ttrfe0		date not null default '0001-01-01',
	ttrfe1		date not null default '0001-01-01',

	ttrpr0id	bigint not null,
	ttrpr1id	bigint not null,
    ttrtuocod   varchar(10) not null default ''
);

comment on table ttr is             'Tractoras';
comment on column ttr.ttrid is      'Id. interno';
comment on column ttr.ttrmat is     'Matrícula';
comment on column ttr.ttrnfl is     'Número de flota';
comment on column ttr.ttrfe0 is     'Fecha desde';
comment on column ttr.ttrfe1 is     'Fecha hasta';
comment on column ttr.ttrpr0id is 	'Proveedor, transportista efectivo';
comment on column ttr.ttrpr1id is 	'Proveedor, pagar a';
comment on column ttr.ttrtuocod is  'Unidad operativa';

create index ttr_ix_01 on ttr(ttrtuocod);
create index ttr_ix_02 on ttr(ttrpr0id);
create index ttr_ix_03 on ttr(ttrpr1id);

alter table ttr add constraint ttr_fk_01 foreign key (ttrtuocod) references tuo(tuocod);
alter table ttr add constraint ttr_fk_02 foreign key (ttrpr0id) references gpr(gprid);
alter table ttr add constraint ttr_fk_03 foreign key (ttrpr1id) references gpr(gprid);

-------------------------------------------------
-- Remolques

create table tre (
    treid       bigserial primary key,
    tremat      varchar(20) not null default '',
	trenfl		varchar(20) not null default '',
	tretip		smallint not null default 0,

	trefe0		date not null default '0001-01-01',
	trefe1		date not null default '0001-01-01',

	tregprid	bigint not null,
    tretuocod   varchar(10) not null default ''

);

comment on table tre is             'Remolques';
comment on column tre.treid is      'Id. interno';
comment on column tre.tremat is     'Matrícula';
comment on column tre.trenfl is     'Número de flota';
comment on column tre.tretip is		'Tipo [0=Trailer, 1=Bogie]';
comment on column tre.trefe0 is     'Fecha desde';
comment on column tre.trefe1 is     'Fecha hasta';
comment on column tre.tregprid is  	'Código de proveedor';
comment on column tre.tretuocod is  'Unidad operativa';

create index tre_ix_01 on tre(tretuocod);
create index tre_ix_02 on tre(tregprid);

alter table tre add constraint tre_fk_01 foreign key (tretuocod) references tuo(tuocod);
alter table tre add constraint tre_fk_02 foreign key (tregprid) references gpr(gprid);

-------------------------------------------------
-- Contenedores

create table tcn (
    tcnid       bigserial primary key,
    tcnmat      varchar(20) not null,

	tcnfe0		date not null default '0001-01-01',
	tcnfe1		date not null default '0001-01-01',

	tcngprid	bigint not null,
    tcntuocod   varchar(10) not null default ''

);

comment on table tcn is             'Contenedores';
comment on column tcn.tcnid is      'Id. interno';
comment on column tcn.tcnmat is     'Matrícula';
comment on column tcn.tcnfe0 is     'Fecha desde';
comment on column tcn.tcnfe1 is     'Fecha hasta';
comment on column tcn.tcngprid is	'Código de proveedor';
comment on column tcn.tcntuocod is  'Unidad operativa';

create index tcn_ix_01 on tcn(tcntuocod);
create index tcn_ix_02 on tcn(tcngprid);

alter table tcn add constraint tcn_fk_01 foreign key (tcntuocod) references tuo(tuocod);
alter table tcn add constraint tcn_fk_02 foreign key (tcngprid) references gpr(gprid);

-------------------------------------------------
-- Tipos de paradas

create table ttp (
    ttpcod      varchar(5) not null primary key,
    ttpnom      varchar(80) not null default '',
	ttpcls		smallint not null default 0,
	ttpsgn		smallint not null default 0,
	ttpmin		smallint not null default 0,
	ttpmax		smallint not null default 0,
	ttpparttp	varchar(5),
	ttppardif	int not null default 0
);

comment on table ttp is             'Tipos de paradas';
comment on column ttp.ttpcod is     'Código';
comment on column ttp.ttpnom is     'Descripción';
comment on column ttp.ttpcls is     'Clase 0=Principal, 1=Auxiliar entrega, -1=Auxiliar retorno';
comment on column ttp.ttpsgn is     'Signo 0=Neutral, 1=Incrementa, -1=Decrementa';
comment on column ttp.ttpmin is     'Posición inicial válida [1,998]';
comment on column ttp.ttpmax is     'Posición final válida [2,999]';
comment on column ttp.ttpparttp is	'Tipo de parada automática';
comment on column ttp.ttppardif is	'Diferencia en segundos (0=No generar)';

create index ttp_ix_01 on ttp(ttpparttp);

alter table ttp add constraint ttp_fk_01 foreign key(ttpparttp) references ttp(ttpcod);

insert into ttp values ('REC', 'RECOGIDA'       , 0, 1, 1, 998, null, 0);
insert into ttp values ('ENT', 'ENTREGA'        , 0, -1, 2, 999, 'REC', 900);
insert into ttp values ('ENG', 'ENGANCHE'       , 1, 0, 3, 998, null, 0);
insert into ttp values ('DES', 'DESENGANCHE'    , 1, 0, 2, 997, 'ENG', 900);
insert into ttp values ('LCI', 'LAVADO CISTERNA', 1, 0, 1, 999, null, 0);

-------------------------------------------------
-- Direcciones de transporte por cliente

create table tdi (
    tdiid       bigserial primary key,
    tdigdiid    bigint not null,
    tdigclid    bigint not null,
    tdieid      varchar(20) not null,
    tdiobs      varchar(80) not null default '',
    tdiparttp   varchar(5),
    tdipardif   int not null default 0,	
    tdipareid   varchar(20) not null default ''
);

comment on table tdi is             'Direcciones por cliente';
comment on column tdi.tdiid is		'Id. de entrada';
comment on column tdi.tdigdiid is	'Id. de dirección';
comment on column tdi.tdigclid is	'Id. de cliente';
comment on column tdi.tdieid is     'Código externo';
comment on column tdi.tdiobs is     'Observaciones';
comment on column tdi.tdiparttp is  'Tipo de parada automática';
comment on column tdi.tdipardif is  'Diferencia en segundos (0=No generar)';
comment on column tdi.tdipareid is  'Código externo del lugar de parada';

create index tdi_ix_01 on tdi(tdigdiid);
create index tdi_ix_02 on tdi(tdigclid);
create index tdi_ix_03 on tdi(tdiparttp);

alter table tdi add constraint tdi_fk_01 foreign key(tdigdiid) references gdi(gdiid);
alter table tdi add constraint tdi_fk_02 foreign key(tdigclid) references gcl(gclid);
alter table tdi add constraint tdi_fk_03 foreign key(tdiparttp) references ttp(ttpcod);

-------------------------------------------------
-- Tipos de contenedores

create table ttc (
    ttccod      varchar(10) not null primary key,
    ttcnom      varchar(80) not null default '',
	ttclar		int not null default 0,
	ttctar		numeric(9,3) not null default 0,
	ttcpes		numeric(9,3) not null default 0,
	ttccub		numeric(9,2) not null default 0,
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

insert into ttc values ('DRY20', 'DRY 20 PIES', 20, 2300, 25000, 33.2, 5.9, 2.35, 2.39, 2.34, 2.28);
insert into ttc values ('DRY40', 'DRY 40 PIES', 40, 3750, 27600, 67.7, 12.03, 2.35, 2.39, 2.34, 2.28);

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
-- Cargas

create table tca (
    tcaid       bigserial primary key,

    -- estado operativo

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
    tcagcuexr   numeric(13, 6) not null default 0,

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

    -- origen
    tcaorgfec   date not null default '0001-01-01',
    tcaorgeid   varchar(20) not null default '',
    tcaorgnom   varchar(80) not null default '',
    tcaorgpcp   varchar(20) not null default '',
    tcaorgpob   varchar(80) not null default '',
    tcaorgtuo   varchar(10) not null default '',

    -- destino
    tcadesfec   date not null default '0001-01-01',
    tcadeseid   varchar(20) not null default '',
    tcadesnom   varchar(80) not null default '',
    tcadespcp   varchar(20) not null default '',
    tcadespob   varchar(80) not null default '',
    tcadestuo   varchar(10) not null default '',

    -- dimensiones logísticas
    tcadimplt   int not null default 0,        
    tcadimpes   numeric(7,2) not null default 0,
    tcadimcub   numeric(5,2) not null default 0,
    tcadimlar   numeric(5,2) not null default 0,
    tcadimalt   numeric(5,2) not null default 0,
    tcadimanc   numeric(5,2) not null default 0,

    -- estadísticas
    tcatpatot   smallint not null default 0,
    tcatpapdt   smallint not null default 0,
    tcaing      numeric(13,2) not null default 0,
    tcakmt      int not null default 0,
    tcaeuk      numeric(13,2) not null default 0

);

comment on table tca is             'Cargas';
comment on column tca.tcaid is      'Id. interno';

create index tca_ix_01 on tca(tcagclid);
create index tca_ix_02 on tca(tcagcleid);
create index tca_ix_03 on tca(tcagclraz);
create index tca_ix_04 on tca(tcagclnom);
create index tca_ix_05 on tca(tcagclnif);
create index tca_ix_06 on tca(tcagcucod);
create index tca_ix_07 on tca(tcaorgtuo);
create index tca_ix_08 on tca(tcadestuo);

alter table tca add constraint tca_fk_01 foreign key(tcagclid) references gcl(gclid);
alter table tca add constraint tca_fk_06 foreign key(tcagcucod) references gcu(gcucod);
alter table tca add constraint tca_fk_07 foreign key(tcaorgtuo) references tuo(tuocod);
alter table tca add constraint tca_fk_08 foreign key(tcadestuo) references tuo(tuocod);

-------------------------------------------------
-- Cargas, conceptos facturables

create table tcb (
    tcbid       bigserial primary key,
    tcbtcaid    bigint not null,
    tcbgcfcod   varchar(10) not null default '',
    tcbgcfnom   varchar(80) not null default '',

    -- falta estado administrativo

    --
    tcbpcd      numeric(5,2) not null default 0,
    tcbcan      numeric(13,2) not null default 0,

    tcbpun      numeric(13,2) not null default 0,
    tcbdto      numeric(13,2) not null default 0,
    tcbnet      numeric(13,2) not null default 0,
    tcbtot      numeric(13,2) not null default 0,

    tcbsispun   numeric(13,2) not null default 0,
    tcbsisdto   numeric(13,2) not null default 0,
    tcbsisnet   numeric(13,2) not null default 0,
    tcbsistot   numeric(13,2) not null default 0

);

comment on table tcb is             'Cargas, conceptos facturables';
comment on column tcb.tcbid is      'Id. interno';
comment on column tcb.tcbtcaid is   'Carga, id interno';
comment on column tcb.tcbgcfcod is  'Código de concepto';


create index tcb_ix_01 on tcb(tcbtcaid);

alter table tcb add constraint tcb_fk_01 foreign key (tcbtcaid) references tca(tcaid);


-------------------------------------------------
-- Transportes

create table tta (
    ttaid       bigserial primary key
);

comment on table tta is             'Transportes';
comment on column tta.ttaid is      'Id. de transporte';

-------------------------------------------------
-- Transportes, conceptos pagables

create table ttb (
    ttbid       bigserial primary key,
    ttbttaid    bigint not null,
    ttbgcfcod   varchar(10) not null default '',
    ttbgcfnom   varchar(80) not null default '',

    -- falta estado administrativo

    --
    ttbpcd      numeric(5,2) not null default 0,
    ttbcan      numeric(13,2) not null default 0,

    ttbpun      numeric(13,2) not null default 0,
    ttbdto      numeric(13,2) not null default 0,
    ttbnet      numeric(13,2) not null default 0,
    ttbtot      numeric(13,2) not null default 0,

    ttbsispun   numeric(13,2) not null default 0,
    ttbsisdto   numeric(13,2) not null default 0,
    ttbsisnet   numeric(13,2) not null default 0,
    ttbsistot   numeric(13,2) not null default 0

);

comment on table ttb is             'Transportes, conceptos facturables';
comment on column ttb.ttbid is      'Id. interno';
comment on column ttb.ttbttaid is   'Transporte, id interno';
comment on column ttb.ttbgcfcod is  'Código de concepto';


create index ttb_ix_01 on ttb(ttbttaid);

alter table ttb add constraint ttb_fk_01 foreign key (ttbttaid) references tta(ttaid);

-------------------------------------------------
-- Paradas

create table tpa (
    tpaid       bigserial primary key,

    tpatcaid    bigint not null,
    tpatcaseq   int not null default 0,
    tpare1      varchar(20) not null default '',
    tpare2      varchar(20) not null default '',
    tpare3      varchar(20) not null default '',
    tpare4      varchar(20) not null default '',    

    tpattaid    bigint,
    tpattaseq   int not null default 0,

    tpattpcod   varchar(5) not null default '',
    tpattpcls   smallint not null default 0,
    tpattpsgn   smallint not null default 0,

    -- dirección
    tpagdiid    bigint,
    tpagdieid   varchar(20) not null default '',
    tpagdinom   varchar(80) not null default '',
    tpagdidir   varchar(200) not null default '',
    tpagdicpo   varchar(20) not null default '',
    tpagdipob   varchar(80) not null default '',
    tpagdigpa   varchar(2) not null,
    tpagdigtz   bigint not null,
    tpagdipcp   varchar(20) not null default '',
    tpagdilat   varchar(20) not null default '',
    tpagdilon   varchar(20) not null default '',
    tpagditlf   varchar(20) not null default '',
    tpagdipdc   varchar(80) not null default '',
    tpagdieml   text not null default '',
    tpagdioea   smallint not null default 0,
    tpagdirmr   smallint not null default 0,

    -- dimensiones logísticas
    tpadimplt   int not null default 0,        
    tpadimpes   numeric(7,2) not null default 0,
    tpadimcub   numeric(5,2) not null default 0,

    -- fechas y planificación
    tpavisfec   date not null default '0001-01-01',

    tpasolfec   date not null default '0001-01-01',
    tpasolts0   timestamp not null default '0001-01-01T00:00:00',
    tpasolts1   timestamp not null default '0001-01-01T00:00:00',

    tpaplnfec   date not null default '0001-01-01',
    tpaplnts0   timestamp not null default '0001-01-01T00:00:00',
    tpaplnts1   timestamp not null default '0001-01-01T00:00:00',
    tpaplnmue   varchar(20) not null default '',

    tpaetatms   timestamp not null default '0001-01-01T00:00:00',
    tpapostms   timestamp not null default '0001-01-01T00:00:00',
    tpainitms   timestamp not null default '0001-01-01T00:00:00',
    tpafintms   timestamp not null default '0001-01-01T00:00:00'

);

comment on table tpa is             'Paradas';
comment on column tpa.tpaid is      'Id. de parada';
comment on column tpa.tpatcaid is   'Id. de carga';
comment on column tpa.tpattaid is   'Id. de transporte';
comment on column tpa.tpattpcod is  'Tipo de parada';
comment on column tpa.tpattpcls is  'Clase de parada';
comment on column tpa.tpattpsgn is  'Signo de parada';

create index tpa_ix_01 on tpa(tpatcaid);
create index tpa_ix_02 on tpa(tpattaid);
create index tpa_ix_03 on tpa(tpagdiid);

alter table tpa add constraint tpa_fk_01 foreign key (tpatcaid) references tca(tcaid);
alter table tpa add constraint tpa_fk_02 foreign key (tpattaid) references tta(ttaid);
alter table tpa add constraint tpa_fk_03 foreign key (tpagdiid) references gdi(gdiid);
;