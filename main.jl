# main.jl - chương trình dòng lệnh cho DT056
# Cách dùng:
#   julia main.jl vd1            ví dụ 1 của phiếu
#   julia main.jl vd2            ví dụ 2 của phiếu
#   julia main.jl phieu          năm ca kiểm trên phiếu
#   julia main.jl nhap           nhập X, Y từ bàn phím
#   julia main.jl bang X Y       in bảng quy hoạch động (độ dài <= 6)
#   julia main.jl tatca          chạy tất cả phần trên

include(joinpath(@__DIR__, "src", "DeTai.jl"))
using .DeTai

const DUONG_KE = "="^62

function in_tieu_de(text)
    println(DUONG_KE)
    println(text)
    println(DUONG_KE)
end

"""
    xu_ly(X, Y; in_bang_chi_tiet=false)

Chạy trọn một ca: kiểm đầu vào, tính bảng, truy vết, áp dụng lại và đối
chiếu xâu cuối với Y. Trả về true nếu kết quả nhất quán.
"""
function xu_ly(X, Y; in_bang_chi_tiet::Bool = false)
    Xs, Ys = kiem_tra_dau_vao(X, Y)
    println("X = \"$Xs\"  ($(length(Xs)) ký tự)")
    println("Y = \"$Ys\"  ($(length(Ys)) ký tự)")

    kq = khoang_cach_sua(Xs, Ys)
    buoc = truy_vet_sua(Xs, Ys, kq.bang)
    ap = ap_dung_cac_buoc(Xs, buoc)

    println("Khoảng cách sửa : $(kq.khoang_cach)")
    println("Số thao tác     : $(dem_thao_tac(buoc))")
    println("Dãy thao tác    : $(chuoi_thao_tac(buoc))")
    println("Các xâu sau từng bước:")
    for (k, s) in enumerate(ap.lich_su)
        println("  $(lpad(k, 2)). \"$s\"")
    end

    khop = ap.xau == Ys
    println("Kiểm lại        : xâu cuối $(khop ? "BẰNG" : "KHÁC") Y")
    if in_bang_chi_tiet
        println()
        println("Bảng quy hoạch động f[i, j]:")
        in_bang(kq.bang, Xs, Ys)
    end
    println()
    return khop && kq.khoang_cach == dem_thao_tac(buoc)
end

function chay_vd1()
    in_tieu_de("VÍ DỤ 1 — thay một ký tự ở giữa")
    ok = xu_ly("CAT", "CUT"; in_bang_chi_tiet = true)
    println("KẾT LUẬN: $(ok ? "ĐẠT" : "KHÔNG ĐẠT")")
    return ok
end

function chay_vd2()
    in_tieu_de("VÍ DỤ 2 — xâu đích rỗng nên xóa ký tự duy nhất")
    ok = xu_ly("A", ""; in_bang_chi_tiet = true)
    println("KẾT LUẬN: $(ok ? "ĐẠT" : "KHÔNG ĐẠT")")
    return ok
end

const NAM_CA_PHIEU = [
    ("P1", "", ""),
    ("P2", "", "AB"),
    ("P3", "ABC", "ABC"),
    ("P4", "AB", "BA"),
    ("P5", "ABC", "AC"),
]

function chay_phieu()
    in_tieu_de("NĂM CA KIỂM TRÊN PHIẾU DT056")
    tat_ca_dat = true
    for (ma, x, y) in NAM_CA_PHIEU
        println("CA $ma")
        ok = xu_ly(x, y)
        println("  -> $(ok ? "ĐẠT" : "KHÔNG ĐẠT")")
        println()
        tat_ca_dat &= ok
    end
    println("TỔNG KẾT: $(tat_ca_dat ? "5/5 ca đạt" : "có ca không đạt")")
    return tat_ca_dat
end

function chay_nhap()
    in_tieu_de("NHẬP DỮ LIỆU TỪ BÀN PHÍM")
    print("Nhập X (Enter nếu xâu rỗng): ")
    x = readline()
    print("Nhập Y (Enter nếu xâu rỗng): ")
    y = readline()
    println()
    try
        ok = xu_ly(x, y)
        println("KẾT LUẬN: $(ok ? "ĐẠT" : "KHÔNG ĐẠT")")
        return ok
    catch err
        if err isa ArgumentError
            println("LOẠI BỎ DỮ LIỆU: $(err.msg)")
            println("KẾT LUẬN: KHÔNG ĐẠT (dữ liệu không hợp lệ)")
            return false
        end
        rethrow()
    end
end

function chay_bang(args)
    x = length(args) >= 1 ? args[1] : "ABC"
    y = length(args) >= 2 ? args[2] : "AC"
    in_tieu_de("IN BẢNG QUY HOẠCH ĐỘNG")
    Xs, Ys = kiem_tra_dau_vao(x, y)
    kq = khoang_cach_sua(Xs, Ys)
    println("X = \"$Xs\", Y = \"$Ys\", khoảng cách = $(kq.khoang_cach)")
    println()
    in_bang(kq.bang, Xs, Ys)
    return true
end

function chay_cap(args)
    if length(args) < 2
        println("Cần nhập đủ hai xâu: julia main.jl chay X Y")
        return false
    end
    x, y = args[1], args[2]
    in_tieu_de("CHẠY MỘT CẶP X, Y")
    try
        ok = xu_ly(x, y)
        println("KẾT LUẬN: $(ok ? "ĐẠT" : "KHÔNG ĐẠT")")
        return ok
    catch err
        if err isa ArgumentError
            println("LOẠI BỎ DỮ LIỆU: $(err.msg)")
            println("KẾT LUẬN: KHÔNG ĐẠT (dữ liệu không hợp lệ)")
            return false
        end
        rethrow()
    end
end

function chay_tatca()
    ok = true
    ok &= chay_vd1()
    ok &= chay_vd2()
    ok &= chay_phieu()
    println(DUONG_KE)
    println("TỔNG KẾT TẤT CẢ: $(ok ? "ĐẠT" : "KHÔNG ĐẠT")")
    return ok
end

function main(args)
    lenh = isempty(args) ? "tatca" : args[1]
    if lenh == "vd1"
        return chay_vd1()
    elseif lenh == "vd2"
        return chay_vd2()
    elseif lenh == "phieu"
        return chay_phieu()
    elseif lenh == "nhap"
        return chay_nhap()
    elseif lenh == "bang"
        return chay_bang(args[2:end])
    elseif lenh == "chay"
        return chay_cap(args[2:end])
    elseif lenh == "tatca"
        return chay_tatca()
    else
        println("Lệnh không hợp lệ: $lenh")
        println("Dùng một trong: vd1 | vd2 | phieu | nhap | bang X Y | chay X Y | tatca")
        return false
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    ok = main(ARGS)
    exit(ok ? 0 : 1)
end
