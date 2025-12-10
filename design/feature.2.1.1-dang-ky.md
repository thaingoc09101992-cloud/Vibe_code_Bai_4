# Feature 2.1.1: Đăng Ký

## Mô tả
Cho phép người dùng mới tạo tài khoản trong hệ thống quản lý thư viện.

## Actor
Mọi người (không cần đăng nhập)

## Yêu cầu
Không có

## Flowchart

```mermaid
flowchart TD
    Start([Người dùng truy cập trang chủ]) --> ClickRegister[Click nút 'Đăng ký']
    ClickRegister --> ShowForm[Hiển thị form đăng ký]
    ShowForm --> InputData[Nhập: Email, Tên, Mật khẩu, Confirm mật khẩu]
    InputData --> SubmitForm[Click 'Đăng ký']
    
    SubmitForm --> ValidateEmail{Validate Email}
    ValidateEmail -->|Email không hợp lệ| ErrorEmail[Hiển thị lỗi: Email không đúng định dạng]
    ErrorEmail --> InputData
    ValidateEmail -->|Email hợp lệ| ValidateName{Validate Tên}
    
    ValidateName -->|Tên trống hoặc > 50 ký tự| ErrorName[Hiển thị lỗi: Tên không hợp lệ]
    ErrorName --> InputData
    ValidateName -->|Tên hợp lệ| ValidatePassword{Validate Mật khẩu}
    
    ValidatePassword -->|Mật khẩu < 8 hoặc > 16 ký tự| ErrorPassword[Hiển thị lỗi: Mật khẩu phải từ 8-16 ký tự]
    ErrorPassword --> InputData
    ValidatePassword -->|Mật khẩu hợp lệ| ValidateConfirm{Mật khẩu khớp?}
    
    ValidateConfirm -->|Không khớp| ErrorConfirm[Hiển thị lỗi: Mật khẩu không khớp]
    ErrorConfirm --> InputData
    ValidateConfirm -->|Khớp| CheckEmailExists{Email đã tồn tại?}
    
    CheckEmailExists -->|Đã tồn tại| ErrorExists[Hiển thị lỗi: Email đã được sử dụng]
    ErrorExists --> InputData
    CheckEmailExists -->|Chưa tồn tại| CreateAccount[Tạo tài khoản với trạng thái 'Chờ xác nhận']
    
    CreateAccount --> SaveDB[(Lưu vào Database)]
    SaveDB --> ShowSuccess[Hiển thị thông báo thành công]
    ShowSuccess --> RedirectLogin[Chuyển hướng đến trang đăng nhập]
    RedirectLogin --> End([Kết thúc])
```

## Validation Rules

| Field | Rule | Message Error |
|-------|------|---------------|
| Email | Định dạng email hợp lệ | "Email không đúng định dạng" |
| Email | Email chưa tồn tại | "Email đã được sử dụng" |
| Tên | Không được để trống | "Tên không được để trống" |
| Tên | Tối đa 50 ký tự | "Tên không được vượt quá 50 ký tự" |
| Mật khẩu | Không được để trống | "Mật khẩu không được để trống" |
| Mật khẩu | Tối thiểu 8 ký tự, tối đa 16 ký tự | "Mật khẩu phải từ 8-16 ký tự" |
| Confirm mật khẩu | Phải trùng với mật khẩu | "Mật khẩu không khớp" |

## Data Model
```json
{
  "email": "string (unique)",
  "name": "string (max 50)",
  "password": "string (hashed, 8-16 chars)",
  "status": "Chờ xác nhận",
  "role": "Reader (default)",
  "created_at": "timestamp"
}
```

## Notes
- Mật khẩu được hash trước khi lưu vào database
- Tài khoản mới tạo mặc định có vai trò "Reader" và trạng thái "Chờ xác nhận"
- Admin có thể kích hoạt tài khoản sau đó

