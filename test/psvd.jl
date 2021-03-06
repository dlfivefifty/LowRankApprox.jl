#= test/psvd.jl
=#

println("psvd.jl")

m = 128
n =  64
M = matrixlib(:fourier, rand(m), rand(n))
opts = LRAOptions(maxdet_tol=0., sketch_randn_niter=1)

@time for (t, s) in ((:none,                 :none ),
                     (:RandomGaussian,       :randn),
                     (:RandomSubset,         :sub  ),
                     (:SRFT,                 :srft ),
                     (:SparseRandomGaussian, :sprn ))
  opts.sketch = s
  for T in (Float32, Float64, Complex64, Complex128)
    println("  $t/$T")

    rtol = 5*eps(real(T))
    approx_rtol = 100*rtol
    opts.rtol = rtol

    A = convert(Array{T}, T <: Real ? real(M) : M)

    F = psvdfact(A, opts)
    @test norm(A - full(F)) < approx_rtol*norm(A)

    s = psvdvals(A, opts, rank=F[:k], rtol=0.)
    @test norm(s - F[:S]) < approx_rtol*norm(s)

    xm = rand(T, m)
    xn = rand(T, n)
    y = A  *xn; @test norm(y - F  *xn) < approx_rtol*norm(y)
    y = A' *xm; @test norm(y - F' *xm) < approx_rtol*norm(y)
    y = A.'*xm; @test norm(y - F.'*xm) < approx_rtol*norm(y)

    Bm = rand(T, m, m)
    Bn = rand(T, n, n)
    C = A   *Bn  ; @test norm(C - F   *Bn  ) < approx_rtol*norm(C)
    C = A   *Bn' ; @test norm(C - F   *Bn' ) < approx_rtol*norm(C)
    C = A   *Bn.'; @test norm(C - F   *Bn.') < approx_rtol*norm(C)
    C = A'  *Bm  ; @test norm(C - F'  *Bm  ) < approx_rtol*norm(C)
    C = A'  *Bm' ; @test norm(C - F'  *Bm' ) < approx_rtol*norm(C)
    C = A.' *Bm  ; @test norm(C - F.' *Bm  ) < approx_rtol*norm(C)
    C = A.' *Bm.'; @test norm(C - F.' *Bm.') < approx_rtol*norm(C)
    C = Bm  *A   ; @test norm(C - Bm  *F   ) < approx_rtol*norm(C)
    C = Bn  *A'  ; @test norm(C - Bn  *F'  ) < approx_rtol*norm(C)
    C = Bn  *A.' ; @test norm(C - Bn  *F.' ) < approx_rtol*norm(C)
    C = Bm' *A   ; @test norm(C - Bm' *F   ) < approx_rtol*norm(C)
    C = Bn' *A'  ; @test norm(C - Bn' *F'  ) < approx_rtol*norm(C)
    C = Bm.'*A   ; @test norm(C - Bm.'*F   ) < approx_rtol*norm(C)
    C = Bn.'*A.' ; @test norm(C - Bn.'*F.' ) < approx_rtol*norm(C)

    x = A*rand(T, n)
    y = F\x; @test norm(x - A*y) < approx_rtol*norm(x)

    X = A*rand(T, n, n)
    C = F\X; @test norm(X - A*C) < approx_rtol*norm(X)
  end
end
