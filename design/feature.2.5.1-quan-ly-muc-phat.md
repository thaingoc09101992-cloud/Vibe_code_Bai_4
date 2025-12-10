# Feature 2.5.1: Quản Lý Mức Phạt

## Mô tả
Cho phép quản lý viên cấu hình các mức phạt cho hư hỏng sách và mất sách. Nhân viên thư viện sẽ chọn từ các mức phạt này khi xác nhận trả sách.

## Actor
Quản lý viên (Admin)

## Yêu cầu
- Đã đăng nhập (Feature 2.1.2)
- Có vai trò Admin

## Flowchart

```mermaid
flowchart TD
    Start([Admin đã đăng nhập]) --> ClickManageFines[Click 'Quản lý mức phạt']
    ClickManageFines --> LoadFineLevels[Tải danh sách mức phạt từ Database]
    
    LoadFineLevels --> DisplayTable[Hiển thị bảng mức phạt<br/>Có thể sửa trực tiếp trên bảng]
    DisplayTable --> ShowColumns[Hiển thị các cột:<br/>- Tên mức phạt<br/>- Loại phạt<br/>- Số tiền VND<br/>- Ngày tạo<br/>- Actions]
    
    ShowColumns --> AdminAction{Admin chọn}
    
    %% ============ LUỒNG THÊM MỨC PHẠT ============
    AdminAction -->|Thêm mức phạt| ClickAdd[Click 'Thêm mức phạt']
    ClickAdd --> ShowAddModal[Hiển thị modal thêm mức phạt]
    
    ShowAddModal --> InputFineData[Nhập thông tin:<br/>- Tên mức phạt<br/>- Loại phạt dropdown<br/>- Số tiền VND]
    InputFineData --> ClickSaveAdd[Click 'Lưu']
    
    ClickSaveAdd --> ValidateNameAdd{Validate Tên}
    ValidateNameAdd -->|Tên trống| ErrorNameEmptyAdd[Hiển thị lỗi: Tên mức phạt không được trống]
    ErrorNameEmptyAdd --> InputFineData
    ValidateNameAdd -->|Tên > 25 ký tự| ErrorNameLengthAdd[Hiển thị lỗi: Tên không quá 25 ký tự]
    ErrorNameLengthAdd --> InputFineData
    ValidateNameAdd -->|Hợp lệ| ValidateTypeAdd{Validate Loại phạt}
    
    ValidateTypeAdd -->|Chưa chọn| ErrorTypeAdd[Hiển thị lỗi: Vui lòng chọn loại phạt]
    ErrorTypeAdd --> InputFineData
    ValidateTypeAdd -->|Đã chọn| ValidateAmountAdd{Validate Số tiền}
    
    ValidateAmountAdd -->|Số tiền <= 0| ErrorAmountAdd1[Hiển thị lỗi: Số tiền phải lớn hơn 0]
    ErrorAmountAdd1 --> InputFineData
    ValidateAmountAdd -->|Không phải số| ErrorAmountAdd2[Hiển thị lỗi: Số tiền phải là số]
    ErrorAmountAdd2 --> InputFineData
    ValidateAmountAdd -->|Hợp lệ| CheckDuplicateAdd{Tên đã tồn tại<br/>trong loại phạt này?}
    
    CheckDuplicateAdd -->|Đã tồn tại| ErrorDuplicateAdd[Hiển thị lỗi: Tên mức phạt đã tồn tại]
    ErrorDuplicateAdd --> InputFineData
    CheckDuplicateAdd -->|Chưa tồn tại| CreateFineLevel[Tạo mức phạt mới]
    
    CreateFineLevel --> SetFineData[Set dữ liệu:<br/>- name<br/>- type<br/>- amount<br/>- created_by = admin_id<br/>- created_at = now]
    SetFineData --> SaveNewFine[(Lưu vào Database)]
    SaveNewFine --> ShowSuccessAdd[Hiển thị: Thêm mức phạt thành công]
    ShowSuccessAdd --> RefreshTable1[Refresh bảng]
    RefreshTable1 --> DisplayTable
    
    %% ============ LUỒNG SỬA MỨC PHẠT ============
    AdminAction -->|Sửa mức phạt| ClickEdit[Click vào ô cần sửa trên bảng<br/>hoặc nút 'Sửa']
    ClickEdit --> EnableEditMode[Cho phép chỉnh sửa]
    EnableEditMode --> EditFineData[Chỉnh sửa:<br/>- Tên mức phạt<br/>- Loại phạt<br/>- Số tiền]
    
    EditFineData --> ClickSaveEdit[Blur hoặc Enter để lưu]
    ClickSaveEdit --> ValidateNameEdit{Validate Tên}
    
    ValidateNameEdit -->|Tên trống| ErrorNameEmptyEdit[Hiển thị lỗi: Tên không được trống]
    ErrorNameEmptyEdit --> EditFineData
    ValidateNameEdit -->|Tên > 25 ký tự| ErrorNameLengthEdit[Hiển thị lỗi: Tên không quá 25 ký tự]
    ErrorNameLengthEdit --> EditFineData
    ValidateNameEdit -->|Hợp lệ| ValidateTypeEdit{Validate Loại}
    
    ValidateTypeEdit -->|Chưa chọn| ErrorTypeEdit[Hiển thị lỗi: Phải chọn loại phạt]
    ErrorTypeEdit --> EditFineData
    ValidateTypeEdit -->|Đã chọn| ValidateAmountEdit{Validate Số tiền}
    
    ValidateAmountEdit -->|<= 0 hoặc không phải số| ErrorAmountEdit[Hiển thị lỗi: Số tiền không hợp lệ]
    ErrorAmountEdit --> EditFineData
    ValidateAmountEdit -->|Hợp lệ| CheckDuplicateEdit{Tên trùng với mức khác<br/>trong cùng loại?}
    
    CheckDuplicateEdit -->|Trùng| ErrorDuplicateEdit[Hiển thị lỗi: Tên mức phạt đã tồn tại]
    ErrorDuplicateEdit --> EditFineData
    CheckDuplicateEdit -->|Không trùng| UpdateFineLevel[Cập nhật mức phạt]
    
    UpdateFineLevel --> SetUpdateData[Set dữ liệu:<br/>- updated_by = admin_id<br/>- updated_at = now]
    SetUpdateData --> SaveUpdate[(Cập nhật Database)]
    SaveUpdate --> ShowSuccessEdit[Hiển thị: Cập nhật thành công]
    ShowSuccessEdit --> RefreshTable2[Refresh bảng]
    RefreshTable2 --> DisplayTable
    
    %% ============ LUỒNG XÓA MỨC PHẠT ============
    AdminAction -->|Xóa mức phạt| ClickDelete[Click nút 'Xóa']
    ClickDelete --> CheckInUse{Mức phạt đang được sử dụng<br/>trong phiếu phạt nào?}
    
    CheckInUse -->|Có| ErrorInUse[Hiển thị lỗi:<br/>Không thể xóa<br/>Mức phạt đang được sử dụng<br/>trong X phiếu phạt]
    ErrorInUse --> DisplayTable
    CheckInUse -->|Không| ShowDeleteConfirm[Hiển thị modal xác nhận xóa<br/>Cảnh báo: Không thể hoàn tác]
    
    ShowDeleteConfirm --> DeleteChoice{Admin chọn}
    DeleteChoice -->|Hủy| DisplayTable
    DeleteChoice -->|Xác nhận xóa| DeleteFineLevel[Xóa mức phạt]
    
    DeleteFineLevel --> SaveDelete[(Xóa khỏi Database)]
    SaveDelete --> ShowSuccessDelete[Hiển thị: Xóa thành công]
    ShowSuccessDelete --> RefreshTable3[Refresh bảng]
    RefreshTable3 --> DisplayTable
    
    %% ============ LUỒNG LỌC & TÌM KIẾM ============
    AdminAction -->|Lọc theo loại| SelectFilterType{Chọn loại phạt}
    SelectFilterType -->|Tất cả| FilterAll[Hiển thị tất cả]
    SelectFilterType -->|Hư hỏng| FilterDamage[Hiển thị mức phạt hư hỏng]
    SelectFilterType -->|Mất| FilterLost[Hiển thị mức phạt mất]
    
    FilterAll --> ApplyFilter[Áp dụng filter]
    FilterDamage --> ApplyFilter
    FilterLost --> ApplyFilter
    ApplyFilter --> DisplayTable
    
    AdminAction -->|Tìm kiếm| InputSearch[Nhập từ khóa tìm kiếm tên mức phạt]
    InputSearch --> SearchFines[Tìm kiếm trong Database]
    SearchFines --> DisplayTable
    
    AdminAction -->|Thoát| End([Kết thúc])
```

## Business Rules

### Loại Phạt
- **Hư hỏng:** Cho sách bị hỏng (rách, mất trang, bẩn,...)
- **Mất:** Cho sách bị mất hoàn toàn

### Mức Phạt Mặc Định (Gợi ý)
| Tên | Loại | Số Tiền |
|-----|------|---------|
| Hư hỏng nhẹ | Hư hỏng | 50,000 VND |
| Hư hỏng vừa | Hư hỏng | 100,000 VND |
| Hư hỏng nặng | Hư hỏng | 200,000 VND |
| Mất sách - Bồi thường 50% | Mất | 150,000 VND |
| Mất sách - Bồi thường 100% | Mất | 300,000 VND |

### Quy Tắc Xóa
- ❌ Không thể xóa nếu mức phạt đang được sử dụng trong bất kỳ phiếu phạt nào
- ✅ Có thể xóa nếu chưa được sử dụng

## Validation Rules

| Field | Rule | Message Error |
|-------|------|---------------|
| Tên mức phạt | Không được để trống | "Tên mức phạt không được để trống" |
| Tên mức phạt | Tối đa 25 ký tự | "Tên mức phạt không được vượt quá 25 ký tự" |
| Tên mức phạt | Unique trong cùng loại phạt | "Tên mức phạt đã tồn tại trong loại này" |
| Loại phạt | Bắt buộc chọn | "Vui lòng chọn loại phạt" |
| Loại phạt | Phải là 'Hư hỏng' hoặc 'Mất' | "Loại phạt không hợp lệ" |
| Số tiền | Phải > 0 | "Số tiền phải lớn hơn 0" |
| Số tiền | Kiểu số | "Số tiền phải là số" |
| Số tiền | Số nguyên dương | "Số tiền phải là số nguyên dương" |

## Data Model
```json
{
  "id": "string (UUID)",
  "name": "string (max 25, unique per type)",
  "type": "Hư hỏng | Mất",
  "amount": "number (> 0, VND)",
  "description": "string (nullable)",
  "created_by": "admin_id",
  "updated_by": "admin_id (nullable)",
  "created_at": "timestamp",
  "updated_at": "timestamp",
  "usage_count": "number (computed, số lần được sử dụng)"
}
```

## Display Information

Mỗi mức phạt hiển thị:

| Column | Description |
|--------|-------------|
| Tên mức phạt | Tên (max 25 chars) |
| Loại phạt | Badge: Hư hỏng / Mất |
| Số tiền | Format: XXX,XXX VND |
| Số lần dùng | Số phiếu phạt sử dụng mức này |
| Ngày tạo | Created date |
| Actions | Edit / Delete buttons |

## UI Components
- Table với inline editing
- Add button (floating hoặc top-right)
- Modal form cho add/edit
- Type filter dropdown
- Search input
- Delete confirmation modal
- Badge cho loại phạt
- Format số tiền (thousand separator)
- Usage count indicator

## Notes
- Admin nên tạo đủ các mức phạt trước khi nhân viên xác nhận trả sách
- Nếu chưa có mức phạt, nhân viên không thể xử lý sách hư hỏng/mất
- Có thể thêm description field để ghi chú chi tiết về mức phạt
- Số tiền nên là số nguyên, không có phần thập phân
- Có thể thêm tính năng sắp xếp theo tên/số tiền/ngày tạo
- Usage count giúp admin biết mức phạt nào được dùng nhiều

