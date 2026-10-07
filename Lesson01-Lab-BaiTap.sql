/* =====================================================================
   Devmaster Academy – Hệ quản trị CSDL SQL Server 2022
   BUỔI 1 – LAB 1 (25 phút): CÀI ĐẶT & KẾT NỐI · LAB 2 (40 phút): HÀM VÔ HƯỚNG & BÀI TẬP VỀ NHÀ
   File nộp: Lab1_<MSSV>.sql – mỗi câu một khối "-- Câu n"
   Chấm: 60% kết quả đúng · 20% dùng đúng hàm/tính năng 2022 · 20% code sạch, có chú thích
   ===================================================================== */

/* ---------------------------------------------------------------------
   LAB 1 – CÀI ĐẶT, KẾT NỐI, KHỞI TẠO DEVMASTERLAB
   1. Cài SQL Server 2022 Developer HOẶC chạy container mssql/server:2022-latest
   2. Kết nối bằng SSMS 22 (Windows) hoặc VS Code + MSSQL; ghi lại kết quả SELECT @@VERSION
   3. Mở và chạy toàn bộ file 00_DevmasterLab_Setup.sql (chạy lại nhiều lần không lỗi)
   4. Chạy khối kiểm tra dưới đây và đối chiếu số liệu
   5. Lưu file vào thư mục dự án và commit Git với thông điệp "lab1"
   --------------------------------------------------------------------- */
USE DevmasterLab;
GO
SELECT 'Categories' AS TableName, COUNT(*) AS NumRows FROM dbo.Categories   -- 8
UNION ALL SELECT 'Courses',     COUNT(*) FROM dbo.Courses                   -- 8
UNION ALL SELECT 'Students',    COUNT(*) FROM dbo.Students                  -- 12
UNION ALL SELECT 'Enrollments', COUNT(*) FROM dbo.Enrollments               -- 20
UNION ALL SELECT 'Payments',    COUNT(*) FROM dbo.Payments;                 -- 21
SELECT compatibility_level FROM sys.databases WHERE name = 'DevmasterLab';  -- 160
GO

/* ---------------------------------------------------------------------
   LAB 2 – HÀM VÔ HƯỚNG, NULL VÀ T-SQL 2022 (làm theo cặp)
   --------------------------------------------------------------------- */
-- Câu 1. Với mỗi học viên: Họ (từ đầu tiên), Tên (từ cuối cùng), UserName (phần trước @ của email),
--        số điện thoại che 3 chữ số giữa (0912***678). (LEFT, CHARINDEX, REVERSE, SUBSTRING, STUFF)
-- Câu 2. Với mỗi khóa học: mã, học phí tính theo triệu đồng (1 chữ số thập phân), học phí mỗi giờ làm tròn
--        đến đồng, và học phí định dạng kiểu Việt Nam (18.000.000). (CAST, ROUND, FORMAT)
-- Câu 3. Điểm cao nhất và thấp nhất trong ba lần thi của mỗi lượt ghi danh, kèm tên học viên và mã khóa;
--        chỉ lấy các lượt ghi danh 1, 2, 7 và giải thích kết quả của lượt 7. (GREATEST, LEAST)
-- Câu 4. (a) Hiển thị số điện thoại của mọi học viên; chưa có thì ghi N'Chưa có'. (COALESCE)
--        (b) Với @city = N'Hà Nội', liệt kê học viên có City KHÁC @city, kể cả City NULL. (IS DISTINCT FROM)
-- Câu 5. Mỗi khóa học chỉ lấy tag đầu tiên trong cột Tags. (STRING_SPLIT có ordinal, TRIM)
-- Câu 6. Với mỗi lượt ghi danh: ngày ghi danh (kiểu date), ngày đầu tháng, ngày cuối tháng, và số ngày từ
--        lúc ghi danh đến 31/10/2026. (CAST, DATETRUNC, EOMONTH, DATEDIFF)
-- Câu 7. Học viên đã xác thực email (bit 0) VÀ có học bổng (bit 1) cùng lúc. Dùng toán tử bit & và hàm GET_BIT
--        cho hai cách viết.
-- Câu 8. Xuất mỗi khóa học thành một đối tượng JSON gồm code, name, fee, hours. (JSON_OBJECT)
-- Câu 9. Dùng WHILE cộng dồn học phí các khóa theo thứ tự CourseId, dừng ngay khi tổng vượt 40.000.000;
--        cho biết dừng ở CourseId nào và tổng là bao nhiêu. (WHILE, IF, BREAK)
-- Câu 10 (nâng cao). Cho chuỗi N'120000, 45, abc, 7500000, 12x': tách thành từng giá trị, đếm số giá trị
--        hợp lệ và không hợp lệ (kiểu số nguyên), và tính tổng các giá trị hợp lệ. (STRING_SPLIT, TRY_CONVERT)

/* =====================================================================
   BÀI TẬP VỀ NHÀ BUỔI 1
   ===================================================================== */
-- BT1. Che email: giữ 2 ký tự đầu của phần tên, thay phần còn lại bằng ***, giữ nguyên tên miền
--      (an.nv@devmaster.vn → an***@devmaster.vn).
-- BT2. Tính tuổi chính xác (theo năm đầy đủ) của học viên có BirthDate. Giải thích vì sao
--      DATEDIFF(year, BirthDate, GETDATE()) cho kết quả sai.
-- BT3. Viết lại điều kiện "City = @city OR (City IS NULL AND @city IS NULL)" bằng IS NOT DISTINCT FROM,
--      và nêu một tình huống thực tế cần so sánh an toàn với NULL.
-- BT4. Với mỗi lượt ghi danh, xuất JSON { "enrollmentId": …, "scores": [Score1, Score2, Score3] } trong đó
--      điểm NULL vẫn xuất hiện dưới dạng null (gợi ý: NULL ON NULL).
-- BT5. So sánh ISNULL và COALESCE: kiểu dữ liệu kết quả, số đối số, và ví dụ cho kết quả khác nhau
--      (gợi ý: ISNULL(NULL, 'abcdef') khi biến đầu là varchar(3)).
