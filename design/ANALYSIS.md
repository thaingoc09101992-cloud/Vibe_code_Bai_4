# Phân Tích Tính Năng - Hệ Thống Quản Lý Thư Viện

## Tổng Quan
Hệ thống quản lý thư viện với 3 vai trò chính:
- **Độc giả (Reader)**: Mượn sách, xem lịch sử, thanh toán phạt
- **Nhân viên (Librarian)**: Quản lý sách, xác nhận mượn/trả, theo dõi phạt
- **Quản lý viên (Admin)**: Quản lý tài khoản, báo cáo, cài đặt hệ thống

---

## 1. QUẢN LÝ TÀI KHOẢN

### 1.1 Đăng Ký (2.1.1)
**Actor:** Mọi người  
**Phụ thuộc:** Không

**Luồng chính:**
1. Người dùng click "Đăng ký"
2. Nhập thông tin: Email, Tên, Mật khẩu, Xác nhận mật khẩu
3. Hệ thống validate dữ liệu
4. Tạo tài khoản với trạng thái "Chờ xác nhận"
5. Hiển thị thông báo thành công

**Luồng thay thế:**
- Validation lỗi → Hiển thị lỗi cụ thể
- Email đã tồn tại → Thông báo lỗi

**Lỗi/Edge cases:**
- Email không đúng định dạng
- Mật khẩu không đủ độ dài (tối thiểu 8, tối đa 16 ký tự)
- Mật khẩu xác nhận không khớp
- Email đã được sử dụng

---

### 1.2 Đăng Nhập (2.1.2)
**Actor:** Mọi người  
**Phụ thuộc:** 2.1.1 (Cần có tài khoản)

**Luồng chính:**
1. Người dùng nhập Email & Mật khẩu
2. Hệ thống xác thực thông tin
3. Tạo JWT token (thời hạn 24h)
4. Chuyển hướng đến dashboard theo vai trò (Độc giả/Nhân viên)

**Luồng thay thế:**
- Thông tin đăng nhập sai → Hiển thị lỗi
- Tài khoản chưa được kích hoạt → Thông báo

**Lỗi/Edge cases:**
- Email hoặc mật khẩu sai
- Tài khoản bị vô hiệu hóa
- Token hết hạn (sau 24h)

---

### 1.3 Hồ Sơ Cá Nhân (2.1.3)
**Actor:** Độc giả  
**Phụ thuộc:** 2.1.2 (Cần đăng nhập)

**Luồng chính - Xem hồ sơ:**
1. Độc giả truy cập trang hồ sơ
2. Hiển thị: Tên, Email, Số điện thoại, Địa chỉ, Ngày tham gia, Số lần mượn, Tổng số tiền phạt

**Luồng chính - Cập nhật thông tin:**
1. Click "Chỉnh sửa"
2. Cập nhật thông tin (Tên, Số điện thoại, Địa chỉ)
3. Validate dữ liệu
4. Lưu thay đổi
5. Hiển thị thông báo thành công

**Luồng chính - Đổi mật khẩu:**
1. Click "Đổi mật khẩu"
2. Nhập mật khẩu cũ, mật khẩu mới, xác nhận mật khẩu mới
3. Validate
4. Cập nhật mật khẩu
5. Hiển thị thông báo thành công

**Luồng thay thế:**
- Validation lỗi → Hiển thị lỗi
- Mật khẩu cũ sai → Thông báo lỗi

**Lỗi/Edge cases:**
- Mật khẩu cũ không đúng
- Mật khẩu mới không đủ độ dài
- Mật khẩu xác nhận không khớp

---

## 2. QUẢN LÝ SÁCH

### 2.1 Quản lý Thể Loại Sách (2.2.1)
**Actor:** Nhân viên thư viện  
**Phụ thuộc:** 2.1.2 (Cần đăng nhập với vai trò nhân viên)

**Luồng chính - Xem danh sách:**
1. Nhân viên truy cập trang quản lý thể loại
2. Hiển thị danh sách thể loại dạng bảng (có thể sửa trực tiếp)

**Luồng chính - Thêm thể loại:**
1. Click "Thêm thể loại sách"
2. Nhập tên thể loại
3. Validate (không trống, tối đa 50 ký tự)
4. Lưu thể loại mới
5. Hiển thị thông báo thành công

**Luồng chính - Sửa thể loại:**
1. Sửa trực tiếp trên bảng
2. Validate
3. Lưu thay đổi

**Luồng chính - Xóa thể loại:**
1. Click "Xóa" trên bảng
2. Kiểm tra có sách thuộc thể loại này không
3. Nếu không có → Xác nhận xóa → Xóa
4. Nếu có → Thông báo không thể xóa

**Luồng thay thế:**
- Có sách thuộc thể loại → Không cho phép xóa

**Lỗi/Edge cases:**
- Tên thể loại trống
- Tên thể loại quá dài (>50 ký tự)
- Xóa thể loại đang được sử dụng

---

### 2.2 Thêm Sách Mới (2.2.2)
**Actor:** Nhân viên thư viện  
**Phụ thuộc:** 2.1.2, 2.2.1 (Cần đăng nhập và có thể loại sách)

**Luồng chính:**
1. Click "Thêm Sách Mới"
2. Nhập thông tin: Tên sách, Tác giả, Năm xuất bản, ISBN, Thể loại, Mô tả, Số lượng
3. Validate tất cả trường
4. Lưu sách vào database với trạng thái "Có sẵn"
5. Hiển thị thông báo "Thêm sách thành công"

**Luồng thay thế:**
- Validation lỗi → Hiển thị lỗi cụ thể cho từng trường

**Lỗi/Edge cases:**
- Tên sách/tác giả trống hoặc quá dài
- ISBN không đúng định dạng (ISBN-10 hoặc ISBN-13)
- Số lượng <= 0
- Năm xuất bản không hợp lệ (1900 - năm hiện tại)
- Thể loại không tồn tại
- Mô tả trống hoặc quá dài

---

### 2.3 Xem Danh Sách Sách (2.2.3)
**Actor:** Tất cả người dùng (không cần login)  
**Phụ thuộc:** Không

**Luồng chính:**
1. Truy cập trang danh sách sách
2. Hiển thị danh sách: Tên sách, Tác giả, Năm xuất bản, Thể loại, Số lượng có sẵn, Số lượng đang mượn
3. Phân trang (10 sách/trang)

**Luồng tìm kiếm:**
1. Nhập từ khóa (tên sách hoặc tác giả)
2. Hệ thống tìm kiếm và hiển thị kết quả

**Luồng lọc:**
1. Chọn thể loại từ dropdown
2. Hệ thống lọc và hiển thị sách theo thể loại

**Luồng sắp xếp:**
1. Chọn tiêu chí sắp xếp: Tên (A-Z), Năm xuất bản (Mới nhất), Lượt mượn (Phổ biến nhất)
2. Hệ thống sắp xếp và hiển thị lại

**Lỗi/Edge cases:**
- Không có kết quả tìm kiếm
- Không có sách trong thể loại đã chọn

---

### 2.4 Xem Chi Tiết Sách (2.2.4)
**Actor:** Tất cả người dùng (không cần login)  
**Phụ thuộc:** 2.2.3 (Cần có danh sách sách)

**Luồng chính:**
1. Click vào sách từ danh sách
2. Hiển thị chi tiết: Tên, Tác giả, ISBN, Năm xuất bản, Mô tả chi tiết, Số lượng bản đang có, đang mượn
3. Nếu là nhân viên → Hiển thị lịch sử mượn (Độc giả, Ngày mượn, Ngày hết hạn)
4. Nếu là độc giả đã đăng nhập → Hiển thị nút "Mượn sách"

**Luồng thay thế:**
- Độc giả chưa đăng nhập → Không hiển thị nút "Mượn sách"

**Lỗi/Edge cases:**
- Sách không tồn tại
- Không có quyền xem lịch sử mượn (không phải nhân viên)

---

### 2.5 Sửa & Xóa Sách (2.2.5)
**Actor:** Nhân viên thư viện  
**Phụ thuộc:** 2.1.2, 2.2.4 (Cần đăng nhập và xem chi tiết sách)

**Luồng chính - Sửa sách:**
1. Xem chi tiết sách
2. Click "Sửa"
3. Chỉnh sửa thông tin sách
4. Validate dữ liệu
5. Lưu thay đổi
6. Hiển thị thông báo thành công

**Luồng chính - Xóa sách:**
1. Xem chi tiết sách
2. Click "Xóa"
3. Kiểm tra có đơn mượn hoạt động không
4. Nếu không có → Xác nhận xóa → Xóa sách
5. Nếu có → Thông báo không thể xóa

**Luồng thay thế:**
- Có đơn mượn hoạt động → Không cho phép xóa

**Lỗi/Edge cases:**
- Sách đang có đơn mượn chưa trả → Không thể xóa
- Validation lỗi khi sửa

---

## 3. QUẢN LÝ MƯỢN SÁCH

### 3.1 Mượn Sách - Độc Giả (2.3.1)
**Actor:** Độc giả  
**Phụ thuộc:** 2.1.2, 2.2.4 (Cần đăng nhập và xem chi tiết sách)

**Luồng chính:**
1. Độc giả xem chi tiết sách
2. Click "Mượn Sách"
3. Kiểm tra điều kiện:
   - Sách còn sẵn (số lượng > 0)
   - Độc giả chưa vượt quá số sách mượn tối đa (5 cuốn)
   - Không có khoản phạt chưa thanh toán
4. Nếu đủ điều kiện → Chọn thời hạn mượn (mặc định 14 ngày, tối đa 30 ngày)
5. Tạo đơn mượn ở trạng thái "Chờ xác nhận"
6. Hiển thị thông báo thành công

**Luồng thay thế:**
- Sách hết → Thông báo "Sách đã hết"
- Đã mượn tối đa 5 cuốn → Thông báo "Bạn đã mượn tối đa số sách cho phép"
- Có phạt chưa thanh toán → Thông báo "Vui lòng thanh toán các khoản phạt trước khi mượn sách"

**Lỗi/Edge cases:**
- Sách không còn sẵn
- Đã đạt giới hạn số sách mượn
- Có khoản phạt chưa thanh toán
- Thời hạn mượn vượt quá 30 ngày

---

### 3.2 Mượn Sách - Nhân Viên (2.3.2)
**Actor:** Nhân viên thư viện  
**Phụ thuộc:** 2.1.2, 2.3.1 (Cần đăng nhập và có đơn mượn chờ xác nhận)

**Luồng chính - Xác nhận:**
1. Nhân viên xem danh sách đơn mượn chờ xác nhận
2. Click "Xác nhận" trên đơn mượn
3. Hệ thống cập nhật trạng thái đơn mượn thành "Đã mượn"
4. Giảm số lượng sách có sẵn
5. Hiển thị thông báo thành công

**Luồng chính - Từ chối:**
1. Nhân viên xem danh sách đơn mượn chờ xác nhận
2. Click "Từ chối" trên đơn mượn
3. Nhập lý do từ chối (bắt buộc)
4. Hệ thống cập nhật trạng thái thành "Bị từ chối" và lưu lý do
5. Hiển thị thông báo thành công

**Luồng thay thế:**
- Không nhập lý do từ chối → Yêu cầu nhập lý do

**Lỗi/Edge cases:**
- Lý do từ chối trống
- Sách đã hết khi xác nhận (race condition)

---

### 3.3 Xem Lịch Sử Mượn Sách (2.3.3)
**Actor:** Độc giả  
**Phụ thuộc:** 2.1.2, 2.3.1 (Cần đăng nhập và có đơn mượn)

**Luồng chính:**
1. Độc giả truy cập trang "Lịch sử mượn sách"
2. Hiển thị:
   - Sách đang mượn: Tên, Tác giả, Ngày mượn, Hạn trả, Số ngày còn lại
   - Sách đã trả: Tên, Ngày mượn, Ngày trả
   - Sách bị từ chối: Tên, Tác giả, Lý do từ chối
3. Trạng thái: "Chờ xác nhận", "Đang mượn", "Quá hạn", "Đã trả", "Bị từ chối"

**Luồng lọc:**
1. Chọn trạng thái từ dropdown
2. Hiển thị danh sách theo trạng thái đã chọn

**Luồng xem lý do từ chối:**
1. Click vào sách bị từ chối
2. Hiển thị lý do từ chối

**Luồng tạo yêu cầu trả sách:**
1. Chọn sách đang mượn
2. Click "Xin trả sách"
3. Xác nhận trong modal
4. Tạo yêu cầu trả sách

**Luồng gia hạn:**
1. Chọn sách đang mượn (chưa hết hạn)
2. Click "Gia hạn"
3. Kiểm tra đã gia hạn chưa (chỉ được gia hạn 1 lần)
4. Nếu chưa → Gia hạn thêm 7 ngày
5. Nếu đã gia hạn → Thông báo "Bạn đã gia hạn sách này rồi"

**Luồng thay thế:**
- Sách đã hết hạn → Không hiển thị nút "Gia hạn"
- Đã gia hạn rồi → Không hiển thị nút "Gia hạn"

**Lỗi/Edge cases:**
- Sách đã quá hạn → Không thể gia hạn
- Đã gia hạn 1 lần → Không thể gia hạn thêm
- Đã có yêu cầu trả sách chờ xác nhận → Không thể tạo yêu cầu mới

---

## 4. TRẢ SÁCH

### 4.1 Yêu Cầu Trả Sách (2.4.1)
**Actor:** Độc giả  
**Phụ thuộc:** 2.1.2, 2.3.1 (Cần đăng nhập và có sách đang mượn)

**Luồng chính:**
1. Độc giả vào trang "Lịch sử mượn sách"
2. Xem danh sách sách đang mượn
3. Click "Xin trả sách" trên sách muốn trả
4. Xác nhận trong modal
5. Kiểm tra chưa có yêu cầu trả sách chờ xác nhận cho đơn mượn này
6. Tạo yêu cầu trả sách ở trạng thái "Chờ xác nhận"
7. Hiển thị thông báo thành công

**Luồng thay thế:**
- Đã có yêu cầu trả sách chờ xác nhận → Thông báo "Bạn đã có yêu cầu trả sách cho đơn mượn này"

**Lỗi/Edge cases:**
- Đã có yêu cầu trả sách chờ xác nhận cho đơn mượn này
- Sách không ở trạng thái "Đang mượn"

---

### 4.2 Xác Nhận Trả Sách (2.4.2)
**Actor:** Nhân viên thư viện  
**Phụ thuộc:** 2.1.2, 2.4.1, 2.5.1 (Cần đăng nhập, có yêu cầu trả sách, và có mức phạt)

**Luồng chính - Trả sách bình thường:**
1. Nhân viên vào trang "Quản lý mượn trả" → Tab "Chờ xác nhận trả"
2. Xem danh sách yêu cầu trả sách chờ xác nhận
3. Nhận sách vật lý từ độc giả
4. Click "Xác nhận trả"
5. Chọn tình trạng sách: "Bình thường"
6. Xác nhận trả
7. Cập nhật đơn mượn thành "Đã trả"
8. Tăng số lượng sách có sẵn
9. Giảm số lượng sách đang mượn
10. Hiển thị thông báo thành công

**Luồng chính - Trả sách hư hỏng:**
1. Nhân viên vào trang "Quản lý mượn trả" → Tab "Chờ xác nhận trả"
2. Xem danh sách yêu cầu trả sách chờ xác nhận
3. Nhận sách vật lý từ độc giả
4. Click "Xác nhận trả"
5. Chọn tình trạng sách: "Hư hỏng"
6. Chọn mức phạt từ danh sách
7. Nhập ghi chú (bắt buộc, tối đa 500 ký tự)
8. Kiểm tra có trả muộn không
9. Nếu muộn → Tạo phiếu phạt "Trả muộn"
10. Tạo phiếu phạt cho hư hỏng
11. Cập nhật đơn mượn thành "Đã trả"
12. Hiển thị thông báo thành công

**Luồng chính - Trả sách bị mất:**
1. Nhân viên vào trang "Quản lý mượn trả" → Tab "Chờ xác nhận trả"
2. Xem danh sách yêu cầu trả sách chờ xác nhận
3. Xác nhận sách bị mất
4. Click "Xác nhận trả"
5. Chọn tình trạng sách: "Mất"
6. Chọn mức phạt từ danh sách
7. Nhập ghi chú (bắt buộc, tối đa 500 ký tự)
8. Tạo phiếu phạt cho mất sách
9. Cập nhật đơn mượn thành "Đã trả"
10. Hiển thị thông báo thành công

**Luồng thay thế:**
- Không chọn mức phạt → Yêu cầu chọn mức phạt
- Không nhập ghi chú → Yêu cầu nhập ghi chú

**Lỗi/Edge cases:**
- Tình trạng sách không được chọn
- Mức phạt không được chọn (khi hư hỏng/mất)
- Ghi chú trống hoặc quá dài (>500 ký tự)
- Mức phạt không tồn tại

---

## 5. QUẢN LÝ NỢ & PHẠT

### 5.1 Quản lý Mức Phạt (2.5.1)
**Actor:** Quản lý viên  
**Phụ thuộc:** 2.1.2 (Cần đăng nhập với vai trò quản lý viên)

**Luồng chính - Xem danh sách:**
1. Quản lý viên truy cập trang quản lý mức phạt
2. Hiển thị danh sách mức phạt dạng bảng (có thể sửa trực tiếp)

**Luồng chính - Thêm mức phạt:**
1. Click "Thêm mức phạt"
2. Nhập thông tin: Tên mức phạt, Số tiền, Ngày phạt (mặc định ngày hiện tại)
3. Validate dữ liệu
4. Lưu mức phạt mới
5. Hiển thị thông báo thành công

**Luồng chính - Sửa mức phạt:**
1. Sửa trực tiếp trên bảng
2. Validate dữ liệu
3. Lưu thay đổi

**Luồng chính - Xóa mức phạt:**
1. Click "Xóa" trên bảng
2. Xác nhận xóa
3. Xóa mức phạt

**Luồng thay thế:**
- Validation lỗi → Hiển thị lỗi

**Lỗi/Edge cases:**
- Tên mức phạt trống hoặc quá dài (>25 ký tự)
- Số tiền <= 0
- Ngày phạt không hợp lệ

---

### 5.2 Xem & Thanh Toán Phạt - Độc Giả (2.5.2)
**Actor:** Độc giả  
**Phụ thuộc:** 2.1.2, 2.4.2, 2.5.1 (Cần đăng nhập, có phiếu phạt và mức phạt)

**Luồng chính - Xem khoản phạt:**
1. Độc giả truy cập trang "Khoản phạt"
2. Hiển thị danh sách khoản phạt chưa thanh toán: Nguyên nhân phạt, Số tiền, Ngày phạt, Trạng thái

**Luồng chính - Thanh toán:**
1. Chọn phiếu phạt ở trạng thái "Chưa thanh toán"
2. Click "Thanh toán"
3. Thanh toán bằng chuyển khoản qua ngân hàng
4. Click "Đã thanh toán"
5. Phiếu phạt chuyển sang trạng thái "Chờ xác nhận"
6. Hiển thị thông báo "Đã gửi yêu cầu xác nhận thanh toán"

**Luồng thay thế:**
- Không có khoản phạt → Hiển thị "Bạn không có khoản phạt nào"

**Lỗi/Edge cases:**
- Phiếu phạt không ở trạng thái "Chưa thanh toán"
- Không có khoản phạt

---

### 5.3 Xem & Thanh Toán Phạt - Nhân Viên (2.5.3)
**Actor:** Nhân viên thư viện  
**Phụ thuộc:** 2.1.2, 2.5.2 (Cần đăng nhập và có phiếu phạt chờ xác nhận)

**Luồng chính - Xem danh sách:**
1. Nhân viên truy cập trang "Quản lý khoản phạt"
2. Xem danh sách khoản phạt chưa thanh toán và chờ xác nhận

**Luồng chính - Xác nhận thanh toán:**
1. Xem chi tiết khoản phạt
2. Kiểm tra số tiền thanh toán có phù hợp không
3. Nếu phù hợp → Click "Đã thanh toán"
4. Cập nhật trạng thái phiếu phạt thành "Đã thanh toán"
5. Hiển thị thông báo thành công

**Luồng chính - Từ chối thanh toán:**
1. Xem chi tiết khoản phạt
2. Kiểm tra số tiền thanh toán không phù hợp
3. Click "Từ chối"
4. Nhập lý do từ chối
5. Cập nhật trạng thái phiếu phạt thành "Từ chối" và lưu lý do
6. Hiển thị thông báo thành công

**Luồng thay thế:**
- Không nhập lý do từ chối → Yêu cầu nhập lý do

**Lỗi/Edge cases:**
- Lý do từ chối trống
- Số tiền không khớp với số tiền phạt

---

## 6. QUẢN LÝ NGƯỜI DÙNG

### 6.1 Danh Sách Người Dùng (2.6.1)
**Actor:** Quản lý viên  
**Phụ thuộc:** 2.1.2 (Cần đăng nhập với vai trò quản lý viên)

**Luồng chính - Xem danh sách:**
1. Quản lý viên truy cập trang "Quản lý người dùng"
2. Hiển thị danh sách: Email, Tên, Vai trò (Reader/Librarian/Admin), Ngày tham gia, Trạng thái (Kích hoạt/Vô hiệu hóa)

**Luồng tìm kiếm:**
1. Nhập từ khóa (email hoặc tên)
2. Hệ thống tìm kiếm và hiển thị kết quả

**Luồng lọc:**
1. Chọn vai trò từ dropdown
2. Hệ thống lọc và hiển thị người dùng theo vai trò

**Luồng vô hiệu hóa/kích hoạt:**
1. Click "Vô hiệu hóa" hoặc "Kích hoạt" trên tài khoản
2. Xác nhận thao tác
3. Cập nhật trạng thái tài khoản
4. Hiển thị thông báo thành công

**Luồng thay thế:**
- Không có kết quả tìm kiếm → Hiển thị "Không tìm thấy người dùng"

**Lỗi/Edge cases:**
- Không tìm thấy người dùng
- Vô hiệu hóa tài khoản của chính mình (có thể không cho phép)

---

### 6.2 Gán Vai Trò (2.6.2)
**Actor:** Quản lý viên  
**Phụ thuộc:** 2.1.2, 2.6.1 (Cần đăng nhập và có danh sách người dùng)

**Luồng chính:**
1. Quản lý viên xem danh sách người dùng
2. Chọn người dùng cần gán vai trò
3. Click "Gán vai trò" hoặc "Sửa vai trò"
4. Chọn vai trò mới: Reader, Librarian, hoặc Admin
5. Xác nhận thay đổi
6. Cập nhật vai trò người dùng
7. Hiển thị thông báo thành công

**Luồng thay thế:**
- Không chọn vai trò → Yêu cầu chọn vai trò

**Lỗi/Edge cases:**
- Vai trò không hợp lệ
- Gán vai trò cho chính mình (có thể cần xác nhận đặc biệt)

---

## 7. BÁO CÁO & THỐNG KÊ

### 7.1 Báo Cáo Tổng Quan - Dashboard (2.7.1)
**Actor:** Quản lý viên, Nhân viên thư viện  
**Phụ thuộc:** 2.1.2, 2.2.2, 2.3.1, 2.4.2 (Cần có dữ liệu sách, mượn, trả)

**Luồng chính:**
1. Đăng nhập với vai trò Quản lý viên hoặc Nhân viên
2. Truy cập Dashboard
3. Hiển thị các thống kê:
   - Tổng số sách: Có sẵn / Đang mượn / Bị mất / Hư hỏng
   - Tổng số độc giả: Hoạt động / Vô hiệu hóa
   - Tổng đơn mượn hôm nay
   - Top 5 sách phổ biến nhất
   - Danh sách độc giả nợ quá hạn

**Luồng thay thế:**
- Không có dữ liệu → Hiển thị 0 hoặc "Chưa có dữ liệu"

**Lỗi/Edge cases:**
- Không có dữ liệu để hiển thị
- Lỗi khi tính toán thống kê

---

### 7.2 Báo Cáo Chi Tiết (2.7.2)
**Actor:** Quản lý viên, Nhân viên thư viện  
**Phụ thuộc:** 2.1.2, 2.7.1 (Cần có dashboard và dữ liệu đầy đủ)

**Luồng chính - Xem báo cáo:**
1. Truy cập trang "Báo cáo chi tiết"
2. Chọn loại báo cáo:
   - Báo cáo Sách: Tổng số sách, tình trạng, số lần mượn
   - Báo cáo Mượn Trả: Số lần mượn/trả theo ngày/tháng/quý
   - Báo cáo Phạt: Tổng doanh thu phạt, người nợ ngoài hạn
   - Báo cáo Sách Mất/Hư: Danh sách sách cần thay thế
3. Chọn khoảng thời gian: Ngày, Tuần, Tháng, Quý, Năm
4. Hiển thị báo cáo

**Luồng xuất báo cáo:**
1. Sau khi xem báo cáo
2. Click "Xuất CSV"
3. Tải file CSV về máy

**Luồng thay thế:**
- Không có dữ liệu trong khoảng thời gian đã chọn → Hiển thị "Không có dữ liệu"

**Lỗi/Edge cases:**
- Không có dữ liệu trong khoảng thời gian
- Lỗi khi xuất file CSV
- Khoảng thời gian không hợp lệ

---

## TỔNG KẾT

**Tổng số tính năng:** 20 tính năng chính

**Phân loại theo vai trò:**
- **Tất cả người dùng:** 2.2.3, 2.2.4
- **Độc giả:** 2.1.3, 2.3.1, 2.3.3, 2.4.1, 2.5.2
- **Nhân viên:** 2.2.1, 2.2.2, 2.2.5, 2.3.2, 2.4.2, 2.5.3, 2.7.1, 2.7.2
- **Quản lý viên:** 2.5.1, 2.6.1, 2.6.2, 2.7.1, 2.7.2

**Thứ tự ưu tiên triển khai:**
1. Giai đoạn 1: Quản lý tài khoản (2.1.1, 2.1.2, 2.1.3)
2. Giai đoạn 2: Quản lý sách (2.2.1 - 2.2.5)
3. Giai đoạn 3: Mượn trả sách (2.3.1 - 2.4.2)
4. Giai đoạn 4: Quản lý phạt (2.5.1 - 2.5.3)
5. Giai đoạn 5: Quản lý người dùng (2.6.1, 2.6.2)
6. Giai đoạn 6: Báo cáo (2.7.1, 2.7.2)

