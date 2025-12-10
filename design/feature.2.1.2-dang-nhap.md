# Feature 2.1.2: Đăng Nhập

## Mô tả
Cho phép người dùng đã có tài khoản đăng nhập vào hệ thống.

## Actor
Mọi người (có tài khoản)

## Yêu cầu
Đã có tài khoản (Feature 2.1.1)

## Flowchart

```mermaid
flowchart TD
    Start([Người dùng truy cập trang đăng nhập]) --> ShowLoginForm[Hiển thị form đăng nhập]
    ShowLoginForm --> InputCredentials[Nhập Email và Mật khẩu]
    InputCredentials --> ClickLogin[Click 'Đăng nhập']
    
    ClickLogin --> ValidateEmail{Validate Email}
    ValidateEmail -->|Email không hợp lệ| ErrorEmailFormat[Hiển thị lỗi: Email không đúng định dạng]
    ErrorEmailFormat --> InputCredentials
    ValidateEmail -->|Email hợp lệ| ValidatePassword{Validate Mật khẩu}
    
    ValidatePassword -->|Mật khẩu trống hoặc < 8 ký tự| ErrorPasswordFormat[Hiển thị lỗi: Mật khẩu không hợp lệ]
    ErrorPasswordFormat --> InputCredentials
    ValidatePassword -->|Mật khẩu hợp lệ| CheckCredentials[Kiểm tra thông tin đăng nhập]
    
    CheckCredentials --> FindUser{Tìm thấy user?}
    FindUser -->|Không tìm thấy| ErrorNotFound[Hiển thị lỗi: Email hoặc mật khẩu không đúng]
    ErrorNotFound --> InputCredentials
    FindUser -->|Tìm thấy| CheckPassword{Mật khẩu đúng?}
    
    CheckPassword -->|Sai| ErrorWrongPassword[Hiển thị lỗi: Email hoặc mật khẩu không đúng]
    ErrorWrongPassword --> InputCredentials
    CheckPassword -->|Đúng| CheckAccountStatus{Tài khoản có bị vô hiệu hóa?}
    
    CheckAccountStatus -->|Bị vô hiệu hóa| ErrorDisabled[Hiển thị lỗi: Tài khoản đã bị vô hiệu hóa]
    ErrorDisabled --> InputCredentials
    CheckAccountStatus -->|Hoạt động| GenerateToken[Tạo JWT token với thời hạn 24h]
    
    GenerateToken --> CreateSession[Tạo session]
    CreateSession --> SaveSession[(Lưu session vào Database)]
    SaveSession --> CheckRole{Kiểm tra vai trò}
    
    CheckRole -->|Reader| RedirectReaderDashboard[Chuyển đến Reader Dashboard]
    CheckRole -->|Librarian| RedirectLibrarianDashboard[Chuyển đến Librarian Dashboard]
    CheckRole -->|Admin| RedirectAdminDashboard[Chuyển đến Admin Dashboard]
    
    RedirectReaderDashboard --> End([Kết thúc])
    RedirectLibrarianDashboard --> End
    RedirectAdminDashboard --> End
```

## Validation Rules

| Field | Rule | Message Error |
|-------|------|---------------|
| Email | Định dạng email hợp lệ | "Email không đúng định dạng" |
| Email | Email tồn tại trong hệ thống | "Email hoặc mật khẩu không đúng" |
| Mật khẩu | Không được để trống | "Mật khẩu không được để trống" |
| Mật khẩu | Tối thiểu 8 ký tự, tối đa 16 ký tự | "Mật khẩu phải từ 8-16 ký tự" |
| Mật khẩu | Mật khẩu khớp với email | "Email hoặc mật khẩu không đúng" |
| Tài khoản | Tài khoản không bị vô hiệu hóa | "Tài khoản đã bị vô hiệu hóa" |

## Session Data
```json
{
  "token": "JWT token string",
  "user_id": "string",
  "email": "string",
  "name": "string",
  "role": "Reader|Librarian|Admin",
  "expires_at": "timestamp (24h from login)",
  "created_at": "timestamp"
}
```

## Notes
- Token có thời hạn 24 giờ
- Sau khi hết hạn, người dùng cần đăng nhập lại
- Mật khẩu được hash và so sánh với hash trong database
- Không hiển thị chi tiết lỗi cụ thể (email sai hay mật khẩu sai) để bảo mật

