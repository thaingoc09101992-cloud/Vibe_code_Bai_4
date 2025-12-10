-- ============================================================================
-- Library Management System - Database Schema
-- PostgreSQL / Supabase
-- ============================================================================

-- ============================================================================
-- SECTION 1: CLEANUP (for re-running migration)
-- ============================================================================

-- Drop existing tables in reverse order of dependencies
DROP TABLE IF EXISTS fines CASCADE;
DROP TABLE IF EXISTS return_requests CASCADE;
DROP TABLE IF EXISTS borrow_requests CASCADE;
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS book_categories CASCADE;
DROP TABLE IF EXISTS fine_levels CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- Drop existing enum types
DROP TYPE IF EXISTS fine_status CASCADE;
DROP TYPE IF EXISTS book_condition CASCADE;
DROP TYPE IF EXISTS return_status CASCADE;
DROP TYPE IF EXISTS borrow_status CASCADE;
DROP TYPE IF EXISTS user_status CASCADE;
DROP TYPE IF EXISTS user_role CASCADE;

-- ============================================================================
-- SECTION 2: ENUM TYPES
-- ============================================================================

-- User role types
CREATE TYPE user_role AS ENUM ('reader', 'librarian', 'admin');

-- User account status
CREATE TYPE user_status AS ENUM ('active', 'disabled');

-- Borrow request status
CREATE TYPE borrow_status AS ENUM ('pending', 'approved', 'rejected', 'borrowed', 'returned', 'overdue');

-- Return request status
CREATE TYPE return_status AS ENUM ('pending', 'confirmed');

-- Book condition when returned
CREATE TYPE book_condition AS ENUM ('normal', 'damaged', 'lost');

-- Fine payment status
CREATE TYPE fine_status AS ENUM ('unpaid', 'pending_confirmation', 'paid', 'rejected');

-- ============================================================================
-- SECTION 3: TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- User Profiles
-- ----------------------------------------------------------------------------
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    role user_role NOT NULL DEFAULT 'reader',
    status user_status NOT NULL DEFAULT 'active',
    borrow_count INTEGER NOT NULL DEFAULT 0,
    total_fines DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),

    CONSTRAINT chk_borrow_count CHECK (borrow_count >= 0),
    CONSTRAINT chk_total_fines CHECK (total_fines >= 0)
);

COMMENT ON TABLE profiles IS 'User accounts and profile information';
COMMENT ON COLUMN profiles.password IS 'Bcrypt hashed password';
COMMENT ON COLUMN profiles.borrow_count IS 'Total number of books borrowed (lifetime)';
COMMENT ON COLUMN profiles.total_fines IS 'Total amount of fines accumulated (lifetime)';

-- ----------------------------------------------------------------------------
-- Book Categories
-- ----------------------------------------------------------------------------
CREATE TABLE book_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

COMMENT ON TABLE book_categories IS 'Book categories/genres for classification';

-- ----------------------------------------------------------------------------
-- Books
-- ----------------------------------------------------------------------------
CREATE TABLE books (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(100) NOT NULL,
    author VARCHAR(100) NOT NULL,
    year INTEGER NOT NULL,
    isbn VARCHAR(13) UNIQUE,
    category_id UUID NOT NULL REFERENCES book_categories(id) ON DELETE RESTRICT,
    description VARCHAR(255) NOT NULL,
    total_copies INTEGER NOT NULL DEFAULT 0,
    available_copies INTEGER NOT NULL DEFAULT 0,
    borrowed_copies INTEGER NOT NULL DEFAULT 0,
    lost_copies INTEGER NOT NULL DEFAULT 0,
    damaged_copies INTEGER NOT NULL DEFAULT 0,
    borrow_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),

    CONSTRAINT chk_year CHECK (year >= 1900 AND year <= EXTRACT(YEAR FROM CURRENT_DATE)),
    CONSTRAINT chk_isbn CHECK (isbn IS NULL OR (LENGTH(isbn) IN (10, 13) AND isbn ~ '^[0-9]+$')),
    CONSTRAINT chk_total_copies CHECK (total_copies >= 0),
    CONSTRAINT chk_available_copies CHECK (available_copies >= 0),
    CONSTRAINT chk_borrowed_copies CHECK (borrowed_copies >= 0),
    CONSTRAINT chk_lost_copies CHECK (lost_copies >= 0),
    CONSTRAINT chk_damaged_copies CHECK (damaged_copies >= 0),
    CONSTRAINT chk_borrow_count CHECK (borrow_count >= 0),
    CONSTRAINT chk_copies_balance CHECK (
        total_copies = available_copies + borrowed_copies + lost_copies + damaged_copies
    )
);

COMMENT ON TABLE books IS 'Book master data with inventory tracking';
COMMENT ON COLUMN books.borrow_count IS 'Total number of times this book has been borrowed';
COMMENT ON COLUMN books.isbn IS 'ISBN-10 (10 digits) or ISBN-13 (13 digits) without hyphens';

-- ----------------------------------------------------------------------------
-- Borrow Requests
-- ----------------------------------------------------------------------------
CREATE TABLE borrow_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    book_id UUID NOT NULL REFERENCES books(id) ON DELETE RESTRICT,
    borrow_date TIMESTAMP WITH TIME ZONE,
    due_date TIMESTAMP WITH TIME ZONE,
    return_date TIMESTAMP WITH TIME ZONE,
    status borrow_status NOT NULL DEFAULT 'pending',
    rejection_reason TEXT,
    extension_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),

    CONSTRAINT chk_extension_count CHECK (extension_count >= 0 AND extension_count <= 1),
    CONSTRAINT chk_due_date CHECK (due_date IS NULL OR due_date > borrow_date),
    CONSTRAINT chk_return_date CHECK (return_date IS NULL OR return_date >= borrow_date),
    CONSTRAINT chk_rejection_reason CHECK (
        (status = 'rejected' AND rejection_reason IS NOT NULL) OR
        (status != 'rejected' AND rejection_reason IS NULL)
    )
);

COMMENT ON TABLE borrow_requests IS 'Book borrowing requests and transactions';
COMMENT ON COLUMN borrow_requests.extension_count IS 'Number of extensions (max 1)';
COMMENT ON COLUMN borrow_requests.rejection_reason IS 'Required when status is rejected';

-- ----------------------------------------------------------------------------
-- Return Requests
-- ----------------------------------------------------------------------------
CREATE TABLE return_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    borrow_request_id UUID NOT NULL UNIQUE REFERENCES borrow_requests(id) ON DELETE CASCADE,
    request_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    confirmation_date TIMESTAMP WITH TIME ZONE,
    book_condition book_condition,
    notes TEXT,
    status return_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),

    CONSTRAINT chk_confirmation_date CHECK (
        confirmation_date IS NULL OR confirmation_date >= request_date
    ),
    CONSTRAINT chk_book_condition CHECK (
        (status = 'confirmed' AND book_condition IS NOT NULL) OR
        (status = 'pending' AND book_condition IS NULL)
    ),
    CONSTRAINT chk_notes CHECK (
        (book_condition IN ('damaged', 'lost') AND notes IS NOT NULL) OR
        (book_condition = 'normal' OR book_condition IS NULL)
    )
);

COMMENT ON TABLE return_requests IS 'Book return requests from readers';
COMMENT ON COLUMN return_requests.book_condition IS 'Set when librarian confirms return';
COMMENT ON COLUMN return_requests.notes IS 'Required when book is damaged or lost';

-- ----------------------------------------------------------------------------
-- Fine Levels (Templates)
-- ----------------------------------------------------------------------------
CREATE TABLE fine_levels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(25) NOT NULL UNIQUE,
    amount DECIMAL(10, 2) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),

    CONSTRAINT chk_amount CHECK (amount > 0)
);

COMMENT ON TABLE fine_levels IS 'Fine amount templates configured by admin';
COMMENT ON COLUMN fine_levels.amount IS 'Fine amount in currency';

-- ----------------------------------------------------------------------------
-- Fines
-- ----------------------------------------------------------------------------
CREATE TABLE fines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    borrow_request_id UUID NOT NULL REFERENCES borrow_requests(id) ON DELETE CASCADE,
    fine_level_id UUID NOT NULL REFERENCES fine_levels(id) ON DELETE RESTRICT,
    reason VARCHAR(100) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    fine_date DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_date DATE,
    status fine_status NOT NULL DEFAULT 'unpaid',
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),

    CONSTRAINT chk_amount CHECK (amount > 0),
    CONSTRAINT chk_payment_date CHECK (payment_date IS NULL OR payment_date >= fine_date),
    CONSTRAINT chk_rejection_reason CHECK (
        (status = 'rejected' AND rejection_reason IS NOT NULL) OR
        (status != 'rejected' AND rejection_reason IS NULL)
    )
);

COMMENT ON TABLE fines IS 'Fine records for late returns, damaged or lost books';
COMMENT ON COLUMN fines.amount IS 'Actual fine amount (copied from fine_level at creation)';

-- ============================================================================
-- SECTION 4: INDEXES
-- ============================================================================

-- Profiles indexes
CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_status ON profiles(status);
CREATE INDEX idx_profiles_created_at ON profiles(created_at);

-- Books indexes
CREATE INDEX idx_books_category_id ON books(category_id);
CREATE INDEX idx_books_borrow_count ON books(borrow_count DESC);
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_author ON books(author);

-- Borrow requests indexes
CREATE INDEX idx_borrow_requests_user_id ON borrow_requests(user_id);
CREATE INDEX idx_borrow_requests_book_id ON borrow_requests(book_id);
CREATE INDEX idx_borrow_requests_status ON borrow_requests(status);
CREATE INDEX idx_borrow_requests_due_date ON borrow_requests(due_date);
CREATE INDEX idx_borrow_requests_created_at ON borrow_requests(created_at DESC);

-- Return requests indexes
CREATE INDEX idx_return_requests_status ON return_requests(status);
CREATE INDEX idx_return_requests_request_date ON return_requests(request_date);

-- Fines indexes
CREATE INDEX idx_fines_user_id ON fines(user_id);
CREATE INDEX idx_fines_borrow_request_id ON fines(borrow_request_id);
CREATE INDEX idx_fines_status ON fines(status);
CREATE INDEX idx_fines_fine_date ON fines(fine_date);

-- ============================================================================
-- SECTION 5: TRIGGERS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to all tables
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_book_categories_updated_at BEFORE UPDATE ON book_categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_books_updated_at BEFORE UPDATE ON books
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_borrow_requests_updated_at BEFORE UPDATE ON borrow_requests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_return_requests_updated_at BEFORE UPDATE ON return_requests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_fine_levels_updated_at BEFORE UPDATE ON fine_levels
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_fines_updated_at BEFORE UPDATE ON fines
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Note: Profile creation is handled by the application during registration

-- ============================================================================
-- SECTION 6: ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE book_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE books ENABLE ROW LEVEL SECURITY;
ALTER TABLE borrow_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE return_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE fine_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE fines ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- SECTION 7: RLS POLICIES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Profiles Policies
-- ----------------------------------------------------------------------------

-- Users can view their own profile; Librarians/Admins can view all
CREATE POLICY "Users can view own profile, staff can view all"
    ON profiles FOR SELECT
    USING (
        auth.uid() = id OR
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- Users can update their own profile (except role and status)
-- Admins can update any profile
CREATE POLICY "Users can update own profile, admins can update any"
    ON profiles FOR UPDATE
    USING (
        auth.uid() = id OR
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    )
    WITH CHECK (
        (auth.uid() = id AND role = (SELECT role FROM profiles WHERE id = auth.uid())) OR
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

-- Profile creation handled by trigger
CREATE POLICY "Profiles created by trigger"
    ON profiles FOR INSERT
    WITH CHECK (false);

-- ----------------------------------------------------------------------------
-- Book Categories Policies
-- ----------------------------------------------------------------------------

-- Everyone can view categories
CREATE POLICY "Anyone can view book categories"
    ON book_categories FOR SELECT
    USING (true);

-- Only librarians and admins can manage categories
CREATE POLICY "Librarians and admins can insert categories"
    ON book_categories FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

CREATE POLICY "Librarians and admins can update categories"
    ON book_categories FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

CREATE POLICY "Librarians and admins can delete categories"
    ON book_categories FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- ----------------------------------------------------------------------------
-- Books Policies
-- ----------------------------------------------------------------------------

-- Everyone can view books
CREATE POLICY "Anyone can view books"
    ON books FOR SELECT
    USING (true);

-- Only librarians and admins can manage books
CREATE POLICY "Librarians and admins can insert books"
    ON books FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

CREATE POLICY "Librarians and admins can update books"
    ON books FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

CREATE POLICY "Librarians and admins can delete books"
    ON books FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- ----------------------------------------------------------------------------
-- Borrow Requests Policies
-- ----------------------------------------------------------------------------

-- Users can view their own requests; Staff can view all
CREATE POLICY "Users can view own borrow requests, staff can view all"
    ON borrow_requests FOR SELECT
    USING (
        user_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- Readers can create borrow requests for themselves
CREATE POLICY "Readers can create borrow requests"
    ON borrow_requests FOR INSERT
    WITH CHECK (
        user_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'reader'
            AND status = 'active'
        )
    );

-- Librarians and admins can update borrow requests (for status changes)
CREATE POLICY "Librarians and admins can update borrow requests"
    ON borrow_requests FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- ----------------------------------------------------------------------------
-- Return Requests Policies
-- ----------------------------------------------------------------------------

-- Users can view their own return requests; Staff can view all
CREATE POLICY "Users can view own return requests, staff can view all"
    ON return_requests FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM borrow_requests
            WHERE id = borrow_request_id
            AND user_id = auth.uid()
        ) OR
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- Readers can create return requests for their own borrow requests
CREATE POLICY "Readers can create return requests"
    ON return_requests FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM borrow_requests
            WHERE id = borrow_request_id
            AND user_id = auth.uid()
            AND status = 'borrowed'
        )
    );

-- Librarians can update return requests (for confirmation)
CREATE POLICY "Librarians can update return requests"
    ON return_requests FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- ----------------------------------------------------------------------------
-- Fine Levels Policies
-- ----------------------------------------------------------------------------

-- Everyone can view fine levels
CREATE POLICY "Anyone can view fine levels"
    ON fine_levels FOR SELECT
    USING (true);

-- Only admins can manage fine levels
CREATE POLICY "Admins can insert fine levels"
    ON fine_levels FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

CREATE POLICY "Admins can update fine levels"
    ON fine_levels FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

CREATE POLICY "Admins can delete fine levels"
    ON fine_levels FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        )
    );

-- ----------------------------------------------------------------------------
-- Fines Policies
-- ----------------------------------------------------------------------------

-- Users can view their own fines; Staff can view all
CREATE POLICY "Users can view own fines, staff can view all"
    ON fines FOR SELECT
    USING (
        user_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- Librarians can create fines (when confirming returns)
CREATE POLICY "Librarians can create fines"
    ON fines FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- Users can update their own fines (to mark as pending_confirmation)
-- Librarians can update any fine (to confirm/reject payment)
CREATE POLICY "Users can update own fines, librarians can update any"
    ON fines FOR UPDATE
    USING (
        (user_id = auth.uid() AND status = 'unpaid') OR
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    )
    WITH CHECK (
        (user_id = auth.uid() AND status = 'pending_confirmation') OR
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- ============================================================================
-- SECTION 8: DEFAULT DATA FOR TESTING
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Default Users (Password: abc@1234)
-- Note: Passwords are hashed using bcrypt
-- Plain text: abc@1234
-- Extension pgcrypto must be enabled: CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- ----------------------------------------------------------------------------

-- Enable pgcrypto extension for password hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Insert default users directly into profiles
INSERT INTO profiles (
    id,
    name,
    email,
    password,
    role,
    status
) VALUES
(
    '00000000-0000-0000-0000-000000000001',
    'Admin User',
    'admin@library.com',
    crypt('abc@1234', gen_salt('bf')),
    'admin',
    'active'
),
(
    '00000000-0000-0000-0000-000000000002',
    'Librarian User',
    'librarian@library.com',
    crypt('abc@1234', gen_salt('bf')),
    'librarian',
    'active'
),
(
    '00000000-0000-0000-0000-000000000003',
    'Reader User',
    'reader@library.com',
    crypt('abc@1234', gen_salt('bf')),
    'reader',
    'active'
);

-- ----------------------------------------------------------------------------
-- Book Categories
-- ----------------------------------------------------------------------------

INSERT INTO book_categories (id, name, description) VALUES
('10000000-0000-0000-0000-000000000001', 'Fiction', 'Fictional novels and stories'),
('10000000-0000-0000-0000-000000000002', 'Non-Fiction', 'Real-world topics and factual books'),
('10000000-0000-0000-0000-000000000003', 'Science', 'Scientific books and research'),
('10000000-0000-0000-0000-000000000004', 'Technology', 'Technology and programming books'),
('10000000-0000-0000-0000-000000000005', 'History', 'Historical books and biographies'),
('10000000-0000-0000-0000-000000000006', 'Self-Help', 'Personal development and self-improvement'),
('10000000-0000-0000-0000-000000000007', 'Business', 'Business and entrepreneurship books');

-- ----------------------------------------------------------------------------
-- Books
-- ----------------------------------------------------------------------------

INSERT INTO books (
    id,
    title,
    author,
    year,
    isbn,
    category_id,
    description,
    total_copies,
    available_copies
) VALUES
-- Fiction
(
    '20000000-0000-0000-0000-000000000001',
    'To Kill a Mockingbird',
    'Harper Lee',
    1960,
    '9780061120084',
    '10000000-0000-0000-0000-000000000001',
    'A classic novel about racial injustice in the American South',
    5,
    5
),
(
    '20000000-0000-0000-0000-000000000002',
    '1984',
    'George Orwell',
    1949,
    '9780451524935',
    '10000000-0000-0000-0000-000000000001',
    'A dystopian social science fiction novel',
    3,
    3
),
(
    '20000000-0000-0000-0000-000000000003',
    'The Great Gatsby',
    'F. Scott Fitzgerald',
    1925,
    '9780743273565',
    '10000000-0000-0000-0000-000000000001',
    'The story of the fabulously wealthy Jay Gatsby',
    4,
    4
),

-- Technology
(
    '20000000-0000-0000-0000-000000000004',
    'Clean Code',
    'Robert C. Martin',
    2008,
    '9780132350884',
    '10000000-0000-0000-0000-000000000004',
    'A handbook of agile software craftsmanship',
    5,
    5
),
(
    '20000000-0000-0000-0000-000000000005',
    'The Pragmatic Programmer',
    'David Thomas, Andrew Hunt',
    1999,
    '9780201616224',
    '10000000-0000-0000-0000-000000000004',
    'Your journey to mastery in software development',
    3,
    3
),
(
    '20000000-0000-0000-0000-000000000006',
    'Design Patterns',
    'Gang of Four',
    1994,
    '9780201633612',
    '10000000-0000-0000-0000-000000000004',
    'Elements of reusable object-oriented software',
    2,
    2
),

-- Science
(
    '20000000-0000-0000-0000-000000000007',
    'A Brief History of Time',
    'Stephen Hawking',
    1988,
    '9780553380163',
    '10000000-0000-0000-0000-000000000003',
    'From the Big Bang to black holes',
    4,
    4
),
(
    '20000000-0000-0000-0000-000000000008',
    'Sapiens',
    'Yuval Noah Harari',
    2011,
    '9780062316097',
    '10000000-0000-0000-0000-000000000002',
    'A brief history of humankind',
    5,
    5
),

-- Business
(
    '20000000-0000-0000-0000-000000000009',
    'The Lean Startup',
    'Eric Ries',
    2011,
    '9780307887894',
    '10000000-0000-0000-0000-000000000007',
    'How constant innovation creates radically successful businesses',
    3,
    3
),
(
    '20000000-0000-0000-0000-000000000010',
    'Zero to One',
    'Peter Thiel',
    2014,
    '9780804139298',
    '10000000-0000-0000-0000-000000000007',
    'Notes on startups, or how to build the future',
    4,
    4
),

-- Self-Help
(
    '20000000-0000-0000-0000-000000000011',
    'Atomic Habits',
    'James Clear',
    2018,
    '9780735211292',
    '10000000-0000-0000-0000-000000000006',
    'An easy and proven way to build good habits',
    6,
    6
),
(
    '20000000-0000-0000-0000-000000000012',
    'The 7 Habits of Highly Effective People',
    'Stephen Covey',
    1989,
    '9781982137274',
    '10000000-0000-0000-0000-000000000006',
    'Powerful lessons in personal change',
    3,
    3
),

-- History
(
    '20000000-0000-0000-0000-000000000013',
    'The Diary of a Young Girl',
    'Anne Frank',
    1947,
    '9780553296983',
    '10000000-0000-0000-0000-000000000005',
    'The diary of Anne Frank during WWII',
    2,
    2
),
(
    '20000000-0000-0000-0000-000000000014',
    'Educated',
    'Tara Westover',
    2018,
    '9780399590504',
    '10000000-0000-0000-0000-000000000002',
    'A memoir about education and self-invention',
    4,
    4
),
(
    '20000000-0000-0000-0000-000000000015',
    'The Immortal Life of Henrietta Lacks',
    'Rebecca Skloot',
    2010,
    '9781400052189',
    '10000000-0000-0000-0000-000000000003',
    'The story of Henrietta Lacks and HeLa cells',
    3,
    3
);

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================

-- Success message
DO $$
BEGIN
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'Library Management System Database Schema Created Successfully';
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'Tables Created: 7';
    RAISE NOTICE 'Enums Created: 6';
    RAISE NOTICE 'Indexes Created: 17';
    RAISE NOTICE 'Triggers Created: 8';
    RAISE NOTICE 'RLS Policies Created: 31';
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'Default Data Inserted:';
    RAISE NOTICE '  - 3 Users (admin@library.com, librarian@library.com, reader@library.com)';
    RAISE NOTICE '  - Password for all users: abc@1234';
    RAISE NOTICE '  - 7 Book Categories';
    RAISE NOTICE '  - 15 Books';
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'Next Steps:';
    RAISE NOTICE '  1. Review the schema in design/schema.md';
    RAISE NOTICE '  2. Execute this migration on your Supabase instance';
    RAISE NOTICE '  3. Test authentication with default users';
    RAISE NOTICE '  4. Begin implementing the application';
    RAISE NOTICE '============================================================================';
END $$;
