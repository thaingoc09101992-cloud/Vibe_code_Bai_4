# Feature 2.2.4: Xem Chi Tiết Sách

## Mô tả
Cho phép tất cả người dùng xem thông tin chi tiết của một cuốn sách. Độc giả có thể mượn sách từ trang này.

## Actor
Tất cả người dùng (không cần đăng nhập để xem, cần đăng nhập để mượn)

## Yêu cầu
- Đã có danh sách sách (Feature 2.2.3)

## Flowchart

```mermaid
flowchart TD
    Start([Người dùng click vào sách từ danh sách]) --> GetBookId[Lấy ID của sách]
    GetBookId --> LoadBookDetails[Tải chi tiết sách từ Database]
    LoadBookDetails --> LoadBorrowHistory[Tải lịch sử mượn sách]
    
    LoadBorrowHistory --> CheckUserRole{Kiểm tra vai trò người dùng}
    
    CheckUserRole -->|Chưa đăng nhập| DisplayBasicInfo[Hiển thị thông tin cơ bản]
    CheckUserRole -->|Reader đã đăng nhập| DisplayInfoWithBorrow[Hiển thị thông tin + Nút 'Mượn sách']
    CheckUserRole -->|Librarian/Admin| DisplayFullInfo[Hiển thị thông tin đầy đủ<br/>+ Lịch sử mượn chi tiết<br/>+ Nút Sửa/Xóa]
    
    DisplayBasicInfo --> ShowBasic[Hiển thị:<br/>- Hình ảnh sách<br/>- Tên sách<br/>- Tác giả<br/>- ISBN<br/>- Năm xuất bản<br/>- Thể loại<br/>- Mô tả chi tiết<br/>- Số lượng có sẵn<br/>- Số lượng đang mượn]
    
    DisplayInfoWithBorrow --> ShowReaderView[Hiển thị thông tin cơ bản<br/>+ Nút 'Mượn sách']
    
    DisplayFullInfo --> ShowStaffView[Hiển thị thông tin đầy đủ<br/>+ Lịch sử mượn:<br/>  * Tên độc giả<br/>  * Ngày mượn<br/>  * Ngày hết hạn<br/>  * Trạng thái<br/>+ Nút Sửa/Xóa]
    
    ShowBasic --> UserAction{Người dùng thao tác}
    ShowReaderView --> UserAction
    ShowStaffView --> UserAction
    
    %% Luồng Mượn Sách (Reader)
    UserAction -->|Click 'Mượn sách'| CheckLoggedIn{Đã đăng nhập?}
    CheckLoggedIn -->|Chưa| RedirectLogin[Chuyển đến trang đăng nhập]
    RedirectLogin --> AfterLogin[Sau khi đăng nhập<br/>Quay lại trang này]
    AfterLogin --> CheckConditions
    CheckLoggedIn -->|Rồi| CheckConditions{Kiểm tra điều kiện mượn}
    
    CheckConditions --> CheckAvailable{Sách còn sẵn?}
    CheckAvailable -->|Không| ErrorNoBook[Hiển thị lỗi: Sách hiện đã hết<br/>Không thể mượn]
    ErrorNoBook --> UserAction
    CheckAvailable -->|Có| CheckBorrowLimit{Đã mượn < 5 cuốn?}
    
    CheckBorrowLimit -->|Không, đã mượn đủ 5| ErrorLimit[Hiển thị lỗi: Bạn đã mượn tối đa 5 cuốn<br/>Vui lòng trả sách trước khi mượn tiếp]
    ErrorLimit --> UserAction
    CheckBorrowLimit -->|Có, chưa đủ 5| CheckFines{Có phạt chưa thanh toán?}
    
    CheckFines -->|Có| ErrorFines[Hiển thị lỗi: Bạn có khoản phạt chưa thanh toán<br/>Vui lòng thanh toán trước khi mượn sách]
    ErrorFines --> UserAction
    CheckFines -->|Không| RedirectBorrow[Chuyển đến trang Mượn sách<br/>Feature 2.3.1]
    RedirectBorrow --> End([Kết thúc])
    
    %% Luồng Sửa Sách (Staff)
    UserAction -->|Click 'Sửa'| CheckStaffPermission1{Là Librarian/Admin?}
    CheckStaffPermission1 -->|Không| ErrorPermission1[Hiển thị lỗi: Không có quyền]
    ErrorPermission1 --> UserAction
    CheckStaffPermission1 -->|Có| RedirectEdit[Chuyển đến trang Sửa sách<br/>Feature 2.2.5]
    RedirectEdit --> End
    
    %% Luồng Xóa Sách (Staff)
    UserAction -->|Click 'Xóa'| CheckStaffPermission2{Là Librarian/Admin?}
    CheckStaffPermission2 -->|Không| ErrorPermission2[Hiển thị lỗi: Không có quyền]
    ErrorPermission2 --> UserAction
    CheckStaffPermission2 -->|Có| CheckActiveBorrows{Có đơn mượn hoạt động?}
    
    CheckActiveBorrows -->|Có| ErrorActiveBorrow[Hiển thị lỗi: Không thể xóa<br/>Sách đang có đơn mượn hoạt động]
    ErrorActiveBorrow --> UserAction
    CheckActiveBorrows -->|Không| ShowConfirmDelete[Hiển thị modal xác nhận xóa]
    
    ShowConfirmDelete --> DeleteChoice{Người dùng chọn}
    DeleteChoice -->|Hủy| UserAction
    DeleteChoice -->|Xác nhận xóa| DeleteBook[(Xóa sách khỏi Database)]
    DeleteBook --> ShowDeleteSuccess[Hiển thị: Xóa sách thành công]
    ShowDeleteSuccess --> RedirectList[Chuyển về danh sách sách]
    RedirectList --> End
    
    %% Luồng Quay Lại
    UserAction -->|Quay lại danh sách| RedirectBack[Quay lại trang danh sách sách<br/>Feature 2.2.3]
    RedirectBack --> End
    
    UserAction -->|Thoát| End
```

## Display Information

### Thông Tin Cơ Bản (Tất cả người dùng)
```json
{
  "book_image": "URL to image",
  "title": "string",
  "author": "string",
  "isbn": "string",
  "publication_year": "number",
  "category": "string",
  "description": "string (full)",
  "total_quantity": "number",
  "available_quantity": "number",
  "borrowed_quantity": "number",
  "borrow_count": "number (total times borrowed)",
  "status": "Có sẵn | Hết sách"
}
```

### Thông Tin Bổ Sung (Librarian/Admin)
```json
{
  "borrow_history": [
    {
      "reader_name": "string",
      "reader_email": "string",
      "borrow_date": "date",
      "due_date": "date",
      "return_date": "date (nullable)",
      "status": "Chờ xác nhận | Đang mượn | Quá hạn | Đã trả | Bị từ chối"
    }
  ]
}
```

## User Actions by Role

### Chưa Đăng Nhập
- Xem thông tin cơ bản
- Quay lại danh sách

### Reader (Đã Đăng Nhập)
- Xem thông tin cơ bản
- Click "Mượn sách" (nếu đủ điều kiện)
- Quay lại danh sách

### Librarian/Admin
- Xem thông tin đầy đủ + lịch sử
- Sửa thông tin sách
- Xóa sách (nếu không có đơn mượn)
- Quay lại danh sách

## Business Rules

### Điều Kiện Mượn Sách
1. ✅ Sách phải còn sẵn (available_quantity > 0)
2. ✅ Độc giả chưa mượn quá 5 cuốn
3. ✅ Độc giả không có khoản phạt chưa thanh toán

### Điều Kiện Xóa Sách
1. ✅ Không có đơn mượn ở trạng thái: "Chờ xác nhận", "Đang mượn", "Quá hạn"
2. ✅ Chỉ Librarian/Admin mới có quyền

## UI Components
- Book detail card với responsive layout
- Image gallery (nếu có nhiều ảnh)
- Availability badge (Có sẵn/Hết sách)
- Borrow button (conditional rendering)
- Edit/Delete buttons (staff only)
- Borrow history table (staff only)
- Breadcrumb navigation
- Related books recommendation (optional)

## Notes
- Nếu user chưa đăng nhập mà click "Mượn sách", redirect đến trang login và sau đó quay lại trang chi tiết
- Lịch sử mượn chỉ hiển thị cho nhân viên thư viện và admin
- Badge "Có sẵn" / "Hết sách" được cập nhật real-time
- Có thể thêm tính năng "Đặt trước" nếu sách hết (future enhancement)

