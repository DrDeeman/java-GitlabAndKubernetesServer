SET SCHEMA public;

DROP SEQUENCE IF EXISTS public.products_id_seq;


CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 10
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

