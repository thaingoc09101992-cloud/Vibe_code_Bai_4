# Feature 2.2.2: Thêm Sách Mới

## Mô tả
Cho phép nhân viên thư viện thêm sách mới vào hệ thống.

## Actor
Nhân viên thư viện

## Yêu cầu
- Đã đăng nhập (Feature 2.1.2)
- Có vai trò Librarian hoặc Admin
- Đã có thể loại sách (Feature 2.2.1)

## Flowchart

```mermaid
flowchart TD
    Start([Nhân viên thư viện đã đăng nhập]) --> ClickAddBook[Click 'Thêm Sách Mới']
    ClickAddBook --> LoadCategories[Tải danh sách thể loại từ Database]
    LoadCategories --> ShowForm[Hiển thị form thêm sách]
    
    ShowForm --> InputBookData[Nhập thông tin sách:<br/>- Tên sách<br/>- Tác giả<br/>- Năm xuất bản<br/>- ISBN<br/>- Thể loại<br/>- Mô tả<br/>- Số lượng]
    
    InputBookData --> ClickSubmit[Click 'Thêm sách']
    
    ClickSubmit --> ValidateTitle{Validate Tên sách}
    ValidateTitle -->|Tên trống| ErrorTitle1[Hiển thị lỗi: Tên sách không được trống]
    ErrorTitle1 --> InputBookData
    ValidateTitle -->|Tên > 100 ký tự| ErrorTitle2[Hiển thị lỗi: Tên sách không quá 100 ký tự]
    ErrorTitle2 --> InputBookData
    ValidateTitle -->|Hợp lệ| ValidateAuthor{Validate Tác giả}
    
    ValidateAuthor -->|Tác giả trống| ErrorAuthor1[Hiển thị lỗi: Tác giả không được trống]
    ErrorAuthor1 --> InputBookData
    ValidateAuthor -->|Tác giả > 100 ký tự| ErrorAuthor2[Hiển thị lỗi: Tác giả không quá 100 ký tự]
    ErrorAuthor2 --> InputBookData
    ValidateAuthor -->|Hợp lệ| ValidateYear{Validate Năm xuất bản}
    
    ValidateYear -->|Năm < 1900 hoặc > năm hiện tại| ErrorYear[Hiển thị lỗi: Năm xuất bản không hợp lệ<br/>1900 - năm hiện tại]
    ErrorYear --> InputBookData
    ValidateYear -->|Hợp lệ| ValidateISBN{ISBN có giá trị?}
    
    ValidateISBN -->|Có nhập ISBN| CheckISBNFormat{Validate ISBN format}
    CheckISBNFormat -->|Không đúng ISBN-10/13| ErrorISBN[Hiển thị lỗi: ISBN không đúng định dạng<br/>ISBN-10 hoặc ISBN-13]
    ErrorISBN --> InputBookData
    CheckISBNFormat -->|Đúng format| ValidateCategory{Validate Thể loại}
    ValidateISBN -->|Không nhập ISBN| ValidateCategory
    
    ValidateCategory -->|Chưa chọn thể loại| ErrorCategory[Hiển thị lỗi: Vui lòng chọn thể loại sách]
    ErrorCategory --> InputBookData
    ValidateCategory -->|Đã chọn| ValidateDescription{Validate Mô tả}
    
    ValidateDescription -->|Mô tả trống| ErrorDesc1[Hiển thị lỗi: Mô tả không được trống]
    ErrorDesc1 --> InputBookData
    ValidateDescription -->|Mô tả > 255 ký tự| ErrorDesc2[Hiển thị lỗi: Mô tả không quá 255 ký tự]
    ErrorDesc2 --> InputBookData
    ValidateDescription -->|Hợp lệ| ValidateQuantity{Validate Số lượng}
    
    ValidateQuantity -->|Số lượng <= 0| ErrorQuantity1[Hiển thị lỗi: Số lượng phải lớn hơn 0]
    ErrorQuantity1 --> InputBookData
    ValidateQuantity -->|Không phải số| ErrorQuantity2[Hiển thị lỗi: Số lượng phải là số]
    ErrorQuantity2 --> InputBookData
    ValidateQuantity -->|Hợp lệ| CheckDuplicateISBN{ISBN đã tồn tại?}
    
    CheckDuplicateISBN -->|Đã tồn tại| ErrorDuplicate[Hiển thị lỗi: ISBN đã tồn tại trong hệ thống]
    ErrorDuplicate --> InputBookData
    CheckDuplicateISBN -->|Chưa tồn tại hoặc không có ISBN| CreateBook[Tạo đối tượng sách]
    
    CreateBook --> SetStatus[Set trạng thái = 'Có sẵn']
    SetStatus --> SetAvailableQuantity[Set số lượng có sẵn = số lượng nhập]
    SetAvailableQuantity --> SetBorrowedQuantity[Set số lượng đang mượn = 0]
    SetBorrowedQuantity --> SaveToDB[(Lưu vào Database)]
    
    SaveToDB --> ShowSuccess[Hiển thị thông báo: Thêm sách thành công]
    ShowSuccess --> UserChoice{Nhân viên chọn}
    
    UserChoice -->|Thêm sách khác| ShowForm
    UserChoice -->|Xem chi tiết sách vừa thêm| RedirectDetail[Chuyển đến trang chi tiết sách]
    UserChoice -->|Về danh sách| RedirectList[Chuyển đến danh sách sách]
    
    RedirectDetail --> End([Kết thúc])
    RedirectList --> End
```

## Validation Rules

| Field | Rule | Message Error |
|-------|------|---------------|
| Tên sách | Không được để trống | "Tên sách không được để trống" |
| Tên sách | Tối đa 100 ký tự | "Tên sách không được vượt quá 100 ký tự" |
| Tác giả | Không được để trống | "Tác giả không được để trống" |
| Tác giả | Tối đa 100 ký tự | "Tác giả không được vượt quá 100 ký tự" |
| Năm xuất bản | Từ 1900 đến năm hiện tại | "Năm xuất bản phải từ 1900 đến năm hiện tại" |
| ISBN | Định dạng ISBN-10 hoặc ISBN-13 (nếu có) | "ISBN không đúng định dạng" |
| ISBN | Không được trùng (unique) | "ISBN đã tồn tại trong hệ thống" |
| Thể loại | Phải chọn thể loại | "Vui lòng chọn thể loại sách" |
| Mô tả | Không được để trống | "Mô tả không được để trống" |
| Mô tả | Tối đa 255 ký tự | "Mô tả không được vượt quá 255 ký tự" |
| Số lượng | Phải > 0 | "Số lượng phải lớn hơn 0" |
| Số lượng | Kiểu số nguyên | "Số lượng phải là số" |

## Data Model
```json
{
  "id": "string (UUID)",
  "title": "string (max 100)",
  "author": "string (max 100)",
  "publication_year": "number (1900 - current year)",
  "isbn": "string (ISBN-10 or ISBN-13, nullable, unique)",
  "category_id": "string (foreign key)",
  "description": "string (max 255)",
  "total_quantity": "number (> 0)",
  "available_quantity": "number (= total_quantity initially)",
  "borrowed_quantity": "number (= 0 initially)",
  "status": "Có sẵn",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

## Notes
- ISBN là trường tùy chọn, nhưng nếu nhập thì phải đúng định dạng
- Sách mới thêm có trạng thái mặc định là "Có sẵn"
- Số lượng có sẵn ban đầu bằng tổng số lượng nhập
- Số lượng đang mượn ban đầu = 0
- Hệ thống tự động tính toán số lượng có sẵn khi có mượn/trả

