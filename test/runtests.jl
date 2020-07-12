using VisualStringDistances
using Test
using VisualStringDistances: glyph!, printglyph, GlyphCoordinates, ConstantVector
using UnbalancedOptimalTransport: fdot, KL, sinkhorn_divergence!
using LinearAlgebra: dot

@testset "VisualStringDistances.jl" begin

    @testset "Glyphs" begin
        g = glyph!(hex2bytes("0000000018242442427E424242420000"))
        @test sprint(show, g) == """
             --------
             --------
             --------
             --------
             ---##---
             --#--#--
             --#--#--
             -#----#-
             -#----#-
             -######-
             -#----#-
             -#----#-
             -#----#-
             -#----#-
             --------
             --------
             """

        @test_throws ArgumentError glyph!(hex2bytes("0000000018242442427E424242420"))
        g = glyph!(hex2bytes("00000000000003C0042004200840095008E01040100010002000200000000000"))
        @test sprint(show, g) == """
            ----------------
            ----------------
            ----------------
            ------####------
            -----#----#-----
            -----#----#-----
            ----#----#------
            ----#--#-#-#----
            ----#---###-----
            ---#-----#------
            ---#------------
            ---#------------
            --#-------------
            --#-------------
            ----------------
            ----------------
            """
    end

    @testset "Printing abc many ways" begin

        abc_printed_rep = """
                          ------------------------
                          ------------------------
                          ------------------------
                          ---------#--------------
                          ---------#--------------
                          ---------#--------------
                          --####---#-###----####--
                          -#----#--##---#--#----#-
                          ------#--#----#--#------
                          --#####--#----#--#------
                          -#----#--#----#--#------
                          -#----#--#----#--#------
                          -#---##--##---#--#----#-
                          --###-#--#-###----####--
                          ------------------------
                          ------------------------
                          """

        @test sprint(show, Glyph("abc")) == abc_printed_rep
        @test sprint(printglyph, Glyph("abc")) == abc_printed_rep
        @test sprint(printglyph, "abc") == abc_printed_rep
        @test sprint(printglyph, hcat(Glyph("a"), Glyph("bc"))) == abc_printed_rep
        @test sprint(printglyph, GlyphCoordinates("abc")) == abc_printed_rep
    end

    @testset "More GlyphCoordinates" begin

        @test GlyphCoordinates('a') ==
              GlyphCoordinates("a") ==
              GlyphCoordinates{Float64}("a")
        @test length(GlyphCoordinates('a')) == sum(!iszero, Glyph("a"))
        # test indexing
        @test GlyphCoordinates('a')[1] == collect(Tuple(findfirst(!iszero, Glyph("a"))))

        gc =  GlyphCoordinates('a')
        @test gc[1:length(gc)] == gc[:] == gc.v

        gcF32 =  GlyphCoordinates{Float32}('a')
        @test gcF32[:] ≈ gc[:]
    end

    @testset "ConstantVector" begin
        for constant in (5.0, 2.2 + im * 3.2, 1f0)
            T = typeof(constant)
            c = ConstantVector{constant,T}(10)
            @test collect(c) isa Vector{T}
            @test length(c) == 10
            @test c == fill(constant, 10) == collect(c)
            @test sum(c) == sum(collect(c))
            f(x) = sin(x) + 10.0
            d = randn(10)
            @test fdot(f, c, d) ≈ fdot(f, collect(c), d)
            @test fdot(f, d, c) ≈ fdot(f, d, collect(c))

            @test dot(c, d) ≈ dot(collect(c), d)
            @test dot(d, c) ≈ dot(d, collect(c))
        end
    end


    @testset "`visual_distance`" begin
        for T in (Float32, Float64), ϵ in (T(0.1), T(0.2)), ρ in (T(1.0), T(5.0))
            v1 = visual_distance(T, "abc", "def"; D=KL(ρ), ϵ=ϵ)
            v2 = visual_distance(T, "def", "ghi"; D=KL(ρ), ϵ=ϵ)
            v3 = visual_distance(T, "abc", "ghi"; D=KL(ρ), ϵ=ϵ)

            @test v1 >= 0
            @test v1 ≈ visual_distance(T, "def", "abc"; D=KL(ρ), ϵ=ϵ) rtol = 1e-3

            @test v3 <= v1 + v2

            v4 = visual_distance(T, "abc", "abd"; D=KL(ρ), ϵ=ϵ)
            @test v4 <= v1
        end

        # Defaults
        v1 = visual_distance("abc", "def")
        v2 = visual_distance("def", "ghi")
        v3 = visual_distance("abc", "ghi")

        @test v1 >= 0
        @test v1 ≈ visual_distance("def", "abc") rtol = 1e-3

        @test v3 <= v1 + v2

        v4 = visual_distance("abc", "abd")
        @test v4 <= v1


        abc_measure = word_measure("abc")
        def_measure = word_measure("def")
        @test v1 ≈ sinkhorn_divergence!(KL(1.0), abc_measure, def_measure, 0.1)

    end
end
