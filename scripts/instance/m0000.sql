drop table if exists lang;

create table lang (
    code varchar(2) not null primary key,
    name varchar(40) not null
);

comment on table lang is 'Languages';
comment on column lang.code is 'Code';
comment on column lang.name is 'Name';
