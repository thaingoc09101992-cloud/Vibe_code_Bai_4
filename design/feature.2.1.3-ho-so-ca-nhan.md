# Feature 2.1.3: Hồ Sơ Cá Nhân

## Mô tả
Cho phép độc giả xem và cập nhật thông tin cá nhân, thay đổi mật khẩu.

## Actor
Độc giả (đã đăng nhập)

## Yêu cầu
- Đã đăng nhập (Feature 2.1.2)
- Có vai trò Reader

## Flowchart

```mermaid
flowchart TD
    Start([Độc giả đã đăng nhập]) --> ClickProfile[Click 'Hồ sơ cá nhân']
    ClickProfile --> LoadProfile[Tải thông tin từ Database]
    LoadProfile --> DisplayProfile[Hiển thị thông tin cá nhân]
    
    DisplayProfile --> ShowInfo[Hiển thị:<br/>- Tên, Email, SĐT, Địa chỉ<br/>- Ngày tham gia<br/>- Số lần mượn<br/>- Tổng tiền phạt]
    
    ShowInfo --> UserChoice{Người dùng chọn}
    
    UserChoice -->|Cập nhật thông tin| ClickEdit[Click 'Chỉnh sửa']
    ClickEdit --> EnableEdit[Cho phép chỉnh sửa các trường]
    EnableEdit --> EditData[Chỉnh sửa: Tên, SĐT, Địa chỉ<br/>Email không được sửa]
    EditData --> ClickSave[Click 'Lưu']
    
    ClickSave --> ValidateName{Validate Tên}
    ValidateName -->|Tên trống hoặc > 50 ký tự| ErrorName[Hiển thị lỗi: Tên không hợp lệ]
    ErrorName --> EditData
    ValidateName -->|Tên hợp lệ| ValidatePhone{Validate SĐT}
    
    ValidatePhone -->|SĐT không đúng định dạng| ErrorPhone[Hiển thị lỗi: Số điện thoại không hợp lệ]
    ErrorPhone --> EditData
    ValidatePhone -->|SĐT hợp lệ| ValidateAddress{Validate Địa chỉ}
    
    ValidateAddress -->|Địa chỉ trống hoặc > 255 ký tự| ErrorAddress[Hiển thị lỗi: Địa chỉ không hợp lệ]
    ErrorAddress --> EditData
    ValidateAddress -->|Địa chỉ hợp lệ| UpdateDB1[(Cập nhật Database)]
    
    UpdateDB1 --> ShowSuccessUpdate[Hiển thị: Cập nhật thành công]
    ShowSuccessUpdate --> DisplayProfile
    
    UserChoice -->|Thay đổi mật khẩu| ClickChangePassword[Click 'Đổi mật khẩu']
    ClickChangePassword --> ShowPasswordForm[Hiển thị form đổi mật khẩu]
    ShowPasswordForm --> InputPasswords[Nhập:<br/>- Mật khẩu hiện tại<br/>- Mật khẩu mới<br/>- Xác nhận mật khẩu mới]
    InputPasswords --> ClickSavePassword[Click 'Đổi mật khẩu']
    
    ClickSavePassword --> ValidateCurrentPassword{Mật khẩu hiện tại đúng?}
    ValidateCurrentPassword -->|Sai| ErrorCurrentPassword[Hiển thị lỗi: Mật khẩu hiện tại không đúng]
    ErrorCurrentPassword --> InputPasswords
    ValidateCurrentPassword -->|Đúng| ValidateNewPassword{Validate mật khẩu mới}
    
    ValidateNewPassword -->|< 8 hoặc > 16 ký tự| ErrorNewPassword[Hiển thị lỗi: Mật khẩu phải từ 8-16 ký tự]
    ErrorNewPassword --> InputPasswords
    ValidateNewPassword -->|Hợp lệ| ValidateConfirmPassword{Mật khẩu mới khớp?}
    
    ValidateConfirmPassword -->|Không khớp| ErrorConfirmPassword[Hiển thị lỗi: Mật khẩu xác nhận không khớp]
    ErrorConfirmPassword --> InputPasswords
    ValidateConfirmPassword -->|Khớp| CheckSamePassword{Mật khẩu mới trùng với cũ?}
    
    CheckSamePassword -->|Trùng| ErrorSamePassword[Hiển thị lỗi: Mật khẩu mới phải khác mật khẩu cũ]
    ErrorSamePassword --> InputPasswords
    CheckSamePassword -->|Khác| HashPassword[Hash mật khẩu mới]
    
    HashPassword --> UpdateDB2[(Cập nhật mật khẩu vào Database)]
    UpdateDB2 --> ShowSuccessPassword[Hiển thị: Đổi mật khẩu thành công]
    ShowSuccessPassword --> LogoutUser[Đăng xuất người dùng]
    LogoutUser --> RedirectLogin[Chuyển đến trang đăng nhập]
    RedirectLogin --> End([Kết thúc])
    
    UserChoice -->|Xem thông tin| DisplayProfile
```

## Validation Rules

### Cập nhật thông tin cá nhân

| Field | Rule | Message Error |
|-------|------|---------------|
| Tên | Không được để trống | "Tên không được để trống" |
| Tên | Tối đa 50 ký tự | "Tên không được vượt quá 50 ký tự" |
| Số điện thoại | Định dạng số điện thoại hợp lệ | "Số điện thoại không đúng định dạng" |
| Địa chỉ | Không được để trống | "Địa chỉ không được để trống" |
| Địa chỉ | Tối đa 255 ký tự | "Địa chỉ không được vượt quá 255 ký tự" |

### Thay đổi mật khẩu

| Field | Rule | Message Error |
|-------|------|---------------|
| Mật khẩu hiện tại | Phải khớp với mật khẩu trong database | "Mật khẩu hiện tại không đúng" |
| Mật khẩu mới | Tối thiểu 8 ký tự, tối đa 16 ký tự | "Mật khẩu phải từ 8-16 ký tự" |
| Mật khẩu mới | Phải khác mật khẩu hiện tại | "Mật khẩu mới phải khác mật khẩu cũ" |
| Xác nhận mật khẩu mới | Phải trùng với mật khẩu mới | "Mật khẩu xác nhận không khớp" |

## Data Display
```json
{
  "name": "string",
  "email": "string (read-only)",
  "phone": "string",
  "address": "string",
  "joined_date": "date",
  "total_borrows": "number",
  "total_fines": "number (VND)"
}
```

## Notes
- Email không được phép chỉnh sửa
- Sau khi đổi mật khẩu, người dùng phải đăng nhập lại
- Số lần mượn và tổng tiền phạt chỉ hiển thị, không thể chỉnh sửa
- Các trường thống kê được tính toán từ database

