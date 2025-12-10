# Feature 2.3.1: Mượn Sách (Độc Giả)

## Mô tả
Cho phép độc giả tạo yêu cầu mượn sách. Yêu cầu sẽ ở trạng thái "Chờ xác nhận" cho đến khi nhân viên thư viện xác nhận.

## Actor
Độc giả (đã đăng nhập)

## Yêu cầu
- Đã đăng nhập (Feature 2.1.2)
- Có vai trò Reader
- Đã xem chi tiết sách (Feature 2.2.4)

## Flowchart

```mermaid
flowchart TD
    Start([Độc giả đã đăng nhập xem chi tiết sách]) --> ClickBorrow[Click nút 'Mượn Sách']
    
    ClickBorrow --> CheckConditions[Kiểm tra điều kiện mượn]
    
    CheckConditions --> CheckAvailable{Sách còn sẵn?<br/>available_quantity > 0}
    CheckAvailable -->|Không| ErrorNoBook[Hiển thị lỗi: Sách hiện đã hết<br/>Không thể mượn]
    ErrorNoBook --> End([Kết thúc])
    CheckAvailable -->|Có| CheckBorrowLimit{Số sách đang mượn < 5?}
    
    CheckBorrowLimit -->|Không| ErrorLimit[Hiển thị lỗi:<br/>Bạn đã mượn tối đa 5 cuốn<br/>Vui lòng trả sách trước khi mượn tiếp]
    ErrorLimit --> End
    CheckBorrowLimit -->|Có| CheckUnpaidFines{Có phạt chưa thanh toán?}
    
    CheckUnpaidFines -->|Có| ShowFineAmount[Hiển thị số tiền phạt:<br/>Bạn có X VND chưa thanh toán]
    ShowFineAmount --> ErrorFines[Hiển thị lỗi:<br/>Vui lòng thanh toán phạt<br/>trước khi mượn sách mới]
    ErrorFines --> ShowPaymentLink[Hiển thị link đến trang thanh toán phạt]
    ShowPaymentLink --> End
    CheckUnpaidFines -->|Không| CheckAlreadyBorrowing{Đã có đơn mượn<br/>sách này chưa trả?}
    
    CheckAlreadyBorrowing -->|Có| ErrorAlreadyBorrowing[Hiển thị lỗi:<br/>Bạn đang mượn sách này<br/>Không thể mượn thêm]
    ErrorAlreadyBorrowing --> End
    CheckAlreadyBorrowing -->|Không| ShowBorrowForm[Hiển thị form mượn sách]
    
    ShowBorrowForm --> DisplayBookInfo[Hiển thị thông tin sách:<br/>- Tên sách<br/>- Tác giả<br/>- ISBN<br/>- Ảnh sách]
    DisplayBookInfo --> ShowDurationOptions[Hiển thị tùy chọn thời hạn mượn]
    
    ShowDurationOptions --> DefaultDuration[Thời hạn mặc định: 14 ngày<br/>Có thể chọn: 7, 14, 21, 30 ngày]
    DefaultDuration --> SelectDuration[Độc giả chọn thời hạn mượn]
    SelectDuration --> ShowDueDate[Hiển thị ngày hết hạn dự kiến]
    
    ShowDueDate --> ShowTerms[Hiển thị điều khoản mượn sách:<br/>- Phạt trả muộn: 5.000 VND/ngày<br/>- Bồi thường nếu mất/hư hỏng<br/>- Tối đa gia hạn 1 lần 7 ngày]
    
    ShowTerms --> BorrowAction{Độc giả chọn}
    BorrowAction -->|Hủy| CancelBorrow[Hủy mượn sách]
    CancelBorrow --> RedirectBack[Quay lại trang chi tiết sách]
    RedirectBack --> End
    
    BorrowAction -->|Xác nhận mượn| ValidateDuration{Validate thời hạn}
    ValidateDuration -->|< 7 hoặc > 30 ngày| ErrorDuration[Hiển thị lỗi: Thời hạn từ 7-30 ngày]
    ErrorDuration --> SelectDuration
    ValidateDuration -->|Hợp lệ| CheckAvailableAgain{Kiểm tra lại sách còn sẵn?}
    
    CheckAvailableAgain -->|Không còn| ErrorRaceCondition[Hiển thị lỗi:<br/>Sách vừa hết<br/>Vui lòng thử lại sau]
    ErrorRaceCondition --> End
    CheckAvailableAgain -->|Còn| CreateBorrowRequest[Tạo đơn mượn sách]
    
    CreateBorrowRequest --> SetBorrowData[Thiết lập dữ liệu đơn mượn:<br/>- reader_id<br/>- book_id<br/>- borrow_date = now<br/>- due_date = now + duration<br/>- status = 'Chờ xác nhận']
    
    SetBorrowData --> SaveRequest[(Lưu đơn mượn vào Database)]
    SaveRequest --> SendNotification[Gửi thông báo cho nhân viên thư viện]
    SendNotification --> ShowSuccess[Hiển thị thông báo thành công:<br/>Đơn mượn đã được tạo<br/>Vui lòng chờ nhân viên xác nhận]
    
    ShowSuccess --> ShowNextSteps[Hiển thị hướng dẫn:<br/>1. Đợi nhân viên xác nhận trong 24h<br/>2. Nhận sách tại thư viện<br/>3. Kiểm tra email/thông báo]
    
    ShowNextSteps --> UserChoice{Độc giả chọn}
    UserChoice -->|Xem lịch sử mượn| RedirectHistory[Chuyển đến trang<br/>Lịch sử mượn sách]
    UserChoice -->|Tiếp tục duyệt sách| RedirectBookList[Chuyển đến danh sách sách]
    UserChoice -->|Về trang chủ| RedirectHome[Chuyển về trang chủ]
    
    RedirectHistory --> End
    RedirectBookList --> End
    RedirectHome --> End
```

## Business Rules

### Điều Kiện Mượn Sách
1. ✅ **Sách còn sẵn:** `available_quantity > 0`
2. ✅ **Giới hạn mượn:** Độc giả không vượt quá 5 cuốn đang mượn cùng lúc
3. ✅ **Không có phạt:** Không có khoản phạt chưa thanh toán
4. ✅ **Không trùng sách:** Chưa có đơn mượn sách này ở trạng thái "Chờ xác nhận" hoặc "Đang mượn"

### Thời Hạn Mượn
- **Mặc định:** 14 ngày
- **Tối thiểu:** 7 ngày
- **Tối đa:** 30 ngày
- **Gia hạn:** Tối đa 1 lần, mỗi lần +7 ngày

### Phạt
- **Trả muộn:** 5.000 VND/ngày
- **Hư hỏng:** Theo mức phạt do admin cấu hình
- **Mất sách:** Theo mức phạt do admin cấu hình

## Validation Rules

| Field | Rule | Message Error |
|-------|------|---------------|
| Sách | available_quantity > 0 | "Sách hiện đã hết. Không thể mượn" |
| Độc giả | Số sách đang mượn < 5 | "Bạn đã mượn tối đa 5 cuốn. Vui lòng trả sách trước" |
| Độc giả | Không có phạt chưa thanh toán | "Vui lòng thanh toán phạt trước khi mượn sách mới" |
| Độc giả | Chưa mượn sách này | "Bạn đang mượn sách này. Không thể mượn thêm" |
| Thời hạn | 7 <= duration <= 30 | "Thời hạn mượn từ 7 đến 30 ngày" |

## Data Model - Borrow Request
```json
{
  "id": "string (UUID)",
  "reader_id": "string (foreign key)",
  "book_id": "string (foreign key)",
  "borrow_date": "timestamp (now)",
  "due_date": "timestamp (borrow_date + duration days)",
  "return_date": "timestamp (nullable)",
  "duration_days": "number (7-30)",
  "status": "Chờ xác nhận",
  "extended": "boolean (false)",
  "rejection_reason": "string (nullable)",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

## Status Flow
```
Chờ xác nhận → Đã mượn (confirmed by staff)
Chờ xác nhận → Bị từ chối (rejected by staff)
Đã mượn → Quá hạn (auto when due_date passed)
Đã mượn → Đã trả (when returned)
```

## Notifications
- **Tới độc giả:**
  - Đơn mượn đã được tạo
  - Đơn được xác nhận/từ chối
  - Sắp đến hạn trả (2 ngày trước)
  - Quá hạn
  
- **Tới nhân viên:**
  - Có đơn mượn mới chờ xác nhận

## UI Components
- Book info card
- Duration selector (dropdown or buttons)
- Due date calculator (real-time)
- Terms & conditions checkbox
- Confirm/Cancel buttons
- Success modal with next steps

## Notes
- Đơn mượn tạo với trạng thái "Chờ xác nhận"
- Nhân viên có 24h để xác nhận đơn
- Độc giả cần đến thư viện để nhận sách vật lý sau khi được xác nhận
- Có thể thêm tính năng đặt lịch nhận sách (future enhancement)

