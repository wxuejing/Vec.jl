#=
VecE3: a 3d euclidean vector
=#


immutable VecE3 <: VecE
    x :: Float64
    y :: Float64
    z :: Float64

    VecE3() = new(0.0,0.0,0.0)
    VecE3(x::Real, y::Real, z::Real) = new(x,y,z)
end

Base.length(::VecE3) = 3
Base.copy(a::VecE3) = VecE3(a.x, a.y, a.z)
Base.convert(::Type{Vector{Float64}}, a::VecE3) = [a.x, a.y, a.z]
function Base.convert{R<:Real}(::Type{VecE3}, a::AbstractArray{R})
    @assert(length(a) == 3)
    VecE3(a[1], a[2], a[3])
end
Base.show(io::IO, a::VecE3) = @printf(io, "VecE3(%.3f, %.3f, %.3f)", a.x, a.y, a.z)

@compat Base.:+(a::VecE3, b::Real) = VecE3(a.x+b, a.y+b, a.z+b)
@compat Base.:+(a::VecE3, b::VecE3) = VecE3(a.x+b.x, a.y+b.y, a.z+b.z)

@compat Base.:-(a::VecE3) = VecE3(-a.x, -a.y, -a.z)
@compat Base.:-(a::VecE3, b::Real) = VecE3(a.x-b, a.y-b, a.z-b)
@compat Base.:-(a::VecE3, b::VecE3) = VecE3(a.x-b.x, a.y-b.y, a.z-b.z)

@compat Base.:*(a::VecE3, b::Real) = VecE3(a.x*b, a.y*b, a.z*b)

@compat Base.:/(a::VecE3, b::Real) = VecE3(a.x/b, a.y/b, a.z/b)

@compat Base.:^(a::VecE3, b::Integer) = VecE3(a.x^b, a.y^b, a.z^b)
@compat Base.:^(a::VecE3, b::AbstractFloat) = VecE3(a.x^b, a.y^b, a.z^b)

# %(a::VecE3, b::Real) = VecE3(a.x%b, a.y%b, a.z%b)

@compat Base.:(==)(a::VecE3, b::VecE3) = isequal(a.x, b.x) && isequal(a.y, b.y) && isequal(a.z, b.z)
Base.isequal(a::VecE3, b::VecE3) = isequal(a.x, b.x) && isequal(a.y, b.y) && isequal(a.z, b.z)

Base.isfinite(a::VecE3) = isfinite(a.x) && isfinite(a.y) && isfinite(a.z)
Base.isinf(a::VecE3) = isinf(a.x) || isinf(a.y) || isinf(a.z)
Base.isnan(a::VecE3) = isnan(a.x) || isnan(a.y) || isnan(a.z)

Base.round(a::VecE3) = VecE3(round(a.x), round(a.y), round(a.z))
Base.floor(a::VecE3) = VecE3(floor(a.x), floor(a.y), floor(a.z))
Base.ceil(a::VecE3) = VecE3(ceil(a.x), ceil(a.y), ceil(a.z))
Base.trunc(a::VecE3) = VecE3(trunc(a.x), trunc(a.y), trunc(a.z))
Base.clamp(a::VecE3, lo::Real, hi::Real) = VecE3(clamp(a.x, lo, hi), clamp(a.y, lo, hi), clamp(a.z, lo, hi))

Base.abs(a::VecE3) = sqrt(a.x*a.x + a.y*a.y + a.z*a.z)
Base.abs2(a::VecE3) = a.x*a.x + a.y*a.y + a.z*a.z
function Base.norm(a::VecE3)
    m = abs(a)
    VecE3(a.x/m, a.y/m, a.z/m)
end

function dist(a::VecE3, b::VecE3)
    Δx = a.x-b.x
    Δy = a.y-b.y
    Δz = a.z-b.z
    sqrt(Δx*Δx + Δy*Δy + Δz*Δz)
end
function dist2(a::VecE3, b::VecE3)
    Δx = a.x-b.x
    Δy = a.y-b.y
    Δz = a.z-b.z
    Δx*Δx + Δy*Δy + Δz*Δz
end

Base.dot(a::VecE3, b::VecE3) = a.x*b.x + a.y*b.y + a.z*b.z
proj(a::VecE3, b::VecE3, ::Type{Float64}) = (a.x*b.x + a.y*b.y + a.z*b.z) / sqrt(b.x*b.x + b.y*b.y + b.z*b.z) # dot(a,b) / |b|
function proj(a::VecE3, b::VecE3, ::Type{VecE3})
    # dot(a,b) / dot(b,b) ⋅ b
    s = (a.x*b.x + a.y*b.y + a.z*b.z) / (b.x*b.x + b.y*b.y + b.z*b.z)
    VecE3(s*b.x, s*b.y, s*b.z)
end

function Base.cross(a::VecE3, b::VecE3)
    x = a.y*b.z - a.z*b.y
    y = a.x*b.z - a.z*b.x
    z = a.x*b.y - a.y*b.x
    VecE3(x,y,z)
end

lerp(a::VecE3, b::VecE3, t::Real) = VecE3(a.x + (b.x-a.x)*t, a.y + (b.y-a.y)*t, a.z + (b.z-a.z)*t)

function rot(a::VecE3, axis::VecE3, θ::Real)

    #=
    rotate the point a: (x,y,z) about the axis: (u,v,w) by the angle θ following the
    right hand rule
    =#

    x,y,z = a.x, a.y, a.z
    u,v,w = axis.x, axis.y, axis.z

    u² = u*u
    v² = v*v
    w² = w*w

    m = u² + v² + w²

    c = cos(θ)
    s = sin(θ)
    mc = 1.0 - c

    rtms = sqrt(m)*s

    magc = m*c
    ux_vy_wz_mc = (u*x + v*y + w*z)*mc

    new_x = (u*ux_vy_wz_mc + x*magc + rtms*(-w*y + v*z)) / m
    new_y = (v*ux_vy_wz_mc + y*magc + rtms*( w*x - u*z)) / m
    new_z = (w*ux_vy_wz_mc + z*magc + rtms*(-v*x + u*y)) / m

    VecE3(new_x, new_y, new_z)
end
function rot_normalized(a::VecE3, axis::VecE3, θ::Real)

    #=
    rotate the point a: (x,y,z) about the axis: (u,v,w) by the angle θ following the
    right hand rule

    Here we assume axis is normalized
    =#

    x,y,z = a.x, a.y, a.z
    u,v,w = axis.x, axis.y, axis.z

    u² = u*u
    v² = v*v
    w² = w*w

    m = u² + v² + w²

    c = cos(θ)
    s = sin(θ)
    mc = 1.0 - c

    ux_vy_wz_mc = (u*x + v*y + w*z)*mc

    new_x = u*ux_vy_wz_mc + x*c + (-w*y + v*z)*s
    new_y = v*ux_vy_wz_mc + y*c + ( w*x - u*z)*s
    new_z = w*ux_vy_wz_mc + z*c + (-v*x + u*y)*s

    VecE3(new_x, new_y, new_z)
end