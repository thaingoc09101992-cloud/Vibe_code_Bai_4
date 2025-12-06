# Database Schema - Library Management System

## Entity-Relationship Diagram

```mermaid
erDiagram
    auth_users ||--o| user_profiles : "has"
    user_profiles ||--o{ borrows : "creates"
    user_profiles ||--o{ return_requests : "creates"
    user_profiles ||--o{ penalties : "receives"
    
    categories ||--o{ books : "contains"
    books ||--o{ borrows : "borrowed_in"
    books ||--o{ return_requests : "returned_in"
    
    borrows ||--o| return_requests : "has"
    borrows ||--o{ penalties : "generates"
    
    penalty_levels ||--o{ penalties : "defines"
    
    user_profiles {
        uuid id PK
        uuid user_id FK "auth.users"
        varchar full_name
        varchar phone
        varchar address
        enum role "reader, librarian, admin"
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }
    
    categories {
        uuid id PK
        varchar name
        timestamp created_at
        timestamp updated_at
    }
    
    books {
        uuid id PK
        uuid category_id FK
        varchar title
        varchar author
        varchar isbn
        integer publication_year
        text description
        integer total_quantity
        integer available_quantity
        integer borrowed_quantity
        integer lost_quantity
        integer damaged_quantity
        timestamp created_at
        timestamp updated_at
    }
    
    borrows {
        uuid id PK
        uuid user_id FK
        uuid book_id FK
        enum status "pending, approved, borrowed, overdue, returned, rejected"
        integer duration_days
        date borrow_date
        date due_date
        date actual_return_date
        varchar rejection_reason
        boolean is_extended
        timestamp created_at
        timestamp updated_at
    }
    
    return_requests {
        uuid id PK
        uuid borrow_id FK
        enum status "pending, confirmed"
        timestamp created_at
        timestamp updated_at
    }
    
    penalty_levels {
        uuid id PK
        varchar name
        numeric amount
        date effective_date
        timestamp created_at
        timestamp updated_at
    }
    
    penalties {
        uuid id PK
        uuid user_id FK
        uuid borrow_id FK
        uuid penalty_level_id FK
        enum penalty_type "late_return, damage, lost"
        enum payment_status "unpaid, pending_confirmation, paid, rejected"
        numeric amount
        text notes
        varchar rejection_reason
        timestamp created_at
        timestamp updated_at
    }
```

## Table Descriptions

### user_profiles
Stores extended user information linked to Supabase Auth users. Each user has a role (reader, librarian, admin) and can be active or inactive.

**Key Fields:**
- `user_id`: Foreign key to `auth.users.id` (Supabase Auth)
- `role`: User role enum (reader, librarian, admin)
- `is_active`: Account status flag

### categories
Book categories managed by librarians.

**Key Fields:**
- `name`: Category name (max 50 characters)

### books
Library books with inventory tracking.

**Key Fields:**
- `category_id`: Foreign key to categories
- `total_quantity`: Total copies owned
- `available_quantity`: Copies available for borrowing
- `borrowed_quantity`: Copies currently borrowed
- `lost_quantity`: Copies lost
- `damaged_quantity`: Copies damaged

### borrows
Borrowing records tracking book loans.

**Key Fields:**
- `status`: Borrow status (pending, approved, borrowed, overdue, returned, rejected)
- `duration_days`: Loan duration (default 14, max 30)
- `due_date`: Calculated return deadline
- `is_extended`: Flag for extension (max 1 extension per borrow)
- `rejection_reason`: Reason if rejected

### return_requests
Return requests created by readers, confirmed by librarians.

**Key Fields:**
- `borrow_id`: Foreign key to borrows
- `status`: Request status (pending, confirmed)

### penalty_levels
Configurable penalty amounts managed by admins.

**Key Fields:**
- `name`: Penalty level name (max 25 characters)
- `amount`: Penalty amount
- `effective_date`: When penalty level becomes active

### penalties
Individual penalty records for late returns, damage, or lost books.

**Key Fields:**
- `penalty_type`: Type of penalty (late_return, damage, lost)
- `payment_status`: Payment status (unpaid, pending_confirmation, paid, rejected)
- `amount`: Actual penalty amount (from penalty_level)
- `notes`: Librarian notes (required for damage/lost, max 500 chars)
- `rejection_reason`: Reason if payment rejected

## Relationships

1. **user_profiles ↔ auth.users**: One-to-one (via user_id)
2. **user_profiles ↔ borrows**: One-to-many
3. **user_profiles ↔ return_requests**: One-to-many
4. **user_profiles ↔ penalties**: One-to-many
5. **categories ↔ books**: One-to-many
6. **books ↔ borrows**: One-to-many
7. **books ↔ return_requests**: One-to-many (via borrows)
8. **borrows ↔ return_requests**: One-to-one (one return request per borrow)
9. **borrows ↔ penalties**: One-to-many (multiple penalties possible: late + damage)
10. **penalty_levels ↔ penalties**: One-to-many

## Indexes

### Performance Indexes
- `user_profiles.user_id`: Unique index (one profile per auth user)
- `user_profiles.role`: B-tree index (role-based queries)
- `books.category_id`: B-tree index (category filtering)
- `books.title`, `books.author`: B-tree indexes (search)
- `borrows.user_id`: B-tree index (user borrow history)
- `borrows.book_id`: B-tree index (book borrow history)
- `borrows.status`: B-tree index (status filtering)
- `borrows.due_date`: B-tree index (overdue detection)
- `return_requests.borrow_id`: Unique index (one request per borrow)
- `return_requests.status`: B-tree index (pending returns)
- `penalties.user_id`: B-tree index (user penalties)
- `penalties.payment_status`: B-tree index (unpaid penalties)
- `penalties.borrow_id`: B-tree index (borrow-related penalties)

### Composite Indexes
- `(borrows.user_id, status)`: User's active borrows
- `(borrows.book_id, status)`: Book availability
- `(penalties.user_id, payment_status)`: User's unpaid penalties

