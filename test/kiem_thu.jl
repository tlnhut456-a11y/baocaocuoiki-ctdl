# test/kiem_thu.jl - bo kiem thu DT056
# Chay: julia test/kiem_thu.jl
# Gom 13 ca doc lap (2 vi du, 5 ca phieu, 2 ca tu thiet ke, 3 ca bien,
# 1 ca du lieu sai) va phan kiem bat bien tren du lieu ngau nhien.

using Test
using Random

include(joinpath(@__DIR__, "..", "src", "DeTai.jl"))
using .DeTai

const SO_CA = 13

"""
    kiem_mot_ca(X, Y, mong_doi)

Kiem mot ca tron ven: khoang cach, so thao tac, xau cuoi va tinh nhat quan
cua bang. Tra ve so phep kiem da chay.
"""
function kiem_mot_ca(X, Y, mong_doi)
    kq = khoang_cach_sua(X, Y)
    buoc = truy_vet_sua(X, Y, kq.bang)
    ap = ap_dung_cac_buoc(X, buoc)

    @test kq.khoang_cach == mong_doi
    @test dem_thao_tac(buoc) == kq.khoang_cach
    @test ap.xau == Y
    @test length(ap.lich_su) == dem_thao_tac(buoc) + 1
    @test kq.bang[1, 1] == 0
    @test kq.bang[end, end] == mong_doi
    return nothing
end

@testset verbose = true "DT056 - khoảng cách chỉnh sửa" begin

    @testset "VD01: CAT → CUT" begin
        kiem_mot_ca("CAT", "CUT", 1)
    end

    @testset "VD02: A → xâu rỗng" begin
        kiem_mot_ca("A", "", 1)
    end

    @testset "P01: rỗng → rỗng" begin
        kiem_mot_ca("", "", 0)
    end

    @testset "P02: rỗng → AB" begin
        kiem_mot_ca("", "AB", 2)
    end

    @testset "P03: ABC → ABC" begin
        kiem_mot_ca("ABC", "ABC", 0)
    end

    @testset "P04: AB → BA" begin
        kiem_mot_ca("AB", "BA", 2)
    end

    @testset "P05: ABC → AC" begin
        kiem_mot_ca("ABC", "AC", 1)
    end

    @testset "TK01: SUNDAY → SATURDAY" begin
        kiem_mot_ca("SUNDAY", "SATURDAY", 3)
    end

    @testset "TK02: kitten → sitting" begin
        kiem_mot_ca("kitten", "sitting", 3)
    end

    @testset "B01: A → B" begin
        kiem_mot_ca("A", "B", 1)
    end

    @testset "B02: xâu dài 30" begin
        x = "ABCDEFGHIJKLMNOPQRSTUVWXYZABCD"
        y = "ABCDEFGHIJKLMNOPQRSTUVWXYZABCE"
        @test length(x) == 30 && length(y) == 30
        kiem_mot_ca(x, y, 1)
    end

    @testset "B03: AAAA → AA" begin
        kiem_mot_ca("AAAA", "AA", 2)
    end

    @testset "LOI01: dữ liệu không hợp lệ" begin
        @test_throws ArgumentError kiem_tra_dau_vao("A"^31, "A")
        @test_throws ArgumentError kiem_tra_dau_vao("ABC", "A1")
        @test_throws ArgumentError kiem_tra_dau_vao("A B", "AB")
        @test_throws ArgumentError kiem_tra_dau_vao(123, "AB")
        @test_throws ArgumentError kiem_tra_dau_vao("ABC", nothing)
        # ca hop le sat bien van phai qua
        @test kiem_tra_dau_vao("A"^30, "A"^30) == ("A"^30, "A"^30)
    end

    @testset "Bất biến trên dữ liệu ngẫu nhiên" begin
        Random.seed!(456)
        so_cap = 400
        for _ in 1:so_cap
            x = String(rand('A':'D', rand(0:8)))
            y = String(rand('A':'D', rand(0:8)))
            kq = khoang_cach_sua(x, y)
            buoc = truy_vet_sua(x, y, kq.bang)
            ap = ap_dung_cac_buoc(x, buoc)
            @test ap.xau == y
            @test dem_thao_tac(buoc) == kq.khoang_cach
            @test kq.khoang_cach == khoang_cach_sua(y, x).khoang_cach
            @test kq.khoang_cach <= length(x) + length(y)
            # moi o chenh lech voi ba o truoc toi da 1
            for i in 1:length(x), j in 1:length(y)
                @test kq.bang[i + 1, j + 1] <= kq.bang[i, j] + 1
                @test kq.bang[i + 1, j + 1] <= kq.bang[i, j + 1] + 1
                @test kq.bang[i + 1, j + 1] <= kq.bang[i + 1, j] + 1
            end
        end
    end
end

println()
println("ĐÃ CHẠY $SO_CA CA (2 ví dụ, 5 ca phiếu, 2 tự thiết kế, 3 biên, 1 dữ liệu sai)")
println("và 400 cặp ngẫu nhiên để kiểm bất biến.")
