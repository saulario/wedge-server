--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5 (Ubuntu 14.5-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.5 (Ubuntu 14.5-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cli; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cli (
    cliid bigint NOT NULL,
    clinom character varying(80) DEFAULT ''::character varying NOT NULL,
    cliact smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE cli; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.cli IS 'Clientes';


--
-- Name: COLUMN cli.cliid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cli.cliid IS 'Id. de cliente';


--
-- Name: COLUMN cli.clinom; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cli.clinom IS 'Nombre';


--
-- Name: COLUMN cli.cliact; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cli.cliact IS 'Activo/inactivo';


--
-- Name: cli_cliid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cli_cliid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cli_cliid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cli_cliid_seq OWNED BY public.cli.cliid;


--
-- Name: ins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ins (
    insid bigint NOT NULL,
    insnom character varying(80) DEFAULT ''::character varying NOT NULL,
    inscliid bigint DEFAULT 0 NOT NULL,
    insurl text DEFAULT ''::text NOT NULL,
    insact smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE ins; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ins IS 'Instancias';


--
-- Name: COLUMN ins.insid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ins.insid IS 'Id. secuencia';


--
-- Name: COLUMN ins.insnom; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ins.insnom IS 'Nombre';


--
-- Name: COLUMN ins.inscliid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ins.inscliid IS 'Id. de cliente';


--
-- Name: COLUMN ins.insurl; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ins.insurl IS 'Database URL';


--
-- Name: COLUMN ins.insact; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ins.insact IS 'Activo/inactivo';


--
-- Name: ins_insid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ins_insid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ins_insid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ins_insid_seq OWNED BY public.ins.insid;


--
-- Name: ses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ses (
    sescod character varying(40) NOT NULL,
    sesusrid bigint DEFAULT 0 NOT NULL,
    sesinsid bigint,
    sesfcr timestamp without time zone DEFAULT '0001-01-01 00:00:00'::timestamp without time zone NOT NULL,
    sesful timestamp without time zone DEFAULT '0001-01-01 00:00:00'::timestamp without time zone NOT NULL,
    sesact smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE ses; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ses IS 'Sesiones';


--
-- Name: COLUMN ses.sescod; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ses.sescod IS 'Código interno';


--
-- Name: COLUMN ses.sesusrid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ses.sesusrid IS 'Id. de usuario';


--
-- Name: COLUMN ses.sesinsid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ses.sesinsid IS 'Id. de instancia';


--
-- Name: COLUMN ses.sesfcr; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ses.sesfcr IS 'Fecha de creación';


--
-- Name: COLUMN ses.sesful; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ses.sesful IS 'Fecha de última modificación';


--
-- Name: COLUMN ses.sesact; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ses.sesact IS 'Activa/inactiva';


--
-- Name: sus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sus (
    susid bigint NOT NULL,
    sususrid bigint DEFAULT 0 NOT NULL,
    susinsid bigint DEFAULT 0 NOT NULL,
    susfcr timestamp without time zone DEFAULT '0001-01-01 00:00:00'::timestamp without time zone NOT NULL,
    susact smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE sus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.sus IS 'Suscripciones';


--
-- Name: COLUMN sus.susid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sus.susid IS 'Id. de suscripción';


--
-- Name: COLUMN sus.sususrid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sus.sususrid IS 'Id. de usuario';


--
-- Name: COLUMN sus.susinsid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sus.susinsid IS 'Id. de instancia';


--
-- Name: COLUMN sus.susfcr; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sus.susfcr IS 'Fecha de creación';


--
-- Name: COLUMN sus.susact; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sus.susact IS 'Activo/inactivo';


--
-- Name: sus_susid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sus_susid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sus_susid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sus_susid_seq OWNED BY public.sus.susid;


--
-- Name: usr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usr (
    usrid bigint NOT NULL,
    usrcod character varying(80) DEFAULT ''::character varying NOT NULL,
    usrnom character varying(80) DEFAULT ''::character varying NOT NULL,
    usrpwd character varying(80) DEFAULT ''::character varying NOT NULL,
    usrfcr timestamp without time zone DEFAULT '0001-01-01 00:00:00'::timestamp without time zone NOT NULL,
    usri18 character varying(10) DEFAULT ''::character varying NOT NULL,
    usract smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE usr; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.usr IS 'Usuarios';


--
-- Name: COLUMN usr.usrid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usr.usrid IS 'Id. secuencia';


--
-- Name: COLUMN usr.usrcod; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usr.usrcod IS 'Código de usuario';


--
-- Name: COLUMN usr.usrnom; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usr.usrnom IS 'Nombre';


--
-- Name: COLUMN usr.usrpwd; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usr.usrpwd IS 'Contraseña';


--
-- Name: COLUMN usr.usrfcr; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usr.usrfcr IS 'Fecha creación';


--
-- Name: COLUMN usr.usri18; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usr.usri18 IS 'Internacionalización';


--
-- Name: COLUMN usr.usract; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usr.usract IS 'Activo/inactivo';


--
-- Name: usr_usrid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usr_usrid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usr_usrid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.usr_usrid_seq OWNED BY public.usr.usrid;


--
-- Name: cli cliid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cli ALTER COLUMN cliid SET DEFAULT nextval('public.cli_cliid_seq'::regclass);


--
-- Name: ins insid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ins ALTER COLUMN insid SET DEFAULT nextval('public.ins_insid_seq'::regclass);


--
-- Name: sus susid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sus ALTER COLUMN susid SET DEFAULT nextval('public.sus_susid_seq'::regclass);


--
-- Name: usr usrid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usr ALTER COLUMN usrid SET DEFAULT nextval('public.usr_usrid_seq'::regclass);


--
-- Name: cli cli_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cli
    ADD CONSTRAINT cli_pkey PRIMARY KEY (cliid);


--
-- Name: ins ins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ins
    ADD CONSTRAINT ins_pkey PRIMARY KEY (insid);


--
-- Name: ses ses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ses
    ADD CONSTRAINT ses_pkey PRIMARY KEY (sescod);


--
-- Name: sus sus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sus
    ADD CONSTRAINT sus_pkey PRIMARY KEY (susid);


--
-- Name: usr usr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usr
    ADD CONSTRAINT usr_pkey PRIMARY KEY (usrid);


--
-- Name: ins_ix_01; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ins_ix_01 ON public.ins USING btree (inscliid);


--
-- Name: ses_ix_01; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ses_ix_01 ON public.ses USING btree (sesfcr);


--
-- Name: ses_ix_02; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ses_ix_02 ON public.ses USING btree (sesful);


--
-- Name: ses_ix_03; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ses_ix_03 ON public.ses USING btree (sesusrid);


--
-- Name: ses_ix_04; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ses_ix_04 ON public.ses USING btree (sesinsid);


--
-- Name: sus_ix_01; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sus_ix_01 ON public.sus USING btree (sususrid);


--
-- Name: sus_ix_02; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sus_ix_02 ON public.sus USING btree (susinsid);


--
-- Name: usr_ix_01; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX usr_ix_01 ON public.usr USING btree (usrcod);


--
-- Name: ins ins_fk_01; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ins
    ADD CONSTRAINT ins_fk_01 FOREIGN KEY (inscliid) REFERENCES public.cli(cliid);


--
-- Name: ses ses_fk_03; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ses
    ADD CONSTRAINT ses_fk_03 FOREIGN KEY (sesusrid) REFERENCES public.usr(usrid);


--
-- Name: ses ses_fk_04; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ses
    ADD CONSTRAINT ses_fk_04 FOREIGN KEY (sesinsid) REFERENCES public.ins(insid);


--
-- Name: sus sus_fk_01; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sus
    ADD CONSTRAINT sus_fk_01 FOREIGN KEY (sususrid) REFERENCES public.usr(usrid);


--
-- Name: sus sus_fk_02; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sus
    ADD CONSTRAINT sus_fk_02 FOREIGN KEY (susinsid) REFERENCES public.ins(insid);


--
-- PostgreSQL database dump complete
--

