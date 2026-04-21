--
-- PostgreSQL database dump
--

-- Dumped from database version 12.17 (Ubuntu 12.17-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.17 (Ubuntu 12.17-0ubuntu0.20.04.1)

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
-- Name: products; Type: DATABASE; Schema: -; Owner: postgress
--

CREATE DATABASE products WITH TEMPLATE = template0 ENCODING = 'UTF8' ;


ALTER DATABASE products OWNER TO postgress;

\connect products

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
-- Name: products; Type: TABLE; Schema: public; Owner: postgress
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(255),
    price numeric(20,0),
    raiting double precision,
    year_issue timestamp(6) without time zone
);


ALTER TABLE public.products OWNER TO postgress;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgress
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 10
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_id_seq OWNER TO postgress;

--
-- Name: products_id_seq1; Type: SEQUENCE; Schema: public; Owner: postgress
--

CREATE SEQUENCE public.products_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_id_seq1 OWNER TO postgress;

--
-- Name: products_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgress
--

ALTER SEQUENCE public.products_id_seq1 OWNED BY public.products.id;


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: postgress
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq1'::regclass);


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgress
--

INSERT INTO public.products VALUES (1, 'Batman #9', 350, 5, '2021-01-01 00:00:00');
INSERT INTO public.products VALUES (2, 'Batman #50', 320, 4.9, '2021-02-01 00:00:00');
INSERT INTO public.products VALUES (3, 'Batman #608', 350, 4.8, '2021-01-01 00:00:00');
INSERT INTO public.products VALUES (4, 'Batman #402', 350, 5, '2021-01-01 00:00:00');
INSERT INTO public.products VALUES (5, 'Batman #422', 350, 5, '2021-01-01 00:00:00');
INSERT INTO public.products VALUES (6, 'Batman #15', 350, 2, '2021-01-01 00:00:00');
INSERT INTO public.products VALUES (7, 'Batman #703', 350, 5, '2021-01-01 00:00:00');
INSERT INTO public.products VALUES (8, 'Batman #800', 350, 5, '2021-01-01 00:00:00');
INSERT INTO public.products VALUES (9, 'Batman #5', 350, 5, '2021-01-01 00:00:00');


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgress
--

SELECT pg_catalog.setval('public.products_id_seq', 1, false);


--
-- Name: products_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: postgress
--

SELECT pg_catalog.setval('public.products_id_seq1', 9, true);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgress
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--