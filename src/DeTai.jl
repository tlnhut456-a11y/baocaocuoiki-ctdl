module DeTai

# DT056 — Khoảng cách chỉnh sửa và dãy phép biến đổi
# Sinh viên: Nguyễn Ngư Nhựt — N24DCDT065 — D24CQDT01-N

export BuocSua, kiem_tra_dau_vao, khoang_cach_sua, truy_vet_sua,
       ap_dung_cac_buoc, in_bang, mo_ta_buoc, chuoi_thao_tac, dem_thao_tac

const DO_DAI_TOI_DA = 30

"""
    BuocSua(loai, vi_tri, cu, moi)

Một thao tác biến đổi xâu. `vi_tri` đếm từ 1 trên xâu tại đúng thời điểm
thao tác được thực hiện, không phải trên xâu gốc X.

`loai` nhận một trong bốn giá trị :giu, :thay, :xoa, :chen.
Với :giu và :xoa thì `moi` bằng '\\0'; với :chen thì `cu` bằng '\\0'.
"""
struct BuocSua
    loai::Symbol
    vi_tri::Int
    cu::Char
    moi::Char
end

"""
    kiem_tra_dau_vao(X, Y) -> (X, Y)

Kiểm tra hợp đồng đầu vào của DT056: X, Y là xâu chỉ gồm chữ cái Latin
không dấu (A–Z, a–z), phân biệt hoa thường, độ dài mỗi xâu từ 0 đến 30.
Trả về hai xâu đã chuẩn hoá, ném ArgumentError nếu vi phạm.
"""
function kiem_tra_dau_vao(X, Y)
    for (ten, s) in (("X", X), ("Y", Y))
        s isa AbstractString ||
            throw(ArgumentError("$ten phải là xâu, nhận được $(typeof(s))"))
        ds = collect(s)
        length(ds) <= DO_DAI_TOI_DA ||
            throw(ArgumentError("$ten dài $(length(ds)) ký tự, vượt giới hạn $DO_DAI_TOI_DA"))
        for (k, c) in enumerate(ds)
            la_chu_cai_latin(c) ||
                throw(ArgumentError("$ten có ký tự không hợp lệ '$c' tại vị trí $k (chỉ nhận A–Z, a–z)"))
        end
    end
    return (String(X), String(Y))
end

la_chu_cai_latin(c::Char) = ('A' <= c <= 'Z') || ('a' <= c <= 'z')

"""
    khoang_cach_sua(X, Y) -> (khoang_cach, bang)

Bảng quy hoạch động hai tiền tố. `bang[i + 1, j + 1]` là số thao tác ít
nhất biến i ký tự đầu của X thành j ký tự đầu của Y. Chi phí mỗi thao tác
bằng 1, giữ nguyên ký tự giống nhau không mất chi phí.
"""
function khoang_cach_sua(X::AbstractString, Y::AbstractString)
    m, n = length(X), length(Y)
    bang = zeros(Int, m + 1, n + 1)
    for i in 1:m
        bang[i + 1, 1] = i          # xoá hết i ký tự
    end
    for j in 1:n
        bang[1, j + 1] = j          # chèn đủ j ký tự
    end
    for i in 1:m, j in 1:n
        thay = bang[i, j] + (X[i] == Y[j] ? 0 : 1)
        xoa = bang[i, j + 1] + 1
        chen = bang[i + 1, j] + 1
        bang[i + 1, j + 1] = min(thay, xoa, chen)
    end
    return (khoang_cach = bang[m + 1, n + 1], bang = bang)
end

"""
    truy_vet_sua(X, Y, bang) -> Vector{BuocSua}

Truy ngược từ ô (m, n) về (0, 0) theo bảng đã tính, ghi lại thao tác rồi
đảo dãy để có thứ tự từ X đến Y. Vị trí ghi trong mỗi bước là vị trí trên
xâu đang được biến đổi, nhờ vậy ap_dung_cac_buoc chạy lại được.
"""
function truy_vet_sua(X::AbstractString, Y::AbstractString, bang::AbstractMatrix{Int})
    m, n = length(X), length(Y)
    size(bang) == (m + 1, n + 1) ||
        throw(ArgumentError("bảng phải có kích thước $(m + 1) x $(n + 1)"))
    buoc = BuocSua[]
    i, j = m, n
    while i > 0 || j > 0
        if i > 0 && j > 0 && X[i] == Y[j] && bang[i, j] == bang[i + 1, j + 1]
            i -= 1
            j -= 1                       # giữ nguyên, không sinh thao tác
        elseif i > 0 && j > 0 && bang[i, j] + 1 == bang[i + 1, j + 1]
            push!(buoc, BuocSua(:thay, j, X[i], Y[j]))
            i -= 1
            j -= 1
        elseif i > 0 && bang[i, j + 1] + 1 == bang[i + 1, j + 1]
            push!(buoc, BuocSua(:xoa, j + 1, X[i], '\0'))
            i -= 1
        elseif j > 0 && bang[i + 1, j] + 1 == bang[i + 1, j + 1]
            push!(buoc, BuocSua(:chen, j, '\0', Y[j]))
            j -= 1
        else
            error("bảng không nhất quán tại ô ($i, $j)")
        end
    end
    reverse!(buoc)
    return buoc
end

"""
    ap_dung_cac_buoc(X, buoc) -> (xau, lich_su)

Thực hiện lại từng thao tác trên xâu đang thay đổi, kiểm vị trí và ký tự
trước khi sửa. Trả về xâu cuối cùng và dãy xâu sau mỗi bước (kể cả xâu gốc)
để đối chiếu với kết quả in ra màn hình.
"""
function ap_dung_cac_buoc(X::AbstractString, buoc::AbstractVector{BuocSua})
    s = collect(X)
    lich_su = String[String(X)]
    for (k, b) in enumerate(buoc)
        if b.loai === :thay
            1 <= b.vi_tri <= length(s) ||
                throw(ArgumentError("bước $k: vị trí $(b.vi_tri) nằm ngoài xâu dài $(length(s))"))
            s[b.vi_tri] == b.cu ||
                throw(ArgumentError("bước $k: vị trí $(b.vi_tri) đang là '$(s[b.vi_tri])', không phải '$(b.cu)'"))
            s[b.vi_tri] = b.moi
        elseif b.loai === :xoa
            1 <= b.vi_tri <= length(s) ||
                throw(ArgumentError("bước $k: vị trí $(b.vi_tri) nằm ngoài xâu dài $(length(s))"))
            s[b.vi_tri] == b.cu ||
                throw(ArgumentError("bước $k: vị trí $(b.vi_tri) đang là '$(s[b.vi_tri])', không phải '$(b.cu)'"))
            deleteat!(s, b.vi_tri)
        elseif b.loai === :chen
            1 <= b.vi_tri <= length(s) + 1 ||
                throw(ArgumentError("bước $k: vị trí chèn $(b.vi_tri) không hợp lệ với xâu dài $(length(s))"))
            insert!(s, b.vi_tri, b.moi)
        elseif b.loai === :giu
            # không đổi xâu
        else
            throw(ArgumentError("bước $k: loại thao tác '$(b.loai)' không hợp lệ"))
        end
        push!(lich_su, String(s))
    end
    return (xau = String(s), lich_su = lich_su)
end

dem_thao_tac(buoc) = count(b -> b.loai !== :giu, buoc)

"""Mô tả một thao tác bằng tiếng Việt, vị trí đếm trên xâu hiện tại."""
function mo_ta_buoc(b::BuocSua)
    if b.loai === :thay
        return "thay vị trí $(b.vi_tri): '$(b.cu)' → '$(b.moi)'"
    elseif b.loai === :xoa
        return "xóa vị trí $(b.vi_tri): '$(b.cu)'"
    elseif b.loai === :chen
        return "chèn vị trí $(b.vi_tri): '$(b.moi)'"
    else
        return "giữ vị trí $(b.vi_tri): '$(b.cu)'"
    end
end

"""Chuỗi mô tả ngắn gọn cả dãy thao tác, dùng cho bảng kết quả."""
function chuoi_thao_tac(buoc)
    ds = [mo_ta_buoc(b) for b in buoc if b.loai !== :giu]
    return isempty(ds) ? "(không có thao tác)" : join(ds, "; ")
end

"""
    in_bang(bang, X, Y)

In nguyên bảng quy hoạch động kèm nhãn hai xâu, chỉ dùng cho trường hợp
độ dài tối đa 6 (yêu cầu tùy chọn của phiếu).
"""
function in_bang(bang::AbstractMatrix{Int}, X::AbstractString, Y::AbstractString)
    m, n = length(X), length(Y)
    (m > 6 || n > 6) &&
        throw(ArgumentError("chỉ in bảng khi độ dài hai xâu không quá 6 (hiện tại $m và $n)"))
    cot = String["ε"]
    for j in 1:n
        push!(cot, string(Y[j]))
    end
    println("      " * join([rpad(c, 4) for c in cot]))
    for i in 0:m
        nhan = i == 0 ? "ε" : string(X[i])
        dong = [lpad(string(bang[i + 1, j + 1]), 4) for j in 0:n]
        println(rpad(nhan, 3) * " |" * join(dong))
    end
    return nothing
end

end # module
