module Lex

export Lexeme, Oper, Action, SymbolTable, EOL

abstract Lexeme

type EOL <: Lexeme
end

type Oper <: Lexeme
	txt::AbstractString
	fn::Function
	arity::Int64
	args::Vector{Oper}
	Oper(t, fn, a) = new(t, v, a, Oper[])
	Oper(t, p) = new(t, p[1], p[2])
end

type Value <: Lexeme
	txt::AbstractString
	fn::Function
	Value(t, v) = new(t, v)
end

type Variable <: Lexeme
	txt::AbstractString
	s::Symbol
	Variable(t) = new(t, symbol(t))
end

type Expr <: Lexeme
	value::Union{Value, Variable, Tuple{Oper, Vector{Expr}})
	Expr(val::Value) = new(val)
	Expr(var::Variable) = new(var)
	Expr(op::Oper) = new((op, Vector{Expr}()))
end

type Action <: Lexeme
	txt::AbstractString
	fn::Function
	arity::Int64
	args::Vector{Expr}
	Action(t, f, e) = new(t, v, a, Expr[])
	Action(t, p) = new(t, p[1], p[2], Expr[])
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

ActionS = Dict{AbstractString, Tuple{Function, Int64}}()
OPS = Dict{AbstractString, Tuple{Function, Int64}}()

#ActionS["forward"] = (forward, 1)
#ActionS["back"] = (backward, 1)
#ActionS["left"] = (left, 1)
#ActionS["right"] = (right, 1)
ActionS["exit"] = (quit, 0)
ActionS["print"] = (println, 1)

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
				if haskey(ActionS, p)
					produce(Action(p, ActionS[p]))
				elseif haskey(OPS, p)
					produce(Expr(Oper(p, OPS[p])))
				elseif isnumber(p)
					produce(Expr(Value(p, parse(Float64, p))))
				elseif p[1] == ':'
					produce(Expr(Variable(p[2:end])))
				elseif p[1] == '"'
					produce(Expr(Variable(p[2:end])))
				end
			end
		end
		produce(EOL())
		promptfn()
	end
end


# staahhhppp
end
