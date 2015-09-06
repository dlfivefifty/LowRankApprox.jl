#= src/LowRankApprox.jl
=#

module LowRankApprox

importall Base
import Base.LinAlg: BlasComplex, BlasFloat, BlasInt, BlasReal, chkstride1

export

  # LowRankApprox.jl
  LRAOptions,

  # id.jl
  IDPackedV,
  ID,
  id, id!,
  idfact, idfact!,

  # linop.jl
  AbstractLinearOperator,
  LinearOperator,
  HermitianLinearOperator,

  # permute.jl
  PermutationMatrix,
  RowPermutation,
  ColumnPermutation,

  # pqr.jl
  pqr, pqr!,
  pqrfact, pqrfact!,

  # rrange.jl
  rrange,

  # sketch.jl
  SketchMatrix,
  RandomGaussian,
  RandomSubset,
  SRFT,
  SparseRandomGaussian,
  sketch,
  sketchfact,

  # snorm.jl
  snorm,
  snormdiff,

  # trapezoidal.jl
  Trapezoidal,
  LowerTrapezoidal,
  UpperTrapezoidal

# common

type LRAOptions
  atol::Float64
  nb::Int
  rank::Int
  rtol::Float64
  sketch::Symbol
  sketch_randn_niter::Int
  sketch_randn_samp::Int
  sketch_srft_samp::Int
  sketch_subs_samp::Int
  snorm_info::Bool
  snorm_niter::Int
end

LRAOptions(;
    atol::Real=0.,
    nb::Integer=32,
    rank::Integer=-1,
    rtol::Real=default_rtol(Float64),
    sketch::Symbol=:none,
    sketch_randn_niter::Integer=0,
    sketch_randn_samp::Integer=8,
    sketch_srft_samp::Integer=8,
    sketch_subs_samp::Integer=6,
    snorm_info::Bool=false,
    snorm_niter::Integer=32,
    ) =
  LRAOptions(
    atol,
    nb,
    rank,
    rtol,
    sketch,
    sketch_randn_niter,
    sketch_randn_samp,
    sketch_srft_samp,
    sketch_subs_samp,
    snorm_info,
    snorm_niter,
    )

function copy(opts::LRAOptions; args...)
  opts_ = LRAOptions(
    opts.atol,
    opts.nb,
    opts.rank,
    opts.rtol,
    opts.sketch,
    opts.sketch_randn_niter,
    opts.sketch_randn_samp,
    opts.sketch_srft_samp,
    opts.sketch_subs_samp,
    opts.snorm_info,
    opts.snorm_niter,
    )
  for (key, value) in args
    setfield!(opts_, key, value)
  end
  opts_
end

function chkopts(opts)
  opts.atol >= 0 || throw(ArgumentError("atol"))
  opts.nb > 0 || throw(ArgumentError("nb"))
  opts.rtol >= 0 || throw(ArgumentError("rtol"))
  opts.sketch in (:none, :randn, :sprn, :srft, :subs) ||
    throw(ArgumentError("sketch"))
  opts.sketch_randn_samp >= 0 || throw(ArgumentError("sketch_randn_samp"))
  opts.sketch_srft_samp >= 0 || throw(ArgumentError("sketch_srft_samp"))
  opts.sketch_subs_samp > 0 || throw(ArgumentError("sketch_subs_samp"))
end

default_rtol{T}(::Type{T}) = 5*eps(real(one(T)))

# source files

include("lapack.jl")
include("linop.jl")
include("permute.jl")
include("snorm.jl")
include("trapezoidal.jl")
include("util.jl")

include("id.jl")
include("pqr.jl")
include("rrange.jl")
include("sketch.jl")

end  # module