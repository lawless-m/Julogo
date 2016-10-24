module Lex

abstract Lexeme

type Num <: Lexeme
	txt::AbstractString
	value::Float64
end

type Oper <: Lexeme
	txt::AbstractString
	value::Function
	arity::Int64
end

type Cmd <: Lexeme
	txt::AbstractString
	value::Function
	arity::Int64
end

type Symbol <: Lexeme
	txt::AbstractString
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


CMDS = Dict{AbstractString, Tuple{Function, Int64}}()

CMDS["forward"] = (forward, 1)
CMDS["back"] = (backward, 1)
CMDS["left"] = (left, 1)
CMDS["right"] = (right, 1)
CMDS["exit"] = (quit, 0)

OPS["+"] = (+, 2)
OPS["-"] = (-, 2)
OPS["*"] = (*, 2)
OPS["/"] = (/, 2)
OPS("MOD") = (mod, 2)
OPS("ABS") = (abs, 1
OPS("ARCTAN") = (atan, 1)
OPS("SIN") = (sin, 1)
OPS("COS") = (cos, 1)
OPS("TAN") = (tan, 1)

function nullfn()
end

function input(stream, promptfn=nullfn)
	promptfn()
	for ln in eachline(stream)
		while length(ln) > 0
			p, ln = split(ln, [' ', '\r', '\n'];limit=2)
			if length(p) > 0
				if haskey(CMDS, p)
					produce(Cmd(p, CMDS[p], CMDS[p]))
				elseif haskey(OPS, p)
					produce(Op(p, CMDS[p], CMDS[p]))
				elseif isnumber(p)
					produce(Num(p, parse(Float64, p)))
				elseif p[1] == ":"
					produce(Expr(p, lookup, p)
				
				end
			end
		end
		promptfn()
	end
end

