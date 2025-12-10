# Hướng Dẫn Khởi Động Nhanh

Hướng dẫn từng bước để chạy dự án LibraryHub - Hệ thống Quản lý Thư viện
---

## 📝 BƯỚC 1: Clone Dự Án

Làm theo hướng dẫn giống như trong slide
1. Clone dự án về 1 thư mục trống
2. Xóa bỏ thông tin git
3. Khởi tạo 1 dự án mới, thêm các file, thư mục hiện có rồi commit toàn bộ lần đầu tiên
4. Tạo 1 repo mới trên Github
5. Push code lên repo mới

```

Bạn sẽ thấy cấu trúc như sau:
```
library/
├── backend/          # Mã nguồn backend (Node.js + Express)
├── frontend/         # Mã nguồn frontend (React + Vite)
├── migrations/       # File SQL để tạo database
├── PRD.md           # Tài liệu yêu cầu dự án
└── QUICKSTART.md    # File này
```

---

## BƯỚC 2: Tạo Database Trên Supabase

### 2.1. Đăng Nhập Supabase

1. Mở trình duyệt web
2. Truy cập: https://supabase.com
3. Nhấn **"Start your project"** hoặc **"Sign In"**
4. Đăng nhập bằng GitHub hoặc email

### 2.2. Tạo Project Mới

1. Sau khi đăng nhập, nhấn **"New Project"**
2. Chọn tổ chức (Organization) của bạn
3. Điền thông tin project:
   - **Name:** `library-hub` (hoặc tên bạn muốn)
   - **Database Password:** Tạo mật khẩu mạnh (VD: `MySecurePass123!`)
   -  **QUAN TRỌNG:** Lưu lại mật khẩu này, bạn sẽ cần nó ở bước sau!
   - **Region:** Chọn `Southeast Asia (Singapore)` (gần Việt Nam nhất)
   - **Pricing Plan:** Chọn **"Free"**
4. Nhấn **"Create new project"**
5. Đợi khoảng 2-3 phút để Supabase khởi tạo database

### 2.3. Chạy Migration (Tạo Bảng Dữ Liệu)

Sau khi project được tạo xong:

#### Bước 2.3.1: Mở SQL Editor

1. Ở sidebar bên trái, tìm và nhấn vào **"SQL Editor"**
2. Nhấn **"New query"** để tạo query mới

#### Bước 2.3.2: Copy Nội Dung File Migration

1. Quay lại Cursor hoặc trình soạn thảo code
2. Mở file: `migrations/schema.sql` copy toàn bộ code trong file này.

#### Bước 2.3.3: Chạy Migration

1. Quay lại Supabase SQL Editor
2. Paste nội dung đã copy vào ô SQL query
3. Nhấn nút **"Run"**
4. Đợi khoảng 5-10 giây
5. Bạn sẽ thấy thông báo **"Success. No rows returned"** ở phía dưới

**Hoàn thành!** Database đã được tạo với:
- 7 bảng dữ liệu (profiles, books, borrow_requests, v.v.)
- 3 tài khoản mẫu (admin, librarian, reader, chung mật khẩu là abc@1234)
- Dữ liệu test (sách, danh mục, v.v.)

#### Bước 2.3.4: Kiểm Tra Bảng Đã Tạo

1. Nhấn vào **"Table Editor"** ở sidebar trái
2. Bạn sẽ thấy các bảng:
   - `profiles` - Thông tin người dùng
   - `books` - Thông tin sách
   - `book_categories` - Danh mục sách
   - `borrow_requests` - Yêu cầu mượn sách
   - `return_requests` - Yêu cầu trả sách
   - `fines` - Phạt
   - `fine_levels` - Mức phạt
3. Nhấn vào bảng `profiles` - bạn sẽ thấy 3 user mẫu

### 2.4. Lấy Connection String (Chuỗi Kết Nối)

Quay lại trang chủ project của Supabase
1. Nhấn vào icon Connect
2. Chọn **"ORMs"**
3. Copy chuỗi kết nối (sẽ giống như này):
   ```
# Connect to Supabase via connection pooling
DATABASE_URL="postgresql://postgres.elmkigicxxqnyjmkfruk:[YOUR-PASSWORD]@aws-1-ap-southeast-1.pooler.supabase.com:6543/postgres?pgbouncer=true"
# Direct connection to the database. Used for migrations
DIRECT_URL="postgresql://postgres.elmkigicxxqnyjmkfruk:[YOUR-PASSWORD]@aws-1-ap-southeast-1.pooler.supabase.com:5432/postgres"
   ```
Chuỗi kết nối này sẽ được dán vào file .env

---

##  BƯỚC 3: Cấu Hình Backend

### 3.1. Mở File .env

1. Trong Cursor, mở thư mục `backend`
2. Tìm file `.env`
3. Nếu không có file `.env`, copy từ `.env.example`:

### 3.2. Cập Nhật Thông Tin Database

Mở file `backend/.env` và chỉnh sửa phần DATABASE_URL và DIRECT_URL theo chuỗi copy từ phần kết nối của Supabase, thay [YOUR-PASSWORD] bằng mật khẩu bạn tạo ra khi tạo project.

### 3.3. Ví Dụ Cụ Thể

Giả sử:
- Connection string của bạn trên Supabase trông như sau: 
`postgresql://postgres.abc123xyz:[YOUR-PASSWORD]@aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres`
và mật khẩu khi bạn tạo project trên Supabase là MySecurePass123!

Thì file `.env` sẽ như sau:

```env
DATABASE_URL="postgresql://postgres.abc123xyz:MySecurePass123!@aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres"
DIRECT_URL="postgresql://postgres.abc123xyz:MySecurePass123!@aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres"

JWT_SECRET="my-super-secret-jwt-key-123456"
JWT_EXPIRES_IN="24h"

... (các tham số khác)

```

**LƯU Ý QUAN TRỌNG:**
- **KHÔNG** được commit file `.env` lên Git (file này đã có trong `.gitignore`)
- Mật khẩu database phải khớp với mật khẩu bạn đã tạo ở Supabase
- Đổi `JWT_SECRET` thành chuỗi ngẫu nhiên phức tạp tùy thích để bảo mật

---

## BƯỚC 4: Cài Đặt Dependencies

### 4.1. Cài Đặt Backend Dependencies

```bash
# Ở thư mục gốc của dự án (library/)
cd backend

# Cài đặt tất cả packages
npm install
```

⏳ Đợi khoảng 1-2 phút để npm tải và cài đặt các packages.

### 4.2. Generate Prisma Client

```bash
# Vẫn ở thư mục backend
npx prisma generate
```

Lệnh này tạo Prisma Client để code có thể tương tác với database.

### 4.3. Cài Đặt Frontend Dependencies

```bash
# Di chuyển đến thư mục frontend
cd ../frontend

# Cài đặt packages
npm install
```

⏳ Đợi khoảng 1-2 phút.

---

## 🚀 BƯỚC 5: Chạy Ứng Dụng

### 5.1. Mở 2 Terminal

Bạn cần mở **2 terminal riêng biệt** trong Cursor để chạy backend và frontend cùng lúc.

### 5.2. Chạy Backend (Terminal 1)

```bash
# Di chuyển vào thư mục backend nếu đang ở thư mục gốc của dự án
cd backend

# Chạy backend ở chế độ development
npm run dev
```

**Thành công!** Bạn sẽ thấy:
```
🚀 Server is running on http://localhost:5000
✅ Database connected successfully
```

### 5.3. Chạy Frontend (Terminal 2)

```bash
# Di chuyển vào thư mục frontend (nếu đang ở thư mục gốc)
cd frontend

# Chạy frontend ở chế độ development
npm run dev
```

**Thành công!** Bạn sẽ thấy:
```
  VITE v5.x.x  ready in xxx ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
  ➜  press h + enter to show help
```

## BƯỚC 6: Test Chức Năng Đăng Ký

### 6.1. Mở Ứng Dụng

Mở trình duyệt và truy cập:
```
http://localhost:5173
```

Bạn sẽ thấy trang Landing Page của LibraryHub.

### 6.2. Đăng Ký Tài Khoản Mới

#### Bước 6.2.1: Vào Trang Đăng Ký

- Nhấn nút **"Get Started**
- Hoặc truy cập trực tiếp: `http://localhost:5173/register`
- Điền các thông tin cần thiết và nhấn "Đăng ký"

### 6.3. Kiểm Tra User Đã Được Tạo

#### Cách 1: Qua Supabase Table Editor

1. Quay lại Supabase Dashboard
2. Nhấn **"Table Editor"** ở sidebar
3. Chọn bảng **"profiles"**
4. Bạn sẽ thấy user mới với:
   - Email: `student@example.com`
   - Name: `Nguyễn Văn A`
   - Password: (đã được mã hóa bằng bcrypt)
   - Role: `reader`
   - Status: `active`
   
---

## Tài Khoản Mẫu

Migration đã tạo sẵn 3 tài khoản để test:

| Email | Mật Khẩu | Vai Trò | Mô Tả |
|-------|----------|---------|-------|
| admin@library.com | `abc@1234` | Admin | Quản trị viên - full quyền |
| librarian@library.com | `abc@1234` | Librarian | Thủ thư - quản lý sách và mượn trả |
| reader@library.com | `abc@1234` | Reader | Độc giả - mượn sách |

Bạn có thể dùng các tài khoản này để test đăng nhập.

---

## Các Tính Năng Đã Hoàn Thành

### Backend (Node.js + Express)

- **Xác thực (Authentication):**
  - Đăng ký user mới với bcrypt hash password


- **Database:**
  - Prisma ORM kết nối PostgreSQL (Supabase)
  - 7 models: Profile, Book, BookCategory, BorrowRequest, ReturnRequest, Fine, FineLevel
  - Migration script với dữ liệu mẫu

- **Validation & Security:**
  - Joi validation cho input
  - Bcrypt password hashing (cost factor 10)
  - CORS enabled
  - Error handling với message tiếng Việt

### Frontend (React + Vite)

- **Pages:**
  - Landing Page - Trang chủ giới thiệu
  - Register - Đăng ký tài khoản
  - Login - Đăng nhập

- **Features:**
  - React Router navigation
  - React Hook Form với validation
  - Axios API client
  - TailwindCSS với theme thư viện
  - Responsive design