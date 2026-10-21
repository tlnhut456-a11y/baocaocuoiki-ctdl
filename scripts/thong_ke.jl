# scripts/thong_ke.jl - khảo sát ba quy mô trong miền của phiếu
# Chạy: julia scripts/thong_ke.jl
# Miền DT056 cho độ dài mỗi xâu từ 0 đến 30 nên ba quy mô chọn là 10, 20, 30.

include(joinpath(@__DIR__, "..", "src", "DeTai.jl"))
using .DeTai
using Printf
using Random

"""
    tao_cap(n)

Sinh cặp xâu cùng độ dài n trên bảng chữ A–H. Dùng hạt giống cố định để
lần chạy sau lặp lại đúng kết quả trong báo cáo.
"""
function tao_cap(n)
    x = String(rand('A':'H', n))
    y = String(rand('A':'H', n))
    return x, y
end

"""
    do_thoi_gian(x, y, so_vong)

Chạy nóng một lần, sau đó chia thành 5 đợt, mỗi đợt `so_vong` lần gọi,
lấy trung vị của 5 đợt để giảm nhiễu do hệ điều hành.
"""
function do_thoi_gian(x, y, so_vong::Int)
    khoang_cach_sua(x, y)
    cac_dot = Float64[]
    for _ in 1:5
        t = @elapsed for _ in 1:so_vong
            khoang_cach_sua(x, y)
        end
        push!(cac_dot, t / so_vong)
    end
    return sort!(cac_dot)[3]
end

function main()
    Random.seed!(456)
    println("KHẢO SÁT BA QUY MÔ — DT056")
    println("Cặp xâu sinh ngẫu nhiên trên bảng chữ A–H, cùng độ dài m = n = 10, 20, 30.")
    println("Thời gian là trung vị của 5 đợt đo, mỗi đợt vài trăm lần gọi.")
    println()
    @printf("%-4s %-6s %-8s %-9s %-12s %-7s\n",
            "Q", "m=n", "số ô", "bước vết", "thời gian", "tỉ lệ")
    println("-"^54)
    truoc = nothing
    for (k, n) in enumerate((10, 20, 30))
        x, y = tao_cap(n)
        kq = khoang_cach_sua(x, y)
        buoc = truy_vet_sua(x, y, kq.bang)
        so_vong = n == 10 ? 2000 : (n == 20 ? 500 : 200)
        t = do_thoi_gian(x, y, so_vong)
        ti_le = truoc === nothing ? "-" : @sprintf("%.2fx", t / truoc)
        @printf("Q%-3d %-6d %-8d %-9d %-12s %-7s\n",
                k, n, (n + 1)^2, length(buoc), @sprintf("%.3f us", t * 1e6), ti_le)
        truoc = t
    end
    println()
    println("Số ô bảng tăng từ 121 lên 441 rồi 961, đúng bằng (m+1)(n+1).")
    println("Số bước truy vết không vượt m + n = 20, 40, 60.")
    println("Thời gian tăng theo số ô; ở quy mô nhỏ phép đo còn nhiễu nên căn cứ")
    println("chính vẫn là số ô và số bước truy vết, khớp dự đoán O(mn).")
end

main()
