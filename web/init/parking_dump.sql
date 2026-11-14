-- ============================================================================
-- PARKING DATABASE DUMP - SANITIZED FOR SUPABASE
-- ============================================================================
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', 'public', false);

-- Drop existing public tables in reverse-dependency order for idempotent execution
DROP TABLE IF EXISTS public.payment_details CASCADE;
DROP TABLE IF EXISTS public.parking_exit CASCADE;
DROP TABLE IF EXISTS public.parking_ticket CASCADE;
DROP TABLE IF EXISTS public.membership_pass CASCADE;
DROP TABLE IF EXISTS public.shift_assignment CASCADE;
DROP TABLE IF EXISTS public.parking_slot CASCADE;
DROP TABLE IF EXISTS public.parking_gate CASCADE;
DROP TABLE IF EXISTS public.vehicle CASCADE;
DROP TABLE IF EXISTS public.tariff CASCADE;
DROP TABLE IF EXISTS public.membership_plan CASCADE;
DROP TABLE IF EXISTS public.pass_holder CASCADE;
DROP TABLE IF EXISTS public.staff_details CASCADE;
DROP TABLE IF EXISTS public.parking_zone CASCADE;
DROP TABLE IF EXISTS public.slot_type CASCADE;
DROP TABLE IF EXISTS public.vehicle_type CASCADE;

--
-- PostgreSQL database dump
--


-- Dumped from database version 18.0 (Postgres.app)
-- Dumped by pg_dump version 18.0 (Postgres.app)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

-- COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: membership_pass; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_pass (
    pass_no integer NOT NULL,
    member_id integer NOT NULL,
    vehicle_id integer NOT NULL,
    plan_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    CONSTRAINT membership_pass_status_check CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'EXPIRED'::character varying, 'CANCELLED'::character varying])::text[])))
);


--
-- Name: membership_pass_pass_no_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.membership_pass_pass_no_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: membership_pass_pass_no_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.membership_pass_pass_no_seq OWNED BY public.membership_pass.pass_no;


--
-- Name: membership_plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_plan (
    plan_id integer NOT NULL,
    plan_name character varying(50) NOT NULL,
    duration_days integer NOT NULL,
    price numeric(10,2) NOT NULL,
    description text,
    CONSTRAINT membership_plan_duration_days_check CHECK ((duration_days > 0)),
    CONSTRAINT membership_plan_price_check CHECK ((price >= (0)::numeric))
);


--
-- Name: membership_plan_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.membership_plan_plan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: membership_plan_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.membership_plan_plan_id_seq OWNED BY public.membership_plan.plan_id;


--
-- Name: parking_exit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parking_exit (
    exit_id integer NOT NULL,
    ticket_no integer NOT NULL,
    exit_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    exit_gate_id integer NOT NULL,
    total_hours numeric(5,2) NOT NULL,
    total_amount numeric(10,2) NOT NULL,
    CONSTRAINT parking_exit_total_amount_check CHECK ((total_amount >= (0)::numeric)),
    CONSTRAINT parking_exit_total_hours_check CHECK ((total_hours >= (0)::numeric))
);


--
-- Name: parking_exit_exit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parking_exit_exit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parking_exit_exit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parking_exit_exit_id_seq OWNED BY public.parking_exit.exit_id;


--
-- Name: parking_gate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parking_gate (
    gate_id integer NOT NULL,
    gate_number character varying(20) NOT NULL,
    gate_type character varying(10) NOT NULL,
    zone_id integer NOT NULL,
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    CONSTRAINT parking_gate_gate_type_check CHECK (((gate_type)::text = ANY ((ARRAY['ENTRY'::character varying, 'EXIT'::character varying])::text[]))),
    CONSTRAINT parking_gate_status_check CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying])::text[])))
);


--
-- Name: parking_gate_gate_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parking_gate_gate_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parking_gate_gate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parking_gate_gate_id_seq OWNED BY public.parking_gate.gate_id;


--
-- Name: parking_slot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parking_slot (
    slot_id integer NOT NULL,
    slot_no character varying(20) NOT NULL,
    zone_id integer NOT NULL,
    slot_type_id integer NOT NULL,
    availability_status character varying(20) DEFAULT 'AVAILABLE'::character varying,
    CONSTRAINT parking_slot_availability_status_check CHECK (((availability_status)::text = ANY ((ARRAY['AVAILABLE'::character varying, 'OCCUPIED'::character varying, 'MAINTENANCE'::character varying])::text[])))
);


--
-- Name: parking_slot_slot_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parking_slot_slot_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parking_slot_slot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parking_slot_slot_id_seq OWNED BY public.parking_slot.slot_id;


--
-- Name: parking_ticket; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parking_ticket (
    ticket_no integer NOT NULL,
    vehicle_id integer NOT NULL,
    slot_id integer NOT NULL,
    entry_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    entry_gate_id integer NOT NULL,
    ticket_status character varying(20) DEFAULT 'ACTIVE'::character varying,
    CONSTRAINT parking_ticket_ticket_status_check CHECK (((ticket_status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[])))
);


--
-- Name: parking_ticket_ticket_no_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parking_ticket_ticket_no_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parking_ticket_ticket_no_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parking_ticket_ticket_no_seq OWNED BY public.parking_ticket.ticket_no;


--
-- Name: parking_zone; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parking_zone (
    zone_id integer NOT NULL,
    zone_name character varying(50) NOT NULL,
    floor_level integer NOT NULL,
    total_capacity integer NOT NULL,
    CONSTRAINT parking_zone_total_capacity_check CHECK ((total_capacity >= 0))
);


--
-- Name: parking_zone_zone_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parking_zone_zone_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parking_zone_zone_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parking_zone_zone_id_seq OWNED BY public.parking_zone.zone_id;


--
-- Name: pass_holder; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pass_holder (
    member_id integer NOT NULL,
    member_name character varying(100) NOT NULL,
    contact_no character varying(15) NOT NULL,
    address text
);


--
-- Name: pass_holder_member_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pass_holder_member_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pass_holder_member_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pass_holder_member_id_seq OWNED BY public.pass_holder.member_id;


--
-- Name: payment_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_details (
    payment_id integer NOT NULL,
    exit_id integer NOT NULL,
    payment_mode character varying(20) NOT NULL,
    payment_status character varying(20) DEFAULT 'PENDING'::character varying,
    transaction_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    amount_paid numeric(10,2) NOT NULL,
    CONSTRAINT payment_details_amount_paid_check CHECK ((amount_paid >= (0)::numeric)),
    CONSTRAINT payment_details_payment_mode_check CHECK (((payment_mode)::text = ANY ((ARRAY['CASH'::character varying, 'CARD'::character varying, 'UPI'::character varying])::text[]))),
    CONSTRAINT payment_details_payment_status_check CHECK (((payment_status)::text = ANY ((ARRAY['SUCCESSFUL'::character varying, 'PENDING'::character varying, 'FAILED'::character varying])::text[])))
);


--
-- Name: payment_details_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_details_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_details_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_details_payment_id_seq OWNED BY public.payment_details.payment_id;


--
-- Name: shift_assignment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shift_assignment (
    assignment_id integer NOT NULL,
    staff_id integer NOT NULL,
    zone_id integer,
    gate_id integer,
    shift_date date NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL
);


--
-- Name: shift_assignment_assignment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shift_assignment_assignment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shift_assignment_assignment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shift_assignment_assignment_id_seq OWNED BY public.shift_assignment.assignment_id;


--
-- Name: slot_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.slot_type (
    slot_type_id integer NOT NULL,
    slot_type_name character varying(50) NOT NULL,
    description text
);


--
-- Name: slot_type_slot_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.slot_type_slot_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slot_type_slot_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.slot_type_slot_type_id_seq OWNED BY public.slot_type.slot_type_id;


--
-- Name: staff_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staff_details (
    staff_id integer NOT NULL,
    staff_name character varying(100) NOT NULL,
    designation character varying(50) NOT NULL,
    phone_no character varying(15) NOT NULL,
    salary numeric(10,2),
    date_of_joining date NOT NULL,
    CONSTRAINT staff_details_salary_check CHECK ((salary >= (0)::numeric))
);


--
-- Name: staff_details_staff_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.staff_details_staff_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: staff_details_staff_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.staff_details_staff_id_seq OWNED BY public.staff_details.staff_id;


--
-- Name: tariff; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tariff (
    tariff_id integer NOT NULL,
    type_id integer NOT NULL,
    day_type character varying(20) NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    hourly_rate numeric(8,2) NOT NULL,
    overtime_rate numeric(8,2) NOT NULL,
    valid_from date NOT NULL,
    valid_to date NOT NULL,
    CONSTRAINT tariff_day_type_check CHECK (((day_type)::text = ANY ((ARRAY['WEEKDAY'::character varying, 'WEEKEND'::character varying, 'HOLIDAY'::character varying])::text[]))),
    CONSTRAINT tariff_hourly_rate_check CHECK ((hourly_rate >= (0)::numeric)),
    CONSTRAINT tariff_overtime_rate_check CHECK ((overtime_rate >= (0)::numeric))
);


--
-- Name: tariff_tariff_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tariff_tariff_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tariff_tariff_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tariff_tariff_id_seq OWNED BY public.tariff.tariff_id;


--
-- Name: vehicle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicle (
    vehicle_id integer NOT NULL,
    registration_no character varying(20) NOT NULL,
    type_id integer NOT NULL,
    owner_name character varying(100),
    owner_phone character varying(15)
);


--
-- Name: vehicle_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicle_type (
    type_id integer NOT NULL,
    type_name character varying(50) NOT NULL
);


--
-- Name: vehicle_type_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vehicle_type_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vehicle_type_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vehicle_type_type_id_seq OWNED BY public.vehicle_type.type_id;


--
-- Name: vehicle_vehicle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vehicle_vehicle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vehicle_vehicle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vehicle_vehicle_id_seq OWNED BY public.vehicle.vehicle_id;


--
-- Name: membership_pass pass_no; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_pass ALTER COLUMN pass_no SET DEFAULT nextval('public.membership_pass_pass_no_seq'::regclass);


--
-- Name: membership_plan plan_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_plan ALTER COLUMN plan_id SET DEFAULT nextval('public.membership_plan_plan_id_seq'::regclass);


--
-- Name: parking_exit exit_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_exit ALTER COLUMN exit_id SET DEFAULT nextval('public.parking_exit_exit_id_seq'::regclass);


--
-- Name: parking_gate gate_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_gate ALTER COLUMN gate_id SET DEFAULT nextval('public.parking_gate_gate_id_seq'::regclass);


--
-- Name: parking_slot slot_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_slot ALTER COLUMN slot_id SET DEFAULT nextval('public.parking_slot_slot_id_seq'::regclass);


--
-- Name: parking_ticket ticket_no; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_ticket ALTER COLUMN ticket_no SET DEFAULT nextval('public.parking_ticket_ticket_no_seq'::regclass);


--
-- Name: parking_zone zone_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_zone ALTER COLUMN zone_id SET DEFAULT nextval('public.parking_zone_zone_id_seq'::regclass);


--
-- Name: pass_holder member_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pass_holder ALTER COLUMN member_id SET DEFAULT nextval('public.pass_holder_member_id_seq'::regclass);


--
-- Name: payment_details payment_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_details ALTER COLUMN payment_id SET DEFAULT nextval('public.payment_details_payment_id_seq'::regclass);


--
-- Name: shift_assignment assignment_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shift_assignment ALTER COLUMN assignment_id SET DEFAULT nextval('public.shift_assignment_assignment_id_seq'::regclass);


--
-- Name: slot_type slot_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slot_type ALTER COLUMN slot_type_id SET DEFAULT nextval('public.slot_type_slot_type_id_seq'::regclass);


--
-- Name: staff_details staff_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_details ALTER COLUMN staff_id SET DEFAULT nextval('public.staff_details_staff_id_seq'::regclass);


--
-- Name: tariff tariff_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tariff ALTER COLUMN tariff_id SET DEFAULT nextval('public.tariff_tariff_id_seq'::regclass);


--
-- Name: vehicle vehicle_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle ALTER COLUMN vehicle_id SET DEFAULT nextval('public.vehicle_vehicle_id_seq'::regclass);


--
-- Name: vehicle_type type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_type ALTER COLUMN type_id SET DEFAULT nextval('public.vehicle_type_type_id_seq'::regclass);


--
-- Data for Name: membership_pass; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.membership_pass (pass_no, member_id, vehicle_id, plan_id, start_date, end_date, status) FROM stdin;
1	1	1	1	2026-08-01	2026-08-31	ACTIVE
2	3	84	1	2026-10-20	2026-11-18	ACTIVE
3	2	81	2	2026-10-25	2026-11-23	ACTIVE
4	9	80	3	2026-09-01	2026-11-29	ACTIVE
5	4	88	4	2026-06-01	2026-11-27	CANCELLED
6	6	87	5	2026-08-01	2026-08-30	EXPIRED
7	5	82	5	2026-10-15	2026-11-13	ACTIVE
8	8	89	6	2026-04-01	2027-03-31	ACTIVE
9	7	83	7	2026-09-01	2026-09-30	EXPIRED
\.


--
-- Data for Name: membership_plan; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.membership_plan (plan_id, plan_name, duration_days, price, description) FROM stdin;
1	Monthly Unlimited	30	2500.00	Provides 24/7 unlimited parking access across all standard zones for 30 days
2	EV Monthly	30	3200.00	Unlimited parking with priority access to EV charging bays, 30 days
3	Quarterly Unlimited	90	6750.00	24/7 unlimited car parking for 90 days
4	Half-Yearly Unlimited	180	12500.00	24/7 unlimited car parking for 180 days
5	Two-Wheeler Monthly	30	500.00	Unlimited two-wheeler parking in Basement 1 for 30 days
6	Annual Unlimited	365	24000.00	24/7 unlimited car parking for a year, reserved bay in Basement 2
7	Weekday Commuter	30	1800.00	Monday–Friday car parking for office commuters, 30 days
\.


--
-- Data for Name: parking_exit; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.parking_exit (exit_id, ticket_no, exit_time, exit_gate_id, total_hours, total_amount) FROM stdin;
1	1	2026-08-17 12:30:00	1	3.00	150.00
2	4	2026-10-19 15:01:00	4	4.00	120.00
3	5	2026-10-19 23:38:00	2	5.00	180.00
4	6	2026-10-19 13:28:00	4	5.00	150.00
5	7	2026-10-20 00:36:00	4	4.00	250.00
6	8	2026-10-19 13:17:00	2	4.00	160.00
7	9	2026-10-19 18:33:00	4	1.00	30.00
8	10	2026-10-20 00:29:00	4	4.00	250.00
9	11	2026-10-19 21:16:00	4	2.00	60.00
10	12	2026-10-19 17:32:00	4	1.00	50.00
11	13	2026-10-19 11:07:00	4	1.00	40.00
12	14	2026-10-19 18:08:00	4	3.00	90.00
13	15	2026-10-19 16:14:00	4	3.00	120.00
14	16	2026-10-19 09:34:00	4	3.00	135.00
15	17	2026-10-19 14:08:00	2	2.00	80.00
16	18	2026-10-19 14:49:00	2	2.00	60.00
17	19	2026-10-19 11:34:00	6	1.00	10.00
18	20	2026-10-19 11:12:00	6	2.00	20.00
19	21	2026-10-19 20:16:00	4	3.00	150.00
20	22	2026-10-19 11:44:00	6	4.00	40.00
21	23	2026-10-19 19:05:00	6	2.00	20.00
22	24	2026-10-19 15:08:00	4	4.00	120.00
23	25	2026-10-19 15:51:00	2	3.00	150.00
24	26	2026-10-19 20:46:00	4	2.00	80.00
25	27	2026-10-19 08:33:00	4	1.00	60.00
26	28	2026-10-19 12:55:00	2	4.00	120.00
27	29	2026-10-19 14:13:00	2	1.00	30.00
28	30	2026-10-19 22:54:00	2	2.00	100.00
29	31	2026-10-19 15:02:00	2	1.00	30.00
30	32	2026-10-19 13:20:00	4	3.00	90.00
31	33	2026-10-19 21:38:00	6	2.00	20.00
32	34	2026-10-19 12:38:00	4	4.00	120.00
33	35	2026-10-19 12:33:00	4	1.00	40.00
34	37	2026-10-19 21:46:00	4	2.00	100.00
35	38	2026-10-19 21:23:00	6	1.00	10.00
36	39	2026-10-19 13:53:00	2	1.00	30.00
37	40	2026-10-19 12:03:00	2	4.00	120.00
38	41	2026-10-19 20:49:00	6	1.00	10.00
39	42	2026-10-20 01:01:00	2	5.00	195.00
40	43	2026-10-19 21:36:00	4	4.00	120.00
41	44	2026-10-19 19:13:00	6	5.00	50.00
42	45	2026-10-19 18:09:00	2	4.00	200.00
43	46	2026-10-19 17:36:00	2	5.00	150.00
44	47	2026-10-19 13:28:00	4	2.00	100.00
45	48	2026-10-19 11:22:00	2	1.00	30.00
46	49	2026-10-20 17:29:00	4	4.00	120.00
47	50	2026-10-20 14:12:00	4	1.00	30.00
48	51	2026-10-20 14:48:00	6	2.00	20.00
49	53	2026-10-20 09:38:00	4	2.00	150.00
50	54	2026-10-21 00:51:00	4	5.00	325.00
51	55	2026-10-20 07:52:00	2	1.00	45.00
52	56	2026-10-20 18:16:00	4	1.00	30.00
53	57	2026-10-20 10:19:00	4	1.00	50.00
54	58	2026-10-21 04:36:00	6	8.00	115.00
55	59	2026-10-20 15:35:00	6	1.00	10.00
56	60	2026-10-20 18:26:00	4	1.00	30.00
57	61	2026-10-20 11:28:00	4	1.00	30.00
58	62	2026-10-20 14:04:00	4	2.00	80.00
59	63	2026-10-20 17:57:00	4	4.00	200.00
60	64	2026-10-20 16:59:00	6	3.00	30.00
61	65	2026-10-20 15:47:00	4	3.00	150.00
62	66	2026-10-21 01:25:00	6	6.00	80.00
63	67	2026-10-20 14:08:00	4	4.00	160.00
64	68	2026-10-20 19:13:00	4	1.00	40.00
65	69	2026-10-20 10:52:00	4	2.00	100.00
66	70	2026-10-20 13:11:00	2	1.00	40.00
67	71	2026-10-20 13:00:00	2	1.00	30.00
68	72	2026-10-20 18:22:00	4	4.00	120.00
69	73	2026-10-20 16:35:00	6	2.00	20.00
70	74	2026-10-20 22:36:00	6	3.00	35.00
71	75	2026-10-20 15:16:00	6	8.00	80.00
72	76	2026-10-20 16:50:00	6	4.00	40.00
73	77	2026-10-20 21:01:00	6	2.00	20.00
74	78	2026-10-21 02:59:00	2	10.00	375.00
75	79	2026-10-20 18:18:00	2	1.00	30.00
76	80	2026-10-21 01:05:00	6	5.00	70.00
77	81	2026-10-20 11:42:00	4	5.00	300.00
78	82	2026-10-20 08:51:00	4	2.00	90.00
79	83	2026-10-20 10:29:00	4	3.00	135.00
80	84	2026-10-20 15:09:00	4	4.00	160.00
81	85	2026-10-20 23:25:00	2	6.00	210.00
82	86	2026-10-20 14:01:00	2	6.00	240.00
83	87	2026-10-20 13:14:00	4	2.00	60.00
84	88	2026-10-20 08:42:00	6	1.00	10.00
85	89	2026-10-20 18:31:00	4	4.00	120.00
86	90	2026-10-20 20:30:00	4	1.00	30.00
87	91	2026-10-20 10:58:00	6	1.00	10.00
88	92	2026-10-20 10:22:00	6	1.00	10.00
89	93	2026-10-20 17:55:00	6	1.00	10.00
90	94	2026-10-21 14:45:00	6	1.00	10.00
91	95	2026-10-21 19:03:00	2	10.00	300.00
92	96	2026-10-22 00:15:00	2	6.00	210.00
93	97	2026-10-21 15:09:00	6	4.00	40.00
94	98	2026-10-21 19:08:00	4	1.00	50.00
95	99	2026-10-21 15:32:00	4	2.00	80.00
96	100	2026-10-21 18:54:00	4	1.00	40.00
97	101	2026-10-21 23:20:00	6	3.00	35.00
98	102	2026-10-21 10:15:00	4	4.00	180.00
99	103	2026-10-22 05:01:00	2	9.00	375.00
100	104	2026-10-22 00:00:00	4	3.00	120.00
101	105	2026-10-21 17:23:00	4	1.00	30.00
102	106	2026-10-21 16:29:00	6	1.00	10.00
103	107	2026-10-21 15:59:00	6	4.00	40.00
104	108	2026-10-21 11:44:00	2	2.00	80.00
105	109	2026-10-21 14:53:00	4	1.00	50.00
106	110	2026-10-21 22:22:00	6	4.00	40.00
107	111	2026-10-21 16:42:00	6	4.00	40.00
108	112	2026-10-22 03:42:00	2	8.00	330.00
109	113	2026-10-21 15:00:00	4	5.00	200.00
110	114	2026-10-21 15:33:00	2	1.00	30.00
111	115	2026-10-21 19:47:00	2	2.00	60.00
112	116	2026-10-21 10:50:00	4	1.00	30.00
113	117	2026-10-21 19:58:00	2	2.00	100.00
114	118	2026-10-21 13:55:00	2	4.00	120.00
115	119	2026-10-21 10:02:00	2	1.00	40.00
116	120	2026-10-21 09:27:00	4	1.00	30.00
117	121	2026-10-21 10:47:00	4	1.00	30.00
118	122	2026-10-21 12:58:00	4	3.00	90.00
119	123	2026-10-21 11:53:00	6	2.00	20.00
120	124	2026-10-21 15:39:00	4	1.00	50.00
121	125	2026-10-21 11:32:00	6	2.00	20.00
122	126	2026-10-21 11:25:00	6	2.00	20.00
123	127	2026-10-21 17:58:00	2	2.00	100.00
124	128	2026-10-21 19:36:00	6	8.00	80.00
125	129	2026-10-21 11:02:00	4	4.00	180.00
126	130	2026-10-21 14:44:00	6	2.00	20.00
127	131	2026-10-21 19:03:00	2	5.00	150.00
128	132	2026-10-21 13:22:00	2	5.00	150.00
129	133	2026-10-21 13:55:00	6	6.00	60.00
130	134	2026-10-21 19:45:00	2	2.00	80.00
131	135	2026-10-21 21:24:00	4	4.00	200.00
132	136	2026-10-21 15:32:00	6	3.00	30.00
133	137	2026-10-21 18:02:00	2	6.00	180.00
134	138	2026-10-21 13:44:00	2	2.00	60.00
135	139	2026-10-22 16:31:00	2	1.00	40.00
136	140	2026-10-22 12:45:00	4	2.00	60.00
137	141	2026-10-22 11:14:00	4	3.00	90.00
138	143	2026-10-22 14:06:00	4	1.00	30.00
139	144	2026-10-22 17:24:00	4	1.00	0.00
140	145	2026-10-22 13:58:00	4	3.00	90.00
141	146	2026-10-22 20:03:00	4	10.00	300.00
142	147	2026-10-22 10:15:00	2	1.00	50.00
143	148	2026-10-22 16:57:00	6	1.00	10.00
144	149	2026-10-22 23:01:00	4	8.00	255.00
145	150	2026-10-22 17:14:00	2	1.00	30.00
146	151	2026-10-22 17:56:00	4	2.00	100.00
147	152	2026-10-22 12:22:00	4	1.00	30.00
148	153	2026-10-22 21:24:00	6	1.00	10.00
149	154	2026-10-22 11:53:00	4	1.00	50.00
150	155	2026-10-22 11:01:00	2	1.00	30.00
151	156	2026-10-22 14:07:00	4	2.00	60.00
152	157	2026-10-22 08:14:00	6	1.00	15.00
153	158	2026-10-22 08:02:00	6	1.00	15.00
154	159	2026-10-22 17:52:00	4	1.00	30.00
155	160	2026-10-22 16:07:00	4	5.00	250.00
156	161	2026-10-22 11:09:00	6	1.00	10.00
157	162	2026-10-22 11:34:00	2	4.00	120.00
158	163	2026-10-22 20:20:00	4	9.00	270.00
159	164	2026-10-22 22:22:00	2	4.00	135.00
160	165	2026-10-22 21:31:00	6	1.00	10.00
161	166	2026-10-23 02:44:00	2	8.00	400.00
162	167	2026-10-22 16:31:00	4	1.00	50.00
163	168	2026-10-22 10:50:00	2	3.00	90.00
164	169	2026-10-22 19:16:00	4	8.00	320.00
165	170	2026-10-22 18:41:00	4	5.00	200.00
166	171	2026-10-22 19:33:00	2	3.00	150.00
167	172	2026-10-22 14:47:00	2	5.00	250.00
168	173	2026-10-22 12:13:00	4	1.00	30.00
169	174	2026-10-22 12:36:00	6	1.00	10.00
170	175	2026-10-22 13:48:00	4	2.00	60.00
171	176	2026-10-22 21:55:00	2	1.00	30.00
172	177	2026-10-22 18:58:00	4	4.00	200.00
173	178	2026-10-22 21:06:00	6	2.00	20.00
174	179	2026-10-22 10:59:00	4	1.00	30.00
175	180	2026-10-22 12:35:00	2	5.00	0.00
176	181	2026-10-22 11:33:00	4	1.00	30.00
177	182	2026-10-22 16:10:00	6	4.00	40.00
178	183	2026-10-22 20:21:00	2	3.00	90.00
179	184	2026-10-23 18:04:00	4	1.00	30.00
180	186	2026-10-23 15:07:00	2	4.00	120.00
181	187	2026-10-23 12:49:00	6	4.00	40.00
182	188	2026-10-23 21:29:00	2	4.00	120.00
183	189	2026-10-23 17:28:00	2	5.00	150.00
184	190	2026-10-23 17:39:00	2	2.00	60.00
185	191	2026-10-23 12:26:00	4	6.00	270.00
186	192	2026-10-23 13:46:00	4	6.00	300.00
187	193	2026-10-23 14:35:00	2	4.00	120.00
188	194	2026-10-23 09:47:00	2	1.00	40.00
189	196	2026-10-23 08:33:00	2	1.00	45.00
190	197	2026-10-23 21:13:00	2	1.00	50.00
191	198	2026-10-23 22:03:00	6	8.00	80.00
192	199	2026-10-23 22:10:00	6	3.00	35.00
193	200	2026-10-23 23:14:00	4	3.00	140.00
194	201	2026-10-23 12:58:00	4	2.00	100.00
195	202	2026-10-23 12:49:00	6	1.00	10.00
196	203	2026-10-24 00:06:00	2	9.00	500.00
197	204	2026-10-23 10:42:00	2	1.00	50.00
198	205	2026-10-23 18:56:00	6	5.00	50.00
199	206	2026-10-23 14:43:00	4	4.00	120.00
200	207	2026-10-23 11:20:00	6	5.00	75.00
201	208	2026-10-23 08:41:00	6	1.00	10.00
202	209	2026-10-23 14:41:00	6	4.00	40.00
203	210	2026-10-23 15:29:00	2	2.00	80.00
204	211	2026-10-23 12:42:00	4	2.00	80.00
205	212	2026-10-24 01:49:00	6	6.00	80.00
206	213	2026-10-23 14:37:00	2	1.00	30.00
207	214	2026-10-23 22:40:00	4	6.00	260.00
208	215	2026-10-23 12:59:00	4	3.00	150.00
209	216	2026-10-24 01:16:00	2	6.00	0.00
210	217	2026-10-23 15:01:00	2	8.00	360.00
211	218	2026-10-23 18:11:00	6	1.00	10.00
212	219	2026-10-23 15:09:00	2	1.00	30.00
213	220	2026-10-23 13:14:00	2	4.00	120.00
214	221	2026-10-23 14:09:00	6	2.00	20.00
215	222	2026-10-23 18:45:00	6	2.00	20.00
216	223	2026-10-23 20:01:00	4	10.00	300.00
217	224	2026-10-23 07:49:00	6	1.00	15.00
218	225	2026-10-23 14:36:00	4	1.00	30.00
219	226	2026-10-23 16:59:00	4	1.00	40.00
220	227	2026-10-23 18:50:00	2	3.00	90.00
221	228	2026-10-23 22:48:00	2	8.00	255.00
222	229	2026-10-24 12:03:00	6	3.00	45.00
223	230	2026-10-24 21:42:00	2	6.00	360.00
224	231	2026-10-24 16:38:00	6	1.00	15.00
225	232	2026-10-25 05:13:00	2	10.00	540.00
226	233	2026-10-24 11:16:00	6	5.00	100.00
227	234	2026-10-24 08:33:00	2	1.00	60.00
228	235	2026-10-24 14:44:00	4	5.00	300.00
229	236	2026-10-24 14:19:00	6	2.00	30.00
230	237	2026-10-24 11:37:00	4	2.00	120.00
231	238	2026-10-24 10:07:00	2	2.00	100.00
232	239	2026-10-24 23:55:00	4	5.00	240.00
233	240	2026-10-24 21:30:00	6	2.00	30.00
234	241	2026-10-24 12:53:00	6	6.00	120.00
235	242	2026-10-24 16:55:00	2	4.00	200.00
236	243	2026-10-24 19:25:00	6	1.00	15.00
237	244	2026-10-24 20:42:00	2	1.00	40.00
238	245	2026-10-24 22:29:00	6	4.00	65.00
239	246	2026-10-24 12:43:00	2	4.00	160.00
240	247	2026-10-24 10:54:00	2	4.00	240.00
241	248	2026-10-24 13:32:00	4	5.00	200.00
242	249	2026-10-24 19:23:00	6	8.00	120.00
243	250	2026-10-24 12:45:00	6	1.00	15.00
244	251	2026-10-24 12:21:00	2	2.00	100.00
245	252	2026-10-24 10:42:00	2	1.00	40.00
246	253	2026-10-24 09:12:00	2	3.00	180.00
247	255	2026-10-24 18:12:00	4	1.00	60.00
248	256	2026-10-24 22:57:00	2	5.00	275.00
249	257	2026-10-25 05:56:00	2	10.00	840.00
250	258	2026-10-24 16:09:00	4	3.00	180.00
251	259	2026-10-24 12:19:00	4	1.00	40.00
252	260	2026-10-24 09:48:00	4	3.00	225.00
253	261	2026-10-24 21:20:00	4	2.00	80.00
254	262	2026-10-24 16:36:00	6	4.00	60.00
255	263	2026-10-24 14:14:00	2	2.00	80.00
256	264	2026-10-24 14:00:00	6	3.00	45.00
257	265	2026-10-24 12:27:00	2	1.00	60.00
258	266	2026-10-24 12:15:00	2	2.00	100.00
259	267	2026-10-24 09:01:00	2	2.00	120.00
260	268	2026-10-24 21:24:00	4	3.00	120.00
261	269	2026-10-24 07:32:00	6	1.00	20.00
262	270	2026-10-24 19:29:00	6	5.00	75.00
263	271	2026-10-24 15:53:00	2	3.00	120.00
264	272	2026-10-24 18:22:00	6	4.00	60.00
265	273	2026-10-24 16:09:00	2	1.00	40.00
266	274	2026-10-24 16:24:00	2	3.00	120.00
267	275	2026-10-24 19:13:00	2	2.00	80.00
268	276	2026-10-24 13:12:00	4	4.00	160.00
269	277	2026-10-24 15:38:00	2	4.00	160.00
270	278	2026-10-24 16:22:00	2	4.00	160.00
271	279	2026-10-24 07:30:00	4	1.00	60.00
272	280	2026-10-24 09:42:00	2	2.00	100.00
273	281	2026-10-25 00:51:00	6	4.00	75.00
274	282	2026-10-24 12:20:00	6	3.00	45.00
275	283	2026-10-24 20:41:00	4	3.00	120.00
276	284	2026-10-24 09:27:00	6	2.00	30.00
277	285	2026-10-24 21:20:00	4	8.00	320.00
278	286	2026-10-24 18:35:00	4	4.00	160.00
279	287	2026-10-24 13:15:00	6	3.00	45.00
280	288	2026-10-24 07:24:00	6	1.00	20.00
281	289	2026-10-24 17:32:00	6	1.00	15.00
282	290	2026-10-24 13:30:00	2	4.00	160.00
283	291	2026-10-24 10:41:00	6	1.00	15.00
284	292	2026-10-24 18:50:00	2	2.00	120.00
285	293	2026-10-24 12:01:00	4	1.00	0.00
286	295	2026-10-24 17:20:00	4	1.00	40.00
287	296	2026-10-25 05:03:00	6	9.00	170.00
288	297	2026-10-24 23:02:00	2	2.00	125.00
289	298	2026-10-24 10:23:00	4	2.00	80.00
290	299	2026-10-25 13:52:00	6	1.00	15.00
291	300	2026-10-25 16:42:00	4	3.00	150.00
292	301	2026-10-25 17:04:00	6	10.00	200.00
293	302	2026-10-26 05:20:00	6	9.00	170.00
294	303	2026-10-25 19:34:00	2	8.00	480.00
295	304	2026-10-25 22:54:00	2	2.00	100.00
296	305	2026-10-25 13:47:00	4	4.00	160.00
297	306	2026-10-25 19:52:00	6	6.00	90.00
298	307	2026-10-25 13:49:00	6	1.00	15.00
299	308	2026-10-25 17:04:00	2	1.00	100.00
300	309	2026-10-25 12:18:00	4	1.00	60.00
301	310	2026-10-25 20:30:00	6	1.00	15.00
302	311	2026-10-25 18:12:00	4	9.00	540.00
303	312	2026-10-25 19:13:00	2	2.00	120.00
304	313	2026-10-25 15:19:00	2	3.00	120.00
305	314	2026-10-25 14:54:00	4	2.00	120.00
306	315	2026-10-25 11:21:00	2	3.00	180.00
307	316	2026-10-25 08:53:00	6	1.00	20.00
308	317	2026-10-25 08:49:00	4	2.00	120.00
309	318	2026-10-25 16:56:00	2	1.00	40.00
310	319	2026-10-25 19:09:00	4	3.00	120.00
311	320	2026-10-25 13:05:00	4	1.00	40.00
312	321	2026-10-25 09:39:00	4	1.00	40.00
313	322	2026-10-26 03:33:00	2	10.00	520.00
314	323	2026-10-25 22:22:00	6	1.00	15.00
315	324	2026-10-26 06:14:00	6	10.00	190.00
316	325	2026-10-25 20:40:00	6	1.00	15.00
317	326	2026-10-25 12:43:00	4	2.00	100.00
318	327	2026-10-25 08:01:00	2	1.00	60.00
319	328	2026-10-25 12:30:00	2	3.00	120.00
320	329	2026-10-25 13:58:00	2	3.00	180.00
321	330	2026-10-25 15:27:00	2	1.00	60.00
322	331	2026-10-25 15:02:00	2	3.00	180.00
323	332	2026-10-25 23:59:00	4	5.00	240.00
324	333	2026-10-25 15:11:00	2	1.00	40.00
325	334	2026-10-25 18:09:00	4	4.00	240.00
326	335	2026-10-25 16:29:00	6	6.00	90.00
327	336	2026-10-25 11:54:00	2	3.00	150.00
328	337	2026-10-25 16:02:00	2	1.00	50.00
329	338	2026-10-25 09:52:00	6	1.00	15.00
330	339	2026-10-25 22:50:00	2	3.00	210.00
331	340	2026-10-25 10:19:00	6	1.00	15.00
332	341	2026-10-25 15:33:00	2	1.00	40.00
333	342	2026-10-25 14:02:00	4	1.00	50.00
334	343	2026-10-25 12:20:00	6	1.00	15.00
335	344	2026-10-25 13:11:00	2	1.00	0.00
336	345	2026-10-25 14:07:00	4	1.00	60.00
337	346	2026-10-25 20:33:00	4	4.00	240.00
338	347	2026-10-25 23:30:00	6	4.00	70.00
339	349	2026-10-25 13:08:00	2	1.00	60.00
340	350	2026-10-25 15:36:00	2	1.00	60.00
341	351	2026-10-25 11:02:00	2	1.00	50.00
342	352	2026-10-25 23:12:00	4	8.00	340.00
343	353	2026-10-26 05:34:00	4	10.00	540.00
344	354	2026-10-25 14:09:00	6	3.00	45.00
345	355	2026-10-25 13:30:00	2	3.00	150.00
346	356	2026-10-25 17:26:00	4	4.00	160.00
347	357	2026-10-25 19:01:00	2	1.00	40.00
348	358	2026-10-25 14:48:00	6	1.00	15.00
349	359	2026-10-25 14:23:00	6	1.00	15.00
350	360	2026-10-26 06:20:00	2	9.00	520.00
351	361	2026-10-25 12:54:00	4	3.00	120.00
352	362	2026-10-25 18:52:00	6	2.00	30.00
353	363	2026-10-25 18:43:00	6	4.00	60.00
354	364	2026-10-25 21:27:00	2	1.00	50.00
355	365	2026-10-25 14:21:00	4	1.00	40.00
356	366	2026-10-25 19:58:00	6	8.00	120.00
357	367	2026-10-25 09:35:00	2	2.00	180.00
358	368	2026-10-26 01:35:00	4	9.00	630.00
359	369	2026-10-26 12:10:00	2	1.00	50.00
360	370	2026-10-26 09:59:00	4	1.00	30.00
361	371	2026-10-26 10:30:00	4	2.00	60.00
362	372	2026-10-26 23:44:00	6	8.00	90.00
363	373	2026-10-26 20:08:00	2	1.00	30.00
364	374	2026-10-26 23:27:00	4	9.00	285.00
365	375	2026-10-26 20:28:00	2	1.00	50.00
366	376	2026-10-26 19:58:00	6	2.00	20.00
367	377	2026-10-26 21:08:00	2	2.00	60.00
368	378	2026-10-26 21:08:00	2	1.00	40.00
369	379	2026-10-26 22:05:00	2	5.00	150.00
370	380	2026-10-26 10:35:00	6	1.00	10.00
371	381	2026-10-27 04:10:00	4	10.00	520.00
372	382	2026-10-26 20:40:00	4	1.00	30.00
373	383	2026-10-26 22:27:00	4	3.00	150.00
374	384	2026-10-26 22:17:00	6	5.00	55.00
375	385	2026-10-26 16:23:00	6	1.00	10.00
376	386	2026-10-26 13:28:00	2	1.00	30.00
377	387	2026-10-26 11:17:00	4	2.00	60.00
378	388	2026-10-26 17:05:00	6	4.00	40.00
379	389	2026-10-26 12:19:00	4	1.00	50.00
380	390	2026-10-26 13:00:00	2	2.00	60.00
381	391	2026-10-26 13:11:00	2	2.00	60.00
382	392	2026-10-27 00:03:00	4	10.00	0.00
383	393	2026-10-26 22:11:00	6	4.00	45.00
384	394	2026-10-26 18:30:00	4	4.00	120.00
385	395	2026-10-26 20:27:00	6	5.00	50.00
386	396	2026-10-26 14:22:00	6	1.00	10.00
387	397	2026-10-26 18:00:00	2	4.00	120.00
388	398	2026-10-26 20:39:00	6	6.00	60.00
389	399	2026-10-27 00:53:00	2	10.00	345.00
390	400	2026-10-26 19:16:00	4	3.00	90.00
391	401	2026-10-26 09:23:00	6	1.00	10.00
392	402	2026-10-26 19:15:00	6	3.00	30.00
393	403	2026-10-26 12:12:00	2	2.00	80.00
394	404	2026-10-26 08:03:00	2	1.00	60.00
395	405	2026-10-26 08:49:00	2	2.00	90.00
396	406	2026-10-26 20:06:00	2	2.00	80.00
397	407	2026-10-26 22:36:00	2	3.00	105.00
398	408	2026-10-26 12:47:00	6	1.00	10.00
399	409	2026-10-26 15:35:00	2	1.00	40.00
400	410	2026-10-26 16:15:00	2	3.00	90.00
401	411	2026-10-26 19:44:00	6	1.00	10.00
402	412	2026-10-26 18:48:00	4	4.00	120.00
403	413	2026-10-26 19:22:00	4	4.00	120.00
404	414	2026-10-27 18:02:00	4	2.00	60.00
405	415	2026-10-27 18:54:00	4	1.00	30.00
406	416	2026-10-27 23:21:00	2	5.00	165.00
407	417	2026-10-27 18:32:00	4	2.00	100.00
408	418	2026-10-27 12:51:00	2	6.00	360.00
409	419	2026-10-27 20:41:00	4	2.00	60.00
410	420	2026-10-27 16:46:00	2	2.00	100.00
411	421	2026-10-27 17:09:00	2	1.00	40.00
412	422	2026-10-27 12:42:00	6	5.00	50.00
413	423	2026-10-27 16:06:00	4	1.00	30.00
414	424	2026-10-28 01:36:00	2	10.00	360.00
415	425	2026-10-27 20:15:00	4	5.00	200.00
416	426	2026-10-27 17:52:00	6	3.00	30.00
417	427	2026-10-27 17:43:00	4	2.00	80.00
418	428	2026-10-27 13:32:00	6	1.00	10.00
419	429	2026-10-27 12:57:00	2	2.00	60.00
420	430	2026-10-27 18:00:00	6	2.00	20.00
421	431	2026-10-27 23:46:00	6	4.00	50.00
422	432	2026-10-28 02:12:00	2	5.00	350.00
423	433	2026-10-27 18:28:00	4	8.00	240.00
424	434	2026-10-28 01:42:00	6	10.00	120.00
425	435	2026-10-27 09:34:00	2	1.00	40.00
426	436	2026-10-27 13:42:00	4	1.00	50.00
427	437	2026-10-27 18:26:00	2	2.00	80.00
428	438	2026-10-27 18:43:00	2	1.00	30.00
429	439	2026-10-27 21:53:00	4	1.00	50.00
430	440	2026-10-27 16:01:00	2	6.00	180.00
431	441	2026-10-27 20:44:00	4	10.00	400.00
432	442	2026-10-27 18:28:00	2	4.00	120.00
433	443	2026-10-27 09:28:00	6	1.00	10.00
434	444	2026-10-27 08:08:00	2	2.00	90.00
435	445	2026-10-27 15:44:00	6	5.00	50.00
436	446	2026-10-27 18:22:00	6	2.00	20.00
437	447	2026-10-27 17:40:00	2	10.00	300.00
438	448	2026-10-27 20:03:00	4	5.00	200.00
439	449	2026-10-27 11:35:00	2	4.00	160.00
440	450	2026-10-27 15:43:00	4	4.00	160.00
441	451	2026-10-27 17:09:00	4	1.00	30.00
442	452	2026-10-27 10:43:00	6	1.00	10.00
443	453	2026-10-27 13:44:00	4	1.00	40.00
444	454	2026-10-27 11:39:00	6	3.00	30.00
445	455	2026-10-27 21:52:00	4	2.00	60.00
446	456	2026-10-27 12:54:00	6	1.00	10.00
447	457	2026-10-27 13:57:00	6	2.00	20.00
448	458	2026-10-27 11:45:00	6	2.00	20.00
449	459	2026-10-28 10:12:00	2	1.00	30.00
450	460	2026-10-28 18:31:00	2	3.00	90.00
451	461	2026-10-28 19:44:00	4	4.00	200.00
452	462	2026-10-29 05:35:00	4	9.00	650.00
453	463	2026-10-28 23:31:00	4	5.00	165.00
454	464	2026-10-28 23:18:00	2	2.00	125.00
455	465	2026-10-28 11:56:00	2	3.00	150.00
456	466	2026-10-28 11:19:00	2	3.00	150.00
457	467	2026-10-28 12:41:00	4	4.00	200.00
458	468	2026-10-29 02:05:00	6	5.00	70.00
459	469	2026-10-28 21:13:00	2	4.00	200.00
460	470	2026-10-28 12:50:00	4	2.00	80.00
461	471	2026-10-28 08:48:00	2	1.00	75.00
462	472	2026-10-28 09:01:00	4	2.00	120.00
463	473	2026-10-28 16:28:00	6	2.00	20.00
464	474	2026-10-29 00:00:00	2	5.00	240.00
465	475	2026-10-29 00:58:00	2	8.00	475.00
466	476	2026-10-28 21:35:00	2	2.00	60.00
467	477	2026-10-28 18:29:00	2	3.00	150.00
468	478	2026-10-28 14:32:00	4	3.00	90.00
469	479	2026-10-28 10:16:00	4	2.00	60.00
470	480	2026-10-28 20:07:00	6	5.00	50.00
471	481	2026-10-28 21:23:00	2	1.00	30.00
472	482	2026-10-28 17:59:00	2	4.00	200.00
473	483	2026-10-28 14:29:00	2	3.00	90.00
474	484	2026-10-28 15:53:00	2	1.00	50.00
475	485	2026-10-28 15:19:00	6	1.00	10.00
476	486	2026-10-28 19:48:00	2	1.00	0.00
477	487	2026-10-28 18:37:00	4	2.00	100.00
478	488	2026-10-28 22:22:00	6	4.00	45.00
479	489	2026-10-28 13:32:00	2	1.00	30.00
480	490	2026-10-28 15:26:00	6	3.00	30.00
481	491	2026-10-28 10:36:00	6	3.00	30.00
482	492	2026-10-28 21:38:00	6	1.00	10.00
483	493	2026-10-28 12:29:00	6	1.00	10.00
484	495	2026-10-28 09:14:00	2	2.00	90.00
485	496	2026-10-28 19:15:00	6	4.00	40.00
486	497	2026-10-28 12:13:00	4	5.00	300.00
487	498	2026-10-28 15:36:00	4	1.00	30.00
488	500	2026-10-28 14:27:00	6	4.00	40.00
489	501	2026-10-28 17:08:00	4	1.00	50.00
490	502	2026-10-28 15:53:00	6	3.00	30.00
491	503	2026-10-28 12:39:00	4	1.00	80.00
492	504	2026-10-29 10:29:00	2	1.00	30.00
493	505	2026-10-29 17:43:00	2	2.00	80.00
494	506	2026-10-29 17:13:00	6	3.00	30.00
495	507	2026-10-29 11:14:00	6	4.00	60.00
496	508	2026-10-29 16:48:00	4	4.00	0.00
497	509	2026-10-29 13:32:00	6	2.00	20.00
498	510	2026-10-30 03:20:00	4	10.00	650.00
499	511	2026-10-30 00:25:00	2	5.00	240.00
500	512	2026-10-29 18:29:00	6	2.00	20.00
501	513	2026-10-29 17:23:00	4	10.00	450.00
502	514	2026-10-30 02:58:00	6	9.00	115.00
503	515	2026-10-29 18:41:00	6	4.00	40.00
504	516	2026-10-29 08:49:00	2	2.00	120.00
505	517	2026-10-29 11:39:00	2	3.00	90.00
506	518	2026-10-29 15:57:00	2	4.00	120.00
507	519	2026-10-29 09:52:00	4	1.00	30.00
508	520	2026-10-29 17:26:00	2	1.00	30.00
509	521	2026-10-29 13:50:00	4	3.00	120.00
510	522	2026-10-29 16:12:00	4	3.00	150.00
511	523	2026-10-29 09:25:00	4	3.00	180.00
512	524	2026-10-29 12:21:00	6	4.00	40.00
513	525	2026-10-29 12:31:00	6	3.00	30.00
514	526	2026-10-29 23:46:00	4	8.00	450.00
515	527	2026-10-29 17:21:00	2	2.00	80.00
516	529	2026-10-29 15:53:00	6	1.00	10.00
517	530	2026-10-29 22:51:00	2	4.00	225.00
518	531	2026-10-29 10:26:00	6	1.00	10.00
519	532	2026-10-29 12:57:00	2	4.00	200.00
520	533	2026-10-29 11:02:00	2	1.00	30.00
521	534	2026-10-29 17:35:00	6	5.00	50.00
522	535	2026-10-29 08:39:00	2	2.00	90.00
523	536	2026-10-29 11:46:00	4	4.00	120.00
524	537	2026-10-29 17:40:00	4	5.00	150.00
525	538	2026-10-29 21:32:00	6	1.00	10.00
526	539	2026-10-29 13:46:00	4	5.00	200.00
527	540	2026-10-29 21:04:00	6	1.00	10.00
528	541	2026-10-29 22:30:00	2	3.00	105.00
529	542	2026-10-29 15:55:00	2	2.00	80.00
530	543	2026-10-29 15:04:00	4	3.00	90.00
531	544	2026-10-29 16:16:00	2	8.00	240.00
532	545	2026-10-29 19:07:00	2	3.00	240.00
533	546	2026-10-29 17:43:00	4	1.00	50.00
534	547	2026-10-29 18:47:00	6	2.00	20.00
535	548	2026-10-30 00:01:00	4	4.00	250.00
536	549	2026-10-30 18:58:00	2	3.00	90.00
537	550	2026-10-30 20:53:00	6	2.00	20.00
538	551	2026-10-30 10:05:00	4	1.00	50.00
539	552	2026-10-30 17:18:00	4	3.00	90.00
540	553	2026-10-30 10:54:00	4	3.00	135.00
541	554	2026-10-30 23:53:00	4	4.00	200.00
542	555	2026-10-30 12:41:00	2	2.00	60.00
543	556	2026-10-30 15:03:00	2	4.00	200.00
544	557	2026-10-30 15:16:00	4	2.00	60.00
545	558	2026-10-30 15:54:00	4	2.00	60.00
546	559	2026-10-30 13:45:00	6	1.00	10.00
547	560	2026-10-30 21:41:00	6	1.00	10.00
548	561	2026-10-30 21:27:00	6	1.00	10.00
549	562	2026-10-30 12:00:00	2	1.00	40.00
550	563	2026-10-30 23:11:00	6	4.00	50.00
551	564	2026-10-30 21:06:00	6	1.00	10.00
552	565	2026-10-30 17:08:00	6	2.00	20.00
553	566	2026-10-31 02:35:00	2	8.00	525.00
554	567	2026-10-30 11:56:00	2	3.00	150.00
555	568	2026-10-30 12:27:00	4	2.00	60.00
556	569	2026-10-30 18:51:00	4	1.00	30.00
557	571	2026-10-30 21:04:00	4	1.00	30.00
558	572	2026-10-30 11:24:00	4	2.00	60.00
559	573	2026-10-30 19:18:00	2	5.00	200.00
560	574	2026-10-30 16:25:00	2	1.00	30.00
561	575	2026-10-30 19:05:00	2	1.00	50.00
562	576	2026-10-31 03:52:00	6	8.00	110.00
563	577	2026-10-30 18:57:00	4	8.00	400.00
564	578	2026-10-31 01:50:00	6	10.00	120.00
565	579	2026-10-31 06:53:00	4	10.00	420.00
566	580	2026-10-30 12:17:00	6	6.00	90.00
567	581	2026-10-30 12:05:00	4	1.00	30.00
568	582	2026-10-30 20:58:00	4	2.00	60.00
569	583	2026-10-30 18:50:00	4	2.00	100.00
570	584	2026-10-30 21:33:00	6	1.00	10.00
571	585	2026-10-30 13:54:00	2	4.00	200.00
572	586	2026-10-30 15:29:00	2	1.00	40.00
573	587	2026-10-30 08:35:00	4	1.00	30.00
574	588	2026-10-30 19:30:00	4	3.00	150.00
575	590	2026-10-30 18:59:00	6	2.00	20.00
576	591	2026-10-30 22:34:00	4	5.00	220.00
577	592	2026-10-30 17:25:00	4	2.00	60.00
578	593	2026-10-30 14:29:00	4	2.00	60.00
579	594	2026-10-31 10:19:00	6	1.00	15.00
580	595	2026-10-31 10:45:00	4	3.00	120.00
581	596	2026-10-31 12:30:00	6	6.00	120.00
582	597	2026-11-01 00:39:00	2	5.00	360.00
583	598	2026-10-31 09:06:00	4	2.00	120.00
584	599	2026-10-31 21:06:00	4	1.00	40.00
585	600	2026-10-31 11:55:00	6	1.00	15.00
586	601	2026-10-31 16:42:00	6	1.00	15.00
587	603	2026-10-31 19:30:00	2	8.00	320.00
588	604	2026-10-31 21:48:00	6	1.00	15.00
589	605	2026-10-31 20:25:00	4	8.00	320.00
590	606	2026-11-01 00:25:00	4	8.00	360.00
591	607	2026-10-31 14:31:00	2	1.00	60.00
592	608	2026-10-31 12:53:00	4	3.00	120.00
593	609	2026-10-31 20:30:00	6	4.00	60.00
594	610	2026-11-01 00:37:00	4	5.00	240.00
595	611	2026-10-31 10:10:00	4	1.00	40.00
596	612	2026-11-01 00:16:00	2	4.00	330.00
597	613	2026-10-31 11:49:00	2	4.00	160.00
598	614	2026-10-31 12:34:00	6	1.00	15.00
599	615	2026-10-31 17:11:00	4	2.00	80.00
600	616	2026-10-31 15:22:00	6	1.00	15.00
601	617	2026-10-31 21:46:00	6	5.00	75.00
602	618	2026-10-31 22:47:00	4	5.00	275.00
603	619	2026-10-31 14:41:00	6	1.00	15.00
604	620	2026-10-31 08:50:00	6	1.00	15.00
605	621	2026-10-31 14:31:00	2	2.00	120.00
606	622	2026-10-31 17:24:00	4	3.00	120.00
607	623	2026-10-31 11:45:00	4	1.00	0.00
608	624	2026-10-31 16:24:00	2	4.00	200.00
609	625	2026-10-31 22:30:00	4	4.00	225.00
610	626	2026-10-31 21:23:00	6	1.00	15.00
611	627	2026-10-31 20:27:00	4	1.00	40.00
612	628	2026-10-31 10:20:00	2	3.00	180.00
613	629	2026-10-31 10:36:00	2	1.00	40.00
614	630	2026-10-31 15:33:00	6	1.00	15.00
615	631	2026-10-31 22:37:00	2	5.00	300.00
616	632	2026-10-31 21:08:00	6	9.00	135.00
617	633	2026-10-31 19:04:00	4	4.00	200.00
618	634	2026-10-31 13:59:00	4	2.00	100.00
619	635	2026-10-31 16:00:00	2	2.00	80.00
620	636	2026-10-31 21:04:00	4	8.00	480.00
621	637	2026-10-31 20:24:00	4	5.00	200.00
622	638	2026-10-31 21:42:00	2	2.00	80.00
623	639	2026-10-31 15:49:00	4	1.00	40.00
624	640	2026-10-31 08:28:00	6	1.00	0.00
625	641	2026-10-31 09:10:00	6	2.00	40.00
626	642	2026-10-31 14:22:00	6	3.00	45.00
627	643	2026-10-31 20:51:00	4	1.00	50.00
628	644	2026-10-31 20:22:00	2	5.00	200.00
629	645	2026-10-31 16:47:00	4	9.00	360.00
630	646	2026-10-31 19:23:00	4	4.00	160.00
631	647	2026-10-31 15:38:00	4	4.00	160.00
632	648	2026-10-31 11:56:00	4	1.00	60.00
633	649	2026-10-31 22:41:00	6	2.00	30.00
634	650	2026-10-31 13:24:00	4	1.00	40.00
635	651	2026-10-31 12:29:00	6	2.00	0.00
636	652	2026-10-31 19:52:00	6	2.00	30.00
637	653	2026-10-31 19:00:00	2	2.00	80.00
638	654	2026-10-31 22:54:00	2	3.00	210.00
639	655	2026-10-31 22:40:00	4	5.00	250.00
640	656	2026-10-31 22:33:00	4	2.00	100.00
641	657	2026-10-31 10:22:00	4	2.00	100.00
642	658	2026-10-31 19:03:00	4	3.00	180.00
643	659	2026-10-31 11:41:00	4	2.00	80.00
644	660	2026-10-31 08:01:00	2	1.00	90.00
645	661	2026-11-01 00:09:00	4	3.00	160.00
646	662	2026-10-31 10:56:00	2	2.00	120.00
647	663	2026-10-31 18:52:00	6	1.00	15.00
648	664	2026-11-01 09:23:00	6	1.00	15.00
649	665	2026-11-01 18:14:00	6	3.00	45.00
650	666	2026-11-01 14:16:00	2	5.00	200.00
651	667	2026-11-01 08:43:00	6	1.00	20.00
652	668	2026-11-01 16:24:00	2	1.00	40.00
653	670	2026-11-01 12:38:00	4	1.00	40.00
654	671	2026-11-01 20:55:00	4	1.00	50.00
655	672	2026-11-01 11:07:00	6	3.00	45.00
656	673	2026-11-01 14:21:00	4	5.00	200.00
657	674	2026-11-01 21:13:00	4	4.00	160.00
658	675	2026-11-01 21:03:00	2	3.00	120.00
659	676	2026-11-01 14:19:00	2	2.00	120.00
660	677	2026-11-01 10:53:00	6	2.00	30.00
661	678	2026-11-01 12:41:00	6	3.00	45.00
662	679	2026-11-01 07:41:00	2	1.00	75.00
663	680	2026-11-01 17:18:00	2	4.00	160.00
664	681	2026-11-01 18:38:00	4	3.00	180.00
665	682	2026-11-01 12:29:00	6	6.00	120.00
666	683	2026-11-01 16:53:00	6	4.00	60.00
667	684	2026-11-01 21:46:00	4	9.00	450.00
668	685	2026-11-02 00:08:00	2	4.00	330.00
669	686	2026-11-02 02:05:00	2	6.00	320.00
670	687	2026-11-01 10:03:00	4	2.00	80.00
671	688	2026-11-01 18:24:00	4	2.00	80.00
672	689	2026-11-01 08:15:00	4	1.00	60.00
673	690	2026-11-01 17:46:00	2	2.00	80.00
674	691	2026-11-01 20:29:00	6	1.00	15.00
675	692	2026-11-01 11:07:00	6	2.00	30.00
676	693	2026-11-01 19:58:00	2	2.00	80.00
677	694	2026-11-01 09:46:00	2	3.00	180.00
678	695	2026-11-01 12:19:00	6	4.00	60.00
679	696	2026-11-01 16:05:00	6	1.00	15.00
680	697	2026-11-01 22:35:00	4	2.00	100.00
681	698	2026-11-01 17:26:00	4	6.00	240.00
682	699	2026-11-01 23:43:00	2	3.00	160.00
683	700	2026-11-01 13:09:00	4	1.00	40.00
684	701	2026-11-01 23:29:00	2	5.00	220.00
685	703	2026-11-01 16:19:00	6	5.00	75.00
686	704	2026-11-01 22:08:00	4	4.00	200.00
687	706	2026-11-01 19:00:00	2	1.00	40.00
688	707	2026-11-01 14:53:00	2	1.00	40.00
689	708	2026-11-01 20:29:00	2	4.00	200.00
690	709	2026-11-01 12:14:00	6	2.00	30.00
691	710	2026-11-01 17:27:00	6	4.00	60.00
692	711	2026-11-01 19:43:00	2	3.00	120.00
693	712	2026-11-01 17:22:00	6	1.00	15.00
694	713	2026-11-02 00:25:00	4	4.00	330.00
695	714	2026-11-01 19:09:00	4	5.00	200.00
696	715	2026-11-01 21:17:00	2	2.00	80.00
697	716	2026-11-01 19:18:00	6	1.00	15.00
698	717	2026-11-01 10:48:00	4	1.00	0.00
699	718	2026-11-01 16:39:00	6	1.00	15.00
700	719	2026-11-01 12:44:00	4	4.00	200.00
701	720	2026-11-01 13:04:00	4	4.00	200.00
702	721	2026-11-01 08:32:00	2	1.00	40.00
703	722	2026-11-01 21:45:00	4	2.00	120.00
704	723	2026-11-01 19:42:00	2	9.00	540.00
705	724	2026-11-01 08:30:00	6	1.00	20.00
706	725	2026-11-01 13:14:00	4	3.00	120.00
707	726	2026-11-01 19:11:00	4	1.00	60.00
708	727	2026-11-01 14:51:00	2	2.00	80.00
709	728	2026-11-02 01:36:00	4	10.00	460.00
710	729	2026-11-01 11:11:00	2	4.00	360.00
711	730	2026-11-01 13:42:00	2	3.00	150.00
712	731	2026-11-01 14:31:00	2	2.00	120.00
713	732	2026-11-01 14:22:00	6	5.00	75.00
714	733	2026-11-01 13:12:00	2	3.00	120.00
715	734	2026-11-02 08:52:00	4	2.00	90.00
716	735	2026-11-02 09:24:00	6	1.00	10.00
717	736	2026-11-02 10:22:00	4	1.00	30.00
718	737	2026-11-02 14:11:00	6	3.00	30.00
719	738	2026-11-02 13:15:00	4	1.00	0.00
720	739	2026-11-02 12:18:00	4	1.00	40.00
721	740	2026-11-02 15:16:32.408187	4	2.00	60.00
722	741	2026-11-02 10:13:00	4	1.00	50.00
723	742	2026-11-02 12:17:00	4	4.00	120.00
724	743	2026-11-02 14:19:00	4	2.00	100.00
725	744	2026-11-02 11:35:00	4	2.00	60.00
726	745	2026-11-02 11:30:00	6	2.00	20.00
727	746	2026-11-02 13:06:00	4	1.00	50.00
728	747	2026-11-02 14:58:00	4	3.00	90.00
729	748	2026-11-02 09:14:00	4	2.00	90.00
730	749	2026-11-02 10:12:00	4	1.00	30.00
731	750	2026-11-02 15:16:32.408187	4	3.00	150.00
732	751	2026-11-02 13:23:00	6	4.00	40.00
733	752	2026-11-02 12:54:00	6	3.00	30.00
734	753	2026-11-02 08:11:00	4	1.00	60.00
735	754	2026-11-02 08:35:00	4	2.00	90.00
736	755	2026-11-02 09:23:00	6	2.00	30.00
737	756	2026-11-02 07:33:00	4	1.00	45.00
738	757	2026-11-02 11:30:00	4	2.00	100.00
739	758	2026-11-02 08:04:00	4	1.00	75.00
740	759	2026-11-02 12:39:00	4	5.00	150.00
741	760	2026-11-02 15:16:32.408187	6	2.00	20.00
742	761	2026-11-02 12:39:00	4	1.00	0.00
743	762	2026-11-02 14:46:00	4	4.00	160.00
744	763	2026-11-02 11:47:00	4	1.00	40.00
745	764	2026-11-02 12:51:00	4	1.00	30.00
746	765	2026-11-02 13:02:00	6	2.00	20.00
747	766	2026-11-02 15:16:32.408187	6	4.00	40.00
748	767	2026-11-02 12:22:00	4	1.00	50.00
749	768	2026-11-02 14:55:00	6	3.00	30.00
750	769	2026-11-02 15:16:32.408187	4	2.00	60.00
751	770	2026-11-02 14:19:00	4	1.00	30.00
752	771	2026-11-02 13:50:00	4	1.00	50.00
753	772	2026-11-02 11:32:00	4	2.00	60.00
754	773	2026-11-02 15:16:32.408187	4	2.00	60.00
\.


--
-- Data for Name: parking_gate; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.parking_gate (gate_id, gate_number, gate_type, zone_id, status) FROM stdin;
1	GATE-IN-01	ENTRY	1	ACTIVE
2	GATE-OUT-02	EXIT	1	ACTIVE
3	GATE-IN-02	ENTRY	1	ACTIVE
4	GATE-OUT-01	EXIT	1	ACTIVE
5	GATE-IN-B1	ENTRY	4	ACTIVE
6	GATE-OUT-B1	EXIT	4	ACTIVE
7	GATE-SVC-IN	ENTRY	5	INACTIVE
8	GATE-SVC-OUT	EXIT	5	INACTIVE
\.


--
-- Data for Name: parking_slot; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.parking_slot (slot_id, slot_no, zone_id, slot_type_id, availability_status) FROM stdin;
3	A-G-02	1	7	OCCUPIED
4	A-G-03	1	7	OCCUPIED
17	A-G-38	1	6	MAINTENANCE
98	B-F1-17	2	1	MAINTENANCE
6	A-G-27	1	6	OCCUPIED
7	A-G-28	1	6	OCCUPIED
8	A-G-29	1	6	OCCUPIED
9	A-G-30	1	6	OCCUPIED
1	A-G-01	1	1	OCCUPIED
5	A-G-04	1	7	AVAILABLE
10	A-G-31	1	6	AVAILABLE
11	A-G-32	1	6	AVAILABLE
13	A-G-34	1	6	AVAILABLE
14	A-G-35	1	6	AVAILABLE
16	A-G-37	1	6	AVAILABLE
19	A-G-40	1	6	AVAILABLE
21	A-G-06	1	4	AVAILABLE
23	A-G-08	1	4	AVAILABLE
26	A-G-11	1	4	AVAILABLE
28	A-G-13	1	1	AVAILABLE
29	A-G-14	1	1	AVAILABLE
32	A-G-17	1	1	AVAILABLE
39	A-G-24	1	1	AVAILABLE
41	A-G-26	1	1	AVAILABLE
42	B-F1-01	2	7	AVAILABLE
43	B-F1-02	2	7	AVAILABLE
45	B-F1-22	2	6	AVAILABLE
46	B-F1-23	2	6	AVAILABLE
47	B-F1-24	2	6	AVAILABLE
48	B-F1-25	2	6	AVAILABLE
50	B-F1-27	2	6	AVAILABLE
52	B-F1-29	2	6	AVAILABLE
54	B-F1-31	2	6	AVAILABLE
55	B-F1-32	2	6	AVAILABLE
57	B-F1-34	2	6	AVAILABLE
59	B-F1-36	2	6	AVAILABLE
60	B-F1-37	2	6	AVAILABLE
62	B-F1-39	2	6	AVAILABLE
63	B-F1-40	2	6	AVAILABLE
66	B-F1-43	2	6	AVAILABLE
70	B-F1-47	2	6	AVAILABLE
72	B-F1-49	2	6	AVAILABLE
73	B-F1-50	2	6	AVAILABLE
74	B-F1-51	2	2	AVAILABLE
75	B-F1-52	2	2	AVAILABLE
77	B-F1-54	2	2	AVAILABLE
78	B-F1-55	2	2	AVAILABLE
80	B-F1-57	2	2	AVAILABLE
81	B-F1-58	2	2	AVAILABLE
87	B-F1-06	2	1	AVAILABLE
88	B-F1-07	2	1	AVAILABLE
90	B-F1-09	2	1	AVAILABLE
91	B-F1-10	2	1	AVAILABLE
99	B-F1-18	2	1	AVAILABLE
100	B-F1-19	2	1	AVAILABLE
102	C-F2-01	3	7	AVAILABLE
103	C-F2-02	3	7	AVAILABLE
105	C-F2-12	3	6	AVAILABLE
106	C-F2-13	3	6	AVAILABLE
109	C-F2-16	3	6	AVAILABLE
110	C-F2-17	3	6	AVAILABLE
111	C-F2-18	3	6	AVAILABLE
112	C-F2-19	3	6	AVAILABLE
117	C-F2-24	3	6	AVAILABLE
123	C-F2-30	3	6	AVAILABLE
124	C-F2-03	3	4	AVAILABLE
12	A-G-33	1	6	OCCUPIED
15	A-G-36	1	6	OCCUPIED
18	A-G-39	1	6	OCCUPIED
20	A-G-05	1	4	OCCUPIED
22	A-G-07	1	4	OCCUPIED
24	A-G-09	1	4	OCCUPIED
128	C-F2-07	3	4	AVAILABLE
129	C-F2-08	3	4	AVAILABLE
135	C-F2-34	3	2	AVAILABLE
136	C-F2-35	3	2	AVAILABLE
138	C-F2-37	3	2	AVAILABLE
140	C-F2-39	3	2	AVAILABLE
141	C-F2-40	3	2	AVAILABLE
142	C-F2-41	3	2	AVAILABLE
143	C-F2-42	3	2	AVAILABLE
144	C-F2-43	3	2	AVAILABLE
150	C-F2-49	3	2	AVAILABLE
151	C-F2-50	3	2	AVAILABLE
154	C-F2-53	3	2	AVAILABLE
155	C-F2-54	3	2	AVAILABLE
160	C-F2-59	3	2	AVAILABLE
161	C-F2-60	3	2	AVAILABLE
162	D-B1-001	4	3	AVAILABLE
164	D-B1-003	4	3	AVAILABLE
165	D-B1-004	4	3	AVAILABLE
166	D-B1-005	4	3	AVAILABLE
174	D-B1-013	4	3	AVAILABLE
175	D-B1-014	4	3	AVAILABLE
178	D-B1-017	4	3	AVAILABLE
179	D-B1-018	4	3	AVAILABLE
180	D-B1-019	4	3	AVAILABLE
181	D-B1-020	4	3	AVAILABLE
189	D-B1-028	4	3	AVAILABLE
191	D-B1-030	4	3	AVAILABLE
192	D-B1-031	4	3	AVAILABLE
195	D-B1-034	4	3	AVAILABLE
196	D-B1-035	4	3	AVAILABLE
204	D-B1-043	4	3	AVAILABLE
205	D-B1-044	4	3	AVAILABLE
206	D-B1-045	4	3	AVAILABLE
215	D-B1-054	4	3	AVAILABLE
219	D-B1-058	4	3	AVAILABLE
221	D-B1-060	4	3	AVAILABLE
225	D-B1-064	4	3	AVAILABLE
226	D-B1-065	4	3	AVAILABLE
227	D-B1-066	4	3	AVAILABLE
229	D-B1-068	4	3	AVAILABLE
231	D-B1-070	4	3	AVAILABLE
234	D-B1-073	4	3	AVAILABLE
235	D-B1-074	4	3	AVAILABLE
236	D-B1-075	4	3	AVAILABLE
240	D-B1-079	4	3	AVAILABLE
244	D-B1-083	4	3	AVAILABLE
246	D-B1-085	4	3	AVAILABLE
247	D-B1-086	4	3	AVAILABLE
250	D-B1-089	4	3	AVAILABLE
312	E-B2-27	5	5	AVAILABLE
252	D-B1-091	4	3	AVAILABLE
255	D-B1-094	4	3	AVAILABLE
258	D-B1-097	4	3	AVAILABLE
265	D-B1-104	4	3	AVAILABLE
266	D-B1-105	4	3	AVAILABLE
268	D-B1-107	4	3	AVAILABLE
270	D-B1-109	4	3	AVAILABLE
271	D-B1-110	4	3	AVAILABLE
272	D-B1-111	4	3	AVAILABLE
273	D-B1-112	4	3	AVAILABLE
275	D-B1-114	4	3	AVAILABLE
276	D-B1-115	4	3	AVAILABLE
284	E-B2-39	5	8	AVAILABLE
285	E-B2-40	5	8	AVAILABLE
289	E-B2-04	5	5	AVAILABLE
290	E-B2-05	5	5	AVAILABLE
291	E-B2-06	5	5	AVAILABLE
292	E-B2-07	5	5	AVAILABLE
293	E-B2-08	5	5	AVAILABLE
294	E-B2-09	5	5	AVAILABLE
295	E-B2-10	5	5	AVAILABLE
296	E-B2-11	5	5	AVAILABLE
297	E-B2-12	5	5	AVAILABLE
298	E-B2-13	5	5	AVAILABLE
299	E-B2-14	5	5	AVAILABLE
300	E-B2-15	5	5	AVAILABLE
301	E-B2-16	5	5	AVAILABLE
302	E-B2-17	5	5	AVAILABLE
303	E-B2-18	5	5	AVAILABLE
304	E-B2-19	5	5	AVAILABLE
305	E-B2-20	5	5	AVAILABLE
306	E-B2-21	5	5	AVAILABLE
307	E-B2-22	5	5	AVAILABLE
308	E-B2-23	5	5	AVAILABLE
309	E-B2-24	5	5	AVAILABLE
310	E-B2-25	5	5	AVAILABLE
311	E-B2-26	5	5	AVAILABLE
313	E-B2-28	5	5	AVAILABLE
314	E-B2-29	5	5	AVAILABLE
315	E-B2-30	5	5	AVAILABLE
318	E-B2-33	5	2	AVAILABLE
319	E-B2-34	5	2	AVAILABLE
321	E-B2-36	5	2	AVAILABLE
130	C-F2-09	3	4	MAINTENANCE
145	C-F2-44	3	2	MAINTENANCE
238	D-B1-077	4	3	MAINTENANCE
239	D-B1-078	4	3	MAINTENANCE
25	A-G-10	1	4	OCCUPIED
27	A-G-12	1	4	OCCUPIED
30	A-G-15	1	1	OCCUPIED
31	A-G-16	1	1	OCCUPIED
33	A-G-18	1	1	OCCUPIED
34	A-G-19	1	1	OCCUPIED
35	A-G-20	1	1	OCCUPIED
36	A-G-21	1	1	OCCUPIED
37	A-G-22	1	1	OCCUPIED
38	A-G-23	1	1	OCCUPIED
40	A-G-25	1	1	OCCUPIED
44	B-F1-21	2	6	OCCUPIED
49	B-F1-26	2	6	OCCUPIED
51	B-F1-28	2	6	OCCUPIED
53	B-F1-30	2	6	OCCUPIED
56	B-F1-33	2	6	OCCUPIED
58	B-F1-35	2	6	OCCUPIED
61	B-F1-38	2	6	OCCUPIED
64	B-F1-41	2	6	OCCUPIED
65	B-F1-42	2	6	OCCUPIED
67	B-F1-44	2	6	OCCUPIED
68	B-F1-45	2	6	OCCUPIED
69	B-F1-46	2	6	OCCUPIED
71	B-F1-48	2	6	OCCUPIED
76	B-F1-53	2	2	OCCUPIED
79	B-F1-56	2	2	OCCUPIED
82	B-F1-59	2	2	OCCUPIED
83	B-F1-60	2	2	OCCUPIED
84	B-F1-03	2	1	OCCUPIED
85	B-F1-04	2	1	OCCUPIED
86	B-F1-05	2	1	OCCUPIED
89	B-F1-08	2	1	OCCUPIED
92	B-F1-11	2	1	OCCUPIED
93	B-F1-12	2	1	OCCUPIED
94	B-F1-13	2	1	OCCUPIED
95	B-F1-14	2	1	OCCUPIED
96	B-F1-15	2	1	OCCUPIED
97	B-F1-16	2	1	OCCUPIED
101	B-F1-20	2	1	OCCUPIED
104	C-F2-11	3	6	OCCUPIED
107	C-F2-14	3	6	OCCUPIED
108	C-F2-15	3	6	OCCUPIED
113	C-F2-20	3	6	OCCUPIED
114	C-F2-21	3	6	OCCUPIED
115	C-F2-22	3	6	OCCUPIED
116	C-F2-23	3	6	OCCUPIED
118	C-F2-25	3	6	OCCUPIED
119	C-F2-26	3	6	OCCUPIED
120	C-F2-27	3	6	OCCUPIED
121	C-F2-28	3	6	OCCUPIED
122	C-F2-29	3	6	OCCUPIED
125	C-F2-04	3	4	OCCUPIED
126	C-F2-05	3	4	OCCUPIED
127	C-F2-06	3	4	OCCUPIED
131	C-F2-10	3	4	OCCUPIED
132	C-F2-31	3	2	OCCUPIED
133	C-F2-32	3	2	OCCUPIED
134	C-F2-33	3	2	OCCUPIED
137	C-F2-36	3	2	OCCUPIED
139	C-F2-38	3	2	OCCUPIED
146	C-F2-45	3	2	OCCUPIED
147	C-F2-46	3	2	OCCUPIED
148	C-F2-47	3	2	OCCUPIED
149	C-F2-48	3	2	OCCUPIED
152	C-F2-51	3	2	OCCUPIED
153	C-F2-52	3	2	OCCUPIED
156	C-F2-55	3	2	OCCUPIED
157	C-F2-56	3	2	OCCUPIED
158	C-F2-57	3	2	OCCUPIED
159	C-F2-58	3	2	OCCUPIED
163	D-B1-002	4	3	OCCUPIED
167	D-B1-006	4	3	OCCUPIED
168	D-B1-007	4	3	OCCUPIED
169	D-B1-008	4	3	OCCUPIED
170	D-B1-009	4	3	OCCUPIED
171	D-B1-010	4	3	OCCUPIED
172	D-B1-011	4	3	OCCUPIED
173	D-B1-012	4	3	OCCUPIED
176	D-B1-015	4	3	OCCUPIED
177	D-B1-016	4	3	OCCUPIED
182	D-B1-021	4	3	OCCUPIED
183	D-B1-022	4	3	OCCUPIED
184	D-B1-023	4	3	OCCUPIED
185	D-B1-024	4	3	OCCUPIED
186	D-B1-025	4	3	OCCUPIED
187	D-B1-026	4	3	OCCUPIED
188	D-B1-027	4	3	OCCUPIED
190	D-B1-029	4	3	OCCUPIED
193	D-B1-032	4	3	OCCUPIED
194	D-B1-033	4	3	OCCUPIED
197	D-B1-036	4	3	OCCUPIED
198	D-B1-037	4	3	OCCUPIED
199	D-B1-038	4	3	OCCUPIED
200	D-B1-039	4	3	OCCUPIED
201	D-B1-040	4	3	OCCUPIED
202	D-B1-041	4	3	OCCUPIED
203	D-B1-042	4	3	OCCUPIED
207	D-B1-046	4	3	OCCUPIED
208	D-B1-047	4	3	OCCUPIED
209	D-B1-048	4	3	OCCUPIED
210	D-B1-049	4	3	OCCUPIED
211	D-B1-050	4	3	OCCUPIED
212	D-B1-051	4	3	OCCUPIED
213	D-B1-052	4	3	OCCUPIED
214	D-B1-053	4	3	OCCUPIED
216	D-B1-055	4	3	OCCUPIED
217	D-B1-056	4	3	OCCUPIED
218	D-B1-057	4	3	OCCUPIED
220	D-B1-059	4	3	OCCUPIED
222	D-B1-061	4	3	OCCUPIED
223	D-B1-062	4	3	OCCUPIED
224	D-B1-063	4	3	OCCUPIED
228	D-B1-067	4	3	OCCUPIED
230	D-B1-069	4	3	OCCUPIED
232	D-B1-071	4	3	OCCUPIED
233	D-B1-072	4	3	OCCUPIED
237	D-B1-076	4	3	OCCUPIED
241	D-B1-080	4	3	OCCUPIED
242	D-B1-081	4	3	OCCUPIED
243	D-B1-082	4	3	OCCUPIED
245	D-B1-084	4	3	OCCUPIED
248	D-B1-087	4	3	OCCUPIED
249	D-B1-088	4	3	OCCUPIED
251	D-B1-090	4	3	OCCUPIED
253	D-B1-092	4	3	OCCUPIED
254	D-B1-093	4	3	OCCUPIED
256	D-B1-095	4	3	OCCUPIED
257	D-B1-096	4	3	OCCUPIED
259	D-B1-098	4	3	OCCUPIED
260	D-B1-099	4	3	OCCUPIED
261	D-B1-100	4	3	OCCUPIED
262	D-B1-101	4	3	OCCUPIED
263	D-B1-102	4	3	OCCUPIED
264	D-B1-103	4	3	OCCUPIED
267	D-B1-106	4	3	OCCUPIED
269	D-B1-108	4	3	OCCUPIED
274	D-B1-113	4	3	OCCUPIED
277	D-B1-116	4	3	OCCUPIED
278	D-B1-117	4	3	OCCUPIED
279	D-B1-118	4	3	OCCUPIED
280	D-B1-119	4	3	OCCUPIED
281	D-B1-120	4	3	OCCUPIED
282	E-B2-37	5	8	OCCUPIED
283	E-B2-38	5	8	OCCUPIED
316	E-B2-31	5	2	OCCUPIED
317	E-B2-32	5	2	OCCUPIED
320	E-B2-35	5	2	OCCUPIED
286	E-B2-01	5	5	OCCUPIED
287	E-B2-02	5	5	OCCUPIED
288	E-B2-03	5	5	OCCUPIED
\.


--
-- Data for Name: parking_ticket; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.parking_ticket (ticket_no, vehicle_id, slot_id, entry_time, entry_gate_id, ticket_status) FROM stdin;
1	1	1	2026-08-17 09:30:00	1	COMPLETED
103	243	11	2026-10-21 20:58:00	3	COMPLETED
104	155	118	2026-10-21 21:12:00	1	COMPLETED
105	52	118	2026-10-21 17:03:00	1	COMPLETED
3	65	1	2026-11-02 14:58:34.491925	1	ACTIVE
4	327	31	2026-10-19 11:47:00	3	COMPLETED
5	306	122	2026-10-19 19:37:00	3	COMPLETED
6	112	121	2026-10-19 08:37:00	3	COMPLETED
7	318	318	2026-10-19 20:57:00	3	COMPLETED
8	320	55	2026-10-19 09:33:00	3	COMPLETED
9	249	51	2026-10-19 17:47:00	3	COMPLETED
10	226	146	2026-10-19 20:38:00	1	COMPLETED
11	68	26	2026-10-19 20:04:00	1	COMPLETED
12	162	136	2026-10-19 16:55:00	1	COMPLETED
13	173	49	2026-10-19 10:47:00	1	COMPLETED
14	363	65	2026-10-19 15:38:00	3	COMPLETED
15	116	45	2026-10-19 13:46:00	3	COMPLETED
16	79	131	2026-10-19 07:33:00	1	COMPLETED
17	1	39	2026-10-19 12:42:00	3	COMPLETED
18	387	54	2026-10-19 13:23:00	3	COMPLETED
19	260	261	2026-10-19 11:07:00	5	COMPLETED
20	283	239	2026-10-19 10:03:00	5	COMPLETED
21	302	134	2026-10-19 18:12:00	3	COMPLETED
22	346	192	2026-10-19 08:09:00	5	COMPLETED
23	352	233	2026-10-19 17:43:00	5	COMPLETED
24	58	128	2026-10-19 12:04:00	3	COMPLETED
25	211	77	2026-10-19 13:28:00	3	COMPLETED
26	310	70	2026-10-19 19:23:00	3	COMPLETED
27	1	13	2026-10-19 07:56:00	1	COMPLETED
28	222	56	2026-10-19 09:39:00	3	COMPLETED
29	248	33	2026-10-19 13:38:00	1	COMPLETED
30	101	111	2026-10-19 21:18:00	1	COMPLETED
31	334	86	2026-10-19 14:38:00	1	COMPLETED
32	94	73	2026-10-19 11:11:00	3	COMPLETED
33	202	273	2026-10-19 20:05:00	5	COMPLETED
34	92	41	2026-10-19 08:43:00	3	COMPLETED
35	106	28	2026-10-19 11:45:00	1	COMPLETED
36	344	175	2026-10-19 20:12:00	5	CANCELLED
37	117	78	2026-10-19 20:27:00	3	COMPLETED
38	375	236	2026-10-19 20:57:00	5	COMPLETED
39	203	67	2026-10-19 13:30:00	1	COMPLETED
40	372	63	2026-10-19 08:48:00	3	COMPLETED
41	146	197	2026-10-19 20:28:00	5	COMPLETED
42	252	98	2026-10-19 20:16:00	3	COMPLETED
43	331	9	2026-10-19 17:40:00	3	COMPLETED
44	102	269	2026-10-19 14:43:00	5	COMPLETED
45	261	155	2026-10-19 15:08:00	3	COMPLETED
46	387	17	2026-10-19 13:11:00	1	COMPLETED
47	380	142	2026-10-19 12:26:00	1	COMPLETED
48	367	55	2026-10-19 10:53:00	3	COMPLETED
49	133	110	2026-10-20 13:51:00	1	COMPLETED
50	210	113	2026-10-20 13:33:00	1	COMPLETED
51	166	244	2026-10-20 13:03:00	5	COMPLETED
52	301	26	2026-10-20 10:22:00	1	CANCELLED
53	230	318	2026-10-20 07:45:00	3	COMPLETED
54	349	146	2026-10-20 20:18:00	3	COMPLETED
55	171	109	2026-10-20 07:00:00	3	COMPLETED
56	52	125	2026-10-20 17:56:00	3	COMPLETED
57	284	316	2026-10-20 09:55:00	1	COMPLETED
58	194	248	2026-10-20 21:15:00	5	COMPLETED
59	343	259	2026-10-20 14:38:00	5	COMPLETED
60	278	8	2026-10-20 17:27:00	3	COMPLETED
61	290	63	2026-10-20 11:08:00	1	COMPLETED
62	163	118	2026-10-20 13:01:00	3	COMPLETED
63	189	82	2026-10-20 14:24:00	3	COMPLETED
64	386	252	2026-10-20 14:51:00	5	COMPLETED
65	255	76	2026-10-20 13:15:00	1	COMPLETED
66	110	280	2026-10-20 20:20:00	5	COMPLETED
67	163	84	2026-10-20 10:12:00	1	COMPLETED
68	55	99	2026-10-20 18:41:00	3	COMPLETED
69	304	77	2026-10-20 09:47:00	1	COMPLETED
70	64	32	2026-10-20 12:49:00	1	COMPLETED
71	119	14	2026-10-20 12:19:00	3	COMPLETED
72	159	113	2026-10-20 14:53:00	3	COMPLETED
73	315	182	2026-10-20 15:13:00	5	COMPLETED
74	225	187	2026-10-20 20:30:00	5	COMPLETED
75	298	217	2026-10-20 08:07:00	5	COMPLETED
76	142	206	2026-10-20 13:03:00	5	COMPLETED
77	343	280	2026-10-20 19:48:00	5	COMPLETED
78	91	59	2026-10-20 17:58:00	1	COMPLETED
79	62	111	2026-10-20 17:58:00	3	COMPLETED
80	383	221	2026-10-20 21:04:00	5	COMPLETED
81	106	19	2026-10-20 07:06:00	3	COMPLETED
82	112	118	2026-10-20 07:48:00	3	COMPLETED
83	366	91	2026-10-20 07:34:00	1	COMPLETED
84	163	112	2026-10-20 11:55:00	1	COMPLETED
85	133	104	2026-10-20 18:23:00	1	COMPLETED
86	329	97	2026-10-20 08:52:00	1	COMPLETED
87	376	59	2026-10-20 12:05:00	3	COMPLETED
88	270	244	2026-10-20 08:22:00	5	COMPLETED
89	168	36	2026-10-20 14:53:00	3	COMPLETED
90	278	99	2026-10-20 19:47:00	1	COMPLETED
91	298	212	2026-10-20 10:29:00	5	COMPLETED
92	231	166	2026-10-20 09:37:00	5	COMPLETED
93	87	271	2026-10-20 17:11:00	5	COMPLETED
94	307	247	2026-10-21 13:53:00	5	COMPLETED
95	160	11	2026-10-21 09:28:00	1	COMPLETED
96	364	57	2026-10-21 18:56:00	1	COMPLETED
97	352	262	2026-10-21 11:17:00	5	COMPLETED
98	264	143	2026-10-21 18:17:00	3	COMPLETED
99	173	97	2026-10-21 14:14:00	3	COMPLETED
100	269	51	2026-10-21 18:11:00	1	COMPLETED
101	129	202	2026-10-21 20:38:00	5	COMPLETED
102	112	57	2026-10-21 07:10:00	1	COMPLETED
106	275	208	2026-10-21 15:58:00	5	COMPLETED
107	321	235	2026-10-21 12:05:00	5	COMPLETED
108	328	15	2026-10-21 10:12:00	3	COMPLETED
109	200	156	2026-10-21 14:06:00	1	COMPLETED
110	110	206	2026-10-21 18:52:00	5	COMPLETED
111	386	260	2026-10-21 13:23:00	5	COMPLETED
112	291	115	2026-10-21 20:14:00	3	COMPLETED
113	207	6	2026-10-21 10:14:00	1	COMPLETED
114	355	88	2026-10-21 15:10:00	1	COMPLETED
115	56	52	2026-10-21 18:43:00	3	COMPLETED
116	222	59	2026-10-21 10:07:00	3	COMPLETED
117	254	132	2026-10-21 18:55:00	1	COMPLETED
118	276	119	2026-10-21 10:26:00	1	COMPLETED
119	57	45	2026-10-21 09:42:00	3	COMPLETED
120	149	13	2026-10-21 09:07:00	3	COMPLETED
121	341	58	2026-10-21 09:59:00	1	COMPLETED
122	372	107	2026-10-21 10:15:00	1	COMPLETED
123	313	239	2026-10-21 10:44:00	5	COMPLETED
124	180	141	2026-10-21 14:42:00	3	COMPLETED
125	293	242	2026-10-21 10:27:00	5	COMPLETED
126	324	237	2026-10-21 10:04:00	5	COMPLETED
127	284	137	2026-10-21 16:05:00	3	COMPLETED
128	343	163	2026-10-21 12:05:00	5	COMPLETED
129	290	111	2026-10-21 07:07:00	3	COMPLETED
130	102	246	2026-10-21 13:21:00	5	COMPLETED
131	316	31	2026-10-21 14:26:00	1	COMPLETED
132	339	73	2026-10-21 08:49:00	1	COMPLETED
133	371	226	2026-10-21 08:49:00	5	COMPLETED
134	49	65	2026-10-21 18:23:00	1	COMPLETED
135	162	140	2026-10-21 17:27:00	3	COMPLETED
136	308	175	2026-10-21 12:53:00	5	COMPLETED
137	339	60	2026-10-21 12:54:00	1	COMPLETED
138	224	115	2026-10-21 12:37:00	3	COMPLETED
139	72	104	2026-10-22 15:46:00	3	COMPLETED
140	247	40	2026-10-22 11:05:00	3	COMPLETED
141	355	46	2026-10-22 08:47:00	1	COMPLETED
142	92	94	2026-10-22 13:22:00	3	CANCELLED
143	155	36	2026-10-22 13:43:00	1	COMPLETED
144	84	41	2026-10-22 16:45:00	1	COMPLETED
145	154	88	2026-10-22 11:07:00	3	COMPLETED
146	197	14	2026-10-22 10:20:00	3	COMPLETED
147	200	82	2026-10-22 09:50:00	3	COMPLETED
148	373	262	2026-10-22 16:15:00	5	COMPLETED
149	133	10	2026-10-22 15:31:00	3	COMPLETED
150	81	130	2026-10-22 16:45:00	1	COMPLETED
151	345	151	2026-10-22 16:48:00	1	COMPLETED
152	50	45	2026-10-22 11:58:00	1	COMPLETED
153	100	194	2026-10-22 20:24:00	5	COMPLETED
154	230	149	2026-10-22 11:16:00	3	COMPLETED
155	252	110	2026-10-22 10:41:00	3	COMPLETED
156	359	113	2026-10-22 13:00:00	3	COMPLETED
157	99	233	2026-10-22 07:43:00	5	COMPLETED
158	288	186	2026-10-22 07:41:00	5	COMPLETED
159	379	104	2026-10-22 17:11:00	3	COMPLETED
160	189	78	2026-10-22 11:50:00	1	COMPLETED
161	100	201	2026-10-22 10:41:00	5	COMPLETED
162	210	65	2026-10-22 08:23:00	1	COMPLETED
163	259	34	2026-10-22 11:49:00	3	COMPLETED
164	299	95	2026-10-22 19:13:00	1	COMPLETED
165	260	240	2026-10-22 20:59:00	5	COMPLETED
166	72	68	2026-10-22 18:59:00	1	COMPLETED
167	345	135	2026-10-22 16:11:00	3	COMPLETED
168	115	90	2026-10-22 08:36:00	3	COMPLETED
169	59	38	2026-10-22 12:13:00	1	COMPLETED
170	216	57	2026-10-22 14:10:00	3	COMPLETED
171	356	143	2026-10-22 16:35:00	1	COMPLETED
172	204	138	2026-10-22 10:38:00	1	COMPLETED
173	309	97	2026-10-22 11:51:00	1	COMPLETED
174	286	250	2026-10-22 11:54:00	5	COMPLETED
175	65	53	2026-10-22 12:17:00	1	COMPLETED
176	291	119	2026-10-22 21:18:00	3	COMPLETED
177	265	154	2026-10-22 15:14:00	1	COMPLETED
178	273	168	2026-10-22 19:32:00	5	COMPLETED
179	316	64	2026-10-22 10:23:00	1	COMPLETED
180	89	141	2026-10-22 07:37:00	3	COMPLETED
181	50	26	2026-10-22 11:01:00	3	COMPLETED
182	220	168	2026-10-22 12:39:00	5	COMPLETED
183	291	99	2026-10-22 17:52:00	3	COMPLETED
184	299	31	2026-10-23 17:09:00	1	COMPLETED
185	278	33	2026-10-23 07:31:00	1	CANCELLED
186	56	7	2026-10-23 11:29:00	1	COMPLETED
187	129	242	2026-10-23 08:50:00	5	COMPLETED
188	306	107	2026-10-23 17:54:00	3	COMPLETED
189	364	111	2026-10-23 13:22:00	1	COMPLETED
190	96	66	2026-10-23 16:25:00	3	COMPLETED
191	363	52	2026-10-23 07:15:00	3	COMPLETED
192	261	151	2026-10-23 08:27:00	1	COMPLETED
193	111	63	2026-10-23 10:35:00	1	COMPLETED
194	177	116	2026-10-23 08:49:00	1	COMPLETED
195	293	213	2026-10-23 17:46:00	5	CANCELLED
196	229	40	2026-10-23 07:40:00	3	COMPLETED
197	141	148	2026-10-23 20:20:00	1	COMPLETED
198	158	193	2026-10-23 14:42:00	5	COMPLETED
199	144	242	2026-10-23 20:00:00	5	COMPLETED
200	45	104	2026-10-23 20:57:00	3	COMPLETED
201	226	154	2026-10-23 11:40:00	3	COMPLETED
202	129	218	2026-10-23 11:57:00	5	COMPLETED
203	130	318	2026-10-23 15:26:00	1	COMPLETED
204	356	155	2026-10-23 10:11:00	3	COMPLETED
205	125	171	2026-10-23 14:44:00	5	COMPLETED
206	219	53	2026-10-23 11:33:00	1	COMPLETED
207	178	249	2026-10-23 07:15:00	5	COMPLETED
208	136	244	2026-10-23 08:20:00	5	COMPLETED
209	313	223	2026-10-23 11:20:00	5	COMPLETED
210	274	67	2026-10-23 13:54:00	1	COMPLETED
211	370	88	2026-10-23 10:51:00	1	COMPLETED
212	315	189	2026-10-23 20:35:00	5	COMPLETED
213	195	116	2026-10-23 14:17:00	1	COMPLETED
214	213	123	2026-10-23 17:34:00	1	COMPLETED
215	265	76	2026-10-23 10:56:00	1	COMPLETED
216	89	159	2026-10-23 20:15:00	3	COMPLETED
217	337	114	2026-10-23 07:02:00	3	COMPLETED
218	373	162	2026-10-23 17:47:00	5	COMPLETED
219	124	97	2026-10-23 14:10:00	3	COMPLETED
220	359	87	2026-10-23 09:38:00	1	COMPLETED
221	206	213	2026-10-23 12:33:00	5	COMPLETED
222	142	176	2026-10-23 16:50:00	5	COMPLETED
223	334	108	2026-10-23 10:53:00	3	COMPLETED
224	353	228	2026-10-23 07:29:00	5	COMPLETED
225	155	38	2026-10-23 14:13:00	3	COMPLETED
226	350	11	2026-10-23 16:07:00	3	COMPLETED
227	256	73	2026-10-23 16:33:00	1	COMPLETED
228	113	57	2026-10-23 15:01:00	3	COMPLETED
229	121	263	2026-10-24 09:37:00	5	COMPLETED
230	356	135	2026-10-24 16:24:00	1	COMPLETED
231	187	280	2026-10-24 16:02:00	5	COMPLETED
232	119	15	2026-10-24 19:35:00	3	COMPLETED
233	167	177	2026-10-24 07:01:00	5	COMPLETED
234	152	118	2026-10-24 07:39:00	1	COMPLETED
235	176	81	2026-10-24 10:41:00	1	COMPLETED
236	383	268	2026-10-24 12:34:00	5	COMPLETED
237	188	142	2026-10-24 09:50:00	3	COMPLETED
238	370	69	2026-10-24 08:58:00	1	COMPLETED
239	387	108	2026-10-24 19:41:00	1	COMPLETED
240	242	188	2026-10-24 20:25:00	5	COMPLETED
241	321	242	2026-10-24 07:47:00	5	COMPLETED
242	123	69	2026-10-24 13:07:00	3	COMPLETED
243	335	276	2026-10-24 18:55:00	5	COMPLETED
244	277	108	2026-10-24 19:48:00	3	COMPLETED
245	266	216	2026-10-24 19:04:00	5	COMPLETED
246	69	72	2026-10-24 08:57:00	3	COMPLETED
247	299	48	2026-10-24 07:09:00	1	COMPLETED
248	182	71	2026-10-24 09:07:00	1	COMPLETED
249	332	240	2026-10-24 11:58:00	5	COMPLETED
250	324	232	2026-10-24 12:09:00	5	COMPLETED
251	57	93	2026-10-24 11:09:00	3	COMPLETED
252	385	18	2026-10-24 10:09:00	1	COMPLETED
253	198	10	2026-10-24 07:02:00	1	COMPLETED
254	347	97	2026-10-24 14:33:00	3	CANCELLED
255	130	82	2026-10-24 17:15:00	1	COMPLETED
256	338	63	2026-10-24 18:42:00	1	COMPLETED
257	389	79	2026-10-24 20:46:00	1	COMPLETED
258	255	161	2026-10-24 13:55:00	3	COMPLETED
259	112	39	2026-10-24 11:38:00	1	COMPLETED
260	106	34	2026-10-24 07:02:00	1	COMPLETED
261	196	33	2026-10-24 20:19:00	1	COMPLETED
262	293	163	2026-10-24 13:11:00	5	COMPLETED
263	362	55	2026-10-24 12:25:00	1	COMPLETED
264	190	205	2026-10-24 11:05:00	5	COMPLETED
265	318	141	2026-10-24 12:07:00	3	COMPLETED
266	208	8	2026-10-24 10:38:00	3	COMPLETED
267	385	93	2026-10-24 07:55:00	1	COMPLETED
268	249	94	2026-10-24 18:51:00	3	COMPLETED
269	142	168	2026-10-24 07:12:00	5	COMPLETED
270	167	266	2026-10-24 15:07:00	5	COMPLETED
271	91	118	2026-10-24 13:17:00	3	COMPLETED
272	231	204	2026-10-24 14:50:00	5	COMPLETED
273	113	6	2026-10-24 15:36:00	3	COMPLETED
274	309	16	2026-10-24 13:58:00	1	COMPLETED
275	372	53	2026-10-24 17:50:00	3	COMPLETED
276	52	117	2026-10-24 10:07:00	1	COMPLETED
277	195	118	2026-10-24 11:49:00	1	COMPLETED
278	67	120	2026-10-24 13:06:00	1	COMPLETED
279	52	51	2026-10-24 07:10:00	3	COMPLETED
280	370	108	2026-10-24 08:28:00	1	COMPLETED
281	99	254	2026-10-24 21:25:00	5	COMPLETED
282	260	190	2026-10-24 10:08:00	5	COMPLETED
283	219	33	2026-10-24 18:29:00	1	COMPLETED
284	120	270	2026-10-24 08:09:00	5	COMPLETED
285	364	14	2026-10-24 13:20:00	3	COMPLETED
286	290	7	2026-10-24 14:52:00	3	COMPLETED
287	129	260	2026-10-24 11:13:00	5	COMPLETED
288	275	204	2026-10-24 07:04:00	5	COMPLETED
289	179	257	2026-10-24 17:05:00	5	COMPLETED
290	341	114	2026-10-24 09:54:00	3	COMPLETED
291	120	206	2026-10-24 10:18:00	5	COMPLETED
292	388	135	2026-10-24 17:48:00	1	COMPLETED
293	84	121	2026-10-24 11:10:00	3	COMPLETED
294	239	51	2026-10-24 07:09:00	3	CANCELLED
295	341	55	2026-10-24 16:41:00	1	COMPLETED
296	262	232	2026-10-24 20:30:00	5	COMPLETED
297	153	66	2026-10-24 21:20:00	1	COMPLETED
298	75	72	2026-10-24 08:49:00	3	COMPLETED
299	144	243	2026-10-25 13:28:00	5	COMPLETED
300	317	71	2026-10-25 14:05:00	1	COMPLETED
301	121	279	2026-10-25 07:31:00	5	COMPLETED
302	241	252	2026-10-25 20:21:00	5	COMPLETED
303	240	147	2026-10-25 11:53:00	3	COMPLETED
304	68	46	2026-10-25 21:07:00	1	COMPLETED
305	366	52	2026-10-25 10:40:00	3	COMPLETED
306	289	280	2026-10-25 14:42:00	5	COMPLETED
307	273	201	2026-10-25 13:09:00	5	COMPLETED
308	86	285	2026-10-25 16:44:00	1	COMPLETED
309	237	132	2026-10-25 11:33:00	1	COMPLETED
310	263	179	2026-10-25 19:51:00	5	COMPLETED
311	114	147	2026-10-25 10:01:00	1	COMPLETED
312	127	134	2026-10-25 17:27:00	3	COMPLETED
313	339	38	2026-10-25 12:28:00	1	COMPLETED
314	141	150	2026-10-25 12:59:00	1	COMPLETED
315	165	143	2026-10-25 09:10:00	3	COMPLETED
316	386	216	2026-10-25 07:58:00	5	COMPLETED
317	290	39	2026-10-25 07:34:00	3	COMPLETED
318	334	59	2026-10-25 16:04:00	1	COMPLETED
319	58	46	2026-10-25 16:10:00	1	COMPLETED
320	124	113	2026-10-25 12:37:00	3	COMPLETED
321	222	106	2026-10-25 09:13:00	3	COMPLETED
322	376	97	2026-10-25 18:00:00	3	COMPLETED
323	373	216	2026-10-25 21:28:00	5	COMPLETED
324	289	207	2026-10-25 20:36:00	5	COMPLETED
325	136	236	2026-10-25 20:18:00	5	COMPLETED
326	208	119	2026-10-25 11:41:00	1	COMPLETED
327	145	69	2026-10-25 07:22:00	1	COMPLETED
328	79	65	2026-10-25 09:30:00	1	COMPLETED
329	188	155	2026-10-25 10:58:00	1	COMPLETED
330	141	158	2026-10-25 14:32:00	1	COMPLETED
331	226	154	2026-10-25 12:21:00	1	COMPLETED
332	337	112	2026-10-25 19:17:00	3	COMPLETED
333	301	104	2026-10-25 14:42:00	3	COMPLETED
334	174	132	2026-10-25 14:10:00	1	COMPLETED
335	275	187	2026-10-25 11:13:00	5	COMPLETED
336	116	11	2026-10-25 09:11:00	1	COMPLETED
337	281	49	2026-10-25 15:09:00	3	COMPLETED
338	293	276	2026-10-25 09:23:00	5	COMPLETED
339	211	154	2026-10-25 20:21:00	3	COMPLETED
340	313	255	2026-10-25 09:58:00	5	COMPLETED
341	113	47	2026-10-25 14:50:00	3	COMPLETED
342	57	116	2026-10-25 13:39:00	3	COMPLETED
343	187	224	2026-10-25 11:20:00	5	COMPLETED
344	84	122	2026-10-25 12:21:00	1	COMPLETED
345	345	140	2026-10-25 13:37:00	1	COMPLETED
346	193	83	2026-10-25 17:23:00	1	COMPLETED
347	354	254	2026-10-25 20:07:00	5	COMPLETED
348	340	261	2026-10-25 16:48:00	5	CANCELLED
349	127	146	2026-10-25 12:37:00	1	COMPLETED
350	180	80	2026-10-25 14:37:00	3	COMPLETED
351	61	96	2026-10-25 10:36:00	3	COMPLETED
352	66	62	2026-10-25 15:52:00	3	COMPLETED
353	246	92	2026-10-25 19:37:00	1	COMPLETED
354	102	191	2026-10-25 11:21:00	5	COMPLETED
355	251	120	2026-10-25 10:54:00	3	COMPLETED
356	113	44	2026-10-25 14:10:00	1	COMPLETED
357	184	72	2026-10-25 18:41:00	1	COMPLETED
358	187	162	2026-10-25 14:00:00	5	COMPLETED
359	169	273	2026-10-25 13:48:00	5	COMPLETED
360	341	69	2026-10-25 21:24:00	1	COMPLETED
361	367	14	2026-10-25 10:42:00	1	COMPLETED
362	107	184	2026-10-25 17:08:00	5	COMPLETED
363	375	238	2026-10-25 14:45:00	5	COMPLETED
364	350	13	2026-10-25 20:53:00	1	COMPLETED
365	46	71	2026-10-25 14:01:00	1	COMPLETED
366	194	238	2026-10-25 12:47:00	5	COMPLETED
367	240	153	2026-10-25 07:49:00	3	COMPLETED
368	261	146	2026-10-25 16:35:00	3	COMPLETED
369	230	142	2026-10-26 11:47:00	3	COMPLETED
370	65	114	2026-10-26 09:37:00	3	COMPLETED
371	191	116	2026-10-26 09:14:00	1	COMPLETED
372	296	256	2026-10-26 16:36:00	5	COMPLETED
373	319	116	2026-10-26 19:20:00	3	COMPLETED
374	294	11	2026-10-26 14:32:00	1	COMPLETED
375	235	137	2026-10-26 20:01:00	3	COMPLETED
376	105	267	2026-10-26 18:34:00	5	COMPLETED
377	2	18	2026-10-26 19:43:00	1	COMPLETED
378	45	65	2026-10-26 20:48:00	1	COMPLETED
379	280	46	2026-10-26 17:58:00	3	COMPLETED
380	146	265	2026-10-26 10:15:00	5	COMPLETED
381	61	16	2026-10-26 18:35:00	3	COMPLETED
382	65	113	2026-10-26 19:51:00	3	COMPLETED
383	237	159	2026-10-26 19:48:00	3	COMPLETED
384	225	277	2026-10-26 18:04:00	5	COMPLETED
385	270	270	2026-10-26 15:35:00	5	COMPLETED
386	330	116	2026-10-26 12:47:00	3	COMPLETED
387	339	123	2026-10-26 09:32:00	3	COMPLETED
388	258	276	2026-10-26 13:18:00	5	COMPLETED
389	204	79	2026-10-26 11:29:00	1	COMPLETED
390	133	106	2026-10-26 11:26:00	3	COMPLETED
391	124	113	2026-10-26 12:09:00	3	COMPLETED
392	81	8	2026-10-26 14:30:00	3	COMPLETED
393	373	222	2026-10-26 19:02:00	5	COMPLETED
394	83	15	2026-10-26 15:23:00	3	COMPLETED
395	190	168	2026-10-26 15:55:00	5	COMPLETED
396	233	255	2026-10-26 13:58:00	5	COMPLETED
397	115	8	2026-10-26 14:28:00	3	COMPLETED
398	321	165	2026-10-26 15:24:00	5	COMPLETED
399	306	69	2026-10-26 15:03:00	1	COMPLETED
400	285	15	2026-10-26 16:34:00	3	COMPLETED
401	126	230	2026-10-26 09:03:00	5	COMPLETED
402	167	201	2026-10-26 16:34:00	5	COMPLETED
403	271	53	2026-10-26 11:09:00	3	COMPLETED
404	300	91	2026-10-26 07:13:00	3	COMPLETED
405	291	64	2026-10-26 07:27:00	1	COMPLETED
406	329	112	2026-10-26 18:56:00	1	COMPLETED
407	52	55	2026-10-26 20:32:00	3	COMPLETED
408	352	267	2026-10-26 12:27:00	5	COMPLETED
409	213	88	2026-10-26 15:03:00	1	COMPLETED
410	372	11	2026-10-26 14:13:00	1	COMPLETED
411	170	207	2026-10-26 18:59:00	5	COMPLETED
412	249	110	2026-10-26 14:52:00	1	COMPLETED
413	65	50	2026-10-26 16:02:00	3	COMPLETED
414	295	52	2026-10-27 16:45:00	3	COMPLETED
415	62	10	2026-10-27 18:07:00	1	COMPLETED
416	175	86	2026-10-27 18:47:00	1	COMPLETED
417	284	141	2026-10-27 16:50:00	3	COMPLETED
418	55	18	2026-10-27 07:37:00	3	COMPLETED
419	337	36	2026-10-27 18:47:00	3	COMPLETED
420	193	150	2026-10-27 15:19:00	3	COMPLETED
421	338	33	2026-10-27 16:42:00	1	COMPLETED
422	314	262	2026-10-27 08:00:00	5	COMPLETED
423	246	34	2026-10-27 15:36:00	1	COMPLETED
424	65	69	2026-10-27 16:14:00	1	COMPLETED
425	173	63	2026-10-27 16:05:00	3	COMPLETED
426	354	217	2026-10-27 14:54:00	5	COMPLETED
427	101	28	2026-10-27 16:09:00	1	COMPLETED
428	187	270	2026-10-27 12:56:00	5	COMPLETED
429	221	34	2026-10-27 11:26:00	3	COMPLETED
430	156	204	2026-10-27 16:07:00	5	COMPLETED
431	134	200	2026-10-27 20:21:00	5	COMPLETED
432	254	135	2026-10-27 21:21:00	1	COMPLETED
433	155	54	2026-10-27 11:04:00	1	COMPLETED
434	245	262	2026-10-27 16:29:00	5	COMPLETED
435	333	30	2026-10-27 08:46:00	1	COMPLETED
436	95	154	2026-10-27 12:47:00	1	COMPLETED
437	153	84	2026-10-27 16:30:00	1	COMPLETED
438	243	65	2026-10-27 18:23:00	3	COMPLETED
439	388	133	2026-10-27 20:58:00	3	COMPLETED
440	222	18	2026-10-27 10:52:00	1	COMPLETED
441	51	119	2026-10-27 10:51:00	3	COMPLETED
442	244	84	2026-10-27 15:26:00	1	COMPLETED
443	286	205	2026-10-27 08:45:00	5	COMPLETED
444	363	108	2026-10-27 07:03:00	3	COMPLETED
445	242	240	2026-10-27 10:45:00	5	COMPLETED
446	147	252	2026-10-27 17:06:00	5	COMPLETED
447	384	54	2026-10-27 08:11:00	1	COMPLETED
448	51	56	2026-10-27 15:55:00	3	COMPLETED
449	320	12	2026-10-27 08:06:00	1	COMPLETED
450	63	6	2026-10-27 12:37:00	3	COMPLETED
451	309	64	2026-10-27 16:38:00	3	COMPLETED
452	340	186	2026-10-27 09:58:00	5	COMPLETED
453	47	62	2026-10-27 13:23:00	1	COMPLETED
454	132	166	2026-10-27 09:07:00	5	COMPLETED
455	369	115	2026-10-27 20:32:00	1	COMPLETED
456	187	230	2026-10-27 12:27:00	5	COMPLETED
457	308	225	2026-10-27 12:49:00	5	COMPLETED
458	373	220	2026-10-27 10:04:00	5	COMPLETED
459	248	97	2026-10-28 09:44:00	3	COMPLETED
460	205	18	2026-10-28 16:07:00	3	COMPLETED
461	114	317	2026-10-28 16:21:00	1	COMPLETED
462	193	137	2026-10-28 21:26:00	1	COMPLETED
463	376	89	2026-10-28 18:32:00	3	COMPLETED
464	254	138	2026-10-28 21:23:00	3	COMPLETED
465	193	145	2026-10-28 09:51:00	3	COMPLETED
466	302	146	2026-10-28 08:32:00	1	COMPLETED
467	165	139	2026-10-28 09:29:00	3	COMPLETED
468	178	275	2026-10-28 21:05:00	5	COMPLETED
469	253	138	2026-10-28 18:11:00	1	COMPLETED
470	61	31	2026-10-28 11:14:00	1	COMPLETED
471	176	83	2026-10-28 07:58:00	3	COMPLETED
472	271	108	2026-10-28 07:26:00	1	COMPLETED
473	293	220	2026-10-28 14:29:00	5	COMPLETED
474	106	73	2026-10-28 19:00:00	1	COMPLETED
475	211	135	2026-10-28 17:35:00	3	COMPLETED
476	112	88	2026-10-28 20:04:00	3	COMPLETED
477	235	320	2026-10-28 15:57:00	1	COMPLETED
478	181	71	2026-10-28 12:16:00	3	COMPLETED
479	171	1	2026-10-28 08:32:00	1	COMPLETED
480	353	212	2026-10-28 15:33:00	5	COMPLETED
481	60	47	2026-10-28 20:25:00	3	COMPLETED
482	254	151	2026-10-28 14:54:00	3	COMPLETED
483	306	108	2026-10-28 11:53:00	1	COMPLETED
484	188	159	2026-10-28 15:05:00	3	COMPLETED
485	146	273	2026-10-28 14:53:00	5	COMPLETED
486	84	11	2026-10-28 19:12:00	1	COMPLETED
487	226	154	2026-10-28 17:14:00	1	COMPLETED
488	273	188	2026-10-28 19:01:00	5	COMPLETED
489	48	131	2026-10-28 13:02:00	1	COMPLETED
490	286	162	2026-10-28 13:13:00	5	COMPLETED
491	107	199	2026-10-28 08:32:00	5	COMPLETED
492	151	180	2026-10-28 21:12:00	5	COMPLETED
493	93	187	2026-10-28 12:09:00	5	COMPLETED
494	84	52	2026-10-28 18:21:00	3	CANCELLED
495	50	73	2026-10-28 07:31:00	3	COMPLETED
496	107	190	2026-10-28 15:44:00	5	COMPLETED
497	269	7	2026-10-28 07:43:00	1	COMPLETED
498	222	117	2026-10-28 14:59:00	1	COMPLETED
499	57	55	2026-10-28 13:06:00	1	CANCELLED
500	99	276	2026-10-28 10:33:00	5	COMPLETED
501	162	143	2026-10-28 16:46:00	3	COMPLETED
502	336	246	2026-10-28 13:30:00	5	COMPLETED
503	86	283	2026-10-28 11:55:00	1	COMPLETED
504	278	117	2026-10-29 09:57:00	1	COMPLETED
505	329	34	2026-10-29 16:40:00	3	COMPLETED
506	236	202	2026-10-29 14:58:00	5	COMPLETED
507	102	211	2026-10-29 07:47:00	5	COMPLETED
508	80	94	2026-10-29 13:19:00	1	COMPLETED
509	266	178	2026-10-29 12:15:00	5	COMPLETED
510	150	154	2026-10-29 18:17:00	3	COMPLETED
511	228	30	2026-10-29 19:47:00	3	COMPLETED
512	120	164	2026-10-29 16:48:00	5	COMPLETED
513	203	32	2026-10-29 07:49:00	3	COMPLETED
514	324	237	2026-10-29 18:03:00	5	COMPLETED
515	266	186	2026-10-29 15:34:00	5	COMPLETED
516	281	9	2026-10-29 07:29:00	1	COMPLETED
517	252	110	2026-10-29 08:59:00	1	COMPLETED
518	2	104	2026-10-29 12:53:00	1	COMPLETED
519	112	122	2026-10-29 09:17:00	1	COMPLETED
520	181	99	2026-10-29 16:58:00	3	COMPLETED
521	123	53	2026-10-29 11:26:00	1	COMPLETED
522	174	157	2026-10-29 13:40:00	3	COMPLETED
523	106	97	2026-10-29 07:08:00	3	COMPLETED
524	107	198	2026-10-29 09:04:00	5	COMPLETED
525	279	215	2026-10-29 09:47:00	5	COMPLETED
526	162	158	2026-10-29 16:45:00	1	COMPLETED
527	274	105	2026-10-29 16:20:00	3	COMPLETED
528	378	240	2026-10-29 14:27:00	5	CANCELLED
529	202	234	2026-10-29 15:32:00	5	COMPLETED
530	345	134	2026-10-29 19:17:00	1	COMPLETED
531	122	173	2026-10-29 09:51:00	5	COMPLETED
532	232	159	2026-10-29 09:20:00	3	COMPLETED
533	234	50	2026-10-29 10:23:00	3	COMPLETED
534	151	221	2026-10-29 12:38:00	5	COMPLETED
535	360	61	2026-10-29 07:27:00	3	COMPLETED
536	246	8	2026-10-29 08:00:00	3	COMPLETED
537	224	15	2026-10-29 13:15:00	3	COMPLETED
538	190	191	2026-10-29 21:03:00	5	COMPLETED
539	216	33	2026-10-29 09:43:00	3	COMPLETED
540	110	229	2026-10-29 20:42:00	5	COMPLETED
541	50	7	2026-10-29 20:15:00	1	COMPLETED
542	310	96	2026-10-29 14:44:00	3	COMPLETED
543	367	61	2026-10-29 12:32:00	3	COMPLETED
544	280	12	2026-10-29 09:07:00	1	COMPLETED
545	85	283	2026-10-29 16:52:00	1	COMPLETED
546	311	160	2026-10-29 17:23:00	3	COMPLETED
547	303	174	2026-10-29 17:11:00	5	COMPLETED
548	318	158	2026-10-29 20:27:00	1	COMPLETED
549	306	118	2026-10-30 16:53:00	3	COMPLETED
550	245	185	2026-10-30 19:30:00	5	COMPLETED
551	254	150	2026-10-30 09:39:00	3	COMPLETED
552	66	9	2026-10-30 15:17:00	3	COMPLETED
553	316	122	2026-10-30 07:55:00	1	COMPLETED
554	153	57	2026-10-30 20:11:00	3	COMPLETED
555	186	6	2026-10-30 11:36:00	3	COMPLETED
556	264	319	2026-10-30 11:18:00	1	COMPLETED
557	249	14	2026-10-30 13:55:00	3	COMPLETED
558	224	53	2026-10-30 14:04:00	1	COMPLETED
559	170	191	2026-10-30 13:04:00	5	COMPLETED
560	156	209	2026-10-30 20:45:00	5	COMPLETED
561	143	281	2026-10-30 21:06:00	5	COMPLETED
562	116	84	2026-10-30 11:01:00	1	COMPLETED
563	324	229	2026-10-30 20:09:00	5	COMPLETED
564	146	281	2026-10-30 20:27:00	5	COMPLETED
565	340	275	2026-10-30 15:19:00	5	COMPLETED
566	380	317	2026-10-30 19:10:00	3	COMPLETED
567	180	147	2026-10-30 09:16:00	3	COMPLETED
568	157	115	2026-10-30 11:00:00	3	COMPLETED
569	364	117	2026-10-30 18:29:00	1	COMPLETED
570	290	7	2026-10-30 10:51:00	1	CANCELLED
571	48	124	2026-10-30 20:29:00	1	COMPLETED
572	155	99	2026-10-30 09:55:00	3	COMPLETED
573	153	70	2026-10-30 14:55:00	1	COMPLETED
574	223	58	2026-10-30 15:47:00	3	COMPLETED
575	311	75	2026-10-30 18:36:00	1	COMPLETED
576	151	230	2026-10-30 20:03:00	5	COMPLETED
577	240	157	2026-10-30 11:29:00	3	COMPLETED
578	266	280	2026-10-30 16:25:00	5	COMPLETED
579	347	39	2026-10-30 20:57:00	3	COMPLETED
580	236	280	2026-10-30 07:04:00	5	COMPLETED
581	92	101	2026-10-30 11:18:00	1	COMPLETED
582	56	57	2026-10-30 19:12:00	3	COMPLETED
583	188	321	2026-10-30 17:33:00	3	COMPLETED
584	187	170	2026-10-30 20:46:00	5	COMPLETED
585	165	74	2026-10-30 10:37:00	3	COMPLETED
586	329	12	2026-10-30 15:07:00	3	COMPLETED
587	149	17	2026-10-30 08:15:00	3	COMPLETED
588	282	316	2026-10-30 16:50:00	1	COMPLETED
589	102	212	2026-10-30 11:27:00	5	CANCELLED
590	260	213	2026-10-30 17:43:00	5	COMPLETED
591	326	112	2026-10-30 18:25:00	1	COMPLETED
592	337	88	2026-10-30 15:38:00	3	COMPLETED
593	54	106	2026-10-30 13:26:00	3	COMPLETED
594	257	239	2026-10-31 09:56:00	5	COMPLETED
595	192	84	2026-10-31 08:03:00	3	COMPLETED
596	323	268	2026-10-31 07:22:00	5	COMPLETED
597	302	143	2026-10-31 19:42:00	1	COMPLETED
598	149	69	2026-10-31 07:20:00	1	COMPLETED
599	94	9	2026-10-31 20:17:00	3	COMPLETED
600	238	213	2026-10-31 11:12:00	5	COMPLETED
601	201	181	2026-10-31 16:21:00	5	COMPLETED
602	88	150	2026-10-31 19:35:00	3	CANCELLED
603	330	14	2026-10-31 12:22:00	3	COMPLETED
604	344	194	2026-10-31 21:11:00	5	COMPLETED
605	295	122	2026-10-31 13:16:00	1	COMPLETED
606	71	49	2026-10-31 16:40:00	3	COMPLETED
607	282	147	2026-10-31 13:51:00	1	COMPLETED
608	299	12	2026-10-31 10:37:00	3	COMPLETED
609	260	209	2026-10-31 16:42:00	5	COMPLETED
610	76	52	2026-10-31 19:57:00	3	COMPLETED
611	192	73	2026-10-31 09:31:00	3	COMPLETED
612	377	157	2026-10-31 21:12:00	3	COMPLETED
613	334	107	2026-10-31 08:35:00	3	COMPLETED
614	151	280	2026-10-31 12:04:00	5	COMPLETED
615	161	63	2026-10-31 15:41:00	3	COMPLETED
616	242	236	2026-10-31 14:55:00	5	COMPLETED
617	225	163	2026-10-31 17:10:00	5	COMPLETED
618	350	28	2026-10-31 18:46:00	3	COMPLETED
619	185	247	2026-10-31 14:06:00	5	COMPLETED
620	134	229	2026-10-31 08:27:00	5	COMPLETED
621	345	146	2026-10-31 13:05:00	1	COMPLETED
622	351	70	2026-10-31 15:22:00	3	COMPLETED
623	81	109	2026-10-31 11:25:00	1	COMPLETED
624	370	51	2026-10-31 12:30:00	3	COMPLETED
625	55	44	2026-10-31 19:02:00	1	COMPLETED
626	125	219	2026-10-31 20:52:00	5	COMPLETED
627	301	13	2026-10-31 19:29:00	3	COMPLETED
628	295	56	2026-10-31 07:46:00	3	COMPLETED
629	94	22	2026-10-31 10:15:00	1	COMPLETED
630	352	167	2026-10-31 15:11:00	5	COMPLETED
631	254	151	2026-10-31 17:58:00	3	COMPLETED
632	147	269	2026-10-31 12:28:00	5	COMPLETED
633	213	46	2026-10-31 15:37:00	3	COMPLETED
634	53	119	2026-10-31 12:05:00	1	COMPLETED
635	119	44	2026-10-31 14:26:00	1	COMPLETED
636	174	146	2026-10-31 13:16:00	3	COMPLETED
637	157	113	2026-10-31 15:31:00	3	COMPLETED
638	198	33	2026-10-31 20:06:00	1	COMPLETED
639	145	113	2026-10-31 15:14:00	3	COMPLETED
640	82	251	2026-10-31 08:01:00	5	COMPLETED
641	352	254	2026-10-31 07:10:00	5	COMPLETED
642	241	246	2026-10-31 11:53:00	5	COMPLETED
643	370	110	2026-10-31 20:25:00	1	COMPLETED
644	381	36	2026-10-31 15:46:00	1	COMPLETED
645	196	65	2026-10-31 08:24:00	3	COMPLETED
646	360	92	2026-10-31 15:28:00	3	COMPLETED
647	161	108	2026-10-31 12:35:00	1	COMPLETED
648	176	82	2026-10-31 11:36:00	3	COMPLETED
649	170	164	2026-10-31 20:44:00	5	COMPLETED
650	348	107	2026-10-31 12:57:00	1	COMPLETED
651	82	264	2026-10-31 11:15:00	5	COMPLETED
652	120	178	2026-10-31 18:08:00	5	COMPLETED
653	301	109	2026-10-31 17:44:00	1	COMPLETED
654	183	144	2026-10-31 20:35:00	3	COMPLETED
655	320	13	2026-10-31 17:53:00	1	COMPLETED
656	221	71	2026-10-31 21:25:00	1	COMPLETED
657	213	67	2026-10-31 09:13:00	1	COMPLETED
658	297	137	2026-10-31 16:27:00	1	COMPLETED
659	360	55	2026-10-31 10:07:00	1	COMPLETED
660	141	140	2026-10-31 07:41:00	1	COMPLETED
661	291	67	2026-10-31 21:24:00	1	COMPLETED
662	255	316	2026-10-31 09:51:00	1	COMPLETED
663	125	218	2026-10-31 18:06:00	5	COMPLETED
664	375	263	2026-11-01 09:03:00	5	COMPLETED
665	146	236	2026-11-01 15:59:00	5	COMPLETED
666	75	47	2026-11-01 09:35:00	3	COMPLETED
667	144	210	2026-11-01 07:47:00	5	COMPLETED
668	119	55	2026-11-01 15:30:00	1	COMPLETED
669	126	265	2026-11-01 11:09:00	5	CANCELLED
670	337	16	2026-11-01 12:06:00	1	COMPLETED
671	338	106	2026-11-01 20:31:00	1	COMPLETED
672	263	184	2026-11-01 08:49:00	5	COMPLETED
673	168	50	2026-11-01 09:40:00	3	COMPLETED
674	76	54	2026-11-01 17:14:00	1	COMPLETED
675	137	48	2026-11-01 18:34:00	3	COMPLETED
676	226	75	2026-11-01 12:39:00	3	COMPLETED
677	270	236	2026-11-01 09:43:00	5	COMPLETED
678	266	214	2026-11-01 10:13:00	5	COMPLETED
679	251	63	2026-11-01 07:20:00	3	COMPLETED
680	186	41	2026-11-01 13:28:00	1	COMPLETED
681	287	141	2026-11-01 16:09:00	3	COMPLETED
682	126	251	2026-11-01 07:16:00	5	COMPLETED
683	241	245	2026-11-01 13:34:00	5	COMPLETED
684	173	120	2026-11-01 12:51:00	1	COMPLETED
685	377	137	2026-11-01 21:03:00	1	COMPLETED
686	325	8	2026-11-01 20:53:00	1	COMPLETED
687	58	22	2026-11-01 08:28:00	1	COMPLETED
688	73	57	2026-11-01 16:33:00	1	COMPLETED
689	278	67	2026-11-01 07:19:00	3	COMPLETED
690	111	112	2026-11-01 16:21:00	1	COMPLETED
691	99	274	2026-11-01 19:44:00	5	COMPLETED
692	343	264	2026-11-01 09:38:00	5	COMPLETED
693	175	50	2026-11-01 18:40:00	3	COMPLETED
694	56	49	2026-11-01 07:28:00	3	COMPLETED
695	373	277	2026-11-01 09:15:00	5	COMPLETED
696	273	168	2026-11-01 15:19:00	5	COMPLETED
697	367	24	2026-11-01 21:29:00	3	COMPLETED
698	67	117	2026-11-01 12:13:00	3	COMPLETED
699	62	114	2026-11-01 21:17:00	1	COMPLETED
700	365	46	2026-11-01 12:49:00	1	COMPLETED
701	214	33	2026-11-01 18:38:00	1	COMPLETED
702	354	272	2026-11-01 10:12:00	5	CANCELLED
703	344	196	2026-11-01 11:51:00	5	COMPLETED
704	45	33	2026-11-01 18:11:00	3	COMPLETED
705	208	10	2026-11-01 13:20:00	3	CANCELLED
706	277	90	2026-11-01 18:22:00	3	COMPLETED
707	252	71	2026-11-01 14:27:00	3	COMPLETED
708	57	117	2026-11-01 17:15:00	3	COMPLETED
709	260	168	2026-11-01 10:58:00	5	COMPLETED
710	206	168	2026-11-01 14:11:00	5	COMPLETED
711	363	26	2026-11-01 17:12:00	3	COMPLETED
712	286	240	2026-11-01 16:44:00	5	COMPLETED
713	130	139	2026-11-01 21:13:00	1	COMPLETED
714	363	49	2026-11-01 14:32:00	1	COMPLETED
715	62	107	2026-11-01 19:36:00	1	COMPLETED
716	143	273	2026-11-01 18:23:00	5	COMPLETED
717	84	122	2026-11-01 10:11:00	1	COMPLETED
718	144	207	2026-11-01 15:39:00	5	COMPLETED
719	63	36	2026-11-01 09:37:00	1	COMPLETED
720	64	51	2026-11-01 09:30:00	3	COMPLETED
721	92	98	2026-11-01 08:12:00	1	COMPLETED
722	211	81	2026-11-01 20:07:00	1	COMPLETED
723	211	79	2026-11-01 10:46:00	1	COMPLETED
724	289	189	2026-11-01 07:43:00	5	COMPLETED
725	330	112	2026-11-01 10:15:00	3	COMPLETED
726	284	149	2026-11-01 18:43:00	1	COMPLETED
727	44	60	2026-11-01 13:36:00	3	COMPLETED
728	227	108	2026-11-01 15:52:00	3	COMPLETED
729	264	138	2026-11-01 07:42:00	3	COMPLETED
730	106	121	2026-11-01 11:35:00	3	COMPLETED
731	349	151	2026-11-01 13:11:00	3	COMPLETED
732	134	192	2026-11-01 09:28:00	5	COMPLETED
733	172	48	2026-11-01 10:50:00	1	COMPLETED
734	68	120	2026-11-02 07:26:00	1	COMPLETED
735	187	197	2026-11-02 08:33:00	5	COMPLETED
736	91	63	2026-11-02 10:00:00	1	COMPLETED
737	148	273	2026-11-02 11:53:00	5	COMPLETED
738	80	118	2026-11-02 12:51:00	1	COMPLETED
739	53	105	2026-11-02 11:58:00	1	COMPLETED
740	54	16	2026-11-02 13:23:00	1	COMPLETED
741	240	142	2026-11-02 09:39:00	1	COMPLETED
742	384	67	2026-11-02 08:28:00	1	COMPLETED
743	189	152	2026-11-02 12:58:00	1	COMPLETED
744	292	20	2026-11-02 10:31:00	1	COMPLETED
745	263	227	2026-11-02 10:27:00	5	COMPLETED
746	284	145	2026-11-02 12:38:00	1	COMPLETED
747	384	11	2026-11-02 12:28:00	1	COMPLETED
748	364	69	2026-11-02 07:33:00	1	COMPLETED
749	223	18	2026-11-02 09:50:00	1	COMPLETED
750	226	82	2026-11-02 13:10:00	1	COMPLETED
751	373	246	2026-11-02 10:22:00	5	COMPLETED
752	303	194	2026-11-02 10:33:00	5	COMPLETED
753	153	13	2026-11-02 07:51:00	1	COMPLETED
754	124	40	2026-11-02 07:25:00	1	COMPLETED
755	335	187	2026-11-02 07:56:00	5	COMPLETED
756	155	36	2026-11-02 07:13:00	1	COMPLETED
757	349	81	2026-11-02 09:39:00	1	COMPLETED
758	267	320	2026-11-02 07:07:00	1	COMPLETED
759	384	105	2026-11-02 08:33:00	1	COMPLETED
760	270	261	2026-11-02 14:00:00	5	COMPLETED
761	80	89	2026-11-02 12:10:00	1	COMPLETED
762	43	50	2026-11-02 10:50:00	1	COMPLETED
763	281	50	2026-11-02 11:23:00	1	COMPLETED
764	292	120	2026-11-02 12:27:00	1	COMPLETED
765	185	271	2026-11-02 11:41:00	5	COMPLETED
766	122	162	2026-11-02 11:17:00	5	COMPLETED
767	297	150	2026-11-02 11:56:00	1	COMPLETED
768	293	213	2026-11-02 12:26:00	5	COMPLETED
769	362	30	2026-11-02 13:58:00	1	COMPLETED
770	109	115	2026-11-02 13:27:00	1	COMPLETED
771	267	157	2026-11-02 13:30:00	1	COMPLETED
772	172	7	2026-11-02 10:03:00	1	COMPLETED
773	278	10	2026-11-02 13:44:00	1	COMPLETED
774	63	6	2026-11-02 13:53:00	3	ACTIVE
775	138	7	2026-11-02 10:56:00	3	ACTIVE
776	217	8	2026-11-02 15:16:00	1	ACTIVE
777	341	9	2026-11-02 10:16:00	1	ACTIVE
778	299	12	2026-11-02 15:16:00	3	ACTIVE
779	247	15	2026-11-02 09:21:00	3	ACTIVE
780	94	18	2026-11-02 11:01:00	3	ACTIVE
781	71	20	2026-11-02 14:04:00	3	ACTIVE
782	70	22	2026-11-02 10:07:00	1	ACTIVE
783	56	24	2026-11-02 14:49:00	1	ACTIVE
784	301	25	2026-11-02 13:19:00	3	ACTIVE
785	285	27	2026-11-02 11:02:00	3	ACTIVE
786	306	30	2026-11-02 12:22:00	1	ACTIVE
787	309	31	2026-11-02 10:39:00	1	ACTIVE
788	210	33	2026-11-02 13:01:00	1	ACTIVE
789	249	34	2026-11-02 13:41:00	3	ACTIVE
790	281	35	2026-11-02 15:10:00	3	ACTIVE
791	214	36	2026-11-02 14:41:00	3	ACTIVE
792	277	37	2026-11-02 13:26:00	1	ACTIVE
793	55	38	2026-11-02 10:49:00	1	ACTIVE
794	215	40	2026-11-02 13:19:00	3	ACTIVE
795	72	44	2026-11-02 09:02:00	1	ACTIVE
796	2	49	2026-11-02 12:37:00	1	ACTIVE
797	50	51	2026-11-02 13:19:00	3	ACTIVE
798	111	53	2026-11-02 14:33:00	1	ACTIVE
799	108	56	2026-11-02 11:10:00	1	ACTIVE
800	248	58	2026-11-02 08:32:00	1	ACTIVE
801	198	61	2026-11-02 14:31:00	1	ACTIVE
802	274	64	2026-11-02 11:02:00	1	ACTIVE
803	300	65	2026-11-02 13:05:00	1	ACTIVE
804	196	67	2026-11-02 11:28:00	3	ACTIVE
805	203	68	2026-11-02 11:33:00	3	ACTIVE
806	208	69	2026-11-02 15:06:00	3	ACTIVE
807	159	71	2026-11-02 14:47:00	1	ACTIVE
808	88	76	2026-11-02 08:39:00	3	ACTIVE
809	183	79	2026-11-02 14:40:00	3	ACTIVE
810	193	82	2026-11-02 09:20:00	3	ACTIVE
811	141	83	2026-11-02 08:56:00	1	ACTIVE
812	154	84	2026-11-02 09:46:00	1	ACTIVE
813	322	85	2026-11-02 10:49:00	3	ACTIVE
814	382	86	2026-11-02 11:08:00	3	ACTIVE
815	334	89	2026-11-02 13:21:00	1	ACTIVE
816	329	92	2026-11-02 08:28:00	3	ACTIVE
817	229	93	2026-11-02 13:26:00	1	ACTIVE
818	51	94	2026-11-02 14:02:00	3	ACTIVE
819	372	95	2026-11-02 14:57:00	3	ACTIVE
820	243	96	2026-11-02 12:50:00	3	ACTIVE
821	333	97	2026-11-02 15:14:00	3	ACTIVE
822	359	101	2026-11-02 15:09:00	3	ACTIVE
823	213	104	2026-11-02 13:01:00	3	ACTIVE
824	52	107	2026-11-02 14:47:00	3	ACTIVE
825	74	108	2026-11-02 13:03:00	3	ACTIVE
826	291	113	2026-11-02 14:38:00	1	ACTIVE
827	101	114	2026-11-02 13:06:00	3	ACTIVE
828	54	115	2026-11-02 12:22:00	1	ACTIVE
829	58	116	2026-11-02 12:46:00	1	ACTIVE
830	205	118	2026-11-02 09:39:00	3	ACTIVE
831	331	119	2026-11-02 15:05:00	3	ACTIVE
832	104	120	2026-11-02 11:48:00	3	ACTIVE
833	181	121	2026-11-02 14:21:00	3	ACTIVE
834	109	122	2026-11-02 11:44:00	1	ACTIVE
835	280	125	2026-11-02 14:21:00	3	ACTIVE
836	292	126	2026-11-02 10:51:00	3	ACTIVE
837	76	127	2026-11-02 11:10:00	3	ACTIVE
838	44	131	2026-11-02 13:20:00	1	ACTIVE
839	265	132	2026-11-02 14:59:00	3	ACTIVE
840	345	133	2026-11-02 11:20:00	1	ACTIVE
841	165	134	2026-11-02 13:46:00	1	ACTIVE
842	250	137	2026-11-02 11:39:00	3	ACTIVE
843	174	139	2026-11-02 08:33:00	1	ACTIVE
844	287	146	2026-11-02 13:29:00	1	ACTIVE
845	297	147	2026-11-02 13:55:00	1	ACTIVE
846	131	148	2026-11-02 10:48:00	3	ACTIVE
847	232	149	2026-11-02 13:22:00	3	ACTIVE
848	212	152	2026-11-02 10:28:00	3	ACTIVE
849	188	153	2026-11-02 13:29:00	3	ACTIVE
850	311	156	2026-11-02 09:54:00	1	ACTIVE
851	304	157	2026-11-02 12:31:00	3	ACTIVE
852	264	158	2026-11-02 08:42:00	3	ACTIVE
853	176	159	2026-11-02 14:59:00	1	ACTIVE
854	298	163	2026-11-02 13:08:00	5	ACTIVE
855	231	167	2026-11-02 10:59:00	5	ACTIVE
856	110	168	2026-11-02 09:20:00	5	ACTIVE
857	120	169	2026-11-02 11:58:00	5	ACTIVE
858	142	170	2026-11-02 12:37:00	5	ACTIVE
859	314	171	2026-11-02 10:13:00	5	ACTIVE
860	346	172	2026-11-02 13:29:00	5	ACTIVE
861	303	173	2026-11-02 13:44:00	5	ACTIVE
862	238	176	2026-11-02 14:41:00	5	ACTIVE
863	102	177	2026-11-02 10:38:00	5	ACTIVE
864	371	182	2026-11-02 09:53:00	5	ACTIVE
865	383	183	2026-11-02 15:16:00	5	ACTIVE
866	275	184	2026-11-02 11:06:00	5	ACTIVE
867	353	185	2026-11-02 08:48:00	5	ACTIVE
868	136	186	2026-11-02 13:02:00	5	ACTIVE
869	313	187	2026-11-02 15:12:00	5	ACTIVE
870	146	188	2026-11-02 15:07:00	5	ACTIVE
871	132	190	2026-11-02 12:10:00	5	ACTIVE
872	343	193	2026-11-02 14:07:00	5	ACTIVE
873	156	194	2026-11-02 14:02:00	5	ACTIVE
874	340	197	2026-11-02 12:00:00	5	ACTIVE
875	270	198	2026-11-02 10:18:00	5	ACTIVE
876	315	199	2026-11-02 14:50:00	5	ACTIVE
877	107	200	2026-11-02 09:37:00	5	ACTIVE
878	178	201	2026-11-02 15:15:00	5	ACTIVE
879	263	202	2026-11-02 13:33:00	5	ACTIVE
880	241	203	2026-11-02 14:56:00	5	ACTIVE
881	190	207	2026-11-02 08:33:00	5	ACTIVE
882	358	208	2026-11-02 15:16:00	5	ACTIVE
883	166	209	2026-11-02 09:56:00	5	ACTIVE
884	167	210	2026-11-02 12:09:00	5	ACTIVE
885	293	211	2026-11-02 09:34:00	5	ACTIVE
886	218	212	2026-11-02 11:42:00	5	ACTIVE
887	373	213	2026-11-02 10:28:00	5	ACTIVE
888	103	214	2026-11-02 13:20:00	5	ACTIVE
889	209	216	2026-11-02 10:43:00	5	ACTIVE
890	321	217	2026-11-02 10:54:00	5	ACTIVE
891	134	218	2026-11-02 14:21:00	5	ACTIVE
892	206	220	2026-11-02 13:40:00	5	ACTIVE
893	194	222	2026-11-02 11:34:00	5	ACTIVE
894	99	223	2026-11-02 13:13:00	5	ACTIVE
895	82	224	2026-11-02 12:16:00	5	ACTIVE
896	336	228	2026-11-02 15:01:00	5	ACTIVE
897	225	230	2026-11-02 12:53:00	5	ACTIVE
898	273	232	2026-11-02 13:47:00	5	ACTIVE
899	179	233	2026-11-02 14:46:00	5	ACTIVE
900	258	237	2026-11-02 15:08:00	5	ACTIVE
901	87	241	2026-11-02 15:05:00	5	ACTIVE
902	233	242	2026-11-02 13:17:00	5	ACTIVE
903	312	243	2026-11-02 08:39:00	5	ACTIVE
904	262	245	2026-11-02 12:34:00	5	ACTIVE
905	139	248	2026-11-02 10:47:00	5	ACTIVE
906	143	249	2026-11-02 11:47:00	5	ACTIVE
907	187	251	2026-11-02 09:20:00	5	ACTIVE
908	288	253	2026-11-02 13:26:00	5	ACTIVE
909	335	254	2026-11-02 14:44:00	5	ACTIVE
910	242	256	2026-11-02 13:27:00	5	ACTIVE
911	147	257	2026-11-02 10:08:00	5	ACTIVE
912	279	259	2026-11-02 10:14:00	5	ACTIVE
913	151	260	2026-11-02 15:16:00	5	ACTIVE
914	125	261	2026-11-02 12:52:00	5	ACTIVE
915	289	262	2026-11-02 10:50:00	5	ACTIVE
916	201	263	2026-11-02 12:41:00	5	ACTIVE
917	220	264	2026-11-02 14:58:00	5	ACTIVE
918	352	267	2026-11-02 08:44:00	5	ACTIVE
919	386	269	2026-11-02 11:03:00	5	ACTIVE
920	332	274	2026-11-02 10:22:00	5	ACTIVE
921	375	277	2026-11-02 08:57:00	5	ACTIVE
922	105	278	2026-11-02 15:10:00	5	ACTIVE
923	93	279	2026-11-02 10:52:00	5	ACTIVE
924	305	280	2026-11-02 11:06:00	5	ACTIVE
925	122	281	2026-11-02 15:11:00	5	ACTIVE
926	86	282	2026-11-02 14:14:00	3	ACTIVE
927	85	283	2026-11-02 09:27:00	3	ACTIVE
928	89	316	2026-11-02 14:50:00	1	ACTIVE
929	302	317	2026-11-02 14:14:00	3	ACTIVE
930	254	320	2026-11-02 13:59:00	3	ACTIVE
931	80	286	2026-11-02 11:36:00	3	ACTIVE
932	81	287	2026-11-02 11:15:00	3	ACTIVE
933	84	288	2026-11-02 12:15:00	3	ACTIVE
934	390	3	2026-11-02 18:32:57.260097	1	ACTIVE
935	391	4	2026-11-02 18:32:58.044879	1	ACTIVE
\.


--
-- Data for Name: parking_zone; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.parking_zone (zone_id, zone_name, floor_level, total_capacity) FROM stdin;
1	Zone A - Ground Level	0	40
2	Zone B - First Floor	1	60
3	Zone C - Second Floor	2	60
4	Zone D - Basement 1 (Two-Wheelers)	-1	120
5	Zone E - Basement 2 (Members & Service)	-2	40
\.


--
-- Data for Name: pass_holder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pass_holder (member_id, member_name, contact_no, address) FROM stdin;
1	John Doe	+19876543210	123 Tech Park Residency, Ahmedabad, Gujarat
2	Aditya Kapoor	9909055566	A-1201, Iscon Platinum, Bopal, Ahmedabad
3	Hetal Shah	9824011223	14, Shanti Kunj Society, Navrangpura, Ahmedabad
4	Rakesh Chaudhary	9898067890	C-404, Prahlad Nagar Residency, Ahmedabad
5	Yash Parmar	9737011122	33, Sardar Patel Nagar, Ellisbridge, Ahmedabad
6	Khushi Dave	9737033344	5, Gulbai Tekra, Panchvati, Ahmedabad
7	Priya Mehta	9824022334	21, Vastrapur Lake View, Vastrapur, Ahmedabad
8	Dhruv Agarwal	9898012345	B-702, Shivalik Heights, Satellite, Ahmedabad
9	Vivek Iyer	9909077788	9, Sindhu Bhavan Road, Thaltej, Ahmedabad
\.


--
-- Data for Name: payment_details; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payment_details (payment_id, exit_id, payment_mode, payment_status, transaction_time, amount_paid) FROM stdin;
1	1	UPI	SUCCESSFUL	2026-08-17 12:31:00	150.00
2	2	UPI	SUCCESSFUL	2026-10-19 15:02:29	120.00
3	3	UPI	SUCCESSFUL	2026-10-19 23:38:31	180.00
4	4	CARD	SUCCESSFUL	2026-10-19 13:29:47	150.00
5	5	UPI	SUCCESSFUL	2026-10-20 00:37:37	250.00
6	6	UPI	SUCCESSFUL	2026-10-19 13:18:40	160.00
7	7	CASH	SUCCESSFUL	2026-10-19 18:34:21	30.00
8	8	CARD	SUCCESSFUL	2026-10-20 00:30:38	250.00
9	9	UPI	SUCCESSFUL	2026-10-19 21:16:46	60.00
10	10	UPI	SUCCESSFUL	2026-10-19 17:32:26	50.00
11	11	CASH	SUCCESSFUL	2026-10-19 11:07:25	40.00
12	12	UPI	SUCCESSFUL	2026-10-19 18:08:44	90.00
13	13	CARD	SUCCESSFUL	2026-10-19 16:14:42	120.00
14	14	UPI	SUCCESSFUL	2026-10-19 09:34:31	135.00
15	15	UPI	SUCCESSFUL	2026-10-19 14:09:30	80.00
16	16	UPI	SUCCESSFUL	2026-10-19 14:50:13	60.00
17	17	CASH	SUCCESSFUL	2026-10-19 11:35:09	10.00
18	18	CASH	SUCCESSFUL	2026-10-19 11:12:41	20.00
19	19	UPI	SUCCESSFUL	2026-10-19 20:17:42	150.00
20	20	UPI	SUCCESSFUL	2026-10-19 11:45:12	40.00
21	21	UPI	SUCCESSFUL	2026-10-19 19:06:11	20.00
22	22	UPI	SUCCESSFUL	2026-10-19 15:08:32	120.00
23	23	UPI	SUCCESSFUL	2026-10-19 15:51:31	150.00
24	24	UPI	SUCCESSFUL	2026-10-19 20:47:11	80.00
25	25	UPI	SUCCESSFUL	2026-10-19 08:33:35	60.00
26	26	CARD	SUCCESSFUL	2026-10-19 12:56:22	120.00
27	27	CARD	SUCCESSFUL	2026-10-19 14:13:46	30.00
28	28	CARD	SUCCESSFUL	2026-10-19 22:54:22	100.00
29	29	CASH	SUCCESSFUL	2026-10-19 15:03:12	30.00
30	30	UPI	SUCCESSFUL	2026-10-19 13:21:00	90.00
31	31	UPI	SUCCESSFUL	2026-10-19 21:39:39	20.00
32	32	UPI	SUCCESSFUL	2026-10-19 12:38:52	120.00
33	33	CASH	SUCCESSFUL	2026-10-19 12:34:20	40.00
34	34	UPI	SUCCESSFUL	2026-10-19 21:47:34	100.00
35	35	CARD	SUCCESSFUL	2026-10-19 21:24:29	10.00
36	36	UPI	SUCCESSFUL	2026-10-19 13:53:36	30.00
37	37	UPI	SUCCESSFUL	2026-10-19 12:03:47	120.00
38	38	UPI	SUCCESSFUL	2026-10-19 20:49:52	10.00
39	39	UPI	SUCCESSFUL	2026-10-20 01:02:15	195.00
40	40	CARD	SUCCESSFUL	2026-10-19 21:36:33	120.00
41	41	CASH	SUCCESSFUL	2026-10-19 19:14:18	50.00
42	42	CARD	SUCCESSFUL	2026-10-19 18:10:05	200.00
43	43	CASH	SUCCESSFUL	2026-10-19 17:37:26	150.00
44	44	UPI	SUCCESSFUL	2026-10-19 13:28:39	100.00
45	45	UPI	SUCCESSFUL	2026-10-19 11:23:33	30.00
46	46	CARD	SUCCESSFUL	2026-10-20 17:30:26	120.00
47	47	UPI	SUCCESSFUL	2026-10-20 14:12:46	30.00
48	48	UPI	SUCCESSFUL	2026-10-20 14:49:06	20.00
49	49	CARD	SUCCESSFUL	2026-10-20 09:38:24	150.00
50	50	UPI	SUCCESSFUL	2026-10-21 00:52:29	325.00
51	51	CARD	SUCCESSFUL	2026-10-20 07:53:06	45.00
52	52	UPI	SUCCESSFUL	2026-10-20 18:17:37	30.00
53	53	UPI	SUCCESSFUL	2026-10-20 10:20:49	50.00
54	54	UPI	SUCCESSFUL	2026-10-21 04:37:42	115.00
55	55	UPI	SUCCESSFUL	2026-10-20 15:36:12	10.00
56	56	CARD	SUCCESSFUL	2026-10-20 18:27:47	30.00
57	57	CASH	SUCCESSFUL	2026-10-20 11:29:37	30.00
58	58	UPI	SUCCESSFUL	2026-10-20 14:04:47	80.00
59	59	UPI	SUCCESSFUL	2026-10-20 17:57:40	200.00
60	60	CARD	SUCCESSFUL	2026-10-20 16:59:52	30.00
61	61	UPI	SUCCESSFUL	2026-10-20 15:48:37	150.00
62	62	CASH	SUCCESSFUL	2026-10-21 01:26:00	80.00
63	63	UPI	SUCCESSFUL	2026-10-20 14:08:55	160.00
64	64	UPI	SUCCESSFUL	2026-10-20 19:14:42	40.00
65	65	UPI	SUCCESSFUL	2026-10-20 10:53:27	100.00
66	66	CARD	SUCCESSFUL	2026-10-20 13:12:01	40.00
67	67	UPI	SUCCESSFUL	2026-10-20 13:01:33	30.00
68	68	UPI	SUCCESSFUL	2026-10-20 18:23:21	120.00
69	69	UPI	SUCCESSFUL	2026-10-20 16:35:32	20.00
70	70	UPI	SUCCESSFUL	2026-10-20 22:37:44	35.00
71	71	UPI	SUCCESSFUL	2026-10-20 15:16:22	80.00
72	72	CARD	SUCCESSFUL	2026-10-20 16:50:54	40.00
73	73	UPI	SUCCESSFUL	2026-10-20 21:01:44	20.00
74	74	UPI	SUCCESSFUL	2026-10-21 02:59:27	375.00
75	75	UPI	SUCCESSFUL	2026-10-20 18:18:49	30.00
76	76	CARD	SUCCESSFUL	2026-10-21 01:06:35	70.00
77	77	CASH	SUCCESSFUL	2026-10-20 11:43:26	300.00
78	78	UPI	SUCCESSFUL	2026-10-20 08:51:34	90.00
79	79	CASH	SUCCESSFUL	2026-10-20 10:29:40	135.00
80	80	UPI	SUCCESSFUL	2026-10-20 15:10:33	160.00
81	81	UPI	SUCCESSFUL	2026-10-20 23:26:33	210.00
82	82	CARD	SUCCESSFUL	2026-10-20 14:02:05	240.00
83	83	UPI	SUCCESSFUL	2026-10-20 13:15:08	60.00
84	84	UPI	SUCCESSFUL	2026-10-20 08:43:13	10.00
85	85	CASH	SUCCESSFUL	2026-10-20 18:32:05	120.00
86	86	UPI	SUCCESSFUL	2026-10-20 20:30:39	30.00
87	87	UPI	SUCCESSFUL	2026-10-20 10:58:51	10.00
88	88	CARD	SUCCESSFUL	2026-10-20 10:22:20	10.00
89	89	UPI	SUCCESSFUL	2026-10-20 17:55:45	10.00
90	90	UPI	SUCCESSFUL	2026-10-21 14:45:35	10.00
91	91	UPI	SUCCESSFUL	2026-10-21 19:03:33	300.00
92	92	UPI	SUCCESSFUL	2026-10-22 00:16:29	210.00
93	93	UPI	SUCCESSFUL	2026-10-21 15:09:48	40.00
94	94	CASH	SUCCESSFUL	2026-10-21 19:08:52	50.00
95	95	CASH	SUCCESSFUL	2026-10-21 15:33:17	80.00
96	96	CARD	SUCCESSFUL	2026-10-21 18:55:31	40.00
97	97	CARD	SUCCESSFUL	2026-10-21 23:21:43	35.00
98	98	CARD	SUCCESSFUL	2026-10-21 10:15:35	180.00
99	99	UPI	SUCCESSFUL	2026-10-22 05:02:13	375.00
100	100	UPI	SUCCESSFUL	2026-10-22 00:01:41	120.00
101	101	UPI	SUCCESSFUL	2026-10-21 17:23:52	30.00
102	102	UPI	SUCCESSFUL	2026-10-21 16:29:37	10.00
103	103	UPI	SUCCESSFUL	2026-10-21 16:00:29	40.00
104	104	CARD	SUCCESSFUL	2026-10-21 11:44:40	80.00
105	105	CASH	SUCCESSFUL	2026-10-21 14:54:01	50.00
106	106	UPI	SUCCESSFUL	2026-10-21 22:23:00	40.00
107	107	UPI	SUCCESSFUL	2026-10-21 16:43:12	40.00
108	108	CASH	SUCCESSFUL	2026-10-22 03:42:41	330.00
109	109	CASH	SUCCESSFUL	2026-10-21 15:00:49	200.00
110	110	CARD	SUCCESSFUL	2026-10-21 15:33:35	30.00
111	111	CARD	SUCCESSFUL	2026-10-21 19:47:46	60.00
112	112	UPI	SUCCESSFUL	2026-10-21 10:50:50	30.00
113	113	UPI	SUCCESSFUL	2026-10-21 19:58:57	100.00
114	114	UPI	SUCCESSFUL	2026-10-21 13:55:29	120.00
115	115	UPI	SUCCESSFUL	2026-10-21 10:02:53	40.00
116	116	CARD	SUCCESSFUL	2026-10-21 09:27:55	30.00
117	117	CARD	SUCCESSFUL	2026-10-21 10:47:44	30.00
118	118	CASH	SUCCESSFUL	2026-10-21 12:58:52	90.00
119	119	UPI	SUCCESSFUL	2026-10-21 11:53:50	20.00
120	120	CARD	SUCCESSFUL	2026-10-21 15:40:21	50.00
121	121	CASH	PENDING	2026-10-21 11:32:47	20.00
122	122	UPI	SUCCESSFUL	2026-10-21 11:26:45	20.00
123	123	CARD	SUCCESSFUL	2026-10-21 17:59:13	100.00
124	124	CARD	SUCCESSFUL	2026-10-21 19:37:33	80.00
125	125	UPI	SUCCESSFUL	2026-10-21 11:03:49	180.00
126	126	UPI	SUCCESSFUL	2026-10-21 14:44:20	20.00
127	127	CARD	SUCCESSFUL	2026-10-21 19:03:58	150.00
128	128	UPI	SUCCESSFUL	2026-10-21 13:22:33	150.00
129	129	UPI	SUCCESSFUL	2026-10-21 13:55:20	60.00
130	130	UPI	SUCCESSFUL	2026-10-21 19:45:29	80.00
131	131	UPI	SUCCESSFUL	2026-10-21 21:24:33	200.00
132	132	CASH	SUCCESSFUL	2026-10-21 15:33:28	30.00
133	133	UPI	SUCCESSFUL	2026-10-21 18:02:29	180.00
134	134	CARD	SUCCESSFUL	2026-10-21 13:44:38	60.00
135	135	UPI	SUCCESSFUL	2026-10-22 16:32:35	40.00
136	136	UPI	SUCCESSFUL	2026-10-22 12:45:50	60.00
137	137	UPI	SUCCESSFUL	2026-10-22 11:15:00	90.00
138	138	UPI	SUCCESSFUL	2026-10-22 14:07:47	30.00
139	139	CARD	SUCCESSFUL	2026-10-22 17:25:27	0.00
140	140	CARD	SUCCESSFUL	2026-10-22 13:59:32	90.00
141	141	UPI	SUCCESSFUL	2026-10-22 20:03:53	300.00
142	142	UPI	SUCCESSFUL	2026-10-22 10:15:56	50.00
143	143	CASH	SUCCESSFUL	2026-10-22 16:58:38	10.00
144	144	UPI	SUCCESSFUL	2026-10-22 23:02:18	255.00
145	145	UPI	SUCCESSFUL	2026-10-22 17:15:22	30.00
146	146	UPI	SUCCESSFUL	2026-10-22 17:56:44	100.00
147	147	UPI	SUCCESSFUL	2026-10-22 12:23:41	30.00
148	148	CASH	SUCCESSFUL	2026-10-22 21:25:44	10.00
149	149	UPI	SUCCESSFUL	2026-10-22 11:54:43	50.00
150	150	UPI	SUCCESSFUL	2026-10-22 11:01:50	30.00
151	151	UPI	SUCCESSFUL	2026-10-22 14:08:17	60.00
152	152	CASH	SUCCESSFUL	2026-10-22 08:14:24	15.00
153	153	UPI	SUCCESSFUL	2026-10-22 08:03:20	15.00
154	154	UPI	SUCCESSFUL	2026-10-22 17:53:49	30.00
155	155	UPI	SUCCESSFUL	2026-10-22 16:08:46	250.00
156	156	UPI	SUCCESSFUL	2026-10-22 11:09:24	10.00
157	157	UPI	SUCCESSFUL	2026-10-22 11:35:02	120.00
158	158	CASH	SUCCESSFUL	2026-10-22 20:20:56	270.00
159	159	UPI	SUCCESSFUL	2026-10-22 22:23:09	135.00
160	160	CARD	SUCCESSFUL	2026-10-22 21:31:56	10.00
161	161	UPI	SUCCESSFUL	2026-10-23 02:45:37	400.00
162	162	UPI	SUCCESSFUL	2026-10-22 16:31:40	50.00
163	163	UPI	SUCCESSFUL	2026-10-22 10:50:28	90.00
164	164	UPI	SUCCESSFUL	2026-10-22 19:16:43	320.00
165	165	UPI	SUCCESSFUL	2026-10-22 18:42:09	200.00
166	166	CARD	SUCCESSFUL	2026-10-22 19:33:31	150.00
167	167	CASH	SUCCESSFUL	2026-10-22 14:47:58	250.00
168	168	UPI	SUCCESSFUL	2026-10-22 12:13:22	30.00
169	169	CARD	SUCCESSFUL	2026-10-22 12:36:49	10.00
170	170	UPI	SUCCESSFUL	2026-10-22 13:49:24	60.00
171	171	UPI	SUCCESSFUL	2026-10-22 21:56:21	30.00
172	172	CARD	SUCCESSFUL	2026-10-22 18:59:34	200.00
173	173	UPI	SUCCESSFUL	2026-10-22 21:06:23	20.00
174	174	UPI	SUCCESSFUL	2026-10-22 11:00:05	30.00
175	175	UPI	SUCCESSFUL	2026-10-22 12:35:30	0.00
176	176	CARD	SUCCESSFUL	2026-10-22 11:33:52	30.00
177	177	UPI	SUCCESSFUL	2026-10-22 16:11:34	40.00
178	178	CARD	SUCCESSFUL	2026-10-22 20:22:47	90.00
179	179	CASH	SUCCESSFUL	2026-10-23 18:05:46	30.00
180	180	UPI	SUCCESSFUL	2026-10-23 15:08:21	120.00
181	181	UPI	SUCCESSFUL	2026-10-23 12:50:23	40.00
182	182	UPI	PENDING	2026-10-23 21:29:30	120.00
183	183	UPI	SUCCESSFUL	2026-10-23 17:29:30	150.00
184	184	UPI	SUCCESSFUL	2026-10-23 17:40:22	60.00
185	185	UPI	PENDING	2026-10-23 12:27:09	270.00
186	186	CASH	SUCCESSFUL	2026-10-23 13:47:31	300.00
187	187	CARD	SUCCESSFUL	2026-10-23 14:35:58	120.00
188	188	UPI	SUCCESSFUL	2026-10-23 09:48:33	40.00
189	189	CARD	SUCCESSFUL	2026-10-23 08:34:03	45.00
190	190	UPI	SUCCESSFUL	2026-10-23 21:14:40	50.00
191	191	CARD	SUCCESSFUL	2026-10-23 22:04:16	80.00
192	192	UPI	SUCCESSFUL	2026-10-23 22:11:10	35.00
193	193	CASH	SUCCESSFUL	2026-10-23 23:15:13	140.00
194	194	CARD	SUCCESSFUL	2026-10-23 12:58:45	100.00
195	195	UPI	SUCCESSFUL	2026-10-23 12:50:14	10.00
196	196	CASH	SUCCESSFUL	2026-10-24 00:07:11	500.00
197	197	UPI	SUCCESSFUL	2026-10-23 10:42:55	50.00
198	198	CASH	SUCCESSFUL	2026-10-23 18:57:25	50.00
199	199	UPI	SUCCESSFUL	2026-10-23 14:44:26	120.00
200	200	UPI	SUCCESSFUL	2026-10-23 11:21:38	75.00
201	201	CASH	SUCCESSFUL	2026-10-23 08:42:26	10.00
202	202	CARD	SUCCESSFUL	2026-10-23 14:41:23	40.00
203	203	UPI	SUCCESSFUL	2026-10-23 15:29:47	80.00
204	204	UPI	SUCCESSFUL	2026-10-23 12:42:43	80.00
205	205	UPI	SUCCESSFUL	2026-10-24 01:50:14	80.00
206	206	CASH	SUCCESSFUL	2026-10-23 14:38:39	30.00
207	207	UPI	SUCCESSFUL	2026-10-23 22:40:45	260.00
208	208	CARD	SUCCESSFUL	2026-10-23 12:59:34	150.00
209	209	UPI	SUCCESSFUL	2026-10-24 01:17:05	0.00
210	210	CARD	SUCCESSFUL	2026-10-23 15:01:42	360.00
211	211	UPI	SUCCESSFUL	2026-10-23 18:11:42	10.00
212	212	UPI	SUCCESSFUL	2026-10-23 15:10:05	30.00
213	213	UPI	SUCCESSFUL	2026-10-23 13:15:42	120.00
214	214	CARD	SUCCESSFUL	2026-10-23 14:09:58	20.00
215	215	UPI	SUCCESSFUL	2026-10-23 18:46:08	20.00
216	216	CARD	SUCCESSFUL	2026-10-23 20:02:21	300.00
217	217	UPI	SUCCESSFUL	2026-10-23 07:49:34	15.00
218	218	UPI	SUCCESSFUL	2026-10-23 14:37:40	30.00
219	219	CARD	SUCCESSFUL	2026-10-23 17:00:31	40.00
220	220	UPI	SUCCESSFUL	2026-10-23 18:50:27	90.00
221	221	CASH	SUCCESSFUL	2026-10-23 22:48:24	255.00
222	222	UPI	SUCCESSFUL	2026-10-24 12:04:04	45.00
223	223	UPI	SUCCESSFUL	2026-10-24 21:42:34	360.00
224	224	UPI	SUCCESSFUL	2026-10-24 16:38:44	15.00
225	225	UPI	SUCCESSFUL	2026-10-25 05:13:20	540.00
226	226	CASH	SUCCESSFUL	2026-10-24 11:17:12	100.00
227	227	UPI	SUCCESSFUL	2026-10-24 08:34:41	60.00
228	228	UPI	SUCCESSFUL	2026-10-24 14:44:33	300.00
229	229	CARD	SUCCESSFUL	2026-10-24 14:19:23	30.00
230	230	CASH	SUCCESSFUL	2026-10-24 11:38:11	120.00
231	231	UPI	SUCCESSFUL	2026-10-24 10:08:36	100.00
232	232	UPI	SUCCESSFUL	2026-10-24 23:55:26	240.00
233	233	UPI	SUCCESSFUL	2026-10-24 21:31:05	30.00
234	234	UPI	SUCCESSFUL	2026-10-24 12:54:04	120.00
235	235	CASH	SUCCESSFUL	2026-10-24 16:56:40	200.00
236	236	CARD	SUCCESSFUL	2026-10-24 19:26:32	15.00
237	237	CASH	SUCCESSFUL	2026-10-24 20:42:25	40.00
238	238	UPI	SUCCESSFUL	2026-10-24 22:29:27	65.00
239	239	CARD	SUCCESSFUL	2026-10-24 12:43:43	160.00
240	240	UPI	SUCCESSFUL	2026-10-24 10:55:20	240.00
241	241	UPI	SUCCESSFUL	2026-10-24 13:33:46	200.00
242	242	CARD	SUCCESSFUL	2026-10-24 19:24:18	120.00
243	243	UPI	SUCCESSFUL	2026-10-24 12:46:08	15.00
244	244	UPI	SUCCESSFUL	2026-10-24 12:22:06	100.00
245	245	UPI	SUCCESSFUL	2026-10-24 10:43:14	40.00
246	246	CASH	SUCCESSFUL	2026-10-24 09:12:20	180.00
247	247	CASH	SUCCESSFUL	2026-10-24 18:13:17	60.00
248	248	UPI	SUCCESSFUL	2026-10-24 22:57:36	275.00
249	249	CARD	SUCCESSFUL	2026-10-25 05:57:30	840.00
250	250	UPI	SUCCESSFUL	2026-10-24 16:09:25	180.00
251	251	CARD	SUCCESSFUL	2026-10-24 12:19:31	40.00
252	252	UPI	SUCCESSFUL	2026-10-24 09:49:48	225.00
253	253	UPI	SUCCESSFUL	2026-10-24 21:21:37	80.00
254	254	CASH	SUCCESSFUL	2026-10-24 16:37:39	60.00
255	255	CASH	SUCCESSFUL	2026-10-24 14:15:35	80.00
256	256	UPI	SUCCESSFUL	2026-10-24 14:00:43	45.00
257	257	CARD	SUCCESSFUL	2026-10-24 12:28:26	60.00
258	258	CASH	SUCCESSFUL	2026-10-24 12:15:33	100.00
259	259	UPI	SUCCESSFUL	2026-10-24 09:02:27	120.00
260	260	CASH	SUCCESSFUL	2026-10-24 21:25:19	120.00
261	261	UPI	SUCCESSFUL	2026-10-24 07:32:45	20.00
262	262	UPI	SUCCESSFUL	2026-10-24 19:29:38	75.00
263	263	UPI	SUCCESSFUL	2026-10-24 15:53:24	120.00
264	264	UPI	SUCCESSFUL	2026-10-24 18:23:41	60.00
265	265	UPI	SUCCESSFUL	2026-10-24 16:09:46	40.00
266	266	UPI	SUCCESSFUL	2026-10-24 16:24:24	120.00
267	267	UPI	SUCCESSFUL	2026-10-24 19:14:48	80.00
268	268	UPI	SUCCESSFUL	2026-10-24 13:12:20	160.00
269	269	UPI	SUCCESSFUL	2026-10-24 15:39:10	160.00
270	270	UPI	SUCCESSFUL	2026-10-24 16:22:50	160.00
271	271	UPI	SUCCESSFUL	2026-10-24 07:31:02	60.00
272	272	CASH	SUCCESSFUL	2026-10-24 09:43:10	100.00
273	273	UPI	SUCCESSFUL	2026-10-25 00:52:18	75.00
274	274	UPI	SUCCESSFUL	2026-10-24 12:21:01	45.00
275	275	UPI	SUCCESSFUL	2026-10-24 20:42:14	120.00
276	276	UPI	SUCCESSFUL	2026-10-24 09:27:43	30.00
277	277	UPI	SUCCESSFUL	2026-10-24 21:21:23	320.00
278	278	UPI	SUCCESSFUL	2026-10-24 18:35:21	160.00
279	279	UPI	SUCCESSFUL	2026-10-24 13:15:40	45.00
280	280	UPI	SUCCESSFUL	2026-10-24 07:25:03	20.00
281	281	CARD	SUCCESSFUL	2026-10-24 17:33:38	15.00
282	282	CASH	SUCCESSFUL	2026-10-24 13:30:37	160.00
283	283	UPI	SUCCESSFUL	2026-10-24 10:41:44	15.00
284	284	CARD	SUCCESSFUL	2026-10-24 18:50:39	120.00
285	285	UPI	SUCCESSFUL	2026-10-24 12:01:20	0.00
286	286	UPI	SUCCESSFUL	2026-10-24 17:21:35	40.00
287	287	CASH	SUCCESSFUL	2026-10-25 05:04:29	170.00
288	288	CARD	SUCCESSFUL	2026-10-24 23:03:37	125.00
289	289	UPI	SUCCESSFUL	2026-10-24 10:23:57	80.00
290	290	UPI	SUCCESSFUL	2026-10-25 13:53:40	15.00
291	291	UPI	SUCCESSFUL	2026-10-25 16:42:24	150.00
292	292	UPI	SUCCESSFUL	2026-10-25 17:05:24	200.00
293	293	UPI	SUCCESSFUL	2026-10-26 05:20:41	170.00
294	294	CASH	SUCCESSFUL	2026-10-25 19:34:45	480.00
295	295	CASH	SUCCESSFUL	2026-10-25 22:55:39	100.00
296	296	UPI	SUCCESSFUL	2026-10-25 13:47:40	160.00
297	297	UPI	SUCCESSFUL	2026-10-25 19:52:23	90.00
298	298	CARD	SUCCESSFUL	2026-10-25 13:50:08	15.00
299	299	UPI	SUCCESSFUL	2026-10-25 17:05:18	100.00
300	300	UPI	SUCCESSFUL	2026-10-25 12:19:48	60.00
301	301	UPI	SUCCESSFUL	2026-10-25 20:31:35	15.00
302	302	UPI	SUCCESSFUL	2026-10-25 18:13:24	540.00
303	303	UPI	SUCCESSFUL	2026-10-25 19:14:02	120.00
304	304	CARD	SUCCESSFUL	2026-10-25 15:20:32	120.00
305	305	UPI	SUCCESSFUL	2026-10-25 14:55:33	120.00
306	306	CASH	SUCCESSFUL	2026-10-25 11:21:37	180.00
307	307	UPI	SUCCESSFUL	2026-10-25 08:54:09	20.00
308	308	UPI	SUCCESSFUL	2026-10-25 08:49:50	120.00
309	309	UPI	SUCCESSFUL	2026-10-25 16:57:31	40.00
310	310	CASH	SUCCESSFUL	2026-10-25 19:10:41	120.00
311	311	CASH	SUCCESSFUL	2026-10-25 13:05:56	40.00
312	312	UPI	SUCCESSFUL	2026-10-25 09:39:57	40.00
313	313	CASH	SUCCESSFUL	2026-10-26 03:34:04	520.00
314	314	UPI	SUCCESSFUL	2026-10-25 22:23:38	15.00
315	315	UPI	SUCCESSFUL	2026-10-26 06:15:13	190.00
316	316	CASH	SUCCESSFUL	2026-10-25 20:41:29	15.00
317	317	UPI	SUCCESSFUL	2026-10-25 12:44:43	100.00
318	318	CARD	SUCCESSFUL	2026-10-25 08:01:56	60.00
319	319	CARD	SUCCESSFUL	2026-10-25 12:31:16	120.00
320	320	UPI	SUCCESSFUL	2026-10-25 13:59:30	180.00
321	321	CARD	SUCCESSFUL	2026-10-25 15:27:58	60.00
322	322	CASH	SUCCESSFUL	2026-10-25 15:02:25	180.00
323	323	CASH	PENDING	2026-10-25 23:59:51	240.00
324	324	CASH	SUCCESSFUL	2026-10-25 15:11:49	40.00
325	325	UPI	SUCCESSFUL	2026-10-25 18:10:13	240.00
326	326	CASH	SUCCESSFUL	2026-10-25 16:29:43	90.00
327	327	CASH	SUCCESSFUL	2026-10-25 11:54:47	150.00
328	328	UPI	SUCCESSFUL	2026-10-25 16:03:13	50.00
329	329	UPI	SUCCESSFUL	2026-10-25 09:53:18	15.00
330	330	CARD	SUCCESSFUL	2026-10-25 22:50:26	210.00
331	331	CARD	SUCCESSFUL	2026-10-25 10:20:45	15.00
332	332	UPI	SUCCESSFUL	2026-10-25 15:33:48	40.00
333	333	UPI	SUCCESSFUL	2026-10-25 14:02:31	50.00
334	334	CASH	SUCCESSFUL	2026-10-25 12:21:33	15.00
335	335	UPI	SUCCESSFUL	2026-10-25 13:12:41	0.00
336	336	UPI	SUCCESSFUL	2026-10-25 14:07:49	60.00
337	337	UPI	SUCCESSFUL	2026-10-25 20:33:58	240.00
338	338	UPI	SUCCESSFUL	2026-10-25 23:31:28	70.00
339	339	UPI	SUCCESSFUL	2026-10-25 13:09:22	60.00
340	340	UPI	SUCCESSFUL	2026-10-25 15:36:59	60.00
341	341	CASH	SUCCESSFUL	2026-10-25 11:02:37	50.00
342	342	UPI	SUCCESSFUL	2026-10-25 23:12:21	340.00
343	343	UPI	SUCCESSFUL	2026-10-26 05:35:08	540.00
344	344	UPI	SUCCESSFUL	2026-10-25 14:10:16	45.00
345	345	UPI	SUCCESSFUL	2026-10-25 13:31:21	150.00
346	346	UPI	SUCCESSFUL	2026-10-25 17:26:23	160.00
347	347	UPI	SUCCESSFUL	2026-10-25 19:01:49	40.00
348	348	UPI	SUCCESSFUL	2026-10-25 14:49:03	15.00
349	349	UPI	SUCCESSFUL	2026-10-25 14:24:26	15.00
350	350	UPI	SUCCESSFUL	2026-10-26 06:21:30	520.00
351	351	CARD	SUCCESSFUL	2026-10-25 12:55:47	120.00
352	352	UPI	SUCCESSFUL	2026-10-25 18:53:14	30.00
353	353	UPI	SUCCESSFUL	2026-10-25 18:44:43	60.00
354	354	CASH	SUCCESSFUL	2026-10-25 21:28:20	50.00
355	355	CARD	SUCCESSFUL	2026-10-25 14:21:30	40.00
356	356	UPI	SUCCESSFUL	2026-10-25 19:58:25	120.00
357	357	CASH	SUCCESSFUL	2026-10-25 09:35:41	180.00
358	358	UPI	SUCCESSFUL	2026-10-26 01:35:34	630.00
359	359	CASH	SUCCESSFUL	2026-10-26 12:11:05	50.00
360	360	UPI	SUCCESSFUL	2026-10-26 10:00:06	30.00
361	361	CASH	SUCCESSFUL	2026-10-26 10:31:41	60.00
362	362	UPI	SUCCESSFUL	2026-10-26 23:45:00	90.00
363	363	UPI	SUCCESSFUL	2026-10-26 20:08:42	30.00
364	364	UPI	SUCCESSFUL	2026-10-26 23:28:06	285.00
365	365	CARD	SUCCESSFUL	2026-10-26 20:29:03	50.00
366	366	UPI	SUCCESSFUL	2026-10-26 19:59:24	20.00
367	367	UPI	SUCCESSFUL	2026-10-26 21:09:22	60.00
368	368	UPI	SUCCESSFUL	2026-10-26 21:09:10	40.00
369	369	CASH	SUCCESSFUL	2026-10-26 22:06:04	150.00
370	370	CARD	SUCCESSFUL	2026-10-26 10:35:24	10.00
371	371	UPI	SUCCESSFUL	2026-10-27 04:10:41	520.00
372	372	UPI	SUCCESSFUL	2026-10-26 20:41:29	30.00
373	373	UPI	SUCCESSFUL	2026-10-26 22:28:05	150.00
374	374	UPI	SUCCESSFUL	2026-10-26 22:18:17	55.00
375	375	CASH	SUCCESSFUL	2026-10-26 16:23:54	10.00
376	376	UPI	SUCCESSFUL	2026-10-26 13:29:45	30.00
377	377	CASH	SUCCESSFUL	2026-10-26 11:18:13	60.00
378	378	CASH	SUCCESSFUL	2026-10-26 17:06:32	40.00
379	379	UPI	SUCCESSFUL	2026-10-26 12:19:55	50.00
380	380	UPI	SUCCESSFUL	2026-10-26 13:01:04	60.00
381	381	UPI	SUCCESSFUL	2026-10-26 13:12:32	60.00
382	382	CASH	SUCCESSFUL	2026-10-27 00:04:30	0.00
383	383	UPI	SUCCESSFUL	2026-10-26 22:12:36	45.00
384	384	UPI	SUCCESSFUL	2026-10-26 18:31:42	120.00
385	385	UPI	SUCCESSFUL	2026-10-26 20:28:14	50.00
386	386	CASH	SUCCESSFUL	2026-10-26 14:23:47	10.00
387	387	CARD	SUCCESSFUL	2026-10-26 18:01:10	120.00
388	388	CARD	SUCCESSFUL	2026-10-26 20:39:47	60.00
389	389	UPI	SUCCESSFUL	2026-10-27 00:54:04	345.00
390	390	UPI	SUCCESSFUL	2026-10-26 19:16:28	90.00
391	391	CASH	SUCCESSFUL	2026-10-26 09:24:12	10.00
392	392	CARD	SUCCESSFUL	2026-10-26 19:15:24	30.00
393	393	UPI	SUCCESSFUL	2026-10-26 12:12:41	80.00
394	394	CASH	SUCCESSFUL	2026-10-26 08:03:29	60.00
395	395	CASH	SUCCESSFUL	2026-10-26 08:50:22	90.00
396	396	CASH	SUCCESSFUL	2026-10-26 20:07:00	80.00
397	397	CARD	SUCCESSFUL	2026-10-26 22:36:58	105.00
398	398	UPI	SUCCESSFUL	2026-10-26 12:48:43	10.00
399	399	UPI	SUCCESSFUL	2026-10-26 15:35:26	40.00
400	400	CASH	SUCCESSFUL	2026-10-26 16:16:05	90.00
401	401	CARD	SUCCESSFUL	2026-10-26 19:45:23	10.00
402	402	CARD	SUCCESSFUL	2026-10-26 18:48:24	120.00
403	403	UPI	SUCCESSFUL	2026-10-26 19:22:50	120.00
404	404	CARD	SUCCESSFUL	2026-10-27 18:03:07	60.00
405	405	CASH	SUCCESSFUL	2026-10-27 18:54:50	30.00
406	406	UPI	SUCCESSFUL	2026-10-27 23:21:56	165.00
407	407	CARD	SUCCESSFUL	2026-10-27 18:32:53	100.00
408	408	CASH	SUCCESSFUL	2026-10-27 12:51:49	360.00
409	409	CARD	SUCCESSFUL	2026-10-27 20:42:07	60.00
410	410	UPI	SUCCESSFUL	2026-10-27 16:46:47	100.00
411	411	UPI	SUCCESSFUL	2026-10-27 17:09:53	40.00
412	412	CASH	SUCCESSFUL	2026-10-27 12:42:36	50.00
413	413	CARD	SUCCESSFUL	2026-10-27 16:06:55	30.00
414	414	UPI	SUCCESSFUL	2026-10-28 01:37:06	360.00
415	415	UPI	SUCCESSFUL	2026-10-27 20:16:17	200.00
416	416	CARD	SUCCESSFUL	2026-10-27 17:52:41	30.00
417	417	UPI	SUCCESSFUL	2026-10-27 17:44:09	80.00
418	418	UPI	SUCCESSFUL	2026-10-27 13:32:29	10.00
419	419	UPI	SUCCESSFUL	2026-10-27 12:58:32	60.00
420	420	CASH	SUCCESSFUL	2026-10-27 18:01:31	20.00
421	421	UPI	PENDING	2026-10-27 23:47:25	50.00
422	422	CARD	SUCCESSFUL	2026-10-28 02:12:21	350.00
423	423	UPI	SUCCESSFUL	2026-10-27 18:29:30	240.00
424	424	CARD	SUCCESSFUL	2026-10-28 01:43:05	120.00
425	425	UPI	SUCCESSFUL	2026-10-27 09:35:26	40.00
426	426	UPI	SUCCESSFUL	2026-10-27 13:43:01	50.00
427	427	CASH	SUCCESSFUL	2026-10-27 18:26:26	80.00
428	428	UPI	SUCCESSFUL	2026-10-27 18:44:45	30.00
429	429	UPI	SUCCESSFUL	2026-10-27 21:54:23	50.00
430	430	UPI	SUCCESSFUL	2026-10-27 16:02:04	180.00
431	431	CASH	SUCCESSFUL	2026-10-27 20:44:57	400.00
432	432	UPI	SUCCESSFUL	2026-10-27 18:28:47	120.00
433	433	UPI	PENDING	2026-10-27 09:29:25	10.00
434	434	CARD	SUCCESSFUL	2026-10-27 08:08:49	90.00
435	435	UPI	SUCCESSFUL	2026-10-27 15:45:29	50.00
436	436	CARD	SUCCESSFUL	2026-10-27 18:23:29	20.00
437	437	UPI	SUCCESSFUL	2026-10-27 17:41:16	300.00
438	438	UPI	SUCCESSFUL	2026-10-27 20:04:40	200.00
439	439	UPI	SUCCESSFUL	2026-10-27 11:35:40	160.00
440	440	UPI	SUCCESSFUL	2026-10-27 15:43:55	160.00
441	441	UPI	SUCCESSFUL	2026-10-27 17:10:43	30.00
442	442	CASH	SUCCESSFUL	2026-10-27 10:43:23	10.00
443	443	UPI	SUCCESSFUL	2026-10-27 13:44:35	40.00
444	444	UPI	SUCCESSFUL	2026-10-27 11:40:46	30.00
445	445	UPI	SUCCESSFUL	2026-10-27 21:53:20	60.00
446	446	UPI	SUCCESSFUL	2026-10-27 12:55:24	10.00
447	447	UPI	SUCCESSFUL	2026-10-27 13:57:42	20.00
448	448	UPI	SUCCESSFUL	2026-10-27 11:46:23	20.00
449	449	UPI	SUCCESSFUL	2026-10-28 10:13:39	30.00
450	450	UPI	SUCCESSFUL	2026-10-28 18:32:13	90.00
451	451	UPI	SUCCESSFUL	2026-10-28 19:45:11	200.00
452	452	CARD	SUCCESSFUL	2026-10-29 05:35:46	650.00
453	453	UPI	SUCCESSFUL	2026-10-28 23:32:28	165.00
454	454	UPI	SUCCESSFUL	2026-10-28 23:18:42	125.00
455	455	UPI	SUCCESSFUL	2026-10-28 11:57:18	150.00
456	456	UPI	SUCCESSFUL	2026-10-28 11:19:52	150.00
457	457	UPI	SUCCESSFUL	2026-10-28 12:42:27	200.00
458	458	CASH	SUCCESSFUL	2026-10-29 02:06:44	70.00
459	459	CARD	SUCCESSFUL	2026-10-28 21:14:30	200.00
460	460	UPI	SUCCESSFUL	2026-10-28 12:51:21	80.00
461	461	UPI	SUCCESSFUL	2026-10-28 08:49:42	75.00
462	462	CARD	SUCCESSFUL	2026-10-28 09:02:47	120.00
463	463	CARD	SUCCESSFUL	2026-10-28 16:28:38	20.00
464	464	UPI	SUCCESSFUL	2026-10-29 00:00:25	240.00
465	465	CASH	SUCCESSFUL	2026-10-29 00:59:14	475.00
466	466	UPI	SUCCESSFUL	2026-10-28 21:36:03	60.00
467	467	UPI	SUCCESSFUL	2026-10-28 18:29:42	150.00
468	468	CASH	SUCCESSFUL	2026-10-28 14:33:39	90.00
469	469	CARD	SUCCESSFUL	2026-10-28 10:17:45	60.00
470	470	CASH	SUCCESSFUL	2026-10-28 20:08:47	50.00
471	471	UPI	SUCCESSFUL	2026-10-28 21:23:45	30.00
472	472	UPI	SUCCESSFUL	2026-10-28 18:00:42	200.00
473	473	UPI	SUCCESSFUL	2026-10-28 14:30:17	90.00
474	474	UPI	SUCCESSFUL	2026-10-28 15:54:25	50.00
475	475	UPI	SUCCESSFUL	2026-10-28 15:19:34	10.00
476	476	CARD	SUCCESSFUL	2026-10-28 19:48:25	0.00
477	477	UPI	SUCCESSFUL	2026-10-28 18:38:15	100.00
478	478	CARD	SUCCESSFUL	2026-10-28 22:22:44	45.00
479	479	UPI	SUCCESSFUL	2026-10-28 13:33:11	30.00
480	480	UPI	SUCCESSFUL	2026-10-28 15:27:26	30.00
481	481	UPI	SUCCESSFUL	2026-10-28 10:36:41	30.00
482	482	UPI	SUCCESSFUL	2026-10-28 21:39:03	10.00
483	483	UPI	SUCCESSFUL	2026-10-28 12:30:22	10.00
484	484	CASH	SUCCESSFUL	2026-10-28 09:15:24	90.00
485	485	CARD	SUCCESSFUL	2026-10-28 19:16:23	40.00
486	486	CASH	SUCCESSFUL	2026-10-28 12:14:17	300.00
487	487	CASH	SUCCESSFUL	2026-10-28 15:36:36	30.00
488	488	CASH	SUCCESSFUL	2026-10-28 14:28:16	40.00
489	489	CASH	SUCCESSFUL	2026-10-28 17:09:10	50.00
490	490	CARD	SUCCESSFUL	2026-10-28 15:54:23	30.00
491	491	CARD	SUCCESSFUL	2026-10-28 12:40:35	80.00
492	492	UPI	SUCCESSFUL	2026-10-29 10:30:06	30.00
493	493	CASH	SUCCESSFUL	2026-10-29 17:43:38	80.00
494	494	UPI	SUCCESSFUL	2026-10-29 17:14:21	30.00
495	495	UPI	SUCCESSFUL	2026-10-29 11:14:32	60.00
496	496	UPI	SUCCESSFUL	2026-10-29 16:49:21	0.00
497	497	UPI	SUCCESSFUL	2026-10-29 13:32:47	20.00
498	498	CASH	SUCCESSFUL	2026-10-30 03:21:19	650.00
499	499	UPI	SUCCESSFUL	2026-10-30 00:25:20	240.00
500	500	UPI	SUCCESSFUL	2026-10-29 18:29:52	20.00
501	501	CASH	SUCCESSFUL	2026-10-29 17:24:39	450.00
502	502	UPI	SUCCESSFUL	2026-10-30 02:59:25	115.00
503	503	CASH	SUCCESSFUL	2026-10-29 18:41:52	40.00
504	504	CASH	SUCCESSFUL	2026-10-29 08:50:42	120.00
505	505	UPI	SUCCESSFUL	2026-10-29 11:40:42	90.00
506	506	CASH	SUCCESSFUL	2026-10-29 15:58:01	120.00
507	507	CASH	SUCCESSFUL	2026-10-29 09:52:23	30.00
508	508	UPI	SUCCESSFUL	2026-10-29 17:27:27	30.00
509	509	CARD	SUCCESSFUL	2026-10-29 13:51:18	120.00
510	510	CARD	SUCCESSFUL	2026-10-29 16:12:36	150.00
511	511	UPI	SUCCESSFUL	2026-10-29 09:25:36	180.00
512	512	CASH	SUCCESSFUL	2026-10-29 12:22:31	40.00
513	513	CARD	SUCCESSFUL	2026-10-29 12:31:34	30.00
514	514	UPI	SUCCESSFUL	2026-10-29 23:47:15	450.00
515	515	UPI	SUCCESSFUL	2026-10-29 17:22:47	80.00
516	516	UPI	SUCCESSFUL	2026-10-29 15:53:44	10.00
517	517	CASH	SUCCESSFUL	2026-10-29 22:52:00	225.00
518	518	UPI	SUCCESSFUL	2026-10-29 10:26:33	10.00
519	519	UPI	SUCCESSFUL	2026-10-29 12:58:46	200.00
520	520	UPI	SUCCESSFUL	2026-10-29 11:02:43	30.00
521	521	UPI	SUCCESSFUL	2026-10-29 17:35:43	50.00
522	522	UPI	SUCCESSFUL	2026-10-29 08:40:18	90.00
523	523	UPI	PENDING	2026-10-29 11:47:20	120.00
524	524	UPI	SUCCESSFUL	2026-10-29 17:40:49	150.00
525	525	UPI	SUCCESSFUL	2026-10-29 21:32:52	10.00
526	526	CARD	SUCCESSFUL	2026-10-29 13:47:30	200.00
527	527	UPI	SUCCESSFUL	2026-10-29 21:05:45	10.00
528	528	UPI	SUCCESSFUL	2026-10-29 22:31:39	105.00
529	529	CARD	SUCCESSFUL	2026-10-29 15:56:20	80.00
530	530	UPI	SUCCESSFUL	2026-10-29 15:04:39	90.00
531	531	UPI	SUCCESSFUL	2026-10-29 16:17:06	240.00
532	532	UPI	SUCCESSFUL	2026-10-29 19:07:47	240.00
533	533	UPI	SUCCESSFUL	2026-10-29 17:44:11	50.00
534	534	UPI	SUCCESSFUL	2026-10-29 18:47:22	20.00
535	535	UPI	SUCCESSFUL	2026-10-30 00:02:18	250.00
536	536	CASH	SUCCESSFUL	2026-10-30 18:59:30	90.00
537	537	CASH	SUCCESSFUL	2026-10-30 20:54:31	20.00
538	538	CASH	SUCCESSFUL	2026-10-30 10:06:06	50.00
539	539	UPI	SUCCESSFUL	2026-10-30 17:19:24	90.00
540	540	UPI	PENDING	2026-10-30 10:54:28	135.00
541	541	UPI	SUCCESSFUL	2026-10-30 23:54:33	200.00
542	542	CASH	SUCCESSFUL	2026-10-30 12:42:47	60.00
543	543	UPI	SUCCESSFUL	2026-10-30 15:03:42	200.00
544	544	UPI	SUCCESSFUL	2026-10-30 15:16:28	60.00
545	545	CASH	SUCCESSFUL	2026-10-30 15:54:34	60.00
546	546	UPI	SUCCESSFUL	2026-10-30 13:46:38	10.00
547	547	UPI	SUCCESSFUL	2026-10-30 21:42:38	10.00
548	548	CARD	SUCCESSFUL	2026-10-30 21:27:23	10.00
549	549	CARD	SUCCESSFUL	2026-10-30 12:01:18	40.00
550	550	CARD	SUCCESSFUL	2026-10-30 23:12:19	50.00
551	551	UPI	SUCCESSFUL	2026-10-30 21:07:49	10.00
552	552	UPI	SUCCESSFUL	2026-10-30 17:09:06	20.00
553	553	UPI	SUCCESSFUL	2026-10-31 02:35:35	525.00
554	554	UPI	SUCCESSFUL	2026-10-30 11:56:41	150.00
555	555	CARD	SUCCESSFUL	2026-10-30 12:27:59	60.00
556	556	UPI	SUCCESSFUL	2026-10-30 18:51:53	30.00
557	557	CARD	SUCCESSFUL	2026-10-30 21:05:24	30.00
558	558	UPI	SUCCESSFUL	2026-10-30 11:24:39	60.00
559	559	UPI	SUCCESSFUL	2026-10-30 19:19:40	200.00
560	560	CASH	SUCCESSFUL	2026-10-30 16:25:27	30.00
561	561	UPI	SUCCESSFUL	2026-10-30 19:06:44	50.00
562	562	UPI	SUCCESSFUL	2026-10-31 03:52:43	110.00
563	563	UPI	SUCCESSFUL	2026-10-30 18:57:21	400.00
564	564	UPI	SUCCESSFUL	2026-10-31 01:51:46	120.00
565	565	CARD	SUCCESSFUL	2026-10-31 06:54:39	420.00
566	566	CASH	SUCCESSFUL	2026-10-30 12:18:00	90.00
567	567	UPI	SUCCESSFUL	2026-10-30 12:05:57	30.00
568	568	UPI	SUCCESSFUL	2026-10-30 20:59:16	60.00
569	569	CASH	SUCCESSFUL	2026-10-30 18:50:21	100.00
570	570	CASH	SUCCESSFUL	2026-10-30 21:33:31	10.00
571	571	UPI	SUCCESSFUL	2026-10-30 13:55:42	200.00
572	572	UPI	SUCCESSFUL	2026-10-30 15:30:48	40.00
573	573	UPI	SUCCESSFUL	2026-10-30 08:36:39	30.00
574	574	UPI	SUCCESSFUL	2026-10-30 19:31:06	150.00
575	575	UPI	SUCCESSFUL	2026-10-30 18:59:37	20.00
576	576	UPI	SUCCESSFUL	2026-10-30 22:35:42	220.00
577	577	UPI	SUCCESSFUL	2026-10-30 17:25:25	60.00
578	578	UPI	SUCCESSFUL	2026-10-30 14:29:25	60.00
579	579	CARD	SUCCESSFUL	2026-10-31 10:20:22	15.00
580	580	CARD	SUCCESSFUL	2026-10-31 10:45:54	120.00
581	581	UPI	SUCCESSFUL	2026-10-31 12:30:42	120.00
582	582	CARD	SUCCESSFUL	2026-11-01 00:39:37	360.00
583	583	UPI	SUCCESSFUL	2026-10-31 09:07:28	120.00
584	584	CASH	SUCCESSFUL	2026-10-31 21:06:32	40.00
585	585	UPI	SUCCESSFUL	2026-10-31 11:56:09	15.00
586	586	CASH	SUCCESSFUL	2026-10-31 16:42:37	15.00
587	587	CARD	SUCCESSFUL	2026-10-31 19:31:08	320.00
588	588	UPI	SUCCESSFUL	2026-10-31 21:48:56	15.00
589	589	CARD	SUCCESSFUL	2026-10-31 20:26:45	320.00
590	590	CARD	SUCCESSFUL	2026-11-01 00:25:24	360.00
591	591	CASH	SUCCESSFUL	2026-10-31 14:32:13	60.00
592	592	UPI	SUCCESSFUL	2026-10-31 12:54:38	120.00
593	593	UPI	SUCCESSFUL	2026-10-31 20:31:36	60.00
594	594	UPI	SUCCESSFUL	2026-11-01 00:37:40	240.00
595	595	UPI	SUCCESSFUL	2026-10-31 10:10:36	40.00
596	596	CARD	SUCCESSFUL	2026-11-01 00:16:45	330.00
597	597	CASH	SUCCESSFUL	2026-10-31 11:50:22	160.00
598	598	UPI	SUCCESSFUL	2026-10-31 12:35:33	15.00
599	599	UPI	SUCCESSFUL	2026-10-31 17:11:22	80.00
600	600	UPI	SUCCESSFUL	2026-10-31 15:22:43	15.00
601	601	UPI	SUCCESSFUL	2026-10-31 21:47:19	75.00
602	602	CASH	SUCCESSFUL	2026-10-31 22:47:50	275.00
603	603	UPI	SUCCESSFUL	2026-10-31 14:42:43	15.00
604	604	CASH	PENDING	2026-10-31 08:50:46	15.00
605	605	UPI	SUCCESSFUL	2026-10-31 14:32:10	120.00
606	606	CARD	SUCCESSFUL	2026-10-31 17:24:30	120.00
607	607	UPI	SUCCESSFUL	2026-10-31 11:45:34	0.00
608	608	UPI	SUCCESSFUL	2026-10-31 16:24:46	200.00
609	609	UPI	SUCCESSFUL	2026-10-31 22:31:13	225.00
610	610	CASH	SUCCESSFUL	2026-10-31 21:23:21	15.00
611	611	UPI	SUCCESSFUL	2026-10-31 20:28:38	40.00
612	612	UPI	SUCCESSFUL	2026-10-31 10:20:54	180.00
613	613	UPI	SUCCESSFUL	2026-10-31 10:37:13	40.00
614	614	UPI	SUCCESSFUL	2026-10-31 15:33:49	15.00
615	615	UPI	SUCCESSFUL	2026-10-31 22:37:37	300.00
616	616	UPI	SUCCESSFUL	2026-10-31 21:09:27	135.00
617	617	CARD	SUCCESSFUL	2026-10-31 19:04:31	200.00
618	618	UPI	SUCCESSFUL	2026-10-31 14:00:00	100.00
619	619	CARD	SUCCESSFUL	2026-10-31 16:01:01	80.00
620	620	UPI	SUCCESSFUL	2026-10-31 21:04:21	480.00
621	621	CASH	SUCCESSFUL	2026-10-31 20:25:24	200.00
622	622	UPI	SUCCESSFUL	2026-10-31 21:42:44	80.00
623	623	CASH	SUCCESSFUL	2026-10-31 15:50:42	40.00
624	624	UPI	SUCCESSFUL	2026-10-31 08:29:48	0.00
625	625	CASH	SUCCESSFUL	2026-10-31 09:11:19	40.00
626	626	UPI	SUCCESSFUL	2026-10-31 14:23:33	45.00
627	627	CARD	SUCCESSFUL	2026-10-31 20:52:43	50.00
628	628	CARD	SUCCESSFUL	2026-10-31 20:23:30	200.00
629	629	CASH	SUCCESSFUL	2026-10-31 16:48:13	360.00
630	630	UPI	SUCCESSFUL	2026-10-31 19:23:59	160.00
631	631	CASH	SUCCESSFUL	2026-10-31 15:38:41	160.00
632	632	UPI	SUCCESSFUL	2026-10-31 11:56:33	60.00
633	633	UPI	SUCCESSFUL	2026-10-31 22:42:41	30.00
634	634	CARD	SUCCESSFUL	2026-10-31 13:24:31	40.00
635	635	UPI	SUCCESSFUL	2026-10-31 12:29:24	0.00
636	636	UPI	SUCCESSFUL	2026-10-31 19:52:23	30.00
637	637	UPI	SUCCESSFUL	2026-10-31 19:00:40	80.00
638	638	CARD	SUCCESSFUL	2026-10-31 22:54:52	210.00
639	639	CASH	SUCCESSFUL	2026-10-31 22:40:32	250.00
640	640	UPI	SUCCESSFUL	2026-10-31 22:33:42	100.00
641	641	CASH	SUCCESSFUL	2026-10-31 10:22:40	100.00
642	642	UPI	SUCCESSFUL	2026-10-31 19:03:27	180.00
643	643	UPI	SUCCESSFUL	2026-10-31 11:42:34	80.00
644	644	CASH	SUCCESSFUL	2026-10-31 08:02:25	90.00
645	645	UPI	SUCCESSFUL	2026-11-01 00:10:48	160.00
646	646	CASH	SUCCESSFUL	2026-10-31 10:56:21	120.00
647	647	UPI	SUCCESSFUL	2026-10-31 18:52:46	15.00
648	648	CARD	SUCCESSFUL	2026-11-01 09:24:26	15.00
649	649	CASH	SUCCESSFUL	2026-11-01 18:15:09	45.00
650	650	UPI	SUCCESSFUL	2026-11-01 14:16:40	200.00
651	651	CARD	SUCCESSFUL	2026-11-01 08:43:58	20.00
652	652	CASH	SUCCESSFUL	2026-11-01 16:25:44	40.00
653	653	CARD	SUCCESSFUL	2026-11-01 12:38:57	40.00
654	654	UPI	SUCCESSFUL	2026-11-01 20:56:04	50.00
655	655	CARD	SUCCESSFUL	2026-11-01 11:07:20	45.00
656	656	UPI	SUCCESSFUL	2026-11-01 14:21:26	200.00
657	657	CARD	SUCCESSFUL	2026-11-01 21:14:43	160.00
658	658	UPI	PENDING	2026-11-01 21:03:47	120.00
659	659	UPI	SUCCESSFUL	2026-11-01 14:20:48	120.00
660	660	CASH	SUCCESSFUL	2026-11-01 10:53:41	30.00
661	661	CASH	SUCCESSFUL	2026-11-01 12:42:19	45.00
662	662	UPI	SUCCESSFUL	2026-11-01 07:42:04	75.00
663	663	UPI	SUCCESSFUL	2026-11-01 17:18:33	160.00
664	664	CARD	SUCCESSFUL	2026-11-01 18:38:49	180.00
665	665	UPI	SUCCESSFUL	2026-11-01 12:30:37	120.00
666	666	UPI	SUCCESSFUL	2026-11-01 16:54:17	60.00
667	667	UPI	SUCCESSFUL	2026-11-01 21:47:26	450.00
668	668	CASH	SUCCESSFUL	2026-11-02 00:09:18	330.00
669	669	UPI	SUCCESSFUL	2026-11-02 02:06:05	320.00
670	670	UPI	SUCCESSFUL	2026-11-01 10:04:18	80.00
671	671	UPI	SUCCESSFUL	2026-11-01 18:25:28	80.00
672	672	UPI	SUCCESSFUL	2026-11-01 08:15:46	60.00
673	673	CARD	SUCCESSFUL	2026-11-01 17:46:50	80.00
674	674	UPI	SUCCESSFUL	2026-11-01 20:30:33	15.00
675	675	UPI	SUCCESSFUL	2026-11-01 11:08:20	30.00
676	676	UPI	SUCCESSFUL	2026-11-01 19:58:34	80.00
677	677	UPI	SUCCESSFUL	2026-11-01 09:47:21	180.00
678	678	UPI	SUCCESSFUL	2026-11-01 12:20:33	60.00
679	679	UPI	SUCCESSFUL	2026-11-01 16:05:47	15.00
680	680	UPI	SUCCESSFUL	2026-11-01 22:36:46	100.00
681	681	CARD	SUCCESSFUL	2026-11-01 17:26:48	240.00
682	682	UPI	SUCCESSFUL	2026-11-01 23:43:25	160.00
683	683	CASH	SUCCESSFUL	2026-11-01 13:10:26	40.00
684	684	CASH	SUCCESSFUL	2026-11-01 23:30:35	220.00
685	685	CARD	SUCCESSFUL	2026-11-01 16:19:20	75.00
686	686	UPI	SUCCESSFUL	2026-11-01 22:08:28	200.00
687	687	CASH	SUCCESSFUL	2026-11-01 19:00:58	40.00
688	688	UPI	SUCCESSFUL	2026-11-01 14:54:48	40.00
689	689	UPI	SUCCESSFUL	2026-11-01 20:29:45	200.00
690	690	UPI	SUCCESSFUL	2026-11-01 12:15:34	30.00
691	691	CARD	SUCCESSFUL	2026-11-01 17:28:13	60.00
692	692	UPI	SUCCESSFUL	2026-11-01 19:43:25	120.00
693	693	UPI	SUCCESSFUL	2026-11-01 17:22:24	15.00
694	694	UPI	SUCCESSFUL	2026-11-02 00:26:19	330.00
695	695	CARD	SUCCESSFUL	2026-11-01 19:10:16	200.00
696	696	UPI	SUCCESSFUL	2026-11-01 21:18:12	80.00
697	697	UPI	SUCCESSFUL	2026-11-01 19:19:09	15.00
698	698	CASH	SUCCESSFUL	2026-11-01 10:49:28	0.00
699	699	UPI	SUCCESSFUL	2026-11-01 16:39:45	15.00
700	700	CARD	SUCCESSFUL	2026-11-01 12:44:41	200.00
701	701	UPI	SUCCESSFUL	2026-11-01 13:04:25	200.00
702	702	CARD	SUCCESSFUL	2026-11-01 08:33:20	40.00
703	703	UPI	SUCCESSFUL	2026-11-01 21:45:27	120.00
704	704	CARD	SUCCESSFUL	2026-11-01 19:43:18	540.00
705	705	UPI	SUCCESSFUL	2026-11-01 08:30:46	20.00
706	706	UPI	SUCCESSFUL	2026-11-01 13:15:17	120.00
707	707	UPI	SUCCESSFUL	2026-11-01 19:12:37	60.00
708	708	CASH	SUCCESSFUL	2026-11-01 14:52:31	80.00
709	709	UPI	SUCCESSFUL	2026-11-02 01:36:50	460.00
710	710	CARD	SUCCESSFUL	2026-11-01 11:11:43	360.00
711	711	UPI	SUCCESSFUL	2026-11-01 13:42:56	150.00
712	712	CARD	SUCCESSFUL	2026-11-01 14:31:46	120.00
713	713	CARD	SUCCESSFUL	2026-11-01 14:22:48	75.00
714	714	UPI	SUCCESSFUL	2026-11-01 13:12:27	120.00
715	715	UPI	SUCCESSFUL	2026-11-02 08:53:00	90.00
716	716	UPI	SUCCESSFUL	2026-11-02 09:25:00	10.00
717	717	CARD	SUCCESSFUL	2026-11-02 10:23:00	30.00
718	718	UPI	SUCCESSFUL	2026-11-02 14:12:00	30.00
719	719	UPI	SUCCESSFUL	2026-11-02 13:16:00	0.00
720	720	UPI	SUCCESSFUL	2026-11-02 12:19:00	40.00
721	721	CARD	SUCCESSFUL	2026-11-02 15:17:32.408187	60.00
722	722	CARD	SUCCESSFUL	2026-11-02 10:14:00	50.00
723	723	UPI	SUCCESSFUL	2026-11-02 12:18:00	120.00
724	724	UPI	SUCCESSFUL	2026-11-02 14:20:00	100.00
725	725	UPI	SUCCESSFUL	2026-11-02 11:36:00	60.00
726	726	UPI	SUCCESSFUL	2026-11-02 11:31:00	20.00
727	727	UPI	SUCCESSFUL	2026-11-02 13:07:00	50.00
728	728	CARD	SUCCESSFUL	2026-11-02 14:59:00	90.00
729	729	UPI	SUCCESSFUL	2026-11-02 09:15:00	90.00
730	730	CARD	SUCCESSFUL	2026-11-02 10:13:00	30.00
731	731	UPI	SUCCESSFUL	2026-11-02 15:17:32.408187	150.00
732	732	CARD	SUCCESSFUL	2026-11-02 13:24:00	40.00
733	733	CARD	SUCCESSFUL	2026-11-02 12:55:00	30.00
734	734	CASH	SUCCESSFUL	2026-11-02 08:12:00	60.00
735	735	UPI	SUCCESSFUL	2026-11-02 08:36:00	90.00
736	736	UPI	SUCCESSFUL	2026-11-02 09:24:00	30.00
737	737	CARD	SUCCESSFUL	2026-11-02 07:34:00	45.00
738	738	UPI	SUCCESSFUL	2026-11-02 11:31:00	100.00
739	739	CASH	SUCCESSFUL	2026-11-02 08:05:00	75.00
740	740	UPI	SUCCESSFUL	2026-11-02 12:40:00	150.00
741	741	UPI	SUCCESSFUL	2026-11-02 15:17:32.408187	20.00
742	742	UPI	SUCCESSFUL	2026-11-02 12:40:00	0.00
743	743	UPI	SUCCESSFUL	2026-11-02 14:47:00	160.00
744	744	CARD	SUCCESSFUL	2026-11-02 11:48:00	40.00
745	745	UPI	SUCCESSFUL	2026-11-02 12:52:00	30.00
746	746	UPI	SUCCESSFUL	2026-11-02 13:03:00	20.00
747	747	UPI	SUCCESSFUL	2026-11-02 15:17:32.408187	40.00
748	748	UPI	SUCCESSFUL	2026-11-02 12:23:00	50.00
749	749	CARD	SUCCESSFUL	2026-11-02 14:56:00	30.00
750	750	UPI	SUCCESSFUL	2026-11-02 15:17:32.408187	60.00
751	751	UPI	SUCCESSFUL	2026-11-02 14:20:00	30.00
752	752	UPI	SUCCESSFUL	2026-11-02 13:51:00	50.00
753	753	UPI	SUCCESSFUL	2026-11-02 11:33:00	60.00
754	754	CARD	SUCCESSFUL	2026-11-02 15:17:32.408187	60.00
\.


--
-- Data for Name: shift_assignment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.shift_assignment (assignment_id, staff_id, zone_id, gate_id, shift_date, start_time, end_time) FROM stdin;
1	1	1	1	2026-08-17	08:00:00	16:00:00
2	24	1	1	2026-11-01	22:00:00	06:00:00
3	6	1	1	2026-11-01	14:00:00	22:00:00
4	1	1	1	2026-11-01	06:00:00	14:00:00
5	26	1	2	2026-11-01	14:00:00	22:00:00
6	10	1	4	2026-11-01	14:00:00	22:00:00
7	3	1	4	2026-11-01	06:00:00	14:00:00
8	25	4	5	2026-11-01	06:00:00	14:00:00
9	18	4	5	2026-11-01	14:00:00	22:00:00
10	23	1	\N	2026-11-01	09:00:00	17:00:00
11	22	5	\N	2026-11-01	22:00:00	06:00:00
12	12	3	\N	2026-11-01	14:00:00	22:00:00
13	11	1	\N	2026-11-01	14:00:00	22:00:00
14	9	2	\N	2026-11-01	14:00:00	22:00:00
15	8	1	\N	2026-11-01	06:00:00	14:00:00
16	5	3	\N	2026-11-01	06:00:00	14:00:00
17	4	1	\N	2026-11-01	06:00:00	14:00:00
18	2	1	\N	2026-11-01	06:00:00	14:00:00
19	24	1	1	2026-11-02	22:00:00	06:00:00
20	1	1	1	2026-11-02	06:00:00	14:00:00
21	26	1	2	2026-11-02	14:00:00	22:00:00
22	10	1	4	2026-11-02	14:00:00	22:00:00
23	3	1	4	2026-11-02	06:00:00	14:00:00
24	25	4	5	2026-11-02	06:00:00	14:00:00
25	18	4	5	2026-11-02	14:00:00	22:00:00
26	23	1	\N	2026-11-02	09:00:00	17:00:00
27	22	5	\N	2026-11-02	22:00:00	06:00:00
28	12	3	\N	2026-11-02	14:00:00	22:00:00
29	11	1	\N	2026-11-02	14:00:00	22:00:00
30	9	2	\N	2026-11-02	14:00:00	22:00:00
31	8	1	\N	2026-11-02	06:00:00	14:00:00
32	7	2	\N	2026-11-02	06:00:00	14:00:00
33	5	3	\N	2026-11-02	06:00:00	14:00:00
34	4	1	\N	2026-11-02	06:00:00	14:00:00
35	2	1	\N	2026-11-02	06:00:00	14:00:00
36	24	1	1	2026-11-03	22:00:00	06:00:00
37	6	1	1	2026-11-03	14:00:00	22:00:00
38	1	1	1	2026-11-03	06:00:00	14:00:00
39	10	1	4	2026-11-03	14:00:00	22:00:00
40	3	1	4	2026-11-03	06:00:00	14:00:00
41	25	4	5	2026-11-03	06:00:00	14:00:00
42	18	4	5	2026-11-03	14:00:00	22:00:00
43	23	1	\N	2026-11-03	09:00:00	17:00:00
44	22	5	\N	2026-11-03	22:00:00	06:00:00
45	11	1	\N	2026-11-03	14:00:00	22:00:00
46	9	2	\N	2026-11-03	14:00:00	22:00:00
47	8	1	\N	2026-11-03	06:00:00	14:00:00
48	7	2	\N	2026-11-03	06:00:00	14:00:00
49	4	1	\N	2026-11-03	06:00:00	14:00:00
50	2	1	\N	2026-11-03	06:00:00	14:00:00
51	24	1	1	2026-11-04	22:00:00	06:00:00
52	6	1	1	2026-11-04	14:00:00	22:00:00
53	1	1	1	2026-11-04	06:00:00	14:00:00
54	26	1	2	2026-11-04	14:00:00	22:00:00
55	10	1	4	2026-11-04	14:00:00	22:00:00
56	3	1	4	2026-11-04	06:00:00	14:00:00
57	23	1	\N	2026-11-04	09:00:00	17:00:00
58	22	5	\N	2026-11-04	22:00:00	06:00:00
59	12	3	\N	2026-11-04	14:00:00	22:00:00
60	9	2	\N	2026-11-04	14:00:00	22:00:00
61	8	1	\N	2026-11-04	06:00:00	14:00:00
62	7	2	\N	2026-11-04	06:00:00	14:00:00
63	5	3	\N	2026-11-04	06:00:00	14:00:00
64	2	1	\N	2026-11-04	06:00:00	14:00:00
65	6	1	1	2026-11-05	14:00:00	22:00:00
66	1	1	1	2026-11-05	06:00:00	14:00:00
67	26	1	2	2026-11-05	14:00:00	22:00:00
68	25	4	5	2026-11-05	06:00:00	14:00:00
69	18	4	5	2026-11-05	14:00:00	22:00:00
70	23	1	\N	2026-11-05	09:00:00	17:00:00
71	22	5	\N	2026-11-05	22:00:00	06:00:00
72	12	3	\N	2026-11-05	14:00:00	22:00:00
73	11	1	\N	2026-11-05	14:00:00	22:00:00
74	9	2	\N	2026-11-05	14:00:00	22:00:00
75	8	1	\N	2026-11-05	06:00:00	14:00:00
76	7	2	\N	2026-11-05	06:00:00	14:00:00
77	5	3	\N	2026-11-05	06:00:00	14:00:00
78	4	1	\N	2026-11-05	06:00:00	14:00:00
79	2	1	\N	2026-11-05	06:00:00	14:00:00
80	24	1	1	2026-11-06	22:00:00	06:00:00
81	6	1	1	2026-11-06	14:00:00	22:00:00
82	1	1	1	2026-11-06	06:00:00	14:00:00
83	26	1	2	2026-11-06	14:00:00	22:00:00
84	10	1	4	2026-11-06	14:00:00	22:00:00
85	3	1	4	2026-11-06	06:00:00	14:00:00
86	25	4	5	2026-11-06	06:00:00	14:00:00
87	18	4	5	2026-11-06	14:00:00	22:00:00
88	22	5	\N	2026-11-06	22:00:00	06:00:00
89	12	3	\N	2026-11-06	14:00:00	22:00:00
90	11	1	\N	2026-11-06	14:00:00	22:00:00
91	8	1	\N	2026-11-06	06:00:00	14:00:00
92	7	2	\N	2026-11-06	06:00:00	14:00:00
93	5	3	\N	2026-11-06	06:00:00	14:00:00
94	4	1	\N	2026-11-06	06:00:00	14:00:00
95	24	1	1	2026-11-07	22:00:00	06:00:00
96	6	1	1	2026-11-07	14:00:00	22:00:00
97	26	1	2	2026-11-07	14:00:00	22:00:00
98	10	1	4	2026-11-07	14:00:00	22:00:00
99	3	1	4	2026-11-07	06:00:00	14:00:00
100	25	4	5	2026-11-07	06:00:00	14:00:00
101	18	4	5	2026-11-07	14:00:00	22:00:00
102	23	1	\N	2026-11-07	09:00:00	17:00:00
103	12	3	\N	2026-11-07	14:00:00	22:00:00
104	11	1	\N	2026-11-07	14:00:00	22:00:00
105	9	2	\N	2026-11-07	14:00:00	22:00:00
106	7	2	\N	2026-11-07	06:00:00	14:00:00
107	5	3	\N	2026-11-07	06:00:00	14:00:00
108	4	1	\N	2026-11-07	06:00:00	14:00:00
109	2	1	\N	2026-11-07	06:00:00	14:00:00
110	24	1	1	2026-11-08	22:00:00	06:00:00
111	6	1	1	2026-11-08	14:00:00	22:00:00
112	1	1	1	2026-11-08	06:00:00	14:00:00
113	26	1	2	2026-11-08	14:00:00	22:00:00
114	10	1	4	2026-11-08	14:00:00	22:00:00
115	3	1	4	2026-11-08	06:00:00	14:00:00
116	25	4	5	2026-11-08	06:00:00	14:00:00
117	18	4	5	2026-11-08	14:00:00	22:00:00
118	23	1	\N	2026-11-08	09:00:00	17:00:00
119	22	5	\N	2026-11-08	22:00:00	06:00:00
120	12	3	\N	2026-11-08	14:00:00	22:00:00
121	11	1	\N	2026-11-08	14:00:00	22:00:00
122	9	2	\N	2026-11-08	14:00:00	22:00:00
123	8	1	\N	2026-11-08	06:00:00	14:00:00
124	5	3	\N	2026-11-08	06:00:00	14:00:00
125	4	1	\N	2026-11-08	06:00:00	14:00:00
126	2	1	\N	2026-11-08	06:00:00	14:00:00
\.


--
-- Data for Name: slot_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.slot_type (slot_type_id, slot_type_name, description) FROM stdin;
1	Compact	2.3 m × 4.5 m bay for hatchbacks and small cars
2	Large	2.8 m × 5.5 m bay for SUVs, MUVs and vans
3	Two-Wheeler	1.0 m × 2.0 m bay for motorcycles and scooters
4	EV Charging	Standard bay with a 7.4 kW AC / 30 kW DC charger
5	Reserved - Members	Bay reserved for membership pass holders
6	Standard	2.5 m × 5.0 m bay for sedans and mid-size cars
7	Accessible	3.6 m wide bay next to the lifts, for drivers with disabilities
8	Loading Bay	3.5 m × 8.0 m bay for deliveries and light commercial vehicles
\.


--
-- Data for Name: staff_details; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.staff_details (staff_id, staff_name, designation, phone_no, salary, date_of_joining) FROM stdin;
1	Alex Smith	Gate Operator	+19876500001	32000.00	2024-03-01
2	Rajesh Patel	Security Guard	9876500002	28000.00	2023-06-15
3	Amit Kumar	Gate Operator	9876500003	30000.00	2024-01-10
4	Suresh Yadav	Supervisor	9876500004	42000.00	2022-08-22
5	Vikram Singh	Security Guard	9876500005	27500.00	2023-11-05
6	Rohit Sharma	Gate Operator	9876500006	31000.00	2024-04-18
7	Manish Gupta	Maintenance Staff	9876500007	35000.00	2022-12-12
8	Kiran Desai	Receptionist	9876500008	30000.00	2024-02-20
9	Deepak Verma	Security Guard	9876500009	28500.00	2023-09-14
10	Nirav Shah	Gate Operator	9876500010	32500.00	2024-05-06
11	Prakash Mehta	Supervisor	9876500011	45000.00	2021-07-19
12	Anil Kumar	Maintenance Staff	9876500012	34000.00	2023-03-11
13	Harsh Patel	Gate Operator	9876500013	31500.00	2024-06-03
14	Gurpreet Singh	Security Guard	9876500014	29000.00	2022-10-27
15	Sanjay Rao	Electrician	9876500015	38000.00	2023-01-16
16	Karthik Reddy	Gate Operator	9876500016	30500.00	2024-07-08
17	Anand Nair	Security Guard	9876500017	29500.00	2023-05-29
18	Harsh Trivedi	Supervisor	9876500018	44000.00	2022-04-04
19	Mohit Jain	Maintenance Staff	9876500019	33500.00	2023-12-01
20	Ravi Krishna	Gate Operator	9876500020	32000.00	2024-08-12
21	Aakash Joshi	Security Guard	9876500021	28500.00	2024-09-10
22	Ramesh Chauhan	Security Guard	9876500018	27000.00	2024-11-11
23	Pooja Nair	EV Charging Technician	9876500013	33000.00	2025-01-06
24	Farhan Shaikh	Gate Operator	9876500017	31500.00	2023-12-04
25	Sanjay Rathod	Parking Attendant	9876500014	24000.00	2024-09-02
26	Meera Joshi	Cashier	9876500016	29000.00	2024-06-24
\.


--
-- Data for Name: tariff; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tariff (tariff_id, type_id, day_type, start_time, end_time, hourly_rate, overtime_rate, valid_from, valid_to) FROM stdin;
1	1	WEEKDAY	08:00:00	22:00:00	50.00	75.00	2026-01-01	2026-12-31
2	1	WEEKDAY	08:00:00	22:00:00	40.00	60.00	2026-01-01	2026-12-31
3	4	WEEKDAY	08:00:00	22:00:00	30.00	45.00	2026-01-01	2026-12-31
4	2	WEEKEND	08:00:00	22:00:00	40.00	60.00	2026-01-01	2026-12-31
5	6	WEEKEND	08:00:00	22:00:00	15.00	20.00	2026-01-01	2026-12-31
6	5	WEEKDAY	08:00:00	22:00:00	80.00	120.00	2026-01-01	2026-12-31
7	3	WEEKDAY	08:00:00	22:00:00	10.00	15.00	2026-01-01	2026-12-31
8	8	WEEKEND	08:00:00	22:00:00	60.00	90.00	2026-01-01	2026-12-31
9	7	WEEKDAY	08:00:00	22:00:00	50.00	75.00	2026-01-01	2026-12-31
10	8	WEEKDAY	08:00:00	22:00:00	50.00	75.00	2026-01-01	2026-12-31
11	3	WEEKEND	08:00:00	22:00:00	15.00	20.00	2026-01-01	2026-12-31
12	7	WEEKEND	08:00:00	22:00:00	60.00	90.00	2026-01-01	2026-12-31
13	4	WEEKEND	08:00:00	22:00:00	40.00	60.00	2026-01-01	2026-12-31
14	5	WEEKEND	08:00:00	22:00:00	100.00	150.00	2026-01-01	2026-12-31
15	1	WEEKEND	08:00:00	22:00:00	50.00	75.00	2026-01-01	2026-12-31
16	2	WEEKDAY	08:00:00	22:00:00	30.00	45.00	2026-01-01	2026-12-31
17	6	WEEKDAY	08:00:00	22:00:00	10.00	15.00	2026-01-01	2026-12-31
\.


--
-- Data for Name: vehicle; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vehicle (vehicle_id, registration_no, type_id, owner_name, owner_phone) FROM stdin;
1	GJ-01-AB-1234	1	Jay	+919876543210
2	MH-12-AB-1234	2	Rahul sharma	+919016002077
43	GJ01AB1234	1	Rajesh Patel	9876543210
44	GJ05CD5678	2	Amit Shah	9825012345
45	MH12EF9012	1	Rahul Sharma	9876543211
46	DL01GH3456	2	Arjun Verma	9810012345
47	RJ14IJ7890	1	Vikram Singh	9799123456
48	KA01KL2345	2	Suresh Kumar	9845012345
49	TN09MN6789	1	Karthik Raman	9840012345
50	UP32OP1234	2	Rohit Yadav	9918012345
51	MP09QR5678	1	Manish Jain	9826012345
52	GJ18ST9012	2	Nirav Mehta	9909012345
53	MH14UV3456	1	Prakash Deshmukh	9890012345
54	DL03WX7890	2	Ankit Gupta	9818012345
55	KA05YZ1234	1	Vijay Reddy	9986012345
56	HR26AB5678	2	Deepak Kumar	9873012345
57	PB10CD9012	1	Gurpreet Singh	9872012345
58	WB06EF3456	2	Sourav Das	9831012345
59	GJ27GH7890	1	Harsh Trivedi	9898012345
60	KL07IJ1234	2	Anand Nair	9847012345
61	AP09KL5678	1	Ravi Krishna	9985012345
62	OD02MN9012	2	Subhash Behera	9861012345
63	GJ-01-AN-9999	1	\N	\N
64	MH-02-CD-5678	1	\N	\N
65	3NE483	2	\N	\N
66	RJ14CV00	2	\N	\N
67	RJ-14-CY-0002	2	\N	\N
68	RJ-14-CV-0002	2	\N	\N
69	RJ14CY000	2	\N	\N
70	RJ14CV000	2	\N	\N
71	1RJ14CV0002	2	\N	\N
72	I4TSYAU	1	\N	\N
73	WB06F57	2	\N	\N
74	NBO06F5Y77	2	\N	\N
75	WB06F5Y78	2	\N	\N
76	4NNYWN	2	\N	\N
77	J706F5377	2	\N	\N
78	XNWBO6FS7	2	\N	\N
79	1BNCLFF	2	\N	\N
80	GJ01SD3344	1	Vivek Iyer	9909077788
81	GJ01EV0123	2	Aditya Kapoor	9909055566
82	GJ01FX1123	3	Yash Parmar	9737011122
83	GJ01HZ0954	4	Priya Mehta	9824022334
84	GJ01KP4521	4	Hetal Shah	9824011223
85	GJ01DZ7719	5	FreshMart Deliveries	7926403344
86	GJ01CT4402	5	Shree Logistics	7926401122
87	GJ01PS2231	6	Khushi Dave	9737033344
88	GJ01MN7007	8	Rakesh Chaudhary	9898067890
89	GJ01WK8888	8	Dhruv Agarwal	9898012345
90	MH12AE3106	1	Darshan Shah	8835749520
91	GJ01JS3554	4	Tushar Rathod	9722538526
92	GJ27XP1993	4	Krupa Patel	7026879845
93	GJ38XE7138	6	Dev Vaghela	9076432169
94	GJ06MU6684	2	Nikhil Trivedi	9882128731
95	RJ14RH8962	8	Ananya Dave	9040187829
96	MH12VZ1194	4	Sneha Bhatt	9759710281
97	MP09BV2471	6	Krupa Chauhan	9769722040
98	GJ01HC4291	4	Foram Joshi	6381838085
99	GJ03RB7130	3	Sagar Nair	9701331408
100	RJ14NV7056	3	Shruti Chauhan	6348641762
101	DL8CJG6070	1	Krish Modi	9993934085
102	DL8CLE3145	6	Jignesh Dave	6388942844
103	GJ01JV8391	6	Hetvi Trivedi	9058795353
104	GJ27DA0145	1	Pooja Solanki	9756367544
105	GJ27TG0723	6	Dev Pandya	9773290689
106	GJ38XD7814	1	Rahul Bhatt	7012849464
107	GJ01SK9582	3	Zoya Chauhan	9094165097
108	MH12BG9812	4	Shruti Panchal	9882040861
109	DL8CBK7013	4	Dhara Patel	9766432757
110	GJ03DC7013	6	Pooja Dave	6348844945
111	DL8CGF2558	4	Kunal Chauhan	9005212945
112	GJ27XD7362	4	Janvi Iyer	9892920714
113	GJ01KR3519	4	Harsh Rathod	8826245651
114	GJ06TL6634	8	Dev Solanki	9950770603
115	MH04JF7761	4	Vihaan Mehta	9991587564
116	MH12RB2408	1	Diya Solanki	8833944036
117	GJ01AW5531	7	Hetvi Joshi	6382203111
118	GJ01GK2168	8	Riya Panchal	8880505346
119	GJ38GJ9790	4	Aarav Sheth	9846967628
120	GJ06LG3770	3	Parth Solanki	9053258265
121	GJ27GF6717	6	Zoya Vaghela	8802948297
122	DL8CVZ0335	6	Mehul Shah	9975150071
123	MP09YD3196	1	Parth Dave	9966085348
124	GJ27VD9532	4	Bhavin Patel	9743979013
125	GJ01UD4653	3	Imran Patel	6348962915
126	GJ38YU4713	6	Shruti Mansuri	6371170097
127	GJ01TS6428	7	Parth Vaghela	9975017671
128	GJ18AH9657	3	Hetvi Chauhan	9093517394
129	GJ05AM1047	3	Sneha Kulkarni	6302583147
130	MH12WV9555	8	Komal Dave	6376228023
131	GJ06AV2736	8	Payal Pandya	6395444989
132	MP09DC5791	6	Shruti Shah	9876144611
133	GJ27TD1948	4	Sagar Mansuri	6364151918
134	GJ01NB4122	3	Ananya Solanki	8862067462
135	GJ18LV8306	2	Rahul Joshi	9942601193
136	GJ18CK4813	3	Shruti Nair	9048727727
137	GJ01GA6778	4	Dhara Thakkar	8882498199
138	GJ03SJ9168	2	Jay Kulkarni	9008885192
139	GJ27RA9403	3	Ravi Desai	6363520702
140	GJ01TW0714	3	Sagar Patel	8846406280
141	MH12YA5191	8	Riya Desai	9714931624
142	RJ14LH4625	3	Sneha Desai	9992720501
143	GJ27RP4346	6	Payal Sharma	9867021499
144	GJ05GM5447	6	Imran Sharma	9926616562
145	GJ01RN6522	4	Shruti Dave	9060985577
146	GJ27UK5480	6	Jignesh Nair	6366168816
147	DL8CUJ4561	3	Sagar Chauhan	9905466782
148	MH12KZ1107	6	Pooja Sheth	6314193060
149	MH04RN8657	2	Chirag Trivedi	6390089480
150	GJ01CA3805	8	Diya Sheth	9957813549
151	MH04SN1841	3	Shruti Patel	8805549877
152	RJ14YN1022	4	Jay Trivedi	9008095157
153	GJ38UC7588	1	Nidhi Modi	9004934857
154	RJ14HS1990	4	Ananya Modi	8811557653
155	DL8CHE3597	4	Imran Thakkar	7044142742
156	GJ01KT4059	3	Parth Chauhan	9768381824
157	GJ01HR2450	2	Harsh Mansuri	9755136428
158	GJ03NX8878	3	Nidhi Thakkar	9851211183
159	DL8CTE4226	2	Parth Nair	9987703518
160	MP09EY7931	4	Sagar Chauhan	9736575310
161	GJ38RD4592	2	Krupa Modi	8862224454
162	GJ05MT9499	8	Foram Trivedi	9964571624
163	GJ01JW7301	1	Krupa Mehta	9959746665
164	GJ01TK1271	3	Jignesh Prajapati	6356522901
165	GJ05TW6338	7	Shruti Solanki	9090855164
166	GJ01PE3828	3	Rahul Rathod	6395168028
167	GJ06AM9481	3	Krish Patel	6331371583
168	DL8CHF4509	4	Mehul Shah	7066813077
169	GJ01RJ5188	6	Shruti Mehta	9849159137
170	GJ01NB7172	6	Foram Thakkar	9934806719
171	GJ03MK8178	4	Mehul Mansuri	9958358286
172	GJ01ND1171	4	Sneha Modi	9981954933
173	GJ01EB6807	1	Ananya Sharma	9833057391
174	GJ06YU8546	7	Ananya Sharma	8815568047
175	DL8CAG1592	4	Nikhil Sheth	8828021554
176	GJ01XM6392	8	Nikhil Nair	9840259510
177	GJ01MC9346	1	Mansi Sharma	6326397229
178	RJ14KP4914	6	Aarav Bhatt	9772648777
179	GJ01SG1346	3	Payal Trivedi	9061291055
180	GJ01AP5616	7	Krish Rathod	7052569935
181	GJ05VB4479	4	Foram Shah	8842339992
182	GJ01UV2252	4	Janvi Mehta	8858468893
183	MH04FJ8585	8	Dev Rathod	9006539445
184	GJ27NF6001	2	Sagar Prajapati	8831403460
185	MH12AD5319	3	Nidhi Mehta	9975866115
186	GJ05HL8144	4	Kunal Sharma	9781209963
187	MH04GL7415	6	Nidhi Joshi	9876683765
188	GJ06WJ5034	8	Bhavin Patel	9708454004
189	MH12TA9016	8	Shruti Nair	9064319717
190	GJ18VT0891	3	Imran Parmar	6352709018
191	MH12MB9677	4	Payal Trivedi	9706119080
192	GJ01UL4684	4	Janvi Vaghela	6337830670
193	GJ01GC6466	8	Ravi Chauhan	6375419035
194	GJ01WL6856	6	Mehul Mehta	9025591027
195	GJ38DC3502	4	Hetvi Nair	9019311674
196	GJ01VT1801	4	Imran Joshi	9810047960
197	GJ01JC7316	4	Zoya Bhatt	9060107961
198	GJ03AP7012	4	Rahul Prajapati	9893183912
199	GJ18NT7511	8	Foram Shah	9095389320
200	GJ01PY1422	8	Komal Patel	9771230269
201	DL8CEB6475	3	Krish Kulkarni	9740269557
202	GJ27ED3539	3	Krupa Bhatt	9049523234
203	MH04LF7784	4	Janvi Rathod	9054526287
204	GJ27MM0744	8	Krupa Dave	9808859707
205	RJ14YS4243	4	Foram Thakkar	9057230839
206	RJ14LZ1042	3	Jignesh Modi	9037021616
207	GJ27BH4657	1	Nidhi Rathod	6359335536
208	GJ38XN2411	1	Sagar Nair	9705514903
209	GJ38PV1721	6	Tushar Dave	8850609465
210	GJ01MB8038	4	Ananya Dave	9713353778
211	MH12BJ5782	8	Payal Sheth	8827749440
212	GJ01CK8782	8	Krish Bhatt	9013478129
213	GJ18PB0890	1	Riya Nair	9066194020
214	GJ01HJ1053	4	Hetvi Dave	9827178397
215	GJ06SS6928	4	Nikhil Prajapati	9067198487
216	GJ05CP7669	1	Chirag Solanki	7047934698
217	GJ38HC3906	4	Foram Pandya	9835359686
218	GJ01MZ0398	6	Rahul Dave	9705235844
219	GJ03ZR6893	4	Zoya Prajapati	9771443731
220	MH04HS6547	6	Mehul Joshi	6383482483
221	GJ06FJ7894	4	Foram Mehta	9738562892
222	MH12WT3058	2	Harsh Iyer	9958274045
223	GJ27PW6923	4	Diya Mansuri	9777496087
224	GJ01WX1405	4	Sagar Nair	7099616800
225	GJ06PA5805	3	Imran Panchal	7071830523
226	GJ01SU2773	8	Vihaan Shah	8817378133
227	GJ01WF4064	4	Mehul Dave	9760635717
228	GJ05JK0696	1	Vihaan Iyer	9913006356
229	GJ27EB6034	4	Ananya Shah	6301274638
230	MH04RC6769	7	Parth Thakkar	9776932271
231	MH04CT3964	6	Krish Kulkarni	6341905922
232	GJ18ZY5276	8	Ananya Bhatt	9025325208
233	GJ06KT0896	3	Nikhil Rathod	8893671539
234	GJ01YB2127	4	Harsh Iyer	8890039021
235	RJ14PK2409	8	Sneha Parmar	9993499853
236	GJ27LC5226	3	Krish Prajapati	6301280484
237	GJ27CF9552	7	Nikhil Patel	9722508294
238	GJ01RS9169	3	Nidhi Joshi	6307517000
239	GJ38SK3307	2	Rahul Chauhan	9879080997
240	GJ01TG8496	8	Nikhil Thakkar	7056737161
241	GJ27TP3654	3	Harsh Patel	9901588040
242	GJ01YH5898	6	Sagar Desai	8857409180
243	DL8CUV0600	4	Imran Trivedi	9084575081
244	GJ38YP0777	4	Krish Iyer	9807363158
245	GJ18RG5768	3	Payal Mansuri	6333458526
246	DL8CKK3356	4	Parth Parmar	6377160483
247	GJ01BL9902	4	Dev Sheth	9841767657
248	MP09AT6276	4	Hetvi Modi	9050066428
249	MH12PH4316	4	Aarav Sheth	9066148617
250	GJ05VD8417	8	Darshan Rathod	9933684025
251	GJ01LU7297	1	Imran Sheth	7043047222
252	GJ03GF1048	4	Mehul Chauhan	6306434824
253	GJ18XT7899	8	Tushar Pandya	6315604664
254	DL8CRB6825	8	Dhara Thakkar	7043003418
255	GJ18BW7389	8	Vihaan Patel	6385291480
256	GJ27VN9485	2	Nikhil Modi	9704039731
257	GJ01AT4276	3	Rahul Desai	9874905601
258	GJ27NY8830	6	Riya Kulkarni	7039772234
259	GJ27SJ2953	4	Dev Kulkarni	9716726476
260	DL8CYE6707	6	Kunal Modi	9026110935
261	GJ01EE6799	8	Ravi Mehta	9752275433
262	GJ01KX4520	6	Komal Desai	9059638309
263	GJ05ZV5873	3	Parth Thakkar	9849864123
264	GJ27KB0591	8	Sagar Sheth	9078098899
265	RJ14YY2121	8	Sneha Kulkarni	9763818488
266	GJ06GT1681	6	Ravi Prajapati	9976865069
267	GJ38LS6758	7	Shruti Modi	9069478714
268	MH04BP9814	3	Harsh Rathod	9891413059
269	GJ01GE8291	1	Krupa Desai	9791914248
270	GJ01MH9263	3	Foram Nair	9893294757
271	MH04PV2003	1	Jay Panchal	8881593024
272	GJ27SV5214	3	Janvi Thakkar	8876927124
273	GJ01FR8651	3	Krish Patel	9962438738
274	GJ01RS9442	1	Ravi Prajapati	9090169459
275	RJ14WH1360	3	Shruti Parmar	9963908656
276	GJ01EH9830	4	Payal Pandya	9093249722
277	GJ05VT8357	4	Sneha Rathod	7098453224
278	GJ01CZ9343	4	Zoya Panchal	9022758743
279	GJ01RC1480	6	Aarav Solanki	6335998344
280	GJ27VZ0552	2	Parth Chauhan	9772335304
281	GJ03NH0783	1	Hardik Dave	9720983397
282	MP09SA7542	8	Krupa Parmar	9044406523
283	GJ01PF7847	3	Hardik Parmar	6346369405
284	MP09BL0490	8	Jay Mehta	9784298205
285	GJ01HD9737	2	Jay Kulkarni	8883002986
286	GJ03CK8022	3	Parth Iyer	6315092894
287	MH04WF8659	8	Shruti Prajapati	9707145782
288	RJ14MV5755	3	Hetvi Sheth	9926161125
289	GJ01WM1916	3	Nidhi Kulkarni	7072880408
290	GJ05WJ6248	4	Diya Sharma	9881504750
291	GJ05WK3897	4	Pooja Chauhan	7099909833
292	GJ01TP7567	2	Diya Chauhan	7077971825
293	GJ06PC0799	6	Dhara Thakkar	9980725283
294	GJ38GU2825	4	Shruti Nair	7064968805
295	RJ14PD6454	4	Tushar Pandya	6319766809
296	RJ14JA5099	6	Sneha Dave	9007619321
297	MP09CG6426	8	Zoya Prajapati	9045687428
298	GJ27EH8577	3	Kunal Sharma	9028178580
299	GJ27FG0919	4	Ananya Panchal	9014634442
300	GJ18XB0001	1	Nikhil Mehta	6396541621
301	GJ18CA9025	2	Aarav Pandya	9870247008
302	MP09JH5861	8	Harsh Panchal	6300027825
303	MH12FL7229	3	Riya Vaghela	7027005237
304	GJ27CW2774	8	Jay Trivedi	6330009024
305	MH12BP8062	3	Vihaan Mansuri	8889733484
306	GJ38DV6604	4	Parth Solanki	6305687855
307	GJ01XZ6188	3	Krupa Sharma	9957892277
308	GJ03MS1277	6	Janvi Mehta	9043881497
309	GJ01ED6952	4	Imran Iyer	7013803007
310	GJ38FW9355	1	Parth Joshi	9965420003
311	GJ01BH6045	8	Pooja Iyer	9758106884
312	GJ27DX4711	6	Chirag Thakkar	9914488431
313	RJ14SD4095	6	Ravi Desai	8869487481
314	RJ14TJ8751	6	Shruti Sharma	6359295039
315	GJ01EF3744	3	Bhavin Modi	6313151132
316	GJ03NY7029	4	Aarav Prajapati	9920427104
317	GJ38KS6182	1	Ananya Sheth	7039778200
318	GJ27KM0012	8	Mehul Sharma	9030489961
319	RJ14MT4642	4	Sneha Panchal	8815817758
320	DL8CLE0525	1	Shruti Desai	6377545893
321	GJ38JH1087	3	Vihaan Shah	6311583308
322	MH12TF4138	4	Tushar Vaghela	7017574822
323	GJ18UF6772	3	Diya Pandya	9064994060
324	MH12EZ6386	6	Komal Modi	6386182575
325	GJ05DU1648	4	Payal Dave	9939359931
326	RJ14GH5237	1	Kunal Rathod	9869354647
327	RJ14VZ5116	4	Mehul Mansuri	7089188028
328	GJ06FM3485	1	Komal Joshi	6351455722
329	RJ14YC9329	1	Chirag Patel	9718329872
330	GJ05JJ4644	4	Kunal Dave	9010717685
331	GJ03BK0551	2	Janvi Sheth	9785028595
332	RJ14UL6156	3	Zoya Shah	9802628654
333	GJ18ZJ1978	1	Payal Iyer	6303610133
334	MH04KK9062	4	Ananya Chauhan	7046596078
335	MH04SC7587	3	Jignesh Pandya	9880805222
336	GJ01PX4966	3	Dev Dave	6344104373
337	DL8CVT0252	4	Tushar Patel	9751349213
338	DL8CRX6158	1	Parth Pandya	9700188670
339	GJ27DK1765	4	Foram Modi	6317171389
340	GJ06WH1920	3	Jay Modi	9076144694
341	GJ01NJ3602	2	Foram Pandya	9705348469
342	GJ05WZ4032	1	Sneha Kulkarni	9714092562
343	GJ38FP8434	6	Dev Shah	8838650332
344	GJ38CB1289	3	Kunal Prajapati	8883381616
345	GJ18BL0843	8	Tushar Joshi	9709919452
346	MH12HE4285	3	Hetvi Patel	6394735494
347	GJ06LK3974	4	Nidhi Prajapati	9718250003
348	MH12XJ1204	4	Shruti Pandya	6356026004
349	GJ27TX2665	8	Mansi Prajapati	9043505617
350	GJ01PK4058	1	Foram Mansuri	8889311377
351	GJ01JE4731	2	Darshan Panchal	9787046559
352	GJ27YS4634	6	Riya Modi	7094799408
353	GJ01GE8295	6	Riya Mansuri	6368471704
354	GJ01WE2991	3	Dev Shah	9970842733
355	GJ38AY2329	4	Riya Kulkarni	9803600385
356	DL8CAX5511	7	Zoya Iyer	6370388005
357	MH04YX3235	1	Tushar Trivedi	8820013196
358	GJ27YT8782	6	Ananya Nair	9928688560
359	GJ01MG1688	4	Mehul Mehta	7024266546
360	GJ18XH5729	4	Payal Kulkarni	9961314453
361	MH12VL9405	8	Diya Patel	9091544774
362	GJ01ZK6172	4	Mansi Panchal	9080709206
363	GJ27SN1497	2	Vihaan Pandya	9757425781
364	MH04NK9493	2	Shruti Parmar	8802802034
365	MH04JB7198	4	Dhara Sharma	9990291394
366	GJ01PM4816	4	Tushar Modi	9706725023
367	MH12ZG2658	2	Ravi Mansuri	9719433173
368	GJ01XK9490	4	Ravi Mehta	9932632808
369	MP09WT8737	4	Ravi Panchal	8866922106
370	GJ06MB0858	1	Harsh Patel	9956163185
371	GJ05UG4057	6	Kunal Mansuri	7024726577
372	GJ01GS9735	4	Payal Nair	8836980902
373	GJ27RW4274	6	Vihaan Shah	8863473446
374	RJ14PG9291	4	Nikhil Patel	9730156042
375	DL8CFS1940	6	Krupa Prajapati	6394707095
376	GJ05XA3807	4	Mansi Kulkarni	7050559978
377	GJ01DX0742	8	Harsh Mansuri	9774045630
378	GJ01LV3401	6	Ravi Desai	9707301021
379	GJ18KN2003	2	Komal Modi	9867156771
380	GJ01ES6192	7	Sneha Parmar	9983334373
381	GJ27FS8834	4	Sagar Trivedi	9861467120
382	MH04YV9869	1	Foram Rathod	9801602042
383	GJ18VG7503	6	Riya Chauhan	7078621545
384	MP09NL1578	2	Sagar Patel	9792800743
385	GJ01VY5697	4	Pooja Chauhan	9856822654
386	MH04CH4114	6	Foram Nair	7008802332
387	GJ18MK8467	4	Rahul Rathod	9001103466
388	GJ06BW7328	8	Ananya Desai	7005143567
389	GJ01GX8745	8	Ravi Thakkar	8863477408
390	0000ON	2	\N	\N
391	VV0009	2	\N	\N
\.


--
-- Data for Name: vehicle_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vehicle_type (type_id, type_name) FROM stdin;
1	Sedan
2	Electric Vehicle
3	Motorcycle
4	Hatchback
5	Light Commercial Vehicle
6	Scooter
7	MUV / Van
8	SUV
\.


--
-- Name: membership_pass_pass_no_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.membership_pass_pass_no_seq', 9, true);


--
-- Name: membership_plan_plan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.membership_plan_plan_id_seq', 7, true);


--
-- Name: parking_exit_exit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.parking_exit_exit_id_seq', 754, true);


--
-- Name: parking_gate_gate_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.parking_gate_gate_id_seq', 8, true);


--
-- Name: parking_slot_slot_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.parking_slot_slot_id_seq', 321, true);


--
-- Name: parking_ticket_ticket_no_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.parking_ticket_ticket_no_seq', 935, true);


--
-- Name: parking_zone_zone_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.parking_zone_zone_id_seq', 5, true);


--
-- Name: pass_holder_member_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pass_holder_member_id_seq', 9, true);


--
-- Name: payment_details_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payment_details_payment_id_seq', 754, true);


--
-- Name: shift_assignment_assignment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.shift_assignment_assignment_id_seq', 126, true);


--
-- Name: slot_type_slot_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.slot_type_slot_type_id_seq', 8, true);


--
-- Name: staff_details_staff_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.staff_details_staff_id_seq', 26, true);


--
-- Name: tariff_tariff_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tariff_tariff_id_seq', 17, true);


--
-- Name: vehicle_type_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vehicle_type_type_id_seq', 8, true);


--
-- Name: vehicle_vehicle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vehicle_vehicle_id_seq', 391, true);


--
-- Name: membership_pass membership_pass_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_pass
    ADD CONSTRAINT membership_pass_pkey PRIMARY KEY (pass_no);


--
-- Name: membership_plan membership_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_plan
    ADD CONSTRAINT membership_plan_pkey PRIMARY KEY (plan_id);


--
-- Name: parking_exit parking_exit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_exit
    ADD CONSTRAINT parking_exit_pkey PRIMARY KEY (exit_id);


--
-- Name: parking_exit parking_exit_ticket_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_exit
    ADD CONSTRAINT parking_exit_ticket_no_key UNIQUE (ticket_no);


--
-- Name: parking_gate parking_gate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_gate
    ADD CONSTRAINT parking_gate_pkey PRIMARY KEY (gate_id);


--
-- Name: parking_slot parking_slot_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_slot
    ADD CONSTRAINT parking_slot_pkey PRIMARY KEY (slot_id);


--
-- Name: parking_slot parking_slot_slot_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_slot
    ADD CONSTRAINT parking_slot_slot_no_key UNIQUE (slot_no);


--
-- Name: parking_ticket parking_ticket_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_ticket
    ADD CONSTRAINT parking_ticket_pkey PRIMARY KEY (ticket_no);


--
-- Name: parking_zone parking_zone_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_zone
    ADD CONSTRAINT parking_zone_pkey PRIMARY KEY (zone_id);


--
-- Name: pass_holder pass_holder_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pass_holder
    ADD CONSTRAINT pass_holder_pkey PRIMARY KEY (member_id);


--
-- Name: payment_details payment_details_exit_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_details
    ADD CONSTRAINT payment_details_exit_id_key UNIQUE (exit_id);


--
-- Name: payment_details payment_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_details
    ADD CONSTRAINT payment_details_pkey PRIMARY KEY (payment_id);


--
-- Name: shift_assignment shift_assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shift_assignment
    ADD CONSTRAINT shift_assignment_pkey PRIMARY KEY (assignment_id);


--
-- Name: slot_type slot_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slot_type
    ADD CONSTRAINT slot_type_pkey PRIMARY KEY (slot_type_id);


--
-- Name: staff_details staff_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_details
    ADD CONSTRAINT staff_details_pkey PRIMARY KEY (staff_id);


--
-- Name: tariff tariff_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tariff
    ADD CONSTRAINT tariff_pkey PRIMARY KEY (tariff_id);


--
-- Name: vehicle vehicle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle
    ADD CONSTRAINT vehicle_pkey PRIMARY KEY (vehicle_id);


--
-- Name: vehicle vehicle_registration_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle
    ADD CONSTRAINT vehicle_registration_no_key UNIQUE (registration_no);


--
-- Name: vehicle_type vehicle_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_type
    ADD CONSTRAINT vehicle_type_pkey PRIMARY KEY (type_id);


--
-- Name: membership_pass membership_pass_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_pass
    ADD CONSTRAINT membership_pass_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.pass_holder(member_id) ON DELETE CASCADE;


--
-- Name: membership_pass membership_pass_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_pass
    ADD CONSTRAINT membership_pass_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.membership_plan(plan_id) ON DELETE RESTRICT;


--
-- Name: membership_pass membership_pass_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_pass
    ADD CONSTRAINT membership_pass_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicle(vehicle_id) ON DELETE CASCADE;


--
-- Name: parking_exit parking_exit_exit_gate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_exit
    ADD CONSTRAINT parking_exit_exit_gate_id_fkey FOREIGN KEY (exit_gate_id) REFERENCES public.parking_gate(gate_id) ON DELETE RESTRICT;


--
-- Name: parking_exit parking_exit_ticket_no_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_exit
    ADD CONSTRAINT parking_exit_ticket_no_fkey FOREIGN KEY (ticket_no) REFERENCES public.parking_ticket(ticket_no) ON DELETE RESTRICT;


--
-- Name: parking_gate parking_gate_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_gate
    ADD CONSTRAINT parking_gate_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.parking_zone(zone_id) ON DELETE CASCADE;


--
-- Name: parking_slot parking_slot_slot_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_slot
    ADD CONSTRAINT parking_slot_slot_type_id_fkey FOREIGN KEY (slot_type_id) REFERENCES public.slot_type(slot_type_id) ON DELETE RESTRICT;


--
-- Name: parking_slot parking_slot_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_slot
    ADD CONSTRAINT parking_slot_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.parking_zone(zone_id) ON DELETE CASCADE;


--
-- Name: parking_ticket parking_ticket_entry_gate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_ticket
    ADD CONSTRAINT parking_ticket_entry_gate_id_fkey FOREIGN KEY (entry_gate_id) REFERENCES public.parking_gate(gate_id) ON DELETE RESTRICT;


--
-- Name: parking_ticket parking_ticket_slot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_ticket
    ADD CONSTRAINT parking_ticket_slot_id_fkey FOREIGN KEY (slot_id) REFERENCES public.parking_slot(slot_id) ON DELETE RESTRICT;


--
-- Name: parking_ticket parking_ticket_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parking_ticket
    ADD CONSTRAINT parking_ticket_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicle(vehicle_id) ON DELETE RESTRICT;


--
-- Name: payment_details payment_details_exit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_details
    ADD CONSTRAINT payment_details_exit_id_fkey FOREIGN KEY (exit_id) REFERENCES public.parking_exit(exit_id) ON DELETE RESTRICT;


--
-- Name: shift_assignment shift_assignment_gate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shift_assignment
    ADD CONSTRAINT shift_assignment_gate_id_fkey FOREIGN KEY (gate_id) REFERENCES public.parking_gate(gate_id) ON DELETE SET NULL;


--
-- Name: shift_assignment shift_assignment_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shift_assignment
    ADD CONSTRAINT shift_assignment_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staff_details(staff_id) ON DELETE CASCADE;


--
-- Name: shift_assignment shift_assignment_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shift_assignment
    ADD CONSTRAINT shift_assignment_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.parking_zone(zone_id) ON DELETE SET NULL;


--
-- Name: tariff tariff_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tariff
    ADD CONSTRAINT tariff_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.vehicle_type(type_id) ON DELETE CASCADE;


--
-- Name: vehicle vehicle_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle
    ADD CONSTRAINT vehicle_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.vehicle_type(type_id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--


