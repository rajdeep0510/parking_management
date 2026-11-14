--
-- PostgreSQL database dump
--

\restrict EATNgbUrtEAc09Sr8A7wZfbFONqMY5k51vVUCgjhzA5bUWVuej81Ebfv7biTbFk

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: membership_pass; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.membership_pass OWNER TO postgres;

--
-- Name: membership_pass_pass_no_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.membership_pass_pass_no_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.membership_pass_pass_no_seq OWNER TO postgres;

--
-- Name: membership_pass_pass_no_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.membership_pass_pass_no_seq OWNED BY public.membership_pass.pass_no;


--
-- Name: membership_plan; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.membership_plan OWNER TO postgres;

--
-- Name: membership_plan_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.membership_plan_plan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.membership_plan_plan_id_seq OWNER TO postgres;

--
-- Name: membership_plan_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.membership_plan_plan_id_seq OWNED BY public.membership_plan.plan_id;


--
-- Name: parking_exit; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.parking_exit OWNER TO postgres;

--
-- Name: parking_exit_exit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.parking_exit_exit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.parking_exit_exit_id_seq OWNER TO postgres;

--
-- Name: parking_exit_exit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.parking_exit_exit_id_seq OWNED BY public.parking_exit.exit_id;


--
-- Name: parking_gate; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.parking_gate OWNER TO postgres;

--
-- Name: parking_gate_gate_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.parking_gate_gate_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.parking_gate_gate_id_seq OWNER TO postgres;

--
-- Name: parking_gate_gate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.parking_gate_gate_id_seq OWNED BY public.parking_gate.gate_id;


--
-- Name: parking_slot; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parking_slot (
    slot_id integer NOT NULL,
    slot_no character varying(20) NOT NULL,
    zone_id integer NOT NULL,
    slot_type_id integer NOT NULL,
    availability_status character varying(20) DEFAULT 'AVAILABLE'::character varying,
    CONSTRAINT parking_slot_availability_status_check CHECK (((availability_status)::text = ANY ((ARRAY['AVAILABLE'::character varying, 'OCCUPIED'::character varying, 'MAINTENANCE'::character varying])::text[])))
);


ALTER TABLE public.parking_slot OWNER TO postgres;

--
-- Name: parking_slot_slot_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.parking_slot_slot_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.parking_slot_slot_id_seq OWNER TO postgres;

--
-- Name: parking_slot_slot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.parking_slot_slot_id_seq OWNED BY public.parking_slot.slot_id;


--
-- Name: parking_ticket; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.parking_ticket OWNER TO postgres;

--
-- Name: parking_ticket_ticket_no_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.parking_ticket_ticket_no_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.parking_ticket_ticket_no_seq OWNER TO postgres;

--
-- Name: parking_ticket_ticket_no_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.parking_ticket_ticket_no_seq OWNED BY public.parking_ticket.ticket_no;


--
-- Name: parking_zone; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parking_zone (
    zone_id integer NOT NULL,
    zone_name character varying(50) NOT NULL,
    floor_level integer NOT NULL,
    total_capacity integer NOT NULL,
    CONSTRAINT parking_zone_total_capacity_check CHECK ((total_capacity >= 0))
);


ALTER TABLE public.parking_zone OWNER TO postgres;

--
-- Name: parking_zone_zone_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.parking_zone_zone_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.parking_zone_zone_id_seq OWNER TO postgres;

--
-- Name: parking_zone_zone_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.parking_zone_zone_id_seq OWNED BY public.parking_zone.zone_id;


--
-- Name: pass_holder; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pass_holder (
    member_id integer NOT NULL,
    member_name character varying(100) NOT NULL,
    contact_no character varying(15) NOT NULL,
    address text
);


ALTER TABLE public.pass_holder OWNER TO postgres;

--
-- Name: pass_holder_member_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pass_holder_member_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pass_holder_member_id_seq OWNER TO postgres;

--
-- Name: pass_holder_member_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pass_holder_member_id_seq OWNED BY public.pass_holder.member_id;


--
-- Name: payment_details; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.payment_details OWNER TO postgres;

--
-- Name: payment_details_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payment_details_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payment_details_payment_id_seq OWNER TO postgres;

--
-- Name: payment_details_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payment_details_payment_id_seq OWNED BY public.payment_details.payment_id;


--
-- Name: shift_assignment; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.shift_assignment OWNER TO postgres;

--
-- Name: shift_assignment_assignment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shift_assignment_assignment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.shift_assignment_assignment_id_seq OWNER TO postgres;

--
-- Name: shift_assignment_assignment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shift_assignment_assignment_id_seq OWNED BY public.shift_assignment.assignment_id;


--
-- Name: slot_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slot_type (
    slot_type_id integer NOT NULL,
    slot_type_name character varying(50) NOT NULL,
    description text
);


ALTER TABLE public.slot_type OWNER TO postgres;

--
-- Name: slot_type_slot_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.slot_type_slot_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.slot_type_slot_type_id_seq OWNER TO postgres;

--
-- Name: slot_type_slot_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.slot_type_slot_type_id_seq OWNED BY public.slot_type.slot_type_id;


--
-- Name: staff_details; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.staff_details OWNER TO postgres;

--
-- Name: staff_details_staff_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.staff_details_staff_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.staff_details_staff_id_seq OWNER TO postgres;

--
-- Name: staff_details_staff_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.staff_details_staff_id_seq OWNED BY public.staff_details.staff_id;


--
-- Name: tariff; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.tariff OWNER TO postgres;

--
-- Name: tariff_tariff_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tariff_tariff_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tariff_tariff_id_seq OWNER TO postgres;

--
-- Name: tariff_tariff_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tariff_tariff_id_seq OWNED BY public.tariff.tariff_id;


--
-- Name: vehicle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vehicle (
    vehicle_id integer NOT NULL,
    registration_no character varying(20) NOT NULL,
    type_id integer NOT NULL,
    owner_name character varying(100),
    owner_phone character varying(15)
);


ALTER TABLE public.vehicle OWNER TO postgres;

--
-- Name: vehicle_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vehicle_type (
    type_id integer NOT NULL,
    type_name character varying(50) NOT NULL
);


ALTER TABLE public.vehicle_type OWNER TO postgres;

--
-- Name: vehicle_type_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vehicle_type_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicle_type_type_id_seq OWNER TO postgres;

--
-- Name: vehicle_type_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vehicle_type_type_id_seq OWNED BY public.vehicle_type.type_id;


--
-- Name: vehicle_vehicle_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vehicle_vehicle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicle_vehicle_id_seq OWNER TO postgres;

--
-- Name: vehicle_vehicle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vehicle_vehicle_id_seq OWNED BY public.vehicle.vehicle_id;


--
-- Name: membership_pass pass_no; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.membership_pass ALTER COLUMN pass_no SET DEFAULT nextval('public.membership_pass_pass_no_seq'::regclass);


--
-- Name: membership_plan plan_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.membership_plan ALTER COLUMN plan_id SET DEFAULT nextval('public.membership_plan_plan_id_seq'::regclass);


--
-- Name: parking_exit exit_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_exit ALTER COLUMN exit_id SET DEFAULT nextval('public.parking_exit_exit_id_seq'::regclass);


--
-- Name: parking_gate gate_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_gate ALTER COLUMN gate_id SET DEFAULT nextval('public.parking_gate_gate_id_seq'::regclass);


--
-- Name: parking_slot slot_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_slot ALTER COLUMN slot_id SET DEFAULT nextval('public.parking_slot_slot_id_seq'::regclass);


--
-- Name: parking_ticket ticket_no; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_ticket ALTER COLUMN ticket_no SET DEFAULT nextval('public.parking_ticket_ticket_no_seq'::regclass);


--
-- Name: parking_zone zone_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_zone ALTER COLUMN zone_id SET DEFAULT nextval('public.parking_zone_zone_id_seq'::regclass);


--
-- Name: pass_holder member_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pass_holder ALTER COLUMN member_id SET DEFAULT nextval('public.pass_holder_member_id_seq'::regclass);


--
-- Name: payment_details payment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_details ALTER COLUMN payment_id SET DEFAULT nextval('public.payment_details_payment_id_seq'::regclass);


--
-- Name: shift_assignment assignment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shift_assignment ALTER COLUMN assignment_id SET DEFAULT nextval('public.shift_assignment_assignment_id_seq'::regclass);


--
-- Name: slot_type slot_type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slot_type ALTER COLUMN slot_type_id SET DEFAULT nextval('public.slot_type_slot_type_id_seq'::regclass);


--
-- Name: staff_details staff_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff_details ALTER COLUMN staff_id SET DEFAULT nextval('public.staff_details_staff_id_seq'::regclass);


--
-- Name: tariff tariff_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tariff ALTER COLUMN tariff_id SET DEFAULT nextval('public.tariff_tariff_id_seq'::regclass);


--
-- Name: vehicle vehicle_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicle ALTER COLUMN vehicle_id SET DEFAULT nextval('public.vehicle_vehicle_id_seq'::regclass);


--
-- Name: vehicle_type type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicle_type ALTER COLUMN type_id SET DEFAULT nextval('public.vehicle_type_type_id_seq'::regclass);


--
-- Name: membership_pass membership_pass_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.membership_pass
    ADD CONSTRAINT membership_pass_pkey PRIMARY KEY (pass_no);


--
-- Name: membership_plan membership_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.membership_plan
    ADD CONSTRAINT membership_plan_pkey PRIMARY KEY (plan_id);


--
-- Name: parking_exit parking_exit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_exit
    ADD CONSTRAINT parking_exit_pkey PRIMARY KEY (exit_id);


--
-- Name: parking_exit parking_exit_ticket_no_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_exit
    ADD CONSTRAINT parking_exit_ticket_no_key UNIQUE (ticket_no);


--
-- Name: parking_gate parking_gate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_gate
    ADD CONSTRAINT parking_gate_pkey PRIMARY KEY (gate_id);


--
-- Name: parking_slot parking_slot_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_slot
    ADD CONSTRAINT parking_slot_pkey PRIMARY KEY (slot_id);


--
-- Name: parking_slot parking_slot_slot_no_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_slot
    ADD CONSTRAINT parking_slot_slot_no_key UNIQUE (slot_no);


--
-- Name: parking_ticket parking_ticket_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_ticket
    ADD CONSTRAINT parking_ticket_pkey PRIMARY KEY (ticket_no);


--
-- Name: parking_zone parking_zone_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_zone
    ADD CONSTRAINT parking_zone_pkey PRIMARY KEY (zone_id);


--
-- Name: pass_holder pass_holder_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pass_holder
    ADD CONSTRAINT pass_holder_pkey PRIMARY KEY (member_id);


--
-- Name: payment_details payment_details_exit_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_details
    ADD CONSTRAINT payment_details_exit_id_key UNIQUE (exit_id);


--
-- Name: payment_details payment_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_details
    ADD CONSTRAINT payment_details_pkey PRIMARY KEY (payment_id);


--
-- Name: shift_assignment shift_assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shift_assignment
    ADD CONSTRAINT shift_assignment_pkey PRIMARY KEY (assignment_id);


--
-- Name: slot_type slot_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slot_type
    ADD CONSTRAINT slot_type_pkey PRIMARY KEY (slot_type_id);


--
-- Name: staff_details staff_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff_details
    ADD CONSTRAINT staff_details_pkey PRIMARY KEY (staff_id);


--
-- Name: tariff tariff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tariff
    ADD CONSTRAINT tariff_pkey PRIMARY KEY (tariff_id);


--
-- Name: vehicle vehicle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicle
    ADD CONSTRAINT vehicle_pkey PRIMARY KEY (vehicle_id);


--
-- Name: vehicle vehicle_registration_no_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicle
    ADD CONSTRAINT vehicle_registration_no_key UNIQUE (registration_no);


--
-- Name: vehicle_type vehicle_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicle_type
    ADD CONSTRAINT vehicle_type_pkey PRIMARY KEY (type_id);


--
-- Name: membership_pass membership_pass_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.membership_pass
    ADD CONSTRAINT membership_pass_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.pass_holder(member_id) ON DELETE CASCADE;


--
-- Name: membership_pass membership_pass_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.membership_pass
    ADD CONSTRAINT membership_pass_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.membership_plan(plan_id) ON DELETE RESTRICT;


--
-- Name: membership_pass membership_pass_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.membership_pass
    ADD CONSTRAINT membership_pass_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicle(vehicle_id) ON DELETE CASCADE;


--
-- Name: parking_exit parking_exit_exit_gate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_exit
    ADD CONSTRAINT parking_exit_exit_gate_id_fkey FOREIGN KEY (exit_gate_id) REFERENCES public.parking_gate(gate_id) ON DELETE RESTRICT;


--
-- Name: parking_exit parking_exit_ticket_no_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_exit
    ADD CONSTRAINT parking_exit_ticket_no_fkey FOREIGN KEY (ticket_no) REFERENCES public.parking_ticket(ticket_no) ON DELETE RESTRICT;


--
-- Name: parking_gate parking_gate_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_gate
    ADD CONSTRAINT parking_gate_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.parking_zone(zone_id) ON DELETE CASCADE;


--
-- Name: parking_slot parking_slot_slot_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_slot
    ADD CONSTRAINT parking_slot_slot_type_id_fkey FOREIGN KEY (slot_type_id) REFERENCES public.slot_type(slot_type_id) ON DELETE RESTRICT;


--
-- Name: parking_slot parking_slot_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_slot
    ADD CONSTRAINT parking_slot_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.parking_zone(zone_id) ON DELETE CASCADE;


--
-- Name: parking_ticket parking_ticket_entry_gate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_ticket
    ADD CONSTRAINT parking_ticket_entry_gate_id_fkey FOREIGN KEY (entry_gate_id) REFERENCES public.parking_gate(gate_id) ON DELETE RESTRICT;


--
-- Name: parking_ticket parking_ticket_slot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_ticket
    ADD CONSTRAINT parking_ticket_slot_id_fkey FOREIGN KEY (slot_id) REFERENCES public.parking_slot(slot_id) ON DELETE RESTRICT;


--
-- Name: parking_ticket parking_ticket_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_ticket
    ADD CONSTRAINT parking_ticket_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicle(vehicle_id) ON DELETE RESTRICT;


--
-- Name: payment_details payment_details_exit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_details
    ADD CONSTRAINT payment_details_exit_id_fkey FOREIGN KEY (exit_id) REFERENCES public.parking_exit(exit_id) ON DELETE RESTRICT;


--
-- Name: shift_assignment shift_assignment_gate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shift_assignment
    ADD CONSTRAINT shift_assignment_gate_id_fkey FOREIGN KEY (gate_id) REFERENCES public.parking_gate(gate_id) ON DELETE SET NULL;


--
-- Name: shift_assignment shift_assignment_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shift_assignment
    ADD CONSTRAINT shift_assignment_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staff_details(staff_id) ON DELETE CASCADE;


--
-- Name: shift_assignment shift_assignment_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shift_assignment
    ADD CONSTRAINT shift_assignment_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.parking_zone(zone_id) ON DELETE SET NULL;


--
-- Name: tariff tariff_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tariff
    ADD CONSTRAINT tariff_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.vehicle_type(type_id) ON DELETE CASCADE;


--
-- Name: vehicle vehicle_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicle
    ADD CONSTRAINT vehicle_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.vehicle_type(type_id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict EATNgbUrtEAc09Sr8A7wZfbFONqMY5k51vVUCgjhzA5bUWVuej81Ebfv7biTbFk

