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

--
-- Name: employment_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.employment_status AS ENUM (
    'active',
    'terminated'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.countries (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    iso_code character varying(2) NOT NULL,
    currency_id bigint NOT NULL
);


--
-- Name: COLUMN countries.iso_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.countries.iso_code IS 'ISO 3166-1 alpha-2';


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.countries_id_seq OWNED BY public.countries.id;


--
-- Name: currencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.currencies (
    id bigint NOT NULL,
    code character varying(3) NOT NULL,
    name character varying(100) NOT NULL
);


--
-- Name: COLUMN currencies.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currencies.code IS 'ISO 4217: USD, INR, GBP';


--
-- Name: currencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.currencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: currencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.currencies_id_seq OWNED BY public.currencies.id;


--
-- Name: departments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departments (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.departments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.departments_id_seq OWNED BY public.departments.id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employees (
    id bigint NOT NULL,
    employee_number character varying(50) NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    email character varying(255) NOT NULL,
    country_id bigint NOT NULL,
    department_id bigint NOT NULL,
    job_title_id bigint NOT NULL,
    employment_level_id bigint NOT NULL,
    manager_id bigint,
    employment_status public.employment_status NOT NULL,
    hire_date date NOT NULL,
    termination_date date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.employees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;


--
-- Name: employment_levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employment_levels (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    rank integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: employment_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.employment_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: employment_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.employment_levels_id_seq OWNED BY public.employment_levels.id;


--
-- Name: job_title_levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_title_levels (
    id bigint NOT NULL,
    job_title_id bigint NOT NULL,
    employment_level_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: job_title_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.job_title_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_title_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_title_levels_id_seq OWNED BY public.job_title_levels.id;


--
-- Name: job_titles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_titles (
    id bigint NOT NULL,
    title character varying(150) NOT NULL,
    description text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: job_titles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.job_titles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_titles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_titles_id_seq OWNED BY public.job_titles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: countries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries ALTER COLUMN id SET DEFAULT nextval('public.countries_id_seq'::regclass);


--
-- Name: currencies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currencies ALTER COLUMN id SET DEFAULT nextval('public.currencies_id_seq'::regclass);


--
-- Name: departments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.departments_id_seq'::regclass);


--
-- Name: employees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);


--
-- Name: employment_levels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employment_levels ALTER COLUMN id SET DEFAULT nextval('public.employment_levels_id_seq'::regclass);


--
-- Name: job_title_levels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_title_levels ALTER COLUMN id SET DEFAULT nextval('public.job_title_levels_id_seq'::regclass);


--
-- Name: job_titles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_titles ALTER COLUMN id SET DEFAULT nextval('public.job_titles_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: currencies currencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currencies
    ADD CONSTRAINT currencies_pkey PRIMARY KEY (id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: employment_levels employment_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employment_levels
    ADD CONSTRAINT employment_levels_pkey PRIMARY KEY (id);


--
-- Name: job_title_levels job_title_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_title_levels
    ADD CONSTRAINT job_title_levels_pkey PRIMARY KEY (id);


--
-- Name: job_titles job_titles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_titles
    ADD CONSTRAINT job_titles_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: index_countries_on_currency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_countries_on_currency_id ON public.countries USING btree (currency_id);


--
-- Name: index_countries_on_iso_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_countries_on_iso_code ON public.countries USING btree (iso_code);


--
-- Name: index_currencies_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_currencies_on_code ON public.currencies USING btree (code);


--
-- Name: index_departments_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_departments_on_name ON public.departments USING btree (name);


--
-- Name: index_employees_on_country_id_and_department_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_employees_on_country_id_and_department_id ON public.employees USING btree (country_id, department_id);


--
-- Name: index_employees_on_department_id_and_job_title_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_employees_on_department_id_and_job_title_id ON public.employees USING btree (department_id, job_title_id);


--
-- Name: index_employees_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_employees_on_email ON public.employees USING btree (email);


--
-- Name: index_employees_on_employee_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_employees_on_employee_number ON public.employees USING btree (employee_number);


--
-- Name: index_employees_on_employment_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_employees_on_employment_level_id ON public.employees USING btree (employment_level_id);


--
-- Name: index_employees_on_employment_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_employees_on_employment_status ON public.employees USING btree (employment_status);


--
-- Name: index_employees_on_manager_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_employees_on_manager_id ON public.employees USING btree (manager_id);


--
-- Name: index_employment_levels_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_employment_levels_on_name ON public.employment_levels USING btree (name);


--
-- Name: index_job_title_levels_on_employment_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_title_levels_on_employment_level_id ON public.job_title_levels USING btree (employment_level_id);


--
-- Name: index_job_title_levels_on_job_title_id_and_employment_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_job_title_levels_on_job_title_id_and_employment_level_id ON public.job_title_levels USING btree (job_title_id, employment_level_id);


--
-- Name: index_job_titles_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_job_titles_on_title ON public.job_titles USING btree (title);


--
-- Name: employees fk_rails_0025f65a97; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT fk_rails_0025f65a97 FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: job_title_levels fk_rails_0929ce7e16; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_title_levels
    ADD CONSTRAINT fk_rails_0929ce7e16 FOREIGN KEY (job_title_id) REFERENCES public.job_titles(id);


--
-- Name: employees fk_rails_0bcfa97aa4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT fk_rails_0bcfa97aa4 FOREIGN KEY (employment_level_id) REFERENCES public.employment_levels(id);


--
-- Name: employees fk_rails_0fe1519b79; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT fk_rails_0fe1519b79 FOREIGN KEY (manager_id) REFERENCES public.employees(id);


--
-- Name: job_title_levels fk_rails_690a5244df; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_title_levels
    ADD CONSTRAINT fk_rails_690a5244df FOREIGN KEY (employment_level_id) REFERENCES public.employment_levels(id);


--
-- Name: countries fk_rails_7cac1212c7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT fk_rails_7cac1212c7 FOREIGN KEY (currency_id) REFERENCES public.currencies(id);


--
-- Name: employees fk_rails_95427cb122; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT fk_rails_95427cb122 FOREIGN KEY (job_title_id) REFERENCES public.job_titles(id);


--
-- Name: employees fk_rails_eb26439f43; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT fk_rails_eb26439f43 FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20261031061100'),
('20261031051105'),
('20261031051104'),
('20261031051103'),
('20261031051102'),
('20261031051101'),
('20261031051100');

