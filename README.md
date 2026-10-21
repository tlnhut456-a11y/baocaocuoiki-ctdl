# DT056 — Khoảng cách chỉnh sửa và dãy phép biến đổi

Bài cá nhân học phần Cấu trúc dữ liệu và Giải thuật (INT13185 — Nhóm 03).

- Sinh viên: Nguyễn Ngư Nhựt
- MSSV: N24DCDT065
- Lớp: D24CQDT01-N
- Giảng viên: Hồ Nhựt Minh
- Ngôn ngữ: Julia 1.13.1, chỉ dùng thư viện chuẩn

## Bài toán

Cho hai xâu X, Y chỉ gồm chữ cái Latin không dấu, độ dài mỗi xâu từ 0 đến 30,
phân biệt hoa thường. Tìm số thao tác ít nhất để biến X thành Y, mỗi thao tác là
chèn, xóa hoặc thay một ký tự với chi phí 1. Kèm theo đó phải in ra một dãy thao
tác cụ thể, thực hiện lại được và cho đúng xâu Y.

## Cấu trúc thư mục

```
.
├── main.jl                  chương trình dòng lệnh (vd1, vd2, phieu, nhap, bang, tatca)
├── src/DeTai.jl             thư viện: kiểm tra đầu vào, bảng quy hoạch động, truy vết
├── test/kiem_thu.jl         13 ca kiểm thử và phần kiểm bất biến
├── scripts/thong_ke.jl      khảo sát ba quy mô 10, 20, 30
├── chay.ps1                 chạy một lượt toàn bộ
├── docs/PHIEU_GOC_DT056.txt nội dung phiếu giao đề
├── docs/logs/               log của các lần chạy
└── docs/anh_ket_qua/        ảnh minh chứng
```

## Cách chạy

Cần Julia 1.13.1 trong PATH. Mở PowerShell tại thư mục gốc của bài:

```
julia main.jl vd1
julia main.jl vd2
julia main.jl phieu
julia main.jl nhap
julia main.jl bang CAT CUT
julia main.jl chay SUNDAY SATURDAY
julia main.jl tatca
```

Chạy bộ kiểm thử:

```
julia test/kiem_thu.jl
```

Chạy khảo sát ba quy mô:

```
julia scripts/thong_ke.jl
```

Hoặc chạy một lượt tất cả:

```
powershell -ExecutionPolicy Bypass -File .\chay.ps1
```

## Hàm chính

| Hàm | Việc làm |
|---|---|
| `kiem_tra_dau_vao(X, Y)` | kiểm xâu, độ dài 0–30, chỉ nhận A–Z, a–z |
| `khoang_cach_sua(X, Y)` | trả `(khoang_cach, bang)` với `bang[i+1, j+1]` là chi phí cho hai tiền tố |
| `truy_vet_sua(X, Y, bang)` | truy ngược, trả danh sách `BuocSua` theo thứ tự từ X đến Y |
| `ap_dung_cac_buoc(X, buoc)` | thực hiện lại dãy thao tác, trả xâu cuối và các xâu trung gian |
| `in_bang(bang, X, Y)` | in bảng kèm nhãn hai xâu khi độ dài không quá 6 |

Vị trí trong mỗi `BuocSua` được tính trên xâu tại đúng thời điểm thao tác, không
phải trên xâu gốc. Nhờ vậy `ap_dung_cac_buoc` chạy lại được nguyên dãy và kiểm
được xâu cuối có bằng Y hay không.

## Kết quả hiện tại

- 13 ca kiểm thử độc lập: 2 ví dụ, 5 ca phiếu, 2 ca tự thiết kế, 3 ca biên, 1 ca dữ liệu sai.
- Bộ kiểm thử chạy 21.803 phép kiểm, tất cả đạt.
- Khảo sát m = n = 10, 20, 30: số ô bảng 121, 441, 961; số bước truy vết không vượt m + n.

## Ghi chú

Toàn bộ kết quả trong báo cáo lấy từ log chạy thật trong `docs/logs/`. Khi sửa mã
phải chạy lại và cập nhật log, không sửa số liệu trong báo cáo trước.
