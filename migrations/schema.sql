    -- =====================================================
    -- Library Management System - Database Schema
    -- Supabase PostgreSQL Migration Script
    -- =====================================================
    -- This script creates all tables, indexes, RLS policies,
    -- and triggers for the library management system.
    -- =====================================================

    -- Enable UUID extension
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

    -- =====================================================
    -- ENUMS
    -- =====================================================

    -- User roles
    CREATE TYPE user_role AS ENUM ('reader', 'librarian', 'admin');

    -- Borrow statuses
    CREATE TYPE borrow_status AS ENUM ('pending', 'approved', 'borrowed', 'overdue', 'returned', 'rejected');

    -- Return request statuses
    CREATE TYPE return_request_status AS ENUM ('pending', 'confirmed');

    -- Penalty types
    CREATE TYPE penalty_type AS ENUM ('late_return', 'damage', 'lost');

    -- Penalty payment statuses
    CREATE TYPE payment_status AS ENUM ('unpaid', 'pending_confirmation', 'paid', 'rejected');

    -- =====================================================
    -- TABLES (in dependency order)
    -- =====================================================

    -- User Profiles
    -- Links to Supabase auth.users via user_id
    CREATE TABLE user_profiles (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
        full_name VARCHAR(50) NOT NULL,
        phone VARCHAR(20),
        address VARCHAR(255),
        role user_role NOT NULL DEFAULT 'reader',
        is_active BOOLEAN NOT NULL DEFAULT true,
        created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT full_name_length CHECK (char_length(full_name) > 0 AND char_length(full_name) <= 50),
        CONSTRAINT address_length CHECK (address IS NULL OR char_length(address) <= 255)
    );

    COMMENT ON TABLE user_profiles IS 'Extended user profiles linked to Supabase Auth users';
    COMMENT ON COLUMN user_profiles.user_id IS 'Foreign key to auth.users.id';
    COMMENT ON COLUMN user_profiles.role IS 'User role: reader, librarian, or admin';

    -- Categories
    CREATE TABLE categories (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name VARCHAR(50) NOT NULL UNIQUE,
        created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT name_length CHECK (char_length(name) > 0 AND char_length(name) <= 50)
    );

    COMMENT ON TABLE categories IS 'Book categories managed by librarians';

    -- Books
    CREATE TABLE books (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        category_id UUID NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
        title VARCHAR(100) NOT NULL,
        author VARCHAR(100) NOT NULL,
        isbn VARCHAR(17), -- ISBN-10 (10 chars) or ISBN-13 (13 chars) with hyphens
        publication_year INTEGER NOT NULL,
        description TEXT NOT NULL,
        total_quantity INTEGER NOT NULL DEFAULT 0,
        available_quantity INTEGER NOT NULL DEFAULT 0,
        borrowed_quantity INTEGER NOT NULL DEFAULT 0,
        lost_quantity INTEGER NOT NULL DEFAULT 0,
        damaged_quantity INTEGER NOT NULL DEFAULT 0,
        created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT title_length CHECK (char_length(title) > 0 AND char_length(title) <= 100),
        CONSTRAINT author_length CHECK (char_length(author) > 0 AND char_length(author) <= 100),
        CONSTRAINT description_length CHECK (char_length(description) > 0 AND char_length(description) <= 500),
        CONSTRAINT publication_year_range CHECK (publication_year >= 1900 AND publication_year <= EXTRACT(YEAR FROM now())),
        CONSTRAINT quantity_non_negative CHECK (
            total_quantity >= 0 AND
            available_quantity >= 0 AND
            borrowed_quantity >= 0 AND
            lost_quantity >= 0 AND
            damaged_quantity >= 0
        ),
        CONSTRAINT quantity_consistency CHECK (
            total_quantity = available_quantity + borrowed_quantity + lost_quantity + damaged_quantity
        )
    );

    COMMENT ON TABLE books IS 'Library books with inventory tracking';
    COMMENT ON COLUMN books.total_quantity IS 'Total copies owned by library';
    COMMENT ON COLUMN books.available_quantity IS 'Copies available for borrowing';
    COMMENT ON COLUMN books.borrowed_quantity IS 'Copies currently borrowed';
    COMMENT ON COLUMN books.lost_quantity IS 'Copies lost';
    COMMENT ON COLUMN books.damaged_quantity IS 'Copies damaged';

    -- Penalty Levels
    CREATE TABLE penalty_levels (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name VARCHAR(25) NOT NULL,
        amount NUMERIC(10, 2) NOT NULL,
        effective_date DATE NOT NULL DEFAULT CURRENT_DATE,
        created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT name_length CHECK (char_length(name) > 0 AND char_length(name) <= 25),
        CONSTRAINT amount_positive CHECK (amount > 0)
    );

    COMMENT ON TABLE penalty_levels IS 'Configurable penalty amounts managed by admins';

    -- Borrows
    CREATE TABLE borrows (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
        book_id UUID NOT NULL REFERENCES books(id) ON DELETE CASCADE,
        status borrow_status NOT NULL DEFAULT 'pending',
        duration_days INTEGER NOT NULL DEFAULT 14,
        borrow_date DATE,
        due_date DATE,
        actual_return_date DATE,
        rejection_reason TEXT,
        is_extended BOOLEAN NOT NULL DEFAULT false,
        created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT duration_days_range CHECK (duration_days >= 1 AND duration_days <= 30),
        CONSTRAINT rejection_reason_when_rejected CHECK (
            (status = 'rejected' AND rejection_reason IS NOT NULL) OR
            (status != 'rejected')
        ),
        CONSTRAINT dates_consistency CHECK (
            (borrow_date IS NULL AND due_date IS NULL) OR
            (borrow_date IS NOT NULL AND due_date IS NOT NULL AND due_date >= borrow_date)
        )
    );

    COMMENT ON TABLE borrows IS 'Borrowing records tracking book loans';
    COMMENT ON COLUMN borrows.status IS 'Borrow status: pending, approved, borrowed, overdue, returned, rejected';
    COMMENT ON COLUMN borrows.duration_days IS 'Loan duration in days (default 14, max 30)';
    COMMENT ON COLUMN borrows.is_extended IS 'Flag indicating if borrow was extended (max 1 extension per borrow)';

    -- Return Requests
    CREATE TABLE return_requests (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        borrow_id UUID NOT NULL REFERENCES borrows(id) ON DELETE CASCADE,
        status return_request_status NOT NULL DEFAULT 'pending',
        created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
    );

    COMMENT ON TABLE return_requests IS 'Return requests created by readers, confirmed by librarians';
    COMMENT ON COLUMN return_requests.borrow_id IS 'Foreign key to borrows. Only one pending request per borrow (enforced by unique partial index)';

    -- Penalties
    CREATE TABLE penalties (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
        borrow_id UUID REFERENCES borrows(id) ON DELETE SET NULL,
        penalty_level_id UUID NOT NULL REFERENCES penalty_levels(id) ON DELETE RESTRICT,
        penalty_type penalty_type NOT NULL,
        payment_status payment_status NOT NULL DEFAULT 'unpaid',
        amount NUMERIC(10, 2) NOT NULL,
        notes TEXT,
        rejection_reason TEXT,
        created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT amount_positive CHECK (amount > 0),
        CONSTRAINT notes_required_for_damage_lost CHECK (
            (penalty_type IN ('damage', 'lost') AND notes IS NOT NULL AND char_length(notes) > 0) OR
            (penalty_type = 'late_return')
        ),
        CONSTRAINT notes_length CHECK (notes IS NULL OR char_length(notes) <= 500),
        CONSTRAINT rejection_reason_when_rejected CHECK (
            (payment_status = 'rejected' AND rejection_reason IS NOT NULL) OR
            (payment_status != 'rejected')
        )
    );

    COMMENT ON TABLE penalties IS 'Individual penalty records for late returns, damage, or lost books';
    COMMENT ON COLUMN penalties.penalty_type IS 'Type of penalty: late_return, damage, or lost';
    COMMENT ON COLUMN penalties.payment_status IS 'Payment status: unpaid, pending_confirmation, paid, rejected';
    COMMENT ON COLUMN penalties.notes IS 'Librarian notes (required for damage/lost, max 500 chars)';

    -- =====================================================
    -- INDEXES
    -- =====================================================

    -- User Profiles Indexes
    CREATE UNIQUE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
    CREATE INDEX idx_user_profiles_role ON user_profiles(role);
    CREATE INDEX idx_user_profiles_is_active ON user_profiles(is_active);

    -- Categories Indexes
    CREATE UNIQUE INDEX idx_categories_name ON categories(name);

    -- Books Indexes
    CREATE INDEX idx_books_category_id ON books(category_id);
    CREATE INDEX idx_books_title ON books(title);
    CREATE INDEX idx_books_author ON books(author);
    CREATE INDEX idx_books_isbn ON books(isbn) WHERE isbn IS NOT NULL;
    CREATE INDEX idx_books_available_quantity ON books(available_quantity) WHERE available_quantity > 0;

    -- Penalty Levels Indexes
    CREATE INDEX idx_penalty_levels_effective_date ON penalty_levels(effective_date);

    -- Borrows Indexes
    CREATE INDEX idx_borrows_user_id ON borrows(user_id);
    CREATE INDEX idx_borrows_book_id ON borrows(book_id);
    CREATE INDEX idx_borrows_status ON borrows(status);
    CREATE INDEX idx_borrows_due_date ON borrows(due_date) WHERE due_date IS NOT NULL;
    CREATE INDEX idx_borrows_user_status ON borrows(user_id, status);
    CREATE INDEX idx_borrows_book_status ON borrows(book_id, status);
    -- Composite index for overdue queries (application will filter with WHERE due_date < CURRENT_DATE)
    CREATE INDEX idx_borrows_borrowed_due_date ON borrows(status, due_date) WHERE status = 'borrowed';

    -- Return Requests Indexes
    -- Unique index ensures only one pending return request per borrow
    CREATE UNIQUE INDEX idx_return_requests_borrow_id_pending ON return_requests(borrow_id) WHERE status = 'pending';
    CREATE INDEX idx_return_requests_borrow_id ON return_requests(borrow_id);
    CREATE INDEX idx_return_requests_status ON return_requests(status);

    -- Penalties Indexes
    CREATE INDEX idx_penalties_user_id ON penalties(user_id);
    CREATE INDEX idx_penalties_borrow_id ON penalties(borrow_id) WHERE borrow_id IS NOT NULL;
    CREATE INDEX idx_penalties_penalty_level_id ON penalties(penalty_level_id);
    CREATE INDEX idx_penalties_payment_status ON penalties(payment_status);
    CREATE INDEX idx_penalties_user_payment_status ON penalties(user_id, payment_status);
    CREATE INDEX idx_penalties_unpaid ON penalties(user_id, payment_status) WHERE payment_status IN ('unpaid', 'pending_confirmation');

    -- =====================================================
    -- FUNCTIONS
    -- =====================================================

    -- Function to automatically update updated_at timestamp
    CREATE OR REPLACE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS $$
    BEGIN
        NEW.updated_at = now();
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_updated_at_column() IS 'Trigger function to automatically update updated_at timestamp';

-- Function to prevent users from changing their own role
CREATE OR REPLACE FUNCTION prevent_role_change()
RETURNS TRIGGER AS $$
BEGIN
    -- If user is trying to change their own role (not admin), prevent it
    IF OLD.user_id = auth.uid() AND OLD.role != NEW.role THEN
        -- Check if current user is admin
        IF NOT EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE user_id = auth.uid() AND role = 'admin'
        ) THEN
            RAISE EXCEPTION 'Users cannot change their own role';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION prevent_role_change() IS 'Prevents users from changing their own role (only admins can change roles)';

-- Function to validate penalty payment status changes
CREATE OR REPLACE FUNCTION validate_penalty_payment_status()
RETURNS TRIGGER AS $$
BEGIN
    -- If user is updating their own penalty
    IF EXISTS (
        SELECT 1 FROM user_profiles 
        WHERE id = NEW.user_id AND user_id = auth.uid()
    ) THEN
        -- Users can only change from 'unpaid' to 'pending_confirmation'
        IF OLD.payment_status != NEW.payment_status THEN
            IF NOT (OLD.payment_status = 'unpaid' AND NEW.payment_status = 'pending_confirmation') THEN
                RAISE EXCEPTION 'Users can only change payment status from unpaid to pending_confirmation';
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION validate_penalty_payment_status() IS 'Validates that users can only change penalty payment status from unpaid to pending_confirmation';

-- =====================================================
-- TRIGGERS
-- =====================================================

    -- Auto-update updated_at for all tables
    CREATE TRIGGER update_user_profiles_updated_at
        BEFORE UPDATE ON user_profiles
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();

    CREATE TRIGGER update_categories_updated_at
        BEFORE UPDATE ON categories
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();

    CREATE TRIGGER update_books_updated_at
        BEFORE UPDATE ON books
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();

    CREATE TRIGGER update_penalty_levels_updated_at
        BEFORE UPDATE ON penalty_levels
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();

    CREATE TRIGGER update_borrows_updated_at
        BEFORE UPDATE ON borrows
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();

    CREATE TRIGGER update_return_requests_updated_at
        BEFORE UPDATE ON return_requests
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_penalties_updated_at
    BEFORE UPDATE ON penalties
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Business rule triggers
CREATE TRIGGER prevent_user_role_change
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION prevent_role_change();

CREATE TRIGGER validate_penalty_status_change
    BEFORE UPDATE ON penalties
    FOR EACH ROW
    EXECUTE FUNCTION validate_penalty_payment_status();

    -- =====================================================
    -- ROW LEVEL SECURITY (RLS)
    -- =====================================================

    -- Enable RLS on all tables
    ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
    ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
    ALTER TABLE books ENABLE ROW LEVEL SECURITY;
    ALTER TABLE penalty_levels ENABLE ROW LEVEL SECURITY;
    ALTER TABLE borrows ENABLE ROW LEVEL SECURITY;
    ALTER TABLE return_requests ENABLE ROW LEVEL SECURITY;
    ALTER TABLE penalties ENABLE ROW LEVEL SECURITY;

    -- =====================================================
    -- RLS POLICIES - User Profiles
    -- =====================================================

    -- Users can view their own profile
    CREATE POLICY "Users can view own profile"
        ON user_profiles FOR SELECT
        USING (auth.uid() = user_id);

-- Users can update their own profile (role change prevented by trigger)
CREATE POLICY "Users can update own profile"
    ON user_profiles FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

    -- Librarians and Admins can view all profiles
    CREATE POLICY "Librarians and Admins can view all profiles"
        ON user_profiles FOR SELECT
        USING (
            EXISTS (
                SELECT 1 FROM user_profiles
                WHERE user_id = auth.uid() AND role IN ('librarian', 'admin')
            )
        );

    -- Admins can update any profile (including role)
    CREATE POLICY "Admins can update any profile"
        ON user_profiles FOR UPDATE
        USING (
            EXISTS (
                SELECT 1 FROM user_profiles
                WHERE user_id = auth.uid() AND role = 'admin'
            )
        );

    -- =====================================================
    -- RLS POLICIES - Categories
    -- =====================================================

    -- Everyone can view categories (public read)
    CREATE POLICY "Anyone can view categories"
        ON categories FOR SELECT
        USING (true);

    -- Only Librarians and Admins can insert categories
    CREATE POLICY "Librarians and Admins can insert categories"
        ON categories FOR INSERT
        WITH CHECK (
            EXISTS (
                SELECT 1 FROM user_profiles
                WHERE user_id = auth.uid() AND role IN ('librarian', 'admin')
            )
        );

    -- Only Librarians and Admins can update categories
    CREATE POLICY "Librarians and Admins can update categories"
        ON categories FOR UPDATE
        USING (
            EXISTS (
                SELECT 1 FROM user_profiles
                WHERE user_id = auth.uid() AND role IN ('librarian', 'admin')
            )
        );

    -- Only Librarians and Admins can delete categories
    CREATE POLICY "Librarians and Admins can delete categories"
        ON categories FOR DELETE
        USING (
            EXISTS (
                SELECT 1 FROM user_profiles
                WHERE user_id = auth.uid() AND role IN ('librarian', 'admin')
            )
        );

    -- =====================================================
    -- RLS POLICIES - Books
    -- =====================================================

    -- Everyone can view books (public read)
    CREATE POLICY "Anyone can view books"
        ON books FOR SELECT
        USING (true);

    -- Only Librarians and Admins can insert books
    CREATE POLICY "Librarians and Admins can insert books"
        ON books FOR INSERT
        WITH CHECK (
            EXISTS (
                SELECT 1 FROM user_profiles
                WHERE user_id = auth.uid() AND role IN ('librarian', 'admin')
            )
        );

    -- Only Librarians and Admins can update books
    CREATE POLICY "Librarians and Admins can update books"
        ON books FOR UPDATE
        USING (
            EXISTS (
                SELECT 1 FROM user_profiles
                WHERE user_id = auth.uid() AND role IN ('librarian', 'admin')
            )
        );

    -- Only Librarians and Admins can delete books
    CREATE POLICY "Librarians and Admins can delete books"
        ON books FOR DELETE
        USING (
            EXISTS (
                SELECT 1 FROM user_profiles
                WHERE user_id = auth.uid() AND role IN ('librarian', 'admin')
            )
        );

    -- =====================================================
    -- RLS POLICIES - Penalty Levels
    -- =====================================================

    -- Only Admins can view penalty levels
    CREATE POLICY "Admins can view penalty levels"
        ON penalty_levels FOR SELECT
        USING (
            EXISTS (
                SELECT 1 FROM user_profiles
                WHERE user_id = auth.uid() AND role = 'admin'
            )
        );

    -- Only Admins can insert penalty levels
    CREATE POLICY "Admins can insert penalty levels"
        ON penalty_levels FOR INSERT
        WITH CHECK (
            EXISTS (
                SELECT 1 FROM user_profiles
                WHERE user_id = auth.uid() AND role = 'admin'
            )
        );

    -- Only Admins can update penalty levels
    CREATE POLICY "Admins can update penalty levels"
        ON penalty_levels FOR UPDATE
        USING (
            EXISTS (
                SELECT 1 FROM user_profiles
                WHERE user_id = auth.uid() AND role = 'admin'
            )
        );

    -- Only Admins can delete penalty levels
    CREATE POLICY "Admins can delete penalty levels"
        ON penalty_levels FOR DELETE
        USING (
            EXISTS (
                SELECT 1 FROM user_profiles
                WHERE user_id = auth.uid() AND role = 'admin'
            )
        );

    -- =====================================================
    -- RLS POLICIES - Borrows
    -- =====================================================

    -- Users can view their own borrows
    CREATE POLICY "Users can view own borrows"
        ON borrows FOR SELECT
        USING (
            user_id IN (
                SELECT id FROM user_profiles WHERE user_id = auth.uid()
            )
        );

    -- Readers can insert their own borrow requests
    CREATE POLICY "Readers can create borrow requests"
        ON borrows FOR INSERT
        WITH CHECK (
            user_id IN (
                SELECT id FROM user_profiles WHERE user_id = auth.uid() AND role = 'reader'
            ) AND status = 'pending'
        );

    -- Librarians and Admins can view all borrows
    CREATE POLICY "Librarians and Admins can view all borrows"
        ON borrows FOR SELECT
        USING (
            EXISTS (
                SELECT 1 FROM user_profiles
                WHERE user_id = auth.uid() AND role IN ('librarian', 'admin')
            )
        );

    -- Librarians and Admins can update borrows (approve/reject/confirm)
    CREATE POLICY "Librarians and Admins can update borrows"
        ON borrows FOR UPDATE
        USING (
            EXISTS (
                SELECT 1 FROM user_profiles
                WHERE user_id = auth.uid() AND role IN ('librarian', 'admin')
            )
        );

    -- =====================================================
    -- RLS POLICIES - Return Requests
    -- =====================================================

    -- Users can view return requests for their own borrows
    CREATE POLICY "Users can view own return requests"
        ON return_requests FOR SELECT
        USING (
            borrow_id IN (
                SELECT id FROM borrows
                WHERE user_id IN (
                    SELECT id FROM user_profiles WHERE user_id = auth.uid()
                )
            )
        );

    -- Readers can create return requests for their own borrows
    CREATE POLICY "Readers can create return requests"
        ON return_requests FOR INSERT
        WITH CHECK (
            borrow_id IN (
                SELECT id FROM borrows
                WHERE user_id IN (
                    SELECT id FROM user_profiles WHERE user_id = auth.uid() AND role = 'reader'
                ) AND status = 'borrowed'
            ) AND status = 'pending'
        );

    -- Librarians and Admins can view all return requests
    CREATE POLICY "Librarians and Admins can view all return requests"
        ON return_requests FOR SELECT
        USING (
            EXISTS (
                SELECT 1 FROM user_profiles
                WHERE user_id = auth.uid() AND role IN ('librarian', 'admin')
            )
        );

    -- Librarians and Admins can update return requests (confirm)
    CREATE POLICY "Librarians and Admins can update return requests"
        ON return_requests FOR UPDATE
        USING (
            EXISTS (
                SELECT 1 FROM user_profiles
                WHERE user_id = auth.uid() AND role IN ('librarian', 'admin')
            )
        );

    -- =====================================================
    -- RLS POLICIES - Penalties
    -- =====================================================

    -- Users can view their own penalties
    CREATE POLICY "Users can view own penalties"
        ON penalties FOR SELECT
        USING (
            user_id IN (
                SELECT id FROM user_profiles WHERE user_id = auth.uid()
            )
        );

-- Users can update their own penalties (payment status change validated by trigger)
CREATE POLICY "Users can update own penalty payment status"
    ON penalties FOR UPDATE
    USING (
        user_id IN (
            SELECT id FROM user_profiles WHERE user_id = auth.uid()
        )
    )
    WITH CHECK (
        user_id IN (
            SELECT id FROM user_profiles WHERE user_id = auth.uid()
        )
    );

    -- Librarians and Admins can view all penalties
    CREATE POLICY "Librarians and Admins can view all penalties"
        ON penalties FOR SELECT
        USING (
            EXISTS (
                SELECT 1 FROM user_profiles
                WHERE user_id = auth.uid() AND role IN ('librarian', 'admin')
            )
        );

    -- Librarians and Admins can insert penalties
    CREATE POLICY "Librarians and Admins can create penalties"
        ON penalties FOR INSERT
        WITH CHECK (
            EXISTS (
                SELECT 1 FROM user_profiles
                WHERE user_id = auth.uid() AND role IN ('librarian', 'admin')
            )
        );

    -- Librarians and Admins can update penalties (confirm/reject payment)
    CREATE POLICY "Librarians and Admins can update penalties"
        ON penalties FOR UPDATE
        USING (
            EXISTS (
                SELECT 1 FROM user_profiles
                WHERE user_id = auth.uid() AND role IN ('librarian', 'admin')
            )
        );

    -- =====================================================
    -- END OF SCHEMA
    -- =====================================================

