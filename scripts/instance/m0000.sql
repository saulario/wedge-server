
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
drop table if exists ttd;
drop table if exists ttc;
drop table if exists ttb;
drop table if exists tta;
drop table if exists tdi;

drop table if exists txc;
drop table if exists txe;
drop table if exists txm;
drop table if exists txp;

drop table if exists tct;
drop table if exists tit;
drop table if exists tba;
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
    gcunom      varchar(80) not null,
	gcured		int not null default 0
);

comment on table gcu is             'Divisas';
comment on column gcu.gcucod is     'Código';
comment on column gcu.gcunom is     'Descripción';
comment on column gcu.gcured is     'Redondeo a decimales';

insert into gcu values ('EUR', 'EURO', 2);
insert into gcu values ('USD', 'US DOLAR', 2);

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
    gcfact      smallint not null default 0 check(gcfact in (0, 1))
);

comment on table gcf is             'Conceptos de facturación';
comment on column gcf.gcfcod is     'Código de concepto';
comment on column gcf.gcfnom is     'Descripción';
comment on column gcf.gcfact is     'Activo/inactivo';

insert into gcf values ('FLETE', 'FLETE', 1);
insert into gcf values ('DETENCION', 'DETENCIÓN', 1);
insert into gcf values ('DEMURRAGE', 'SOBREESTADÍA', 1);

-------------------------------------------------
-- Configuración general

create table gxx (
    gxxcod      smallint primary key,
    gxxgcucod   varchar(5) not null,
    gxxgcfcod   varchar(10) not null,
	gxxpundec	integer not null default 0
);

comment on table gxx is             'Configuración general';
comment on column gxx.gxxcod is     'Código cero';
comment on column gxx.gxxgcucod is  'Divisa del sistema';
comment on column gxx.gxxgcfcod is  'Código para facturación de flete';
comment on column gxx.gxxpundec is  'Precio unitario, redondeo a decimales';

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
	gclgeo		geography(POLYGON, 4326),
    gcltlf      varchar(20) not null default '',
    gclpdc      varchar(80) not null default '',
    gcleml      text not null default '',
    gclgcucod   varchar(5) not null default '',
    gclact      smallint not null default 0 check(gclact in (0, 1))
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
comment on column gcl.gclgeo is		'Geolocalización';
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
	gprgeo		geography(POLYGON, 4326),
    gprtlf      varchar(20) not null default '',
    gprpdc      varchar(80) not null default '',
    gpreml      text not null default '',
    gprgcucod   varchar(5) not null default '',
    gpract      smallint not null default 0 check(gpract in (0, 1))
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
comment on column gpr.gprgeo is		'Geolocalización';
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
    gdinif      varchar(20) not null default '',
    gdidir      varchar(200) not null default '',
    gdicpo      varchar(20) not null default '',
    gdipob      varchar(80) not null default '',
    gdigpacod   varchar(2) not null,
    gdigtzid    bigint not null,
	gdigeo		geography(POLYGON, 4326),
    gditlf      varchar(20) not null default '',
    gdipdc      varchar(80) not null default '',
    gdieml      text not null default '',
	gdihub		smallint not null default 0 check(gdihub in (0, 1)),
    gdioea      smallint not null default 0 check(gdioea in (0, 1)),
    gdirmr      smallint not null default 0 check(gdirmr in (0, 1)),
    gdiact      smallint not null default 0 check(gdiact in (0, 1))
);

comment on table gdi is             'Direcciones';
comment on column gdi.gdiid is		'Id. de dirección';
comment on column gdi.gdieid is		'Código externo';
comment on column gdi.gdinom is		'Nombre';
comment on column gdi.gdinif is     'NIF';
comment on column gdi.gdidir is		'Dirección';
comment on column gdi.gdicpo is		'Código postal';
comment on column gdi.gdipob is		'Población';
comment on column gdi.gdigpacod is  'Código de país';
comment on column gdi.gdigtzid is	'Id. de timezone';
comment on column gdi.gdigeo is		'Geolocalización';
comment on column gdi.gditlf is		'Teléfono';
comment on column gdi.gdipdc is		'Persona de contacto';
comment on column gdi.gdieml is		'Correo electrónico';
comment on column gdi.gdihub is		'Hub';
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
    tuodft      smallint not null default 0 check(tuodft in (0, 1)),
    tuoact      smallint not null default 0 check(tuoact in (0, 1))
);

comment on table tuo is             'Unidades operativas';
comment on column tuo.tuocod is     'Código de unidad';
comment on column tuo.tuonom is     'Descripción';
comment on column tuo.tuodft is     'Unidad por defecto';
comment on column tuo.tuoact is     'Activo/inactivo';

insert into tuo values ('CENTRAL', 'OFICINAS CENTRALES', 1, 1);
insert into tuo values ('ESCAT', 'CATALUÑA', 0, 1);

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
-- Barco/avión

create table tba (
	tbaid		bigserial primary key,
	tbanom		varchar(40) not null default '',
	tbamat		varchar(10) not null default '',
	tbatip		smallint not null default 0 check(tbatip in (0, 1)),
	
	tbafe0		date not null default '0001-01-01',
	tbafe1		date not null default '0001-01-01',

	tbapr0id	bigint not null,
	tbapr1id	bigint not null,
    tbatuocod   varchar(10) not null default ''	
	
);

comment on table tba is             'Barcos y aviones';
comment on column tba.tbaid is      'Id. interno';
comment on column tba.tbanom is		'Nombre o ruta';
comment on column tba.tbamat is		'Matrícula / IMO';
comment on column tba.tbatip is		'Tipo [0=Barco, 1=Avión]';
comment on column tba.tbafe0 is     'Fecha desde';
comment on column tba.tbafe1 is     'Fecha hasta';
comment on column tba.tbapr0id is 	'Proveedor, transportista efectivo';
comment on column tba.tbapr1id is 	'Proveedor, pagar a';
comment on column tba.tbatuocod is  'Unidad operativa';

create index tba_ix_01 on tba(tbatuocod);
create index tba_ix_02 on tba(tbapr0id);
create index tba_ix_03 on tba(tbapr1id);

alter table tba add constraint tba_fk_01 foreign key (tbatuocod) references tuo(tuocod);
alter table tba add constraint tba_fk_02 foreign key (tbapr0id) references gpr(gprid);
alter table tba add constraint tba_fk_03 foreign key (tbapr1id) references gpr(gprid);

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
	tretip		smallint not null default 0 check(tretip in (0, 1)),

	trefe0		date not null default '0001-01-01',
	trefe1		date not null default '0001-01-01',

	tregprid	bigint not null,
    tretuocod   varchar(10) not null default ''

);

comment on table tre is             'Remolques';
comment on column tre.treid is      'Id. interno';
comment on column tre.tremat is     'Matrícula';
comment on column tre.trenfl is     'Número de flota';
comment on column tre.tretip is		'Tipo [0=Trailer, 1=Dolly]';
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

create table txp (
    txpcod      varchar(5) not null primary key,
    txpnom      varchar(80) not null default '',
	txpcls		smallint not null default 0 check(txpcls in (-1, 0, 1)),
	txpsgn		smallint not null default 0 check(txpsgn in (-1, 0, 1)),
	txpmin		smallint not null default 0 check(txpmin between 0 and 998),
	txpmax		smallint not null default 0 check(txpmax between 1 and 999),
	txppartxp	varchar(5),
	txppardif	int not null default 0,
	txpact		smallint not null default 0 check(txpact in (0, 1))
);

comment on table txp is             'Tipos de paradas';
comment on column txp.txpcod is     'Código';
comment on column txp.txpnom is     'Descripción';
comment on column txp.txpcls is     'Clase 0=Principal, 1=Auxiliar entrega, -1=Auxiliar retorno';
comment on column txp.txpsgn is     'Signo 0=Neutral, 1=Incrementa, -1=Decrementa';
comment on column txp.txpmin is     'Posición inicial válida [0,998]';
comment on column txp.txpmax is     'Posición final válida [1,999]';
comment on column txp.txppartxp is	'Tipo de parada automática';
comment on column txp.txppardif is	'Diferencia en segundos (0=No generar)';
comment on column txp.txpact is		'Activo/inactivo';

create index txp_ix_01 on txp(txppartxp);

alter table txp add constraint txp_fk_01 foreign key(txppartxp) references txp(txpcod);

insert into txp values ('REC', 'RECOGIDA'       , 0,  1, 0, 998, null, 0, 1);
insert into txp values ('ENT', 'ENTREGA'        , 0, -1, 1, 999, 'REC', 900, 1);
insert into txp values ('ENG', 'ENGANCHE'       , 1,  0, 2, 998, null, 0, 1);
insert into txp values ('DES', 'DESENGANCHE'    , 1,  0, 1, 998, 'ENG', 900, 1);
insert into txp values ('LCI', 'LAVADO CISTERNA', 1,  0, 0, 999, null, 0, 1);

-------------------------------------------------
-- Tipos de contenedores

create table txc (
    txccod      varchar(10) not null primary key,
    txcnom      varchar(80) not null default '',
	txclar		int not null default 0,
	txctar		numeric(9,3) not null default 0,
	txcpes		numeric(9,3) not null default 0,
	txccub		numeric(9,2) not null default 0,
	txclai		numeric(5,2) not null default 0,
	txcani		numeric(5,2) not null default 0,
	txcali		numeric(5,2) not null default 0,
	txcana		numeric(5,2) not null default 0,
	txcala		numeric(5,2) not null default 0,
	txcact		smallint not null default 0 check(txcact in (0, 1))
);

comment on table txc is             'Tipos de contenedores';
comment on column txc.txccod is     'Código';
comment on column txc.txcnom is     'Descripción';
comment on column txc.txclar is     'Largo en pies';
comment on column txc.txctar is		'Tara';
comment on column txc.txcpes is		'Peso carga útil';
comment on column txc.txccub is		'Capacidad cúbica';
comment on column txc.txclai is		'Largo interno';
comment on column txc.txcani is 	'Ancho interno';
comment on column txc.txcali is		'Alto interno';
comment on column txc.txcana is		'Ancho apertura de puerta';
comment on column txc.txcala is		'Alto apertura de puerta';
comment on column txc.txcact is		'Activo/inactivo';

insert into txc values ('DRY20', 'DRY 20 PIES', 20, 2300, 25000, 33.2, 5.9, 2.35, 2.39, 2.34, 2.28, 1);
insert into txc values ('DRY40', 'DRY 40 PIES', 40, 3750, 27600, 67.7, 12.03, 2.35, 2.39, 2.34, 2.28, 1);

-------------------------------------------------
-- Clase de envío

create table txe (
	txecod		varchar(5) not null primary key,
	txenom		varchar(80) not null default '',
	txeact		smallint not null default 0 check(txeact in (0, 1))
);

comment on table txe is				'Tipos de envío';
comment on column txe.txecod is		'Código';
comment on column txe.txenom is		'Descripción';
comment on column txe.txeact is		'Activo/inactivo';

insert into txe values('FTL', 'FULL TRUCK LOAD', 1);
insert into txe values('LTL', 'LESS THAN TRUCK LOAD', 1);
insert into txe values('FCL', 'FULL CONTAINER LOAD', 1);
insert into txe values('LCL', 'LESS THAN CONTAINER LOAD', 1);

-------------------------------------------------
-- Tipos de mercancía

create table txm (
    txmcod      varchar(20) not null primary key,
    txmnom      varchar(80) not null default '',
    txmadr      smallint not null default 0 check(txmadr in (0, 1)),
    txmadrcls   varchar(10) not null default '',
    txmadrund   int not null default 0,
    txmadrflp   numeric(5,2) not null default 0,
    txmtmp      smallint not null default 0 check(txmtmp in (0, 1)),
    txmtmpstp   numeric(5,2) not null default 0,
    txmtmpmin   numeric(5,2) not null default 0,
    txmtmpmax   numeric(5,2) not null default 0,
	txmact		smallint not null default 0 check(txmact in (0, 1))
);

comment on table txm is             'Tipos de mercancías';
comment on column txm.txmcod is     'Código';
comment on column txm.txmnom is     'Descripción';
comment on column txm.txmadr is     'ADR, mercancía peligrosa';
comment on column txm.txmadrcls is  'ADR, clase';
comment on column txm.txmadrund is  'ADR, número UN';
comment on column txm.txmadrflp is  'ADR, punto inflamabilidad';
comment on column txm.txmtmp is     'TMP, temperatura controlada';
comment on column txm.txmtmpstp is  'TMP, set point';
comment on column txm.txmtmpmin is  'TMP, mínimo';
comment on column txm.txmtmpmax is  'TMP, máximo';
comment on column txm.txmact is 	'Activo/inactivo';

insert into txm values('GENERAL', 'CARGA SECA', 0, '', 0, 0, 0, 0, 0, 0, 1);
insert into txm values('FRA', 'FRIGO 0º', 0, '', 0, 0, 1, 0, -5, 5, 1);
insert into txm values('FRB', 'FRIGO -10º', 0, '', 0, 0, 1, -10, -15, -5, 1);
insert into txm values('FRC', 'FRIGO -20º', 0, '', 0, 0, 1, -20, -25, -15, 1);

-------------------------------------------------
-- Códigos TARIC

create table tct (
    tctcod      varchar(5) primary key,
    tctnom      text not null default '',
    tctact      smallint not null default 0 check(tctact in (0, 1))
);

comment on table tct is             'TARIC, códigos arancelarios';
comment on column tct.tctcod is     'Código';
comment on column tct.tctnom is     'Descripción';
comment on column tct.tctact is     'Activo/inactivo';

insert into tct values ('01', 'ANIMALES VIVOS', 1);
insert into tct values ('02', 'CARNE Y DESPOJOS COMESTIBLES', 1);
insert into tct values ('03', 'PESCADOS Y CRUSTÁCEOS; MOLUSCOS Y OTROS INVERTEBRADOS ACUÁTICOS', 1);
insert into tct values ('04', 'LECHE Y PRODUCTOS LÁCTEOS; HUEVOS DE AVE; MIEL NATURAL; PRODUCTOS COMESTIBLES DE ORIGEN ANIMAL NO EXPRESADOS NI COMPRENDIDOS EN OTROS CAPÍTULOS', 1);
insert into tct values ('05', 'LOS DEMÁS PRODUCTOS DE ORIGEN ANIMAL NO EXPRESADOS NI COMPRENDIDOS EN OTRA PARTE', 1);
insert into tct values ('06', 'PLANTAS VIVAS Y PRODUCTOS DE LA FLORICULTURA', 1);
insert into tct values ('07', 'LEGUMBRES Y HORTALIZAS, PLANTAS, RAÍCES Y TUBÉRCULOS ALIMENTICIOS', 1);
insert into tct values ('08', 'FRUTOS COMESTIBLES, CORTEZAS DE AGRIOS O DE MELONES', 1);
insert into tct values ('09', 'CAFÉ , TE, YERBA MATE Y ESPECIAS', 1);
insert into tct values ('10', 'CEREALES', 1);
insert into tct values ('11', 'PRODUCTOS DE LA MOLINERÍA, MALTA, ALMIDÓN Y FÉCULA, INULINA, GLUTEN DE TRIGO', 1);
insert into tct values ('12', 'SEMILLAS Y FRUTOS OLEAGINOSOS, SEMILLAS Y FRUTOS DIVERSOS, PLANTAS INDUSTRIALES O MEDICINALES, PAJA Y FORRAJES', 1);
insert into tct values ('13', 'GOMAS; RESINAS Y DEMÁS JUGOS Y EXTRACTOS VEGETALES', 1);
insert into tct values ('14', 'MATERIAS TRENZABLES Y DEMÁS PRODUCTOS DE ORIGEN VEGETAL; NO EXPRESADOS NI COMPRENDIDOS EN OTROS CAPÍTULOS', 1);
insert into tct values ('15', 'GRASAS Y ACEITES ANIMALES O VEGETALES, PRODUCTOS DE SU DESDOBLAMIENTO, GRASAS ALIMENTICIAS ELABORADAS, CERAS DE ORIGEN ANIMAL O VEGETAL', 1);
insert into tct values ('16', 'PREPARACIONES DE CARNE; DE PESCADO O DE CRUSTÁCEOS; DE MOLUSCOS O DE OTROS INVERTEBRADOS ACUÁTICOS', 1);
insert into tct values ('17', 'AZUCARES Y ARTÍCULOS DE CONFITERÍA', 1);
insert into tct values ('18', 'CACAO Y SUS PREPARACIONES', 1);
insert into tct values ('19', 'PREPARACIONES A BASE DE CEREALES, HARINA, ALMIDÓN, FÉCULA O LECHE, PRODUCTOS DE PASTELERÍA', 1);
insert into tct values ('20', 'PREPARACIONES DE LEGUMBRES U HORTALIZAS, DE FRUTOS O DE OTRAS PARTES DE PLANTAS', 1);
insert into tct values ('21', 'PREPARACIONES ALIMENTICIAS DIVERSAS', 1);
insert into tct values ('22', 'BEBIDAS, LÍQUIDOS ALCOHÓLICOS Y VINAGRE', 1);
insert into tct values ('23', 'RESIDUOS Y DESPERDICIOS DE LAS INDUSTRIAS ALIMENTARIAS, ALIMENTOS PREPARADOS PARA ANIMALES', 1);
insert into tct values ('24', 'TABACO Y SUCEDÁNEOS DEL TABACO; ELABORADOS', 1);
insert into tct values ('25', 'SAL, AZUFRE, TIERRAS Y PIEDRAS, YESOS, CALES Y CEMENTOS', 1);
insert into tct values ('26', 'MINERALES, ESCORIAS Y CENIZAS', 1);
insert into tct values ('27', 'COMBUSTIBLES MINERALES, ACEITES MINERALES Y PRODUCTOS DE SU DESTILACIÓN, MATERIAS BITUMINOSAS, CERAS MINERALES', 1);
insert into tct values ('28', 'PRODUCTOS QUÍMICOS INORGÁNICOS; COMPUESTOS INORGÁNICOS U ORGÁNICOS DE LOS METALES PRECIOSOS; DE LOS ELEMENTOS RADIACTIVOS; DE LOS METALES DE LAS TIERRAS RARAS O DE ISOTOPOS', 1);
insert into tct values ('29', 'PRODUCTOS QUÍMICOS ORGÁNICOS', 1);
insert into tct values ('30', 'PRODUCTOS FARMACÉUTICOS', 1);
insert into tct values ('31', 'ABONOS', 1);
insert into tct values ('32', 'EXTRACTOS CURTIENTES O TINTÓREOS; TANINOS Y SUS DERIVADOS; PIGMENTOS Y DEMÁS MATERIAS COLORANTES; PINTURAS Y BARNICES; MASTIQUES; TINTAS', 1);
insert into tct values ('33', 'ACEITES ESENCIALES Y RESINOIDES, PREPARACIONES DE PERFUMERÍA, DE TOCADOR O DE COSMÉTICA', 1);
insert into tct values ('34', 'JABONES; AGENTES DE SUPERFICIE ORGÁNICOS; PREPARACIONES PARA LAVAR; PREPARACIONES LUBRICANTES; CERAS ARTIFICIALES; CERAS PREPARADAS; PRODUCTOS DE LIMPIEZA; VELAS Y ARTÍCULOS SIMILARES; PASTA PARA MODELAR; »CERAS PARA ODONTOLOGÍA» Y PREPARACIONES PARA ODONTOLOGÍA A BASE DE YESO', 1);
insert into tct values ('35', 'MATERIAS ALBUMINOIDEAS, PRODUCTOS A BASE DE ALMIDÓN O DE FÉCULAS MODIFICADOS, COLAS, ENZIMAS', 1);
insert into tct values ('36', 'PÓLVORAS Y EXPLOSIVOS, ARTÍCULOS DE PIROTECNIA, FÓSFOROS (CERILLAS), ALEACIONES PIROFÓRICAS, MATERIAS FLAMABLES', 1);
insert into tct values ('37', 'PRODUCTOS FOTOGRÁFICOS O CINEMATOGRÁFICOS', 1);
insert into tct values ('38', 'PRODUCTOS DIVERSOS DE LAS INDUSTRIAS QUÍMICAS', 1);
insert into tct values ('39', 'MATERIAS PLÁSTICAS Y MANUFACTURAS DE ESTAS MATERIAS', 1);
insert into tct values ('40', 'CAUCHO Y MANUFACTURAS DE CAUCHO', 1);
insert into tct values ('41', 'PIELES (EXCEPTO LA PELETERÍA) Y CUEROS', 1);
insert into tct values ('42', 'MANUFACTURAS DE CUERO, ARTÍCULOS DE GUARNICIONERÍA O DE TALABARTERÍA, ARTÍCULOS DE VIAJE, BOLSOS DE MANO Y CONTINENTES SIMILARES, MANUFACTURAS DE TRIPA', 1);
insert into tct values ('43', 'PELETERÍA Y CONFECCIONES DE PELETERÍA, PELETERÍA ARTIFICIAL O FACTICIA', 1);
insert into tct values ('44', 'MADERA, CARBÓN VEGETAL Y MANUFACTURAS DE MADERA', 1);
insert into tct values ('45', 'CORCHO Y SUS MANUFACTURAS', 1);
insert into tct values ('46', 'MANUFACTURAS DE ESPARTERÍA O DE CESTERÍA', 1);
insert into tct values ('47', 'PASTA DE MADERA O DE OTRAS MATERIAS FIBROSAS CELULÓSICAS; RECUPERADAS, DESPERDICIOS Y DESECHOS DE PAPEL O CARTÓN', 1);
insert into tct values ('48', 'PAPEL Y CARTÓN, MANUFACTURAS DE PASTA DE CELULOSA, DE PAPEL O DE CARTÓN', 1);
insert into tct values ('49', 'PRODUCTOS EDITORIALES; DE LA PRENSA O DE OTRAS INDUSTRIAS GRAFICAS; TEXTOS MANUSCRITOS O MECANOGRAFIADOS Y PLANOS', 1);
insert into tct values ('50', 'SEDA', 1);
insert into tct values ('51', 'LANA Y PELO FINO U ORDINARIO, HILADOS Y TEJIDOS DE CRIN', 1);
insert into tct values ('52', 'ALGODÓN', 1);
insert into tct values ('53', 'LAS DEMÁS FIBRAS TEXTILES VEGETALES; HILADOS DE PAPEL Y TEJIDOS DE HILADOS DE PAPEL', 1);
insert into tct values ('54', 'FILAMENTOS SINTÉTICOS O ARTIFICIALES', 1);
insert into tct values ('55', 'FIBRAS SINTÉTICAS O ARTIFICIALES DISCONTINUAS', 1);
insert into tct values ('56', 'GUATA, FIELTRO Y TELAS SIN TEJER, HILADOS ESPECIALES, CORDELES, CUERDAS Y CORDAJES, ARTÍCULOS DE CORDELERÍA', 1);
insert into tct values ('57', 'ALFOMBRAS Y DEMÁS REVESTIMIENTOS PARA EL SUELO; DE MATERIAS TEXTILES', 1);
insert into tct values ('58', 'TEJIDOS ESPECIALES, SUPERFICIES TEXTILES CON PELO INSERTADO, ENCAJES, TAPICERÍA, PASAMANERÍA, BORDADOS', 1);
insert into tct values ('59', 'TEJIDOS IMPREGNADOS, RECUBIERTOS, REVESTIDOS O ESTRATIFICADOS, ARTÍCULOS TÉCNICOS DE MATERIAS TEXTILES', 1);
insert into tct values ('60', 'TEJIDOS DE PUNTO', 1);
insert into tct values ('61', 'PRENDAS Y COMPLEMENTOS DE VESTIR, DE PUNTO', 1);
insert into tct values ('62', 'PRENDAS Y COMPLEMENTOS DE VESTIR, EXCEPTO LOS DE PUNTO', 1);
insert into tct values ('63', 'LOS DEMÁS ARTÍCULOS TEXTILES CONFECCIONADOS; SURTIDOS; PRENDERÍA Y TRAPOS', 1);
insert into tct values ('64', 'CALZADO; POLAINAS; BOTINES Y ARTÍCULOS ANÁLOGOS; PARTES DE ESTOS ARTÍCULOS', 1);
insert into tct values ('65', 'ARTÍCULOS DE SOMBRERERÍA Y SUS PARTES', 1);
insert into tct values ('66', 'PARAGUAS; SOMBRILLAS; QUITASOLES; BASTONES-ASIENTO; LÁTIGOS; FUSTAS Y SUS PARTES', 1);
insert into tct values ('67', 'PLUMAS Y PLUMÓN PREPARADOS Y ARTÍCULOS DE PLUMAS O PLUMÓN, FLORES ARTIFICIALES, MANUFACTURAS DE CABELLOS', 1);
insert into tct values ('68', 'MANUFACTURAS DE PIEDRA; YESO; CEMENTO; AMIANTO; MICA O MATERIAS ANÁLOGAS', 1);
insert into tct values ('69', 'PRODUCTOS CERÁMICOS', 1);
insert into tct values ('70', 'VIDRIO Y MANUFACTURAS DE VIDRIO', 1);
insert into tct values ('71', 'PERLAS FINAS O CULTIVADAS, PIEDRAS PRECIOSAS Y SEMIPRECIOSAS O SIMILARES, METALES PRECIOSOS, CHAPADOS DE METALES PRECIOSOS Y MANUFACTURAS DE ESTAS MATERIAS; BISUTERÍA; MONEDAS', 1);
insert into tct values ('72', 'FUNDICIÓN, HIERRO Y ACERO', 1);
insert into tct values ('73', 'MANUFACTURAS DE FUNDICIÓN, DE HIERRO O DE ACERO', 1);
insert into tct values ('74', 'COBRE Y MANUFACTURAS DE COBRE', 1);
insert into tct values ('75', 'NÍQUEL Y MANUFACTURAS DE NÍQUEL', 1);
insert into tct values ('76', 'ALUMINIO Y MANUFACTURAS DE ALUMINIO', 1);
insert into tct values ('78', 'PLOMO Y MANUFACTURAS DE PLOMO', 1);
insert into tct values ('79', 'CINC Y MANUFACTURAS DE CINC', 1);
insert into tct values ('80', 'ESTAÑO Y MANUFACTURAS DE ESTAÑO', 1);
insert into tct values ('81', 'LOS DEMÁS METALES COMUNES; »CERMETS»; MANUFACTURAS DE ESTAS MATERIAS', 1);
insert into tct values ('82', 'HERRAMIENTAS Y ÚTILES ARTÍCULOS DE CUCHILLERÍA Y CUBIERTOS DE MESA, DE METALES COMUNES, PARTES DE ESTOS ARTÍCULOS, DE METALES COMUNES', 1);
insert into tct values ('84', 'REACTORES NUCLEARES; CALDERAS; MAQUINAS; APARATOS Y ARTEFACTOS MECÁNICOS; PARTES DE ESTAS MAQUINAS O APARATOS', 1);
insert into tct values ('85', 'MÁQUINAS; APARATOS Y MATERIAL ELÉCTRICO Y SUS PARTES; APARATOS DE GRABACIÓN O REPRODUCCIÓN DE SONIDO; APARATOS DE GRABACIÓN O REPRODUCCIÓN DE IMÁGENES Y SONIDO EN TELEVISIÓN; Y LAS PARTES Y ACCESORIOS DE ESOS APARATOS', 1);
insert into tct values ('86', 'VEHÍCULOS Y MATERIAL PARA VÍAS FÉRREAS O SIMILARES Y SUS PARTES; APARATOS MECÁNICOS (INCLUSO ELECTROMECÁNICOS) DE SEÑALIZACIÓN PARA VÍAS DE COMUNICACIÓN', 1);
insert into tct values ('87', 'VEHÍCULOS AUTOMÓVILES; TRACTORES; CICLOS Y DEMÁS VEHÍCULOS TERRESTRES; SUS PARTES Y ACCESORIOS', 1);
insert into tct values ('88', 'NAVEGACIÓN AÉREA O ESPACIAL', 1);
insert into tct values ('89', 'NAVEGACIÓN MARÍTIMA O FLUVIAL', 1);
insert into tct values ('90', 'INSTRUMENTOS Y APARATOS DE ÓPTICA, FOTOGRAFÍA O CINEMATOGRAFÍA, DE MEDIDA, CONTROL O DE PRECISIÓN, INSTRUMENTOS Y APARATOS MEDICO QUIRÚRGICOS, PARTES DE ESTOS INSTRUMENTOS O APARATOS', 1);
insert into tct values ('91', 'RELOJERÍA', 1);
insert into tct values ('92', 'INSTRUMENTOS MUSICALES, PARTES Y ACCESORIOS DE ESTOS INSTRUMENTOS', 1);
insert into tct values ('93', 'ARMAS Y MUNICIONES Y SUS PARTES Y ACCESORIOS', 1);
insert into tct values ('94', 'MUEBLES, MOBILIARIO MÉDICO QUIRÚRGICO, ARTÍCULOS DE CAMA Y SIMILARES, APARATOS DE ALUMBRADO NO EXPRESADOS NI COMPRENDIDOS EN OTROS CAPÍTULOS, ANUNCIOS, LETREROS Y PLACAS INDICADORAS, LUMINOSOS, Y ARTÍCULOS SIMILARES, CONSTRUCCIONES PREFABRICADAS', 1);
insert into tct values ('95', 'JUGUETES, JUEGOS Y ARTÍCULOS PARA RECREO O PARA DEPORTE, PARTES Y ACCESORIOS', 1);
insert into tct values ('97', 'OBJETOS DE ARTE; DE COLECCIÓN O DE ANTIGÜEDAD', 1);
insert into tct values ('99', 'ENVÍOS FORMADOS POR UN CONJUNTO HETEROGÉNEO DE MERCANCÍAS AFORABLES POR DIFERENTES PARTIDAS ARANCELARIAS Y SUPUESTOS NO CONTEMPLADOS EN EL ARANCEL ADUANERO ESPECÍFICAMENTE', 1);

-------------------------------------------------
-- Incoterm

create table tit (
    titcod      varchar(5) primary key,
    titnom      varchar(80) not null default '',
	titact		smallint not null default 0 check(titact in (0, 1))
);

comment on table tit is             'Incoterm';
comment on column tit.titcod is     'Código';
comment on column tit.titnom is     'Descripción';
comment on column tit.titact is     'Activo/inactivo';

insert into tit values('EXW', 'EX WORKS', 1);
insert into tit values('FAS', 'FREE ALONGSIDE SHIP', 1);
insert into tit values('FOB', 'FREE ON BOARD', 1);
insert into tit values('FCA', 'FREE CARRIER', 1);
insert into tit values('CFR', 'COST AND FREIGHT', 1);
insert into tit values('CIF', 'COST, INSURANCE AND FREIGHT', 1);
insert into tit values('CPT', 'CARRIAGE PAID TO', 1);
insert into tit values('CIP', 'CARRIAGE AND INSURANCE PAID', 1);
insert into tit values('DPU', 'DELIVERED AT PLACE AND UNLOADED', 1);
insert into tit values('DAP', 'DELIVERED AT PLACE', 1);
insert into tit values('DDP', 'DELIVERED DUTY PAID', 1);

-------------------------------------------------
-- Direcciones de transporte por cliente

create table tdi (
    tdiid       bigserial primary key,
    tdigdiid    bigint not null,
    tdigclid    bigint not null,
    tdieid      varchar(20) not null,
    tdiobs      varchar(80) not null default '',
	tditxmcod	varchar(20),
	tditxecod	varchar(5),
    tditctcod   varchar(5),
    tdititcod   varchar(5),
    tdipartxp   varchar(5),
    tdipardif   int not null default 0,	
    tdipareid   varchar(20) not null default ''
);

comment on table tdi is             'Direcciones por cliente';
comment on column tdi.tdiid is		'Id. de entrada';
comment on column tdi.tdigdiid is	'Id. de dirección';
comment on column tdi.tdigclid is	'Id. de cliente';
comment on column tdi.tdieid is     'Código externo';
comment on column tdi.tdiobs is     'Observaciones';
comment on column tdi.tditxmcod is	'Tipo de mercancía';
comment on column tdi.tditxecod is	'Tipo de envío';
comment on column tdi.tditctcod is  'Código TARIC';
comment on column tdi.tdititcod is  'Incoterm';
comment on column tdi.tdipartxp is  'Tipo de parada automática';
comment on column tdi.tdipardif is  'Diferencia en segundos (0=No generar)';
comment on column tdi.tdipareid is  'Código externo del lugar de parada';

create index tdi_ix_01 on tdi(tdigdiid);
create index tdi_ix_02 on tdi(tdigclid);
create index tdi_ix_03 on tdi(tdipartxp);
create index tdi_ix_04 on tdi(tditxmcod);
create index tdi_ix_05 on tdi(tditxecod);
create index tdi_ix_06 on tdi(tditctcod);
create index tdi_ix_07 on tdi(tdititcod);

alter table tdi add constraint tdi_fk_01 foreign key(tdigdiid) references gdi(gdiid);
alter table tdi add constraint tdi_fk_02 foreign key(tdigclid) references gcl(gclid);
alter table tdi add constraint tdi_fk_03 foreign key(tdipartxp) references txp(txpcod);
alter table tdi add constraint tdi_fk_04 foreign key(tditxmcod) references txm(txmcod);
alter table tdi add constraint tdi_fk_05 foreign key(tditxecod) references txe(txecod);
alter table tdi add constraint tdi_fk_06 foreign key(tditctcod) references tct(tctcod);
alter table tdi add constraint tdi_fk_07 foreign key(tdititcod) references tit(titcod);

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

    -- tipo de mercancía
    tcatxmcod   varchar(20) not null default '',
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
create index tca_ix_07 on tca(tcaorgtuo);
create index tca_ix_08 on tca(tcadestuo);

alter table tca add constraint tca_fk_01 foreign key(tcagclid) references gcl(gclid);
alter table tca add constraint tca_fk_07 foreign key(tcaorgtuo) references tuo(tuocod);
alter table tca add constraint tca_fk_08 foreign key(tcadestuo) references tuo(tuocod);

-------------------------------------------------
-- Cargas, conceptos facturables

create table tcb (
    tcbid       bigserial primary key,
    tcbtcaid    bigint not null,

    tcbgclid    bigint not null default 0,
    tcbgcleid   varchar(20) not null default '',
    tcbgclraz   varchar(80) not null default '',
    tcbgclnif   varchar(20) not null default '',	
    tcbgcucod   varchar(5) not null default '',
	tcbgcufec	date not null default '0001-01-01',
    tcbgcuexr   numeric(13, 6) default 0,
    tcbgcfcod   varchar(10) not null default '',
    tcbgcfnom   varchar(80) not null default '',

    -- falta estado administrativo
    --
    tcbpcd      numeric(5,2) not null default 0,
    tcbcan      numeric(13,3) not null default 0,
    tcbpun      numeric(13,6) not null default 0,
    tcbdto      numeric(13,6) not null default 0,
    tcbnet      numeric(13,6) not null default 0,
    tcbtot      numeric(13,2) not null default 0,
    tcbsispun   numeric(13,6) not null default 0,
    tcbsisdto   numeric(13,6) not null default 0,
    tcbsisnet   numeric(13,6) not null default 0,
    tcbsistot   numeric(13,2) not null default 0

);

comment on table tcb is             'Cargas, conceptos facturables';
comment on column tcb.tcbid is      'Id. interno';
comment on column tcb.tcbtcaid is   'Carga, id interno';
comment on column tcb.tcbgclid is 	'Cliente, id';
comment on column tcb.tcbgcleid is 	'Cliente, código externo';
comment on column tcb.tcbgclraz is 	'Cliente, razón social';
comment on column tcb.tcbgclnif is 	'Cliente, NIF';
comment on column tcb.tcbgcucod is  'Divisa, código';
comment on column tcb.tcbgcufec is  'Divisa, fecha de cambio';
comment on column tcb.tcbgcuexr is  'Divisa, tipo de cambio';
comment on column tcb.tcbgcfcod is  'Concepto, código';
comment on column tcb.tcbgcfnom is  'Concepto, descripción';
comment on column tcb.tcbpcd is		'Descuento, porcentaje';
comment on column tcb.tcbcan is		'Cantidad a facturar';
comment on column tcb.tcbpun is		'Precio unitario';
comment on column tcb.tcbdto is		'Importe descuento';
comment on column tcb.tcbnet is		'Precio unitario neto';
comment on column tcb.tcbtot is		'Importe total';
comment on column tcb.tcbsispun is	'Precio unitario LCY';
comment on column tcb.tcbsisdto is	'Importe descuento LCY';
comment on column tcb.tcbsisnet is	'Precio unitario neto LCY';
comment on column tcb.tcbsistot is	'Importe total LCY';

create index tcb_ix_01 on tcb(tcbtcaid);
create index tcb_ix_02 on tcb(tcbgclid);
create index tcb_ix_03 on tcb(tcbgcucod);
create index tcb_ix_04 on tcb(tcbgcfcod);

alter table tcb add constraint tcb_fk_01 foreign key (tcbtcaid) references tca(tcaid);
alter table tcb add constraint tcb_fk_02 foreign key (tcbgclid) references gcl(gclid);
alter table tcb add constraint tcb_fk_03 foreign key (tcbgcucod) references gcu(gcucod);
alter table tcb add constraint tcb_fk_04 foreign key (tcbgcfcod) references gcf(gcfcod);


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
	
    ttbgprid    bigint not null default 0,
    ttbgpreid   varchar(20) not null default '',
    ttbgprraz   varchar(80) not null default '',
    ttbgprnif   varchar(20) not null default '',	

    ttbgcucod   varchar(5) not null default '',
	ttbgcufec	date not null default '0001-01-01',
    ttbgcuexr   numeric(13, 6) default 0,
	
    ttbgcfcod   varchar(10) not null default '',
    ttbgcfnom   varchar(80) not null default '',

    -- falta estado administrativo
    --
    ttbpcd      numeric(5,2) not null default 0,
    ttbcan      numeric(13,3) not null default 0,

    ttbpun      numeric(13,6) not null default 0,
    ttbdto      numeric(13,6) not null default 0,
    ttbnet      numeric(13,6) not null default 0,
    ttbtot      numeric(13,2) not null default 0,

    ttbsispun   numeric(13,6) not null default 0,
    ttbsisdto   numeric(13,6) not null default 0,
    ttbsisnet   numeric(13,6) not null default 0,
    ttbsistot   numeric(13,2) not null default 0

);

comment on table ttb is             'Transportes, conceptos facturables';
comment on column ttb.ttbid is      'Id. interno';
comment on column ttb.ttbgprid is 	'Proveedor, id';
comment on column ttb.ttbgpreid is 	'Proveedor, código externo';
comment on column ttb.ttbgprraz is 	'Proveedor, razón social';
comment on column ttb.ttbgprnif is 	'Proveedor, NIF';
comment on column ttb.ttbgcucod is  'Divisa, código';
comment on column ttb.ttbgcufec is  'Divisa, fecha de cambio';
comment on column ttb.ttbgcuexr is  'Divisa, tipo de cambio';
comment on column ttb.ttbgcfcod is  'Concepto, código';
comment on column ttb.ttbgcfnom is  'Concepto, descripción';
comment on column ttb.ttbpcd is		'Descuento, porcentaje';
comment on column ttb.ttbcan is		'Cantidad a facturar';
comment on column ttb.ttbpun is		'Precio unitario';
comment on column ttb.ttbdto is		'Importe descuento';
comment on column ttb.ttbnet is		'Precio unitario neto';
comment on column ttb.ttbtot is		'Importe total';
comment on column ttb.ttbsispun is	'Precio unitario LCY';
comment on column ttb.ttbsisdto is	'Importe descuento LCY';
comment on column ttb.ttbsisnet is	'Precio unitario neto LCY';
comment on column ttb.ttbsistot is	'Importe total LCY';

create index ttb_ix_01 on ttb(ttbttaid);
create index ttb_ix_02 on ttb(ttbgprid);
create index ttb_ix_03 on ttb(ttbgcucod);
create index ttb_ix_04 on ttb(ttbgcfcod);

alter table ttb add constraint ttb_fk_01 foreign key (ttbttaid) references tta(ttaid);
alter table ttb add constraint ttb_fk_02 foreign key (ttbgprid) references gpr(gprid);
alter table ttb add constraint ttb_fk_03 foreign key (ttbgcucod) references gcu(gcucod);
alter table ttb add constraint ttb_fk_04 foreign key (ttbgcfcod) references gcf(gcfcod);

-------------------------------------------------
-- Transportes, conductores

create table ttc (
	ttcid		bigserial primary key,
	ttcttaid	bigint not null,
	ttcpos		integer not null default 0 check(ttcpos in (0, 1)),
	ttctcoid	bigint,
	ttctconom	varchar(80) not null default '',
	ttctconif	varchar(20) not null default ''
);

comment on table ttc is				'Transportes, conductores';
comment on column ttc.ttcid is		'Id. interno';
comment on column ttc.ttcttaid is	'Id. de transporte';
comment on column ttc.ttcpos is		'Posición [0, 1]';
comment on column ttc.ttctcoid is	'Conductor, id';
comment on column ttc.ttctconom is	'Conductor, nombre';
comment on column ttc.ttctconif is	'Conductor, NIF';

create index ttc_ix_01 on ttc(ttcttaid);
create index ttc_ix_02 on ttc(ttctcoid);

alter table ttc add constraint ttc_fk_01 foreign key(ttcttaid) references tta(ttaid);
alter table ttc add constraint ttc_fk_02 foreign key(ttctcoid) references tco(tcoid);

-------------------------------------------------
-- Transportes, remolques

create table ttd (
	ttdid		bigserial primary key,
	ttdttaid	bigint not null,
	ttdpos		integer not null default 0 check(ttdpos between 0 and 2),
	ttdtreid	bigint,
	ttdtremat	varchar(20) not null default '',
	ttdtrenfl	varchar(20) not null default ''
);

comment on table ttd is				'Transportes, remolques';
comment on column ttd.ttdid is		'Id. interno';
comment on column ttd.ttdttaid is	'Id. de transporte';
comment on column ttd.ttdpos is		'Posición [0, 1, 2]';
comment on column ttd.ttdtreid is	'Tractora, id';
comment on column ttd.ttdtremat is	'Tractora, matrícula';
comment on column ttd.ttdtrenfl is	'Tractora, número de flota';

create index ttd_ix_01 on ttd(ttdttaid);
create index ttd_ix_02 on ttd(ttdtreid);

alter table ttd add constraint ttd_fk_01 foreign key(ttdttaid) references tta(ttaid);
alter table ttd add constraint ttd_fk_02 foreign key(ttdtreid) references tre(treid);

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

    tpatxpcod   varchar(5) not null default '',
    tpatxpcls   smallint not null default 0,
    tpatxpsgn   smallint not null default 0,

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
	tpagdigeo	geography(POLYGON, 4326),
    tpagditlf   varchar(20) not null default '',
    tpagdipdc   varchar(80) not null default '',
    tpagdieml   text not null default '',
	tpagdihub	smallint not null default 0 check(tpagdihub in (0, 1)),
    tpagdioea   smallint not null default 0 check(tpagdioea in (0, 1)),
    tpagdirmr   smallint not null default 0 check(tpagdirmr in (0, 1)),

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
comment on column tpa.tpatxpcod is  'Tipo de parada';
comment on column tpa.tpatxpcls is  'Clase de parada';
comment on column tpa.tpatxpsgn is  'Signo de parada';

create index tpa_ix_01 on tpa(tpatcaid);
create index tpa_ix_02 on tpa(tpattaid);
create index tpa_ix_03 on tpa(tpagdiid);

alter table tpa add constraint tpa_fk_01 foreign key (tpatcaid) references tca(tcaid);
alter table tpa add constraint tpa_fk_02 foreign key (tpattaid) references tta(ttaid);
alter table tpa add constraint tpa_fk_03 foreign key (tpagdiid) references gdi(gdiid);
;