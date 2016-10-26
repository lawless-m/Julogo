module Lex

export Lexeme, EOL, Exp, Oper, Value, Variable, Eq, Action, SymbolTable, lookup, assign, input

abstract Lexeme

type EOL <: Lexeme
end

abstract Exp <: Lexeme

type Oper <: Exp
	txt::AbstractString
	fn::Function
	arity::Int64
	args::Vector{Exp}
	Oper(t, fn, a) = new(t, v, a, Exp[])
	Oper(t, p) = new(t, p[1], p[2], Exp[])
end

type Value <: Exp
	txt::AbstractString
	fn::Function
	Value(t, v) = new(t, (st)->v)
end

type Variable <: Exp
	txt::AbstractString
	s::Symbol
	Variable(t) = new(t, symbol(t))
end

type Eq <: Exp
	value::Union{Value, Variable, Oper}
	Eq(val::Value) = new(val)
	Eq(var::Variable) = new(var)
	Eq(op::Oper) = new(op)
end

type Action <: Lexeme
	txt::AbstractString
	fn::Function
	arity::Int64
	args::Vector{Eq}
	Action(t, f, e) = new(t, v, a, Eq[])
	Action(t, p) = new(t, p[1], p[2], Eq[])
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
					produce(Eq(Oper(p, OPS[p])))
				elseif isnumber(p)
					produce(Eq(Value(p, parse(Float64, p))))
				elseif p[1] == ':'
					produce(Eq(Variable(p[2:end])))
				elseif p[1] == '"'
					produce(Eq(Variable(p[2:end])))
				end
			end
		end
		produce(EOL())
		promptfn()
	end
end


# staahhhppp
end
