# Design Documents - Hệ Thống Quản Lý Thư Viện

Thư mục này chứa các tài liệu thiết kế luồng chức năng cho hệ thống quản lý thư viện.

## Cấu Trúc Tài Liệu

### 1. Phân Tích Tổng Quan
- **[ANALYSIS.md](./ANALYSIS.md)**: Phân tích chi tiết tất cả các tính năng, luồng chính, luồng thay thế và edge cases

### 2. Flowcharts Theo Tính Năng

#### 2.1 Quản Lý Tài Khoản
- **[2.1.1-user-registration-flow.md](./2.1.1-user-registration-flow.md)**: Đăng ký tài khoản
- **[2.1.2-login-flow.md](./2.1.2-login-flow.md)**: Đăng nhập
- **[2.1.3-user-profile-flow.md](./2.1.3-user-profile-flow.md)**: Hồ sơ cá nhân

#### 2.2 Quản Lý Sách
- **[2.2.1-category-management-flow.md](./2.2.1-category-management-flow.md)**: Quản lý thể loại sách
- **[2.2.2-add-book-flow.md](./2.2.2-add-book-flow.md)**: Thêm sách mới
- **[2.2.3-view-books-list-flow.md](./2.2.3-view-books-list-flow.md)**: Xem danh sách sách
- **[2.2.4-view-book-detail-flow.md](./2.2.4-view-book-detail-flow.md)**: Xem chi tiết sách
- **[2.2.5-edit-delete-book-flow.md](./2.2.5-edit-delete-book-flow.md)**: Sửa & xóa sách

#### 2.3 Quản Lý Mượn Sách
- **[2.3.1-borrow-book-reader-flow.md](./2.3.1-borrow-book-reader-flow.md)**: Mượn sách (Độc giả)
- **[2.3.2-borrow-book-librarian-flow.md](./2.3.2-borrow-book-librarian-flow.md)**: Mượn sách (Nhân viên)
- **[2.3.3-view-borrow-history-flow.md](./2.3.3-view-borrow-history-flow.md)**: Xem lịch sử mượn sách

#### 2.4 Trả Sách
- **[2.4.1-return-request-flow.md](./2.4.1-return-request-flow.md)**: Yêu cầu trả sách
- **[2.4.2-confirm-return-flow.md](./2.4.2-confirm-return-flow.md)**: Xác nhận trả sách

#### 2.5 Quản Lý Nợ & Phạt
- **[2.5.1-penalty-level-management-flow.md](./2.5.1-penalty-level-management-flow.md)**: Quản lý mức phạt
- **[2.5.2-view-pay-penalty-reader-flow.md](./2.5.2-view-pay-penalty-reader-flow.md)**: Xem & thanh toán phạt (Độc giả)
- **[2.5.3-view-pay-penalty-librarian-flow.md](./2.5.3-view-pay-penalty-librarian-flow.md)**: Xem & thanh toán phạt (Nhân viên)

#### 2.6 Quản Lý Người Dùng
- **[2.6.1-user-list-flow.md](./2.6.1-user-list-flow.md)**: Danh sách người dùng
- **[2.6.2-assign-role-flow.md](./2.6.2-assign-role-flow.md)**: Gán vai trò

#### 2.7 Báo Cáo & Thống Kê
- **[2.7.1-dashboard-flow.md](./2.7.1-dashboard-flow.md)**: Báo cáo tổng quan (Dashboard)
- **[2.7.2-detailed-reports-flow.md](./2.7.2-detailed-reports-flow.md)**: Báo cáo chi tiết

## Cách Sử Dụng

Mỗi file flowchart chứa:
- **Mô tả**: Tóm tắt tính năng
- **Actor**: Người sử dụng tính năng
- **Phụ thuộc**: Các tính năng cần có trước
- **Flowchart**: Sơ đồ luồng sử dụng Mermaid syntax
- **Validation Rules**: Quy tắc kiểm tra dữ liệu
- **Luồng thay thế**: Các luồng xử lý ngoại lệ
- **Edge Cases**: Các trường hợp biên

## Xem Flowcharts

Các flowchart được viết bằng Mermaid syntax và có thể xem trực tiếp trên:
- GitHub (hỗ trợ Mermaid natively)
- VS Code với extension Mermaid Preview
- Các công cụ hỗ trợ Mermaid khác

## Thứ Tự Triển Khai

Theo PRD, thứ tự ưu tiên triển khai:
1. **Giai đoạn 1**: Quản lý tài khoản (2.1.1 - 2.1.3)
2. **Giai đoạn 2**: Quản lý sách (2.2.1 - 2.2.5)
3. **Giai đoạn 3**: Mượn trả sách (2.3.1 - 2.4.2)
4. **Giai đoạn 4**: Quản lý phạt (2.5.1 - 2.5.3)
5. **Giai đoạn 5**: Quản lý người dùng (2.6.1 - 2.6.2)
6. **Giai đoạn 6**: Báo cáo (2.7.1 - 2.7.2)

