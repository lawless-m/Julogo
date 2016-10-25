module Lex

abstract Lexeme

type Oper <: Lexeme
	txt::AbstractString
	fn::Function
	arity::Int64
	args::Vector{Oper}
	Oper(t, fn, a) = new(t, v, a, Oper[])
	Oper(t, p) = new(t, p[1], p[2])
end

type Cmd <: Lexeme
	txt::AbstractString
	fn::Function
	arity::Int64
	args::Vector{Oper}
	Cmd(t, f, a) = new(t, v, a, Oper[])
	Cmd(t, p) = new(t, p[1], p[2], Oper[])
end

type SymbolTable
	parent::Union{SymbolTable, Void}
	symbols::Dict{AbstractString, Union{Float64, AbstractString}}
	SymbolTable() = new(nothing, Dict{AbstractString, Union{Float64, AbstractString}}())
	SymbolTable(p) = new(p, Dict{AbstractString, Union{Float64, AbstractString}}())
end

function lookup(s::Symbol, st::SymbolTable)
	if st==nothing
		error("$s not found")
	end
	if haskey(st, s)
		st[s]
	else
		lookup(s, st.parent)
	end
end

function assign(s::Symbol, st::SymbolTable, v)
	st[s] = v
end

CMDS = Dict{AbstractString, Tuple{Function, Int64}}()
OPS = Dict{AbstractString, Tuple{Function, Int64}}()

#CMDS["forward"] = (forward, 1)
#CMDS["back"] = (backward, 1)
#CMDS["left"] = (left, 1)
#CMDS["right"] = (right, 1)
CMDS["exit"] = (quit, 0)
CMDS["print"] = (println, 1)

OPS["+"] = (+, 2)
OPS["-"] = (-, 2)
OPS["*"] = (*, 2)
OPS["/"] = (/, 2)
OPS["MOD"] = (mod, 2)
OPS["ABS"] = (abs, 1)
OPS["ARCTAN"] = (atan, 1)
OPS["SIN"] = (sin, 1)
OPS["COS"] = (cos, 1)
OPS["TAN"] = (tan, 1)


function input(stream, promptfn)
	promptfn()
	for ln in eachline(stream)
		while length(ln) > 0
			p, ln = split(ln, [' ', '\r', '\n'];limit=2)
			if length(p) > 0
				if haskey(CMDS, p)
					produce(Cmd(p, CMDS[p]))
				elseif haskey(OPS, p)
					produce(Oper(p, OPS[p]))
				elseif isnumber(p)
					produce(Oper(p, ((st)->parse(Float64, p), 0)))
				elseif p[1] == ':'
					produce(Oper(p, ((st)->lookup(symbol(p)), p)))
				elseif p[1] == '"'
					produce(Oper(p, ((st, v)->assign(st, symbol(p), v), p)))
				end
			end
		end
		promptfn()
	end
end


# staahhhppp
end
