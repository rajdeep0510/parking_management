-- Create staff_account table
CREATE TABLE IF NOT EXISTS public.staff_account (
    account_id serial PRIMARY KEY,
    staff_id integer REFERENCES public.staff_details(staff_id) ON DELETE CASCADE,
    username varchar(50) UNIQUE NOT NULL,
    password varchar(100) NOT NULL,
    display_name varchar(100) NOT NULL,
    role varchar(50) NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Index for fast lookup by username
CREATE INDEX IF NOT EXISTS idx_staff_account_username ON public.staff_account (username);

-- Seed Accounts: Role-based primary logins
INSERT INTO public.staff_account (staff_id, username, password, display_name, role)
VALUES
    (1,    'gate_worker',   'gate123',   'Alex Smith',           'Gate Operator'),
    (1,    'gate',          'gate123',   'Gate Operations Desk', 'Gate Operator'),
    (4,    'supervisor',    'super123',  'Suresh Yadav',         'Supervisor'),
    (2,    'security',      'sec123',    'Rajesh Patel',         'Security Guard'),
    (26,   'cashier',       'cash123',   'Meera Joshi',          'Cashier'),
    (25,   'attendant',     'park123',   'Sanjay Rathod',        'Parking Attendant'),
    (8,    'reception',     'recep123',  'Kiran Desai',          'Receptionist'),
    (7,    'maintenance',   'maint123',  'Manish Gupta',         'Maintenance Staff'),
    (23,   'ev_tech',       'ev123',     'Pooja Nair',           'EV Charging Technician'),
    (15,   'electrician',   'elec123',   'Sanjay Rao',           'Electrician'),
    (NULL, 'admin',         'admin123',  'System Administrator', 'Administrator')
ON CONFLICT (username) DO UPDATE 
SET password = EXCLUDED.password, 
    display_name = EXCLUDED.display_name, 
    role = EXCLUDED.role;

-- Seed Accounts: Individual logins for all existing staff
INSERT INTO public.staff_account (staff_id, username, password, display_name, role)
SELECT 
    s.staff_id,
    LOWER(REPLACE(s.staff_name, ' ', '.')) AS username,
    'pass123' AS password,
    s.staff_name AS display_name,
    s.designation AS role
FROM public.staff_details s
ON CONFLICT (username) DO NOTHING;

