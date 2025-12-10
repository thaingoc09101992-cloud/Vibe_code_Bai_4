# Feature 2.3.2: Mượn Sách (Nhân Viên Thư Viện)

## Mô tả
Cho phép nhân viên thư viện xem danh sách đơn mượn chờ xác nhận và xác nhận hoặc từ chối đơn mượn.

## Actor
Nhân viên thư viện, Admin

## Yêu cầu
- Đã đăng nhập (Feature 2.1.2)
- Có vai trò Librarian hoặc Admin
- Độc giả đã tạo đơn mượn (Feature 2.3.1)

## Flowchart

```mermaid
flowchart TD
    Start([Nhân viên thư viện đã đăng nhập]) --> AccessBorrowManagement[Vào trang 'Quản lý mượn trả']
    AccessBorrowManagement --> LoadPendingRequests[Tải danh sách đơn mượn<br/>trạng thái 'Chờ xác nhận']
    
    LoadPendingRequests --> CheckHasRequests{Có đơn mượn nào?}
    CheckHasRequests -->|Không| ShowNoRequests[Hiển thị: Không có đơn mượn chờ xác nhận]
    ShowNoRequests --> End([Kết thúc])
    
    CheckHasRequests -->|Có| DisplayRequests[Hiển thị bảng đơn mượn<br/>Sắp xếp: Mới nhất trên cùng]
    
    DisplayRequests --> ShowRequestInfo[Hiển thị cho mỗi đơn:<br/>- Tên độc giả<br/>- Email độc giả<br/>- Tên sách<br/>- Ngày tạo đơn<br/>- Ngày hết hạn dự kiến<br/>- Thời hạn mượn<br/>- Trạng thái]
    
    ShowRequestInfo --> StaffAction{Nhân viên chọn đơn}
    
    %% ============ LUỒNG XÁC NHẬN ============
    StaffAction -->|Click 'Xác nhận'| ClickConfirm[Click nút 'Xác nhận' trên đơn]
    ClickConfirm --> ShowConfirmModal[Hiển thị modal xác nhận]
    
    ShowConfirmModal --> DisplayConfirmInfo[Hiển thị thông tin:<br/>- Thông tin độc giả<br/>- Thông tin sách<br/>- Ngày mượn<br/>- Ngày hết hạn]
    
    DisplayConfirmInfo --> CheckReaderStatus{Kiểm tra trạng thái độc giả}
    CheckReaderStatus -->|Tài khoản bị vô hiệu| ErrorDisabledAccount[Hiển thị lỗi:<br/>Tài khoản độc giả đã bị vô hiệu hóa<br/>Không thể xác nhận]
    ErrorDisabledAccount --> StaffAction
    CheckReaderStatus -->|Tài khoản hoạt động| CheckBookAvailable{Kiểm tra sách còn sẵn?}
    
    CheckBookAvailable -->|Không còn| ErrorNoBook[Hiển thị lỗi:<br/>Sách đã hết<br/>Không thể xác nhận]
    ErrorNoBook --> StaffAction
    CheckBookAvailable -->|Còn sẵn| CheckReaderLimit{Độc giả đã mượn < 5 cuốn?}
    
    CheckReaderLimit -->|Không, đã đủ 5| ErrorReaderLimit[Hiển thị lỗi:<br/>Độc giả đã mượn đủ 5 cuốn<br/>Không thể xác nhận thêm]
    ErrorReaderLimit --> StaffAction
    CheckReaderLimit -->|Có, chưa đủ| CheckReaderFines{Độc giả có phạt chưa thanh toán?}
    
    CheckReaderFines -->|Có| ErrorReaderFines[Hiển thị cảnh báo:<br/>Độc giả có khoản phạt: X VND<br/>Vẫn muốn xác nhận?]
    ErrorReaderFines --> ConfirmWithFines{Nhân viên chọn}
    ConfirmWithFines -->|Hủy| StaffAction
    ConfirmWithFines -->|Vẫn xác nhận| ProceedConfirm
    CheckReaderFines -->|Không| ProceedConfirm[Tiếp tục xác nhận]
    
    ProceedConfirm --> ConfirmChoice{Nhân viên xác nhận cuối cùng}
    ConfirmChoice -->|Hủy| StaffAction
    ConfirmChoice -->|Xác nhận| UpdateRequestStatus[Cập nhật trạng thái đơn = 'Đã mượn']
    
    UpdateRequestStatus --> UpdateBookQuantity[Giảm số lượng sách có sẵn:<br/>available_quantity -= 1<br/>borrowed_quantity += 1]
    UpdateBookQuantity --> IncrementBorrowCount[Tăng số lần mượn sách:<br/>borrow_count += 1]
    IncrementBorrowCount --> SaveConfirm[(Lưu vào Database)]
    
    SaveConfirm --> NotifyReader1[Gửi thông báo cho độc giả:<br/>'Đơn mượn đã được xác nhận'<br/>Hướng dẫn đến thư viện nhận sách]
    NotifyReader1 --> ShowSuccessConfirm[Hiển thị: Xác nhận thành công]
    ShowSuccessConfirm --> RefreshList1[Refresh danh sách đơn mượn]
    RefreshList1 --> DisplayRequests
    
    %% ============ LUỒNG TỪ CHỐI ============
    StaffAction -->|Click 'Từ chối'| ClickReject[Click nút 'Từ chối' trên đơn]
    ClickReject --> ShowRejectModal[Hiển thị modal từ chối]
    
    ShowRejectModal --> DisplayRejectInfo[Hiển thị thông tin đơn mượn]
    DisplayRejectInfo --> InputRejectReason[Nhập lý do từ chối<br/>Bắt buộc]
    InputRejectReason --> RejectChoice{Nhân viên chọn}
    
    RejectChoice -->|Hủy| StaffAction
    RejectChoice -->|Xác nhận từ chối| ValidateReason{Validate lý do}
    ValidateReason -->|Lý do trống| ErrorEmptyReason[Hiển thị lỗi:<br/>Vui lòng nhập lý do từ chối]
    ErrorEmptyReason --> InputRejectReason
    ValidateReason -->|Lý do < 10 ký tự| ErrorShortReason[Hiển thị lỗi:<br/>Lý do phải ít nhất 10 ký tự]
    ErrorShortReason --> InputRejectReason
    ValidateReason -->|Lý do > 500 ký tự| ErrorLongReason[Hiển thị lỗi:<br/>Lý do không quá 500 ký tự]
    ErrorLongReason --> InputRejectReason
    ValidateReason -->|Hợp lệ| UpdateRejectStatus[Cập nhật trạng thái đơn = 'Bị từ chối']
    
    UpdateRejectStatus --> SaveRejection[Lưu lý do từ chối:<br/>rejection_reason = reason<br/>rejected_by = staff_id<br/>rejected_at = now]
    SaveRejection --> SaveReject[(Lưu vào Database)]
    
    SaveReject --> NotifyReader2[Gửi thông báo cho độc giả:<br/>'Đơn mượn bị từ chối'<br/>Kèm lý do từ chối]
    NotifyReader2 --> ShowSuccessReject[Hiển thị: Từ chối thành công]
    ShowSuccessReject --> RefreshList2[Refresh danh sách đơn mượn]
    RefreshList2 --> DisplayRequests
    
    %% ============ LUỒNG XEM CHI TIẾT ============
    StaffAction -->|Click vào đơn để xem chi tiết| ShowDetail[Hiển thị modal chi tiết đơn mượn]
    ShowDetail --> ShowDetailInfo[Hiển thị:<br/>- Thông tin độc giả đầy đủ<br/>- Thông tin sách đầy đủ<br/>- Lịch sử mượn của độc giả<br/>- Số sách độc giả đang mượn<br/>- Khoản phạt nếu có]
    ShowDetailInfo --> StaffAction
    
    %% ============ LUỒNG LỌC & TÌM KIẾM ============
    StaffAction -->|Lọc/Tìm kiếm| FilterOptions{Chọn bộ lọc}
    FilterOptions -->|Tìm theo độc giả| SearchReader[Nhập tên/email độc giả]
    FilterOptions -->|Tìm theo sách| SearchBook[Nhập tên sách]
    FilterOptions -->|Lọc theo ngày| FilterDate[Chọn khoảng thời gian]
    
    SearchReader --> ApplyFilter[Áp dụng filter]
    SearchBook --> ApplyFilter
    FilterDate --> ApplyFilter
    ApplyFilter --> DisplayRequests
    
    StaffAction -->|Refresh| LoadPendingRequests
    StaffAction -->|Thoát| End
```

## Business Rules

### Điều Kiện Xác Nhận
1. ✅ Tài khoản độc giả không bị vô hiệu hóa
2. ✅ Sách còn sẵn (`available_quantity > 0`)
3. ✅ Độc giả chưa mượn quá 5 cuốn
4. ⚠️ Độc giả có phạt chưa thanh toán → Cảnh báo nhưng vẫn có thể xác nhận

### Điều Kiện Từ Chối
1. ✅ Bắt buộc nhập lý do từ chối
2. ✅ Lý do: 10-500 ký tự

## Validation Rules

### Xác Nhận
| Check | Rule | Action |
|-------|------|--------|
| Tài khoản độc giả | Không bị vô hiệu hóa | Block nếu bị vô hiệu |
| Sách có sẵn | available_quantity > 0 | Block nếu hết sách |
| Giới hạn mượn | Số sách đang mượn < 5 | Block nếu đã đủ 5 |
| Phạt chưa thanh toán | Kiểm tra unpaid fines | Cảnh báo, cho phép xác nhận |

### Từ Chối
| Field | Rule | Message Error |
|-------|------|---------------|
| Lý do | Không được để trống | "Vui lòng nhập lý do từ chối" |
| Lý do | Tối thiểu 10 ký tự | "Lý do phải ít nhất 10 ký tự" |
| Lý do | Tối đa 500 ký tự | "Lý do không được vượt quá 500 ký tự" |

## Data Model - Update on Confirm
```json
{
  "status": "Đã mượn",
  "confirmed_by": "staff_id",
  "confirmed_at": "timestamp",
  "actual_borrow_date": "timestamp",
  "updated_at": "timestamp"
}
```

## Data Model - Update on Reject
```json
{
  "status": "Bị từ chối",
  "rejection_reason": "string (10-500 chars)",
  "rejected_by": "staff_id",
  "rejected_at": "timestamp",
  "updated_at": "timestamp"
}
```

## Display Information

Mỗi đơn mượn hiển thị:

| Field | Description |
|-------|-------------|
| ID | Mã đơn mượn |
| Độc giả | Tên + Email |
| Sách | Tên sách |
| Ngày tạo đơn | Thời gian gửi yêu cầu |
| Ngày hết hạn dự kiến | Due date |
| Thời hạn | Số ngày mượn |
| Trạng thái | Badge: Chờ xác nhận |
| Actions | Nút Xác nhận / Từ chối / Xem chi tiết |

## Notifications

### Khi Xác Nhận
**Tới độc giả:**
- Tiêu đề: "Đơn mượn được xác nhận"
- Nội dung: Chi tiết đơn + hướng dẫn nhận sách
- Email + In-app notification

### Khi Từ Chối
**Tới độc giả:**
- Tiêu đề: "Đơn mượn bị từ chối"
- Nội dung: Lý do từ chối + hướng dẫn liên hệ
- Email + In-app notification

## UI Components
- Table/List view với sorting
- Search & Filter bar
- Badge cho status
- Action buttons (Confirm/Reject/Detail)
- Modal cho confirm/reject/detail
- Pagination (if needed)
- Real-time update (optional: WebSocket)

## Notes
- Đơn mượn sau khi xác nhận sẽ chuyển sang trạng thái "Đang mượn"
- Số lượng sách được cập nhật ngay lập tức
- Độc giả nhận thông báo qua email và trong app
- Có thể in phiếu mượn sách để giao cho độc giả
- Nhân viên nên kiểm tra sách vật lý trước khi xác nhận

