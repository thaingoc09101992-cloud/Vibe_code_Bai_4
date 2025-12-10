# Feature 2.5.3: Xem & Xác Nhận Thanh Toán Phạt (Nhân Viên)

## Mô tả
Cho phép nhân viên thư viện xem danh sách phiếu phạt chờ xác nhận thanh toán, kiểm tra giao dịch ngân hàng và xác nhận hoặc từ chối.

## Actor
Nhân viên thư viện, Admin

## Yêu cầu
- Đã đăng nhập (Feature 2.1.2)
- Có vai trò Librarian hoặc Admin
- Độc giả đã đánh dấu thanh toán (Feature 2.5.2)

## Flowchart

```mermaid
flowchart TD
    Start([Nhân viên thư viện đã đăng nhập]) --> AccessFineManagement[Vào trang 'Quản lý phạt']
    AccessFineManagement --> DisplayTabs[Hiển thị 3 tabs:<br/>- Chờ xác nhận thanh toán<br/>- Chưa thanh toán<br/>- Đã thanh toán]
    
    DisplayTabs --> UserSelectTab{Nhân viên chọn tab}
    
    %% ============ TAB: CHỜ XÁC NHẬN THANH TOÁN ============
    UserSelectTab -->|Tab 'Chờ xác nhận'| LoadWaiting[Tải phiếu phạt<br/>Status = 'Chờ xác nhận']
    LoadWaiting --> CheckHasWaiting{Có phiếu nào?}
    CheckHasWaiting -->|Không| ShowNoWaiting[Hiển thị: Không có phiếu chờ xác nhận]
    ShowNoWaiting --> End([Kết thúc])
    
    CheckHasWaiting -->|Có| DisplayWaiting[Hiển thị bảng phiếu phạt chờ xác nhận]
    DisplayWaiting --> ShowWaitingInfo[Hiển thị cho mỗi phiếu:<br/>- Mã phiếu<br/>- Tên độc giả<br/>- Email độc giả<br/>- Tên sách<br/>- Loại phạt<br/>- Số tiền<br/>- Ngày phạt<br/>- Ngày độc giả đánh dấu thanh toán<br/>- Thời gian chờ]
    
    ShowWaitingInfo --> StaffAction{Nhân viên chọn phiếu}
    
    StaffAction -->|Click 'Xác nhận'| ClickConfirm[Click nút 'Xác nhận thanh toán']
    ClickConfirm --> ShowConfirmModal[Hiển thị modal xác nhận]
    
    ShowConfirmModal --> DisplayFineDetail[Hiển thị chi tiết đầy đủ:<br/>- Thông tin độc giả<br/>- Thông tin sách<br/>- Loại phạt & nguyên nhân<br/>- Số tiền<br/>- Ngày phạt<br/>- Ngày độc giả thanh toán<br/>- Nội dung chuyển khoản]
    
    DisplayFineDetail --> ShowBankInfo[Hiển thị thông tin ngân hàng:<br/>- Nội dung cần kiểm tra: FINE-XXXXXX<br/>- Số tiền cần kiểm tra: XXX,XXX VND]
    
    ShowBankInfo --> StaffCheckBank[Nhân viên kiểm tra<br/>giao dịch trong hệ thống ngân hàng]
    StaffCheckBank --> ConfirmChoice{Nhân viên chọn}
    
    ConfirmChoice -->|Hủy| DisplayWaiting
    ConfirmChoice -->|Xác nhận| CheckBankTransaction{Đã nhận được tiền<br/>đúng số tiền?}
    
    CheckBankTransaction -->|Chưa nhận hoặc sai số tiền| StaffReject[Nhân viên chọn 'Từ chối']
    StaffReject --> InputRejectReason[Nhập lý do từ chối<br/>Bắt buộc]
    InputRejectReason --> ValidateReason{Validate lý do}
    
    ValidateReason -->|Lý do trống| ErrorEmptyReason[Hiển thị lỗi: Vui lòng nhập lý do từ chối]
    ErrorEmptyReason --> InputRejectReason
    ValidateReason -->|Lý do < 10 ký tự| ErrorShortReason[Hiển thị lỗi: Lý do ít nhất 10 ký tự]
    ErrorShortReason --> InputRejectReason
    ValidateReason -->|Lý do > 500 ký tự| ErrorLongReason[Hiển thị lỗi: Lý do không quá 500 ký tự]
    ErrorLongReason --> InputRejectReason
    ValidateReason -->|Hợp lệ| UpdateToUnpaid[Cập nhật phiếu phạt<br/>status = 'Chưa thanh toán'<br/>Xóa paid_date]
    
    UpdateToUnpaid --> SaveRejection[Lưu lý do từ chối:<br/>- rejection_reason<br/>- rejected_by = staff_id<br/>- rejected_at = now]
    SaveRejection --> SaveReject[(Lưu vào Database)]
    SaveReject --> NotifyReaderReject[Gửi thông báo cho độc giả:<br/>Phiếu phạt bị từ chối<br/>Lý do: XXX]
    NotifyReaderReject --> ShowSuccessReject[Hiển thị: Từ chối thành công]
    ShowSuccessReject --> RefreshList1[Refresh danh sách]
    RefreshList1 --> DisplayWaiting
    
    CheckBankTransaction -->|Đã nhận đúng| UpdateToPaid[Cập nhật phiếu phạt<br/>status = 'Đã thanh toán']
    UpdateToPaid --> SetConfirmData[Set dữ liệu:<br/>- confirmed_date = now<br/>- confirmed_by = staff_id<br/>- payment_verified = true]
    SetConfirmData --> SaveConfirm[(Lưu vào Database)]
    
    SaveConfirm --> CheckReaderStatus{Kiểm tra trạng thái độc giả}
    CheckReaderStatus --> CheckAllFinesPaid{Tất cả phạt<br/>đã thanh toán?}
    CheckAllFinesPaid -->|Có| UpdateReaderStatus[Cập nhật trạng thái độc giả:<br/>can_borrow = true]
    CheckAllFinesPaid -->|Không, còn phạt khác| SkipUpdateReader[Không cập nhật]
    UpdateReaderStatus --> NotifyReaderConfirm[Gửi thông báo cho độc giả:<br/>Thanh toán phạt thành công<br/>Có thể mượn sách tiếp]
    SkipUpdateReader --> NotifyReaderConfirm
    
    NotifyReaderConfirm --> ShowSuccessConfirm[Hiển thị: Xác nhận thành công]
    ShowSuccessConfirm --> RefreshList2[Refresh danh sách]
    RefreshList2 --> DisplayWaiting
    
    StaffAction -->|Xem chi tiết| ShowDetail[Hiển thị modal chi tiết phiếu phạt]
    ShowDetail --> StaffAction
    
    %% ============ TAB: CHƯA THANH TOÁN ============
    UserSelectTab -->|Tab 'Chưa thanh toán'| LoadUnpaid[Tải phiếu phạt<br/>Status = 'Chưa thanh toán']
    LoadUnpaid --> DisplayUnpaid[Hiển thị bảng phiếu chưa thanh toán]
    
    DisplayUnpaid --> ShowUnpaidInfo[Hiển thị cho mỗi phiếu:<br/>- Mã phiếu<br/>- Tên độc giả<br/>- Tên sách<br/>- Loại phạt<br/>- Số tiền<br/>- Ngày phạt<br/>- Số ngày chưa thanh toán<br/>- Lý do từ chối nếu có]
    
    ShowUnpaidInfo --> UnpaidAction{Nhân viên chọn}
    UnpaidAction -->|Xem chi tiết| ShowUnpaidDetail[Hiển thị chi tiết phiếu]
    ShowUnpaidDetail --> UnpaidAction
    UnpaidAction -->|Liên hệ độc giả| ContactReader[Hiển thị thông tin liên hệ độc giả<br/>Email, SĐT]
    ContactReader --> UnpaidAction
    UnpaidAction -->|Lọc/Tìm kiếm| ApplyFilter[Áp dụng filter]
    ApplyFilter --> DisplayUnpaid
    UnpaidAction -->|Quay lại| DisplayTabs
    
    %% ============ TAB: ĐÃ THANH TOÁN ============
    UserSelectTab -->|Tab 'Đã thanh toán'| LoadPaid[Tải phiếu phạt<br/>Status = 'Đã thanh toán']
    LoadPaid --> DisplayPaid[Hiển thị bảng phiếu đã thanh toán]
    
    DisplayPaid --> ShowPaidInfo[Hiển thị cho mỗi phiếu:<br/>- Mã phiếu<br/>- Tên độc giả<br/>- Tên sách<br/>- Số tiền<br/>- Ngày thanh toán<br/>- Người xác nhận<br/>- Ngày xác nhận]
    
    ShowPaidInfo --> PaidAction{Nhân viên chọn}
    PaidAction -->|Xem chi tiết| ShowPaidDetail[Hiển thị chi tiết<br/>+ lịch sử thanh toán]
    ShowPaidDetail --> PaidAction
    PaidAction -->|In phiếu thu| PrintReceipt[In/Tải PDF phiếu thu]
    PrintReceipt --> PaidAction
    PaidAction -->|Xuất báo cáo| ExportReport[Xuất danh sách ra CSV/Excel]
    ExportReport --> PaidAction
    PaidAction -->|Quay lại| DisplayTabs
    
    DisplayTabs --> End
```

## Business Rules

### Xác Nhận Thanh Toán
1. ✅ Nhân viên phải kiểm tra giao dịch ngân hàng
2. ✅ Nội dung chuyển khoản phải chính xác: `FINE-{ID}`
3. ✅ Số tiền phải đúng với số tiền phạt
4. ✅ Sau khi xác nhận → Độc giả có thể mượn sách (nếu hết phạt)

### Từ Chối Thanh Toán
1. ✅ Phải nhập lý do từ chối (10-500 ký tự)
2. ✅ Phiếu phạt quay về trạng thái "Chưa thanh toán"
3. ✅ Xóa thông tin `paid_date`
4. ✅ Độc giả nhận thông báo kèm lý do

### Lý Do Từ Chối Thường Gặp
- "Chưa nhận được chuyển khoản"
- "Số tiền chuyển khoản không đúng (thiếu XXX VND)"
- "Nội dung chuyển khoản không đúng"
- "Chuyển khoản vào sai tài khoản"

## Validation Rules

### Xác Nhận
| Check | Rule | Action |
|-------|------|--------|
| Phiếu phạt | Status = 'Chờ xác nhận' | Block nếu khác |
| Giao dịch ngân hàng | Đã nhận tiền | Xác nhận bằng mắt/hệ thống |
| Số tiền | Đúng với amount | Cần match |

### Từ Chối
| Field | Rule | Message Error |
|-------|------|---------------|
| Lý do | Không được trống | "Vui lòng nhập lý do từ chối" |
| Lý do | Tối thiểu 10 ký tự | "Lý do phải ít nhất 10 ký tự" |
| Lý do | Tối đa 500 ký tự | "Lý do không được vượt quá 500 ký tự" |

## Data Model - Update on Confirm
```json
{
  "status": "Đã thanh toán",
  "confirmed_date": "timestamp (now)",
  "confirmed_by": "staff_id",
  "payment_verified": true,
  "updated_at": "timestamp"
}
```

## Data Model - Update on Reject
```json
{
  "status": "Chưa thanh toán",
  "paid_date": null,
  "payment_method": null,
  "rejection_reason": "string (10-500 chars)",
  "rejected_by": "staff_id",
  "rejected_at": "timestamp",
  "rejection_count": "number (increment)",
  "updated_at": "timestamp"
}
```

## Display Information

### Tab: Chờ Xác Nhận
```json
{
  "fine_code": "FINE-XXXXXX",
  "reader_name": "string",
  "reader_email": "string",
  "book_title": "string",
  "fine_type": "string",
  "amount": "number",
  "fine_date": "date",
  "paid_date": "date",
  "waiting_hours": "number",
  "transfer_content": "FINE-XXXXXX",
  "status": "Chờ xác nhận"
}
```

### Tab: Chưa Thanh Toán
```json
{
  "fine_code": "FINE-XXXXXX",
  "reader_name": "string",
  "reader_contact": "email, phone",
  "book_title": "string",
  "fine_type": "string",
  "amount": "number",
  "fine_date": "date",
  "unpaid_days": "number",
  "rejection_reason": "string (nullable)",
  "status": "Chưa thanh toán"
}
```

### Tab: Đã Thanh Toán
```json
{
  "fine_code": "FINE-XXXXXX",
  "reader_name": "string",
  "book_title": "string",
  "amount": "number",
  "fine_date": "date",
  "paid_date": "date",
  "confirmed_date": "date",
  "confirmed_by": "staff_name",
  "status": "Đã thanh toán"
}
```

## Bank Verification Display
```
🏦 Thông tin cần kiểm tra

Nội dung CK: FINE-123456
Số tiền: 50,000 VND
Thời gian độc giả đánh dấu: 2024-01-15 10:30

⚠️ Vui lòng kiểm tra trong hệ thống ngân hàng:
1. Tìm giao dịch với nội dung: FINE-123456
2. Kiểm tra số tiền: 50,000 VND
3. Xác nhận thời gian giao dịch gần với thời gian đánh dấu
```

## Notifications

### Khi Xác Nhận Thanh Toán
**Tới độc giả:**
- Tiêu đề: "Đã xác nhận thanh toán phạt"
- Nội dung:
  - Phiếu phạt FINE-XXXXXX đã được xác nhận thanh toán
  - Số tiền: XXX VND
  - Bạn có thể mượn sách tiếp (nếu hết phạt)

### Khi Từ Chối
**Tới độc giả:**
- Tiêu đề: "Thanh toán phạt bị từ chối"
- Nội dung:
  - Phiếu phạt FINE-XXXXXX bị từ chối
  - Lý do: {rejection_reason}
  - Vui lòng kiểm tra và thanh toán lại

## UI Components
- Tabs navigation
- Table với sorting & filtering
- Modal cho confirm/reject/detail
- Bank info display panel
- Action buttons (Confirm/Reject/Detail)
- Badge cho status & fine type
- Search & filter bar
- Export CSV/Excel button
- Print receipt button

## Statistics Display
```
📊 Thống kê nhanh

Chờ xác nhận: 5 phiếu | 250,000 VND
Chưa thanh toán: 12 phiếu | 600,000 VND
Đã thanh toán (tháng này): 45 phiếu | 2,250,000 VND
```

## Notes
- Nhân viên nên kiểm tra giao dịch trong hệ thống ngân hàng
- Có thể tích hợp API ngân hàng để tự động đối soát (future)
- Tab mặc định là "Chờ xác nhận"
- Hiển thị số lượng phiếu ở mỗi tab
- Có thể sort theo: ngày, số tiền, độc giả
- Filter theo: loại phạt, khoảng thời gian, độc giả
- Export CSV/Excel cho báo cáo

