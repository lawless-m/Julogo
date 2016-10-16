include("Turtle.jl")
using Turtles

function prompt()
	@printf "JL> "
end

stack = Any[]

cmds = Dict{AbstractString, Function}("fd"=>Turtles.forward, "rt"=>Turtles.right, "+"=>+)

prompt()
for ln in eachline(STDIN)
	sp = split(ln, [' ', '\n']; limit=2)
	while size(sp)[1] > 1
		tok, ln = sp
		if haskey(cmds, tok)
			push!(stack, cmds[tok])
		else
			n = tryparse(Float64, tok)
			if isnull(n)
				println("Expecting numeric")
				break
			end
			push!(stack, get(n))
		end
		sp = split(ln, [' ', '\n']; limit=2)
	end
	println(stack)
	stack = Any[]
	prompt()
end
