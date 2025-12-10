# Feature 2.2.3: Xem Danh Sách Sách

## Mô tả
Cho phép tất cả người dùng (kể cả chưa đăng nhập) xem danh sách sách trong thư viện với các tính năng tìm kiếm, lọc và sắp xếp.

## Actor
Tất cả người dùng (không cần đăng nhập)

## Yêu cầu
Không có (tính năng public)

## Flowchart

```mermaid
flowchart TD
    Start([Người dùng truy cập trang web]) --> ClickBooks[Click 'Danh sách sách' hoặc trang chủ]
    ClickBooks --> LoadBooks[Tải danh sách sách từ Database]
    LoadBooks --> LoadCategories[Tải danh sách thể loại để lọc]
    LoadCategories --> DisplayList[Hiển thị danh sách sách<br/>Phân trang: 10 sách/trang]
    
    DisplayList --> ShowBookInfo[Hiển thị cho mỗi sách:<br/>- Tên sách<br/>- Tác giả<br/>- Năm xuất bản<br/>- Thể loại<br/>- Số lượng có sẵn<br/>- Số lượng đang mượn]
    
    ShowBookInfo --> UserAction{Người dùng thao tác}
    
    %% Luồng Tìm Kiếm
    UserAction -->|Tìm kiếm| InputSearch[Nhập từ khóa vào ô tìm kiếm<br/>Theo tên sách hoặc tác giả]
    InputSearch --> ClickSearch[Click 'Tìm kiếm' hoặc Enter]
    ClickSearch --> SearchDB[Tìm kiếm trong Database<br/>Search pattern: LIKE %keyword%]
    SearchDB --> CheckSearchResult{Có kết quả?}
    
    CheckSearchResult -->|Không có| ShowNoResult[Hiển thị: Không tìm thấy sách nào]
    ShowNoResult --> UserAction
    CheckSearchResult -->|Có kết quả| DisplaySearchResult[Hiển thị danh sách sách tìm được]
    DisplaySearchResult --> UserAction
    
    %% Luồng Lọc Theo Thể Loại
    UserAction -->|Lọc theo thể loại| SelectCategory[Chọn thể loại từ dropdown]
    SelectCategory --> FilterByCategory[Lọc sách theo thể loại đã chọn]
    FilterByCategory --> CheckFilterResult{Có kết quả?}
    
    CheckFilterResult -->|Không có| ShowNoCategory[Hiển thị: Không có sách nào<br/>thuộc thể loại này]
    ShowNoCategory --> UserAction
    CheckFilterResult -->|Có kết quả| DisplayFilterResult[Hiển thị danh sách sách đã lọc]
    DisplayFilterResult --> UserAction
    
    %% Luồng Sắp Xếp
    UserAction -->|Sắp xếp| SelectSort{Chọn kiểu sắp xếp}
    SelectSort -->|Tên A-Z| SortByNameAsc[Sắp xếp theo tên tăng dần]
    SelectSort -->|Tên Z-A| SortByNameDesc[Sắp xếp theo tên giảm dần]
    SelectSort -->|Năm XB Mới nhất| SortByYearDesc[Sắp xếp theo năm xuất bản giảm dần]
    SelectSort -->|Năm XB Cũ nhất| SortByYearAsc[Sắp xếp theo năm xuất bản tăng dần]
    SelectSort -->|Phổ biến nhất| SortByBorrowCount[Sắp xếp theo lượt mượn giảm dần]
    
    SortByNameAsc --> ApplySort[Áp dụng sắp xếp]
    SortByNameDesc --> ApplySort
    SortByYearDesc --> ApplySort
    SortByYearAsc --> ApplySort
    SortByBorrowCount --> ApplySort
    ApplySort --> DisplaySortedList[Hiển thị danh sách đã sắp xếp]
    DisplaySortedList --> UserAction
    
    %% Luồng Phân Trang
    UserAction -->|Chuyển trang| SelectPage{Chọn trang}
    SelectPage -->|Trang trước| LoadPrevPage[Tải trang trước đó]
    SelectPage -->|Trang sau| LoadNextPage[Tải trang tiếp theo]
    SelectPage -->|Trang cụ thể| LoadSpecificPage[Tải trang được chọn]
    
    LoadPrevPage --> CheckPrevValid{Có trang trước?}
    CheckPrevValid -->|Không| UserAction
    CheckPrevValid -->|Có| DisplayList
    
    LoadNextPage --> CheckNextValid{Có trang sau?}
    CheckNextValid -->|Không| UserAction
    CheckNextValid -->|Có| DisplayList
    
    LoadSpecificPage --> DisplayList
    
    %% Luồng Xem Chi Tiết
    UserAction -->|Click vào sách| RedirectDetail[Chuyển đến trang chi tiết sách<br/>Feature 2.2.4]
    RedirectDetail --> End([Kết thúc])
    
    %% Luồng Reset
    UserAction -->|Reset bộ lọc| ResetFilters[Xóa tất cả filter và search]
    ResetFilters --> LoadBooks
    
    UserAction -->|Thoát| End
```

## Display Information

Mỗi sách trong danh sách hiển thị:

| Field | Description |
|-------|-------------|
| Hình ảnh | Thumbnail của sách (nếu có) |
| Tên sách | Tiêu đề sách |
| Tác giả | Tên tác giả |
| Năm xuất bản | Năm phát hành |
| Thể loại | Tên thể loại |
| Số lượng có sẵn | Số sách còn có thể mượn |
| Số lượng đang mượn | Số sách đang được mượn |
| Trạng thái | Badge: Có sẵn / Hết sách |

## Features

### 1. Tìm Kiếm
- Input: Text field
- Search trong: Tên sách, Tác giả
- Real-time search hoặc search on submit
- Hỗ trợ tìm kiếm không dấu

### 2. Lọc Theo Thể Loại
- Dropdown chọn thể loại
- Option "Tất cả thể loại" để bỏ lọc
- Hiển thị số lượng sách trong mỗi thể loại

### 3. Sắp Xếp
- Tên (A-Z)
- Tên (Z-A)
- Năm xuất bản (Mới nhất)
- Năm xuất bản (Cũ nhất)
- Lượt mượn (Phổ biến nhất)

### 4. Phân Trang
- 10 sách trên 1 trang
- Hiển thị: Trang hiện tại / Tổng số trang
- Navigation: Đầu, Trước, Số trang, Sau, Cuối

## Data Query
```sql
-- Example query structure
SELECT 
  id, title, author, publication_year, 
  category_name, available_quantity, 
  borrowed_quantity, borrow_count
FROM books
LEFT JOIN categories ON books.category_id = categories.id
WHERE 
  (title LIKE '%keyword%' OR author LIKE '%keyword%')
  AND (category_id = ? OR ? IS NULL)
ORDER BY 
  CASE 
    WHEN sort = 'name_asc' THEN title ASC
    WHEN sort = 'name_desc' THEN title DESC
    WHEN sort = 'year_desc' THEN publication_year DESC
    WHEN sort = 'popular' THEN borrow_count DESC
  END
LIMIT 10 OFFSET page_offset;
```

## UI Components
- Search bar (sticky top)
- Filter dropdown (Category)
- Sort dropdown
- Book grid/list view
- Pagination controls
- No result message

## Notes
- Tính năng này không yêu cầu đăng nhập
- Kết quả tìm kiếm có thể cache để tăng performance
- Hỗ trợ cả desktop và mobile responsive
- Loading state khi đang tải dữ liệu

