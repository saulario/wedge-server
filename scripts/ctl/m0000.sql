drop table if exists account;
create table account (
    id bigserial not null primary key,
    username varchar(80) not null,
    email varchar(255) not null,
    pass varchar(255) not null,
    active smallint not null,
    creation_date timestamp not null
);

create index account_ix_01 on account(username);

comment on table account is 'Accounts';
comment on column account.id is 'Id, sequence';
comment on column account.username is 'User name';
comment on column account.email is 'E-mail';
comment on column account.pass is 'Encrypted password';
comment on column account.active is 'Active/inactive';
comment on column account.creation_date is 'Creation date';
