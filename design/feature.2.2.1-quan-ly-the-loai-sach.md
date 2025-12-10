# Feature 2.2.1: Quản Lý Thể Loại Sách

## Mô tả
Cho phép nhân viên thư viện quản lý (xem, thêm, sửa, xóa) các thể loại sách trong hệ thống.

## Actor
Nhân viên thư viện

## Yêu cầu
- Đã đăng nhập (Feature 2.1.2)
- Có vai trò Librarian hoặc Admin

## Flowchart

```mermaid
flowchart TD
    Start([Nhân viên thư viện đã đăng nhập]) --> ClickManage[Click 'Quản lý thể loại sách']
    ClickManage --> LoadCategories[Tải danh sách thể loại từ Database]
    LoadCategories --> DisplayTable[Hiển thị bảng danh sách thể loại<br/>Có thể sửa trực tiếp trên bảng]
    
    DisplayTable --> UserChoice{Nhân viên chọn}
    
    %% Luồng Thêm Thể Loại
    UserChoice -->|Thêm thể loại| ClickAdd[Click 'Thêm thể loại sách']
    ClickAdd --> ShowAddForm[Hiển thị form thêm mới]
    ShowAddForm --> InputCategoryName[Nhập tên thể loại]
    InputCategoryName --> ClickSaveAdd[Click 'Lưu']
    
    ClickSaveAdd --> ValidateNameAdd{Validate Tên}
    ValidateNameAdd -->|Tên trống| ErrorEmptyAdd[Hiển thị lỗi: Tên thể loại không được trống]
    ErrorEmptyAdd --> InputCategoryName
    ValidateNameAdd -->|Tên > 50 ký tự| ErrorLengthAdd[Hiển thị lỗi: Tên không quá 50 ký tự]
    ErrorLengthAdd --> InputCategoryName
    ValidateNameAdd -->|Hợp lệ| CheckDuplicateAdd{Tên đã tồn tại?}
    
    CheckDuplicateAdd -->|Đã tồn tại| ErrorDuplicateAdd[Hiển thị lỗi: Thể loại đã tồn tại]
    ErrorDuplicateAdd --> InputCategoryName
    CheckDuplicateAdd -->|Chưa tồn tại| SaveNewCategory[(Lưu thể loại mới vào Database)]
    
    SaveNewCategory --> ShowSuccessAdd[Hiển thị: Thêm thành công]
    ShowSuccessAdd --> RefreshTable1[Refresh bảng danh sách]
    RefreshTable1 --> DisplayTable
    
    %% Luồng Sửa Thể Loại
    UserChoice -->|Sửa thể loại| ClickEdit[Click vào ô cần sửa trên bảng]
    ClickEdit --> EnableEditMode[Cho phép chỉnh sửa trực tiếp]
    EnableEditMode --> EditCategoryName[Sửa tên thể loại]
    EditCategoryName --> BlurOrEnter[Blur hoặc Enter để lưu]
    
    BlurOrEnter --> ValidateNameEdit{Validate Tên}
    ValidateNameEdit -->|Tên trống| ErrorEmptyEdit[Hiển thị lỗi: Tên không được trống]
    ErrorEmptyEdit --> EditCategoryName
    ValidateNameEdit -->|Tên > 50 ký tự| ErrorLengthEdit[Hiển thị lỗi: Tên không quá 50 ký tự]
    ErrorLengthEdit --> EditCategoryName
    ValidateNameEdit -->|Hợp lệ| CheckDuplicateEdit{Tên đã tồn tại?}
    
    CheckDuplicateEdit -->|Đã tồn tại| ErrorDuplicateEdit[Hiển thị lỗi: Thể loại đã tồn tại]
    ErrorDuplicateEdit --> EditCategoryName
    CheckDuplicateEdit -->|Chưa tồn tại| UpdateCategory[(Cập nhật Database)]
    
    UpdateCategory --> ShowSuccessEdit[Hiển thị: Cập nhật thành công]
    ShowSuccessEdit --> RefreshTable2[Refresh bảng danh sách]
    RefreshTable2 --> DisplayTable
    
    %% Luồng Xóa Thể Loại
    UserChoice -->|Xóa thể loại| ClickDelete[Click nút 'Xóa' trên bảng]
    ClickDelete --> CheckBooksInCategory{Có sách nào thuộc thể loại này?}
    
    CheckBooksInCategory -->|Có sách| ErrorHasBooks[Hiển thị lỗi: Không thể xóa<br/>Thể loại đang có sách]
    ErrorHasBooks --> DisplayTable
    CheckBooksInCategory -->|Không có sách| ShowConfirmDelete[Hiển thị modal xác nhận xóa]
    
    ShowConfirmDelete --> ConfirmChoice{Người dùng chọn}
    ConfirmChoice -->|Hủy| DisplayTable
    ConfirmChoice -->|Xác nhận| DeleteCategory[(Xóa thể loại khỏi Database)]
    
    DeleteCategory --> ShowSuccessDelete[Hiển thị: Xóa thành công]
    ShowSuccessDelete --> RefreshTable3[Refresh bảng danh sách]
    RefreshTable3 --> DisplayTable
    
    UserChoice -->|Đóng| End([Kết thúc])
```

## Validation Rules

| Operation | Field | Rule | Message Error |
|-----------|-------|------|---------------|
| Thêm/Sửa | Tên thể loại | Không được để trống | "Tên thể loại không được để trống" |
| Thêm/Sửa | Tên thể loại | Tối đa 50 ký tự | "Tên thể loại không được vượt quá 50 ký tự" |
| Thêm/Sửa | Tên thể loại | Phải unique | "Thể loại đã tồn tại" |
| Xóa | Thể loại | Không có sách nào thuộc thể loại | "Không thể xóa. Thể loại đang có sách" |

## Data Model
```json
{
  "id": "string (UUID)",
  "name": "string (max 50, unique)",
  "created_at": "timestamp",
  "updated_at": "timestamp",
  "books_count": "number (computed)"
}
```

## UI Features
- Bảng có thể sửa trực tiếp (inline editing)
- Hiển thị số lượng sách thuộc mỗi thể loại
- Có chức năng tìm kiếm/lọc thể loại
- Sắp xếp theo tên hoặc số lượng sách

## Notes
- Không thể xóa thể loại nếu còn sách thuộc thể loại đó
- Cần xác nhận trước khi xóa để tránh xóa nhầm
- Thể loại "Chưa phân loại" (mặc định) không được xóa

