# Feature 2.2.5: Sửa & Xóa Sách

## Mô tả
Cho phép nhân viên thư viện chỉnh sửa thông tin sách hoặc xóa sách khỏi hệ thống.

## Actor
Nhân viên thư viện, Admin

## Yêu cầu
- Đã đăng nhập (Feature 2.1.2)
- Có vai trò Librarian hoặc Admin
- Sách đã tồn tại (Feature 2.2.4)

## Flowchart

```mermaid
flowchart TD
    Start([Nhân viên thư viện xem chi tiết sách]) --> StaffChoice{Nhân viên chọn}
    
    %% ============ LUỒNG SỬA SÁCH ============
    StaffChoice -->|Click 'Sửa'| CheckEditPermission{Có quyền sửa?}
    CheckEditPermission -->|Không| ErrorEditPermission[Hiển thị lỗi: Không có quyền sửa]
    ErrorEditPermission --> End([Kết thúc])
    CheckEditPermission -->|Có| LoadEditForm[Tải form sửa sách]
    
    LoadEditForm --> LoadCategories[Tải danh sách thể loại]
    LoadCategories --> FillCurrentData[Điền dữ liệu hiện tại vào form]
    FillCurrentData --> ShowEditForm[Hiển thị form chỉnh sửa]
    
    ShowEditForm --> EditBookData[Chỉnh sửa thông tin:<br/>- Tên sách<br/>- Tác giả<br/>- Năm xuất bản<br/>- ISBN<br/>- Thể loại<br/>- Mô tả<br/>- Số lượng<br/>Email KHÔNG được sửa]
    
    EditBookData --> EditAction{Nhân viên chọn}
    EditAction -->|Hủy| CancelEdit[Hủy chỉnh sửa]
    CancelEdit --> RedirectBackEdit[Quay lại trang chi tiết sách]
    RedirectBackEdit --> End
    
    EditAction -->|Lưu| ClickSave[Click 'Lưu thay đổi']
    ClickSave --> ValidateTitleEdit{Validate Tên sách}
    
    ValidateTitleEdit -->|Tên trống hoặc > 100| ErrorTitleEdit[Hiển thị lỗi: Tên sách không hợp lệ]
    ErrorTitleEdit --> EditBookData
    ValidateTitleEdit -->|Hợp lệ| ValidateAuthorEdit{Validate Tác giả}
    
    ValidateAuthorEdit -->|Tác giả trống hoặc > 100| ErrorAuthorEdit[Hiển thị lỗi: Tác giả không hợp lệ]
    ErrorAuthorEdit --> EditBookData
    ValidateAuthorEdit -->|Hợp lệ| ValidateYearEdit{Validate Năm XB}
    
    ValidateYearEdit -->|Năm không hợp lệ| ErrorYearEdit[Hiển thị lỗi: Năm XB phải từ 1900 - hiện tại]
    ErrorYearEdit --> EditBookData
    ValidateYearEdit -->|Hợp lệ| ValidateISBNEdit{ISBN có thay đổi?}
    
    ValidateISBNEdit -->|Không thay đổi| ValidateCategoryEdit
    ValidateISBNEdit -->|Có thay đổi| CheckISBNFormatEdit{Validate ISBN format}
    CheckISBNFormatEdit -->|Không đúng format| ErrorISBNEdit[Hiển thị lỗi: ISBN không đúng định dạng]
    ErrorISBNEdit --> EditBookData
    CheckISBNFormatEdit -->|Đúng format| CheckISBNDuplicateEdit{ISBN đã tồn tại?}
    
    CheckISBNDuplicateEdit -->|Đã tồn tại| ErrorISBNDuplicateEdit[Hiển thị lỗi: ISBN đã được sử dụng]
    ErrorISBNDuplicateEdit --> EditBookData
    CheckISBNDuplicateEdit -->|Chưa tồn tại| ValidateCategoryEdit{Validate Thể loại}
    
    ValidateCategoryEdit -->|Chưa chọn thể loại| ErrorCategoryEdit[Hiển thị lỗi: Phải chọn thể loại]
    ErrorCategoryEdit --> EditBookData
    ValidateCategoryEdit -->|Đã chọn| ValidateDescEdit{Validate Mô tả}
    
    ValidateDescEdit -->|Mô tả trống hoặc > 255| ErrorDescEdit[Hiển thị lỗi: Mô tả không hợp lệ]
    ErrorDescEdit --> EditBookData
    ValidateDescEdit -->|Hợp lệ| ValidateQuantityEdit{Validate Số lượng}
    
    ValidateQuantityEdit -->|<= 0 hoặc không phải số| ErrorQuantityEdit[Hiển thị lỗi: Số lượng không hợp lệ]
    ErrorQuantityEdit --> EditBookData
    ValidateQuantityEdit -->|Hợp lệ| CheckQuantityChange{Số lượng có thay đổi?}
    
    CheckQuantityChange -->|Không| UpdateBookInfo[(Cập nhật thông tin sách vào Database)]
    CheckQuantityChange -->|Có| CalculateNewAvailable[Tính toán lại số lượng có sẵn<br/>available = new_total - borrowed]
    CalculateNewAvailable --> CheckNewAvailable{available >= 0?}
    
    CheckNewAvailable -->|Không| ErrorInsufficientQty[Hiển thị lỗi: Số lượng mới không đủ<br/>Hiện đang có X cuốn đang mượn]
    ErrorInsufficientQty --> EditBookData
    CheckNewAvailable -->|Có| UpdateBookInfo
    
    UpdateBookInfo --> LogUpdate[Ghi log lịch sử chỉnh sửa]
    LogUpdate --> ShowSuccessEdit[Hiển thị: Cập nhật thành công]
    ShowSuccessEdit --> RefreshDetail[Refresh trang chi tiết sách]
    RefreshDetail --> End
    
    %% ============ LUỒNG XÓA SÁCH ============
    StaffChoice -->|Click 'Xóa'| CheckDeletePermission{Có quyền xóa?}
    CheckDeletePermission -->|Không| ErrorDeletePermission[Hiển thị lỗi: Không có quyền xóa]
    ErrorDeletePermission --> End
    CheckDeletePermission -->|Có| CheckActiveBorrows{Có đơn mượn hoạt động?}
    
    CheckActiveBorrows -->|Có| ErrorActiveBorrows[Hiển thị lỗi: Không thể xóa<br/>Sách đang có đơn mượn hoạt động<br/>Trạng thái: Chờ xác nhận/Đang mượn/Quá hạn]
    ErrorActiveBorrows --> End
    CheckActiveBorrows -->|Không| ShowDeleteConfirm[Hiển thị modal xác nhận xóa<br/>Cảnh báo: Thao tác không thể hoàn tác]
    
    ShowDeleteConfirm --> DeleteChoice{Nhân viên chọn}
    DeleteChoice -->|Hủy| CancelDelete[Hủy xóa]
    CancelDelete --> End
    DeleteChoice -->|Xác nhận xóa| SoftDelete[Đánh dấu xóa mềm<br/>soft_delete = true<br/>deleted_at = now]
    
    SoftDelete --> UpdateRelatedRecords[Cập nhật các bản ghi liên quan<br/>Lịch sử mượn đã trả giữ lại]
    UpdateRelatedRecords --> LogDelete[Ghi log lịch sử xóa<br/>Lưu: user_id, book_info, timestamp]
    LogDelete --> ShowSuccessDelete[Hiển thị: Xóa sách thành công]
    ShowSuccessDelete --> RedirectList[Chuyển về danh sách sách]
    RedirectList --> End
```

## Validation Rules - Sửa Sách

| Field | Rule | Message Error |
|-------|------|---------------|
| Tên sách | Không được để trống | "Tên sách không được để trống" |
| Tên sách | Tối đa 100 ký tự | "Tên sách không được vượt quá 100 ký tự" |
| Tác giả | Không được để trống | "Tác giả không được để trống" |
| Tác giả | Tối đa 100 ký tự | "Tác giả không được vượt quá 100 ký tự" |
| Năm xuất bản | Từ 1900 đến năm hiện tại | "Năm xuất bản phải từ 1900 đến năm hiện tại" |
| ISBN | Định dạng ISBN-10 hoặc ISBN-13 (nếu có) | "ISBN không đúng định dạng" |
| ISBN | Không được trùng với sách khác | "ISBN đã được sử dụng" |
| Thể loại | Phải chọn thể loại | "Vui lòng chọn thể loại sách" |
| Mô tả | Không được để trống | "Mô tả không được để trống" |
| Mô tả | Tối đa 255 ký tự | "Mô tả không được vượt quá 255 ký tự" |
| Số lượng | Phải > 0 | "Số lượng phải lớn hơn 0" |
| Số lượng | Phải >= số lượng đang mượn | "Số lượng mới không đủ. Hiện có {borrowed_quantity} cuốn đang mượn" |
| Số lượng | Kiểu số nguyên | "Số lượng phải là số" |

## Business Rules - Xóa Sách

### Điều Kiện Xóa
1. ✅ Không có đơn mượn ở trạng thái "Chờ xác nhận"
2. ✅ Không có đơn mượn ở trạng thái "Đang mượn"
3. ✅ Không có đơn mượn ở trạng thái "Quá hạn"
4. ✅ Chỉ Librarian/Admin có quyền xóa

### Xóa Mềm (Soft Delete)
- Không xóa hẳn khỏi database
- Đánh dấu `soft_delete = true`
- Lưu `deleted_at` timestamp
- Các đơn mượn đã trả vẫn giữ lại trong lịch sử

## Data Update - Sửa Sách
```json
{
  "title": "string (max 100)",
  "author": "string (max 100)",
  "publication_year": "number (1900 - current)",
  "isbn": "string (ISBN-10/13, nullable, unique)",
  "category_id": "string (foreign key)",
  "description": "string (max 255)",
  "total_quantity": "number (> 0, >= borrowed_quantity)",
  "available_quantity": "number (calculated: total - borrowed)",
  "updated_at": "timestamp",
  "updated_by": "user_id"
}
```

## Data Update - Xóa Sách
```json
{
  "soft_delete": true,
  "deleted_at": "timestamp",
  "deleted_by": "user_id"
}
```

## Audit Log
Mỗi thao tác sửa/xóa cần ghi log:
```json
{
  "action": "update | delete",
  "book_id": "string",
  "book_title": "string",
  "user_id": "string",
  "user_name": "string",
  "changes": {
    "field_name": {
      "old_value": "value",
      "new_value": "value"
    }
  },
  "timestamp": "timestamp"
}
```

## Notes
- Số lượng mới phải >= số lượng đang mượn
- ISBN có thể để trống nhưng nếu nhập phải unique
- Xóa sách là soft delete để giữ lại dữ liệu lịch sử
- Cần xác nhận trước khi xóa
- Ghi log đầy đủ để audit trail

