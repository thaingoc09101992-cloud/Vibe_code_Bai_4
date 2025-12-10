# Feature 2.7.2: Báo Cáo Chi Tiết

## Mô tả
Cung cấp các báo cáo chi tiết về sách, mượn trả, phạt và sách mất/hư. Hỗ trợ lọc theo thời gian và xuất file CSV.

## Actor
Quản lý viên, Nhân viên thư viện

## Yêu cầu
- Đã đăng nhập (Feature 2.1.2)
- Có vai trò Librarian hoặc Admin
- Có dashboard tổng quan (Feature 2.7.1)

## Flowchart

```mermaid
flowchart TD
    Start([Nhân viên/Admin đăng nhập]) --> ClickReports[Click 'Báo cáo chi tiết']
    ClickReports --> ShowReportTypes[Hiển thị 4 loại báo cáo:<br/>1. Báo cáo Sách<br/>2. Báo cáo Mượn Trả<br/>3. Báo cáo Phạt<br/>4. Báo cáo Sách Mất/Hư]
    
    ShowReportTypes --> UserSelectReport{Chọn loại báo cáo}
    
    %% ============ BÁO CÁO SÁCH ============
    UserSelectReport -->|Báo cáo Sách| LoadBookReport[Tải báo cáo sách]
    LoadBookReport --> ShowDateFilter1[Hiển thị bộ lọc thời gian:<br/>- Ngày<br/>- Tuần<br/>- Tháng<br/>- Quý<br/>- Năm<br/>- Tùy chỉnh]
    
    ShowDateFilter1 --> SelectDateRange1[Chọn khoảng thời gian]
    SelectDateRange1 --> LoadBookData[Tải dữ liệu sách từ Database]
    LoadBookData --> DisplayBookReport[Hiển thị báo cáo sách]
    
    DisplayBookReport --> ShowBookStats[Hiển thị thống kê:<br/>- Tổng số đầu sách<br/>- Tổng số bản sách<br/>- Có sẵn<br/>- Đang mượn<br/>- Mất<br/>- Hư hỏng]
    
    ShowBookStats --> ShowBookTable[Hiển thị bảng chi tiết:<br/>- Tên sách<br/>- Tác giả<br/>- Thể loại<br/>- Tổng số bản<br/>- Có sẵn<br/>- Đang mượn<br/>- Số lần mượn<br/>- Tình trạng]
    
    ShowBookTable --> ShowBookCharts[Hiển thị biểu đồ:<br/>1. Phân bố theo thể loại<br/>2. Trạng thái sách<br/>3. Top 10 sách phổ biến]
    
    ShowBookCharts --> BookReportAction{Nhân viên chọn}
    BookReportAction -->|Xuất CSV| ExportBookCSV[Xuất báo cáo sách ra file CSV]
    ExportBookCSV --> DownloadBookFile[Tải file về]
    DownloadBookFile --> BookReportAction
    
    BookReportAction -->|Lọc theo thể loại| FilterBookCategory[Chọn thể loại]
    FilterBookCategory --> LoadBookData
    
    BookReportAction -->|Sắp xếp| SortBook[Chọn cột sắp xếp]
    SortBook --> LoadBookData
    
    BookReportAction -->|Quay lại| ShowReportTypes
    
    %% ============ BÁO CÁO MƯỢN TRẢ ============
    UserSelectReport -->|Báo cáo Mượn Trả| LoadBorrowReport[Tải báo cáo mượn trả]
    LoadBorrowReport --> ShowDateFilter2[Hiển thị bộ lọc thời gian]
    ShowDateFilter2 --> SelectDateRange2[Chọn khoảng thời gian]
    
    SelectDateRange2 --> LoadBorrowData[Tải dữ liệu mượn trả từ Database]
    LoadBorrowData --> DisplayBorrowReport[Hiển thị báo cáo mượn trả]
    
    DisplayBorrowReport --> ShowBorrowStats[Hiển thị thống kê:<br/>- Tổng đơn mượn<br/>- Đơn đã xác nhận<br/>- Đơn bị từ chối<br/>- Đơn đã trả<br/>- Đơn quá hạn<br/>- Tỷ lệ trả đúng hạn]
    
    ShowBorrowStats --> ShowBorrowTable[Hiển thị bảng chi tiết:<br/>- Ngày<br/>- Số đơn mượn<br/>- Số đơn trả<br/>- Số đơn quá hạn<br/>- Độc giả mới]
    
    ShowBorrowTable --> ShowBorrowCharts[Hiển thị biểu đồ:<br/>1. Xu hướng mượn trả theo ngày<br/>2. Phân bố theo thể loại sách<br/>3. Top 10 độc giả mượn nhiều nhất<br/>4. Giờ cao điểm mượn sách]
    
    ShowBorrowCharts --> BorrowReportAction{Nhân viên chọn}
    BorrowReportAction -->|Xuất CSV| ExportBorrowCSV[Xuất báo cáo mượn trả ra CSV]
    ExportBorrowCSV --> DownloadBorrowFile[Tải file về]
    DownloadBorrowFile --> BorrowReportAction
    
    BorrowReportAction -->|Lọc theo trạng thái| FilterBorrowStatus[Chọn trạng thái]
    FilterBorrowStatus --> LoadBorrowData
    
    BorrowReportAction -->|Xem chi tiết ngày| ViewDayDetail[Xem chi tiết các đơn trong ngày]
    ViewDayDetail --> ShowDayModal[Hiển thị modal danh sách đơn]
    ShowDayModal --> BorrowReportAction
    
    BorrowReportAction -->|Quay lại| ShowReportTypes
    
    %% ============ BÁO CÁO PHẠT ============
    UserSelectReport -->|Báo cáo Phạt| LoadFineReport[Tải báo cáo phạt]
    LoadFineReport --> ShowDateFilter3[Hiển thị bộ lọc thời gian]
    ShowDateFilter3 --> SelectDateRange3[Chọn khoảng thời gian]
    
    SelectDateRange3 --> LoadFineData[Tải dữ liệu phạt từ Database]
    LoadFineData --> DisplayFineReport[Hiển thị báo cáo phạt]
    
    DisplayFineReport --> ShowFineStats[Hiển thị thống kê:<br/>- Tổng doanh thu phạt<br/>- Đã thanh toán<br/>- Chưa thanh toán<br/>- Chờ xác nhận<br/>- Số phiếu phạt<br/>- Độc giả có phạt]
    
    ShowFineStats --> ShowFineTable[Hiển thị bảng chi tiết:<br/>- Ngày<br/>- Số phiếu phạt<br/>- Tổng tiền phạt<br/>- Đã thanh toán<br/>- Chưa thanh toán<br/>- Phạt trễ<br/>- Phạt hư hỏng<br/>- Phạt mất]
    
    ShowFineTable --> ShowFineCharts[Hiển thị biểu đồ:<br/>1. Doanh thu phạt theo tháng<br/>2. Phân bố loại phạt<br/>3. Top 10 độc giả bị phạt nhiều<br/>4. Tỷ lệ thanh toán phạt]
    
    ShowFineCharts --> FineReportAction{Nhân viên chọn}
    FineReportAction -->|Xuất CSV| ExportFineCSV[Xuất báo cáo phạt ra CSV]
    ExportFineCSV --> DownloadFineFile[Tải file về]
    DownloadFineFile --> FineReportAction
    
    FineReportAction -->|Lọc theo loại phạt| FilterFineType[Chọn loại phạt]
    FilterFineType --> LoadFineData
    
    FineReportAction -->|Xem danh sách nợ| ViewDebtList[Xem độc giả nợ quá hạn]
    ViewDebtList --> ShowDebtModal[Hiển thị modal danh sách nợ]
    ShowDebtModal --> FineReportAction
    
    FineReportAction -->|Quay lại| ShowReportTypes
    
    %% ============ BÁO CÁO SÁCH MẤT/HƯ ============
    UserSelectReport -->|Báo cáo Sách Mất/Hư| LoadDamageReport[Tải báo cáo sách mất/hư]
    LoadDamageReport --> ShowDateFilter4[Hiển thị bộ lọc thời gian]
    ShowDateFilter4 --> SelectDateRange4[Chọn khoảng thời gian]
    
    SelectDateRange4 --> LoadDamageData[Tải dữ liệu sách mất/hư từ Database]
    LoadDamageData --> DisplayDamageReport[Hiển thị báo cáo sách mất/hư]
    
    DisplayDamageReport --> ShowDamageStats[Hiển thị thống kê:<br/>- Tổng sách mất<br/>- Tổng sách hư hỏng<br/>- Tổng giá trị thiệt hại<br/>- Đã bồi thường<br/>- Chưa bồi thường]
    
    ShowDamageStats --> ShowDamageTable[Hiển thị bảng chi tiết:<br/>- Tên sách<br/>- Độc giả<br/>- Ngày mất/hư<br/>- Tình trạng<br/>- Mức phạt<br/>- Trạng thái thanh toán<br/>- Ghi chú]
    
    ShowDamageTable --> ShowDamageCharts[Hiển thị biểu đồ:<br/>1. Xu hướng mất/hư theo tháng<br/>2. Phân bố theo thể loại<br/>3. Top sách bị mất/hư nhiều<br/>4. Tỷ lệ bồi thường]
    
    ShowDamageCharts --> DamageReportAction{Nhân viên chọn}
    DamageReportAction -->|Xuất CSV| ExportDamageCSV[Xuất báo cáo sách mất/hư ra CSV]
    ExportDamageCSV --> DownloadDamageFile[Tải file về]
    DownloadDamageFile --> DamageReportAction
    
    DamageReportAction -->|Lọc theo tình trạng| FilterDamageCondition[Chọn: Mất / Hư hỏng]
    FilterDamageCondition --> LoadDamageData
    
    DamageReportAction -->|Danh sách cần thay thế| ViewReplaceList[Xem sách cần mua thay thế]
    ViewReplaceList --> ShowReplaceModal[Hiển thị modal danh sách<br/>sách cần thay thế]
    ShowReplaceModal --> DamageReportAction
    
    DamageReportAction -->|Quay lại| ShowReportTypes
    
    ShowReportTypes --> End([Kết thúc])
```

## Display Information

### 1. Báo Cáo Sách
```json
{
  "summary": {
    "total_titles": "number",
    "total_copies": "number",
    "available": "number",
    "borrowed": "number",
    "lost": "number",
    "damaged": "number"
  },
  "by_category": [
    {
      "category": "string",
      "count": "number",
      "percentage": "number"
    }
  ],
  "top_books": [
    {
      "title": "string",
      "borrow_count": "number",
      "rating": "number"
    }
  ]
}
```

### 2. Báo Cáo Mượn Trả
```json
{
  "summary": {
    "total_borrows": "number",
    "confirmed": "number",
    "rejected": "number",
    "returned": "number",
    "overdue": "number",
    "on_time_rate": "number (%)"
  },
  "by_date": [
    {
      "date": "date",
      "borrows": "number",
      "returns": "number",
      "overdue": "number"
    }
  ],
  "top_borrowers": [
    {
      "reader_name": "string",
      "total_borrows": "number"
    }
  ],
  "peak_hours": [
    {
      "hour": "number (0-23)",
      "count": "number"
    }
  ]
}
```

### 3. Báo Cáo Phạt
```json
{
  "summary": {
    "total_revenue": "number (VND)",
    "paid": "number (VND)",
    "unpaid": "number (VND)",
    "pending": "number (VND)",
    "total_fines": "number",
    "readers_with_fines": "number"
  },
  "by_type": {
    "late_return": "number (VND)",
    "damaged": "number (VND)",
    "lost": "number (VND)"
  },
  "by_month": [
    {
      "month": "string (YYYY-MM)",
      "total": "number (VND)",
      "paid": "number (VND)"
    }
  ],
  "top_fined_readers": [
    {
      "reader_name": "string",
      "total_fines": "number (VND)",
      "unpaid": "number (VND)"
    }
  ]
}
```

### 4. Báo Cáo Sách Mất/Hư
```json
{
  "summary": {
    "total_lost": "number",
    "total_damaged": "number",
    "total_value": "number (VND)",
    "compensated": "number (VND)",
    "not_compensated": "number (VND)"
  },
  "items": [
    {
      "book_title": "string",
      "reader_name": "string",
      "date": "date",
      "condition": "Mất | Hư hỏng",
      "fine_amount": "number (VND)",
      "payment_status": "string",
      "note": "string"
    }
  ],
  "by_category": [
    {
      "category": "string",
      "lost_count": "number",
      "damaged_count": "number"
    }
  ],
  "replacement_needed": [
    {
      "book_title": "string",
      "copies_lost": "number",
      "priority": "High | Medium | Low"
    }
  ]
}
```

## Date Range Filters

| Filter | Description |
|--------|-------------|
| Hôm nay | Dữ liệu trong ngày |
| Tuần này | 7 ngày gần nhất |
| Tháng này | Tháng hiện tại |
| Quý này | Quý hiện tại (3 tháng) |
| Năm này | Năm hiện tại |
| Tùy chỉnh | Chọn ngày bắt đầu & kết thúc |

## Export CSV Format

### Book Report CSV
```csv
Tên Sách,Tác Giả,Thể Loại,Tổng Số Bản,Có Sẵn,Đang Mượn,Số Lần Mượn,Tình Trạng
"Lập trình Python","Nguyễn Văn A","Công nghệ",10,7,3,25,"Tốt"
```

### Borrow/Return Report CSV
```csv
Ngày,Số Đơn Mượn,Số Đơn Trả,Số Đơn Quá Hạn,Độc Giả Mới
"2024-01-15",12,8,2,3
```

### Fine Report CSV
```csv
Ngày,Số Phiếu Phạt,Tổng Tiền,Đã Thanh Toán,Chưa Thanh Toán,Phạt Trễ,Phạt Hư Hỏng,Phạt Mất
"2024-01-15",5,250000,150000,100000,100000,50000,100000
```

### Damage Report CSV
```csv
Tên Sách,Độc Giả,Ngày,Tình Trạng,Mức Phạt,Trạng Thái Thanh Toán,Ghi Chú
"Clean Code","Trần Văn B","2024-01-15","Mất",300000,"Đã thanh toán","Mất hoàn toàn"
```

## UI Components

### Report Navigation Tabs
```
[📚 Báo cáo Sách] [📊 Mượn Trả] [💰 Phạt] [⚠️ Mất/Hư]
```

### Date Range Picker
```
┌────────────────────────────────────┐
│ Khoảng thời gian: [Tháng này ▼]  │
│ Từ: [__/__/____]  Đến: [__/__/____] │
│              [Áp dụng]             │
└────────────────────────────────────┘
```

### Export Button
```
[📥 Xuất CSV]
```

## Charts Library
- **Recharts** (React)
- Responsive design
- Interactive tooltips
- Legend
- Color coding

## Performance Optimization
- Pagination cho tables (50 rows/page)
- Lazy load charts
- Cache query results
- Index database cho report queries
- Background job cho export lớn

## Notes
- Tất cả báo cáo hỗ trợ xuất CSV
- Charts có thể zoom & pan
- Click vào data point → Chi tiết
- Responsive design
- Print-friendly layout
- Admin có thể schedule báo cáo tự động qua email (future)
- Có thể save custom report templates (future)
- Integration với Excel/Google Sheets (future)

