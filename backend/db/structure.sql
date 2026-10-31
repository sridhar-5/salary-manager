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
-- Name: admin_user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_user_roles (
    id bigint NOT NULL,
    admin_user_id bigint NOT NULL,
    role_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_user_roles_id_seq OWNED BY public.admin_user_roles.id;


--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_users (
    id bigint NOT NULL,
    email character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp(6) without time zone,
    last_sign_in_at timestamp(6) without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    failed_attempts integer DEFAULT 0 NOT NULL,
    locked_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_users_id_seq OWNED BY public.admin_users.id;


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
-- Name: compensation_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.compensation_records (
    id bigint NOT NULL,
    employee_id bigint NOT NULL,
    annual_salary numeric(19,4) NOT NULL,
    currency_id bigint NOT NULL,
    effective_from date NOT NULL,
    effective_to date,
    created_by_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT compensation_records_annual_salary_positive CHECK ((annual_salary > (0)::numeric)),
    CONSTRAINT compensation_records_effective_range CHECK (((effective_to IS NULL) OR (effective_to >= effective_from)))
);


--
-- Name: TABLE compensation_records; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.compensation_records IS 'Maintain historical salary records. Do not overwrite previous salary amounts.';


--
-- Name: COLUMN compensation_records.created_by_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.compensation_records.created_by_id IS 'Admin who created the compensation record';


--
-- Name: compensation_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.compensation_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: compensation_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.compensation_records_id_seq OWNED BY public.compensation_records.id;


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
-- Name: exchange_rates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exchange_rates (
    id bigint NOT NULL,
    base_currency_id bigint NOT NULL,
    quote_currency_id bigint NOT NULL,
    rate numeric(20,10) NOT NULL,
    effective_date date NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT exchange_rates_currencies_differ CHECK ((base_currency_id <> quote_currency_id)),
    CONSTRAINT exchange_rates_rate_positive CHECK ((rate > (0)::numeric))
);


--
-- Name: TABLE exchange_rates; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.exchange_rates IS 'Rate represents one unit of base currency in quote currency.';


--
-- Name: exchange_rates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exchange_rates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exchange_rates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exchange_rates_id_seq OWNED BY public.exchange_rates.id;


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
    updated_at timestamp(6) without time zone NOT NULL,
    department_id bigint NOT NULL
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
-- Name: jwt_denylist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jwt_denylist (
    id bigint NOT NULL,
    jti character varying NOT NULL,
    exp timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: jwt_denylist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jwt_denylist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jwt_denylist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jwt_denylist_id_seq OWNED BY public.jwt_denylist.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    name character varying NOT NULL,
    description text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: salary_bands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.salary_bands (
    id bigint NOT NULL,
    country_id bigint NOT NULL,
    department_id bigint NOT NULL,
    job_title_id bigint NOT NULL,
    employment_level_id bigint NOT NULL,
    currency_id bigint NOT NULL,
    min_salary numeric(19,4) NOT NULL,
    max_salary numeric(19,4) NOT NULL,
    effective_from date NOT NULL,
    effective_to date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT salary_bands_effective_range CHECK (((effective_to IS NULL) OR (effective_to >= effective_from))),
    CONSTRAINT salary_bands_max_salary_gte_min CHECK ((max_salary >= min_salary)),
    CONSTRAINT salary_bands_min_salary_positive CHECK ((min_salary > (0)::numeric))
);


--
-- Name: TABLE salary_bands; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.salary_bands IS 'Defines acceptable compensation ranges for comparable employee groups.';


--
-- Name: salary_bands_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.salary_bands_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: salary_bands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.salary_bands_id_seq OWNED BY public.salary_bands.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id bigint NOT NULL,
    item_type character varying NOT NULL,
    item_id bigint NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    user_id bigint,
    object jsonb,
    object_changes jsonb,
    created_at timestamp(6) without time zone
);


--
-- Name: COLUMN versions.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.versions.user_id IS 'FK to Devise users.id';


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: admin_user_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_user_roles ALTER COLUMN id SET DEFAULT nextval('public.admin_user_roles_id_seq'::regclass);


--
-- Name: admin_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users ALTER COLUMN id SET DEFAULT nextval('public.admin_users_id_seq'::regclass);


--
-- Name: compensation_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.compensation_records ALTER COLUMN id SET DEFAULT nextval('public.compensation_records_id_seq'::regclass);


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
-- Name: exchange_rates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rates ALTER COLUMN id SET DEFAULT nextval('public.exchange_rates_id_seq'::regclass);


--
-- Name: job_title_levels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_title_levels ALTER COLUMN id SET DEFAULT nextval('public.job_title_levels_id_seq'::regclass);


--
-- Name: job_titles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_titles ALTER COLUMN id SET DEFAULT nextval('public.job_titles_id_seq'::regclass);


--
-- Name: jwt_denylist id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jwt_denylist ALTER COLUMN id SET DEFAULT nextval('public.jwt_denylist_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: salary_bands id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salary_bands ALTER COLUMN id SET DEFAULT nextval('public.salary_bands_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: admin_user_roles admin_user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_user_roles
    ADD CONSTRAINT admin_user_roles_pkey PRIMARY KEY (id);


--
-- Name: admin_users admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: compensation_records compensation_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.compensation_records
    ADD CONSTRAINT compensation_records_pkey PRIMARY KEY (id);


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
-- Name: exchange_rates exchange_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rates
    ADD CONSTRAINT exchange_rates_pkey PRIMARY KEY (id);


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
-- Name: jwt_denylist jwt_denylist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jwt_denylist
    ADD CONSTRAINT jwt_denylist_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: salary_bands salary_bands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salary_bands
    ADD CONSTRAINT salary_bands_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: idx_on_base_currency_id_quote_currency_id_effective_30546a8cbe; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_base_currency_id_quote_currency_id_effective_30546a8cbe ON public.exchange_rates USING btree (base_currency_id, quote_currency_id, effective_date);


--
-- Name: index_admin_user_roles_on_admin_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_user_roles_on_admin_user_id ON public.admin_user_roles USING btree (admin_user_id);


--
-- Name: index_admin_user_roles_on_admin_user_id_and_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_user_roles_on_admin_user_id_and_role_id ON public.admin_user_roles USING btree (admin_user_id, role_id);


--
-- Name: index_admin_user_roles_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_user_roles_on_role_id ON public.admin_user_roles USING btree (role_id);


--
-- Name: index_admin_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_email ON public.admin_users USING btree (email);


--
-- Name: index_compensation_records_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_compensation_records_on_created_by_id ON public.compensation_records USING btree (created_by_id);


--
-- Name: index_compensation_records_on_currency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_compensation_records_on_currency_id ON public.compensation_records USING btree (currency_id);


--
-- Name: index_compensation_records_on_employee_id_and_effective_from; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_compensation_records_on_employee_id_and_effective_from ON public.compensation_records USING btree (employee_id, effective_from);


--
-- Name: index_compensation_records_on_employee_id_and_effective_to; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_compensation_records_on_employee_id_and_effective_to ON public.compensation_records USING btree (employee_id, effective_to);


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
-- Name: index_employment_levels_on_rank; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_employment_levels_on_rank ON public.employment_levels USING btree (rank);


--
-- Name: index_exchange_rates_on_base_currency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exchange_rates_on_base_currency_id ON public.exchange_rates USING btree (base_currency_id);


--
-- Name: index_exchange_rates_on_quote_currency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exchange_rates_on_quote_currency_id ON public.exchange_rates USING btree (quote_currency_id);


--
-- Name: index_job_title_levels_on_employment_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_title_levels_on_employment_level_id ON public.job_title_levels USING btree (employment_level_id);


--
-- Name: index_job_title_levels_on_job_title_id_and_employment_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_job_title_levels_on_job_title_id_and_employment_level_id ON public.job_title_levels USING btree (job_title_id, employment_level_id);


--
-- Name: index_job_titles_on_department_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_titles_on_department_id ON public.job_titles USING btree (department_id);


--
-- Name: index_job_titles_on_department_id_and_title; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_job_titles_on_department_id_and_title ON public.job_titles USING btree (department_id, title);


--
-- Name: index_jwt_denylist_on_jti; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_jwt_denylist_on_jti ON public.jwt_denylist USING btree (jti);


--
-- Name: index_roles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_roles_on_name ON public.roles USING btree (name);


--
-- Name: index_salary_bands_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_salary_bands_on_country_id ON public.salary_bands USING btree (country_id);


--
-- Name: index_salary_bands_on_currency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_salary_bands_on_currency_id ON public.salary_bands USING btree (currency_id);


--
-- Name: index_salary_bands_on_department_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_salary_bands_on_department_id ON public.salary_bands USING btree (department_id);


--
-- Name: index_salary_bands_on_employment_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_salary_bands_on_employment_level_id ON public.salary_bands USING btree (employment_level_id);


--
-- Name: index_salary_bands_on_job_title_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_salary_bands_on_job_title_id ON public.salary_bands USING btree (job_title_id);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON public.versions USING btree (item_type, item_id);


--
-- Name: employees fk_rails_0025f65a97; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT fk_rails_0025f65a97 FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: salary_bands fk_rails_0031b07529; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salary_bands
    ADD CONSTRAINT fk_rails_0031b07529 FOREIGN KEY (employment_level_id) REFERENCES public.employment_levels(id);


--
-- Name: job_title_levels fk_rails_0929ce7e16; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_title_levels
    ADD CONSTRAINT fk_rails_0929ce7e16 FOREIGN KEY (job_title_id) REFERENCES public.job_titles(id);


--
-- Name: salary_bands fk_rails_0a0da6fd42; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salary_bands
    ADD CONSTRAINT fk_rails_0a0da6fd42 FOREIGN KEY (job_title_id) REFERENCES public.job_titles(id);


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
-- Name: salary_bands fk_rails_2eee39dec7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salary_bands
    ADD CONSTRAINT fk_rails_2eee39dec7 FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: exchange_rates fk_rails_30e7fd82bb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rates
    ADD CONSTRAINT fk_rails_30e7fd82bb FOREIGN KEY (base_currency_id) REFERENCES public.currencies(id);


--
-- Name: compensation_records fk_rails_39a5276d48; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.compensation_records
    ADD CONSTRAINT fk_rails_39a5276d48 FOREIGN KEY (created_by_id) REFERENCES public.admin_users(id);


--
-- Name: compensation_records fk_rails_44caab045b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.compensation_records
    ADD CONSTRAINT fk_rails_44caab045b FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- Name: admin_user_roles fk_rails_4a5d8cb055; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_user_roles
    ADD CONSTRAINT fk_rails_4a5d8cb055 FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: salary_bands fk_rails_5ab5a2fef8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salary_bands
    ADD CONSTRAINT fk_rails_5ab5a2fef8 FOREIGN KEY (country_id) REFERENCES public.countries(id);


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
-- Name: exchange_rates fk_rails_a461f7577a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rates
    ADD CONSTRAINT fk_rails_a461f7577a FOREIGN KEY (quote_currency_id) REFERENCES public.currencies(id);


--
-- Name: job_titles fk_rails_a89cac1a3a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_titles
    ADD CONSTRAINT fk_rails_a89cac1a3a FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: salary_bands fk_rails_c778057967; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salary_bands
    ADD CONSTRAINT fk_rails_c778057967 FOREIGN KEY (currency_id) REFERENCES public.currencies(id);


--
-- Name: employees fk_rails_eb26439f43; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT fk_rails_eb26439f43 FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: compensation_records fk_rails_eed1d34caf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.compensation_records
    ADD CONSTRAINT fk_rails_eed1d34caf FOREIGN KEY (currency_id) REFERENCES public.currencies(id);


--
-- Name: admin_user_roles fk_rails_fd39deb99f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_user_roles
    ADD CONSTRAINT fk_rails_fd39deb99f FOREIGN KEY (admin_user_id) REFERENCES public.admin_users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20261031120003'),
('20261031120002'),
('20261031120001'),
('20261031120000'),
('20261031071103'),
('20261031071102'),
('20261031071101'),
('20261031071100'),
('20261031061100'),
('20261031051105'),
('20261031051104'),
('20261031051103'),
('20261031051102'),
('20261031051101'),
('20261031051100');

