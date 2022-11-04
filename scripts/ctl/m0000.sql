drop table if exists sus;
drop table if exists ses;

drop table if exists ins;
drop table if exists cli;
drop table if exists usr;

-------------------------------------------------
-- usuarios

create table usr (
        usrid           bigserial primary key,
        usrcod          varchar(80) not null default '',
        usrnom          varchar(80) not null default '',
        usrpwd          varchar(80) not null default '',
        usrfcr          timestamp not null default '0001-01-01T00:00:00',
        usri18          varchar(10) not null default '',
        usreml          text not null default '',
        usract          smallint not null default 0
);

comment on table usr is         'Usuarios';
comment on column usr.usrid is  'Id. secuencia';
comment on column usr.usrcod is 'Código de usuario';
comment on column usr.usrnom is 'Nombre';
comment on column usr.usrpwd is 'Contraseña';
comment on column usr.usrfcr is 'Fecha creación';
comment on column usr.usri18 is 'Internacionalización';
comment on column usr.usreml is 'Correo electrónico';
comment on column usr.usract is 'Activo/inactivo';

create unique index usr_ix_01 on usr(usrcod);

-------------------------------------------------
-- clientes

create table cli (
    cliid       bigserial primary key,
    clinom      varchar(80) not null default '',
    cliact      smallint not null default 0
);

comment on table cli is         'Clientes';
comment on column cli.cliid is  'Id. de cliente';
comment on column cli.clinom is 'Nombre';
comment on column cli.cliact is 'Activo/inactivo';

-------------------------------------------------
-- instancias

create table ins (
    insid       bigserial primary key,
    insnom      varchar(80) not null default '',
    inscliid    bigint not null default 0,
    insurl      text not null default '',
    insact      smallint not null default 0
);

comment on table ins is             'Instancias';
comment on column ins.insid is      'Id. secuencia';
comment on column ins.insnom is     'Nombre';
comment on column ins.inscliid is   'Id. de cliente';
comment on column ins.insurl is     'Database URL';
comment on column ins.insact is     'Activo/inactivo';

create index ins_ix_01 on ins(inscliid);

alter table ins add constraint ins_fk_01 foreign key(inscliid) references cli(cliid);

-------------------------------------------------
-- suscripciones

create table sus (
    susid       bigserial primary key,
    sususrid    bigint not null default 0,
    susinsid    bigint not null default 0,
    susfcr      timestamp not null default '0001-01-01T00:00:00',
    susact      smallint not null default 0
);

comment on table sus is             'Suscripciones';
comment on column sus.susid is      'Id. de suscripción';
comment on column sus.sususrid is   'Id. de usuario';
comment on column sus.susinsid is   'Id. de instancia';
comment on column sus.susfcr is     'Fecha de creación';
comment on column sus.susact is     'Activo/inactivo';

create index sus_ix_01 on sus(sususrid);
create index sus_ix_02 on sus(susinsid);

alter table sus add constraint sus_fk_01 foreign key(sususrid) references usr(usrid);
alter table sus add constraint sus_fk_02 foreign key(susinsid) references ins(insid);

-------------------------------------------------
-- sesiones

create table ses (
    sescod      varchar(40) not null primary key,
    sesusrid    bigint not null default 0,
    sesinsid    bigint,
    sesfcr      timestamp not null default '0001-01-01T00:00:00',
    sesful      timestamp not null default '0001-01-01T00:00:00',
    sesact      smallint not null default 0
);

comment on table ses is             'Sesiones';
comment on column ses.sescod is     'Código interno';
comment on column ses.sesusrid is   'Id. de usuario';
comment on column ses.sesinsid is   'Id. de instancia';
comment on column ses.sesfcr is     'Fecha de creación';
comment on column ses.sesful is     'Fecha de última modificación';
comment on column ses.sesact is     'Activa/inactiva';

create index ses_ix_01 on ses(sesfcr);
create index ses_ix_02 on ses(sesful);
create index ses_ix_03 on ses(sesusrid);
create index ses_ix_04 on ses(sesinsid);

alter table ses add constraint ses_fk_03 foreign key(sesusrid) references usr(usrid);
alter table ses add constraint ses_fk_04 foreign key(sesinsid) references ins(insid);



