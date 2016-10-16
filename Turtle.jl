module Turtles
#=
	This module tracks the state of a turtle
	I suppose multiple turtles will be allowed maybe even remote ones
	
	Non Euclidean geometry will be incorporated eventually so that needs to be borne in mind too
	
	So the reference point for the T will be in Polar co-ordinates, any other representation shall be invalidated by movement
=#

@enum PenState PenUp PenDown PenRed PenBlue PenGreen

type Turtle
	a::Float64 # which way is T facing
	r::Float64 # distance travelled since spawning
	p::PenState
	track::Vector{Tuple{Float64, Float64, PenState}} # this type is likely to change, for now just it is (a, r, pen) deltas
	Turtle() = new(0.0, 0.0, PenUp, [(0.0, 0.0, PenUp)])
end

function forward(t::Turtle, r)
	t.r += r
	push!(t.track, (0.0, -r, t.p))
end

function back(t::Turtle, r)
	t.r -= r
	push!(t.track, (0.0, -r, t.p))
end

function left(t::Turtle, a)
	t.a -= a
	push!(t.track, (-a, 0, t.p))
end

function right(t::Turtle, a)
	t.a += a
	push!(t.track, (a, 0, t.p))
end

end