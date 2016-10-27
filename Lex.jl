module Lex

export Ops, Actions, Lexeme, Unrecognised, EOL, Oper, Natural, Numeric, Lookup, Assign, Value, Eq, Action, SymbolTable, lookup, assign, input

abstract Lexeme

type Unrecognised <: Lexeme
	txt::AbstractString
end

type EOL <: Lexeme
end

abstract Oper <: lexeme

type LH <: Oper
	txt::AbstractString
	fn::Function
end

type RH <: Oper
	txt::AbstractString
	fn::Function
end

type Op <: Oper
	txt::AbstractString
	fn::Function
end

abstract Value <: Lexeme

type Natural <: Value
	txt::AbstractString
	value::UInt64
end

type Numeric <: Value
	txt::AbstractString
	value::Float64
end

type Lookup <: Value
	txt::AbstractString
	s::Symbol
end

type Assign <: Lexeme
	txt::AbstractString
	s::Symbol
end

type Eq <: Value
	op::Union{Oper, Void}
	lh::Union{Value, Void}
	rh::Union{Value, Void}
	Eq(val::Value) = new(nothing, val, nothing)
	Eq(op::Oper) = new(op, nothing, nothing)
end

type Action <: Lexeme
	txt::AbstractString
	fn::Function
	arity::Int64
	args::Vector{Value}
	Action(t, f, a) = new(t, f, a, Value[])
	Action(t, p) = new(t, p[1], p[2], Value[])
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

Actions = Dict{AbstractString, Tuple{Function, Int64}}()
Ops = Dict{AbstractString, Tuple{Function, Int64}}()


function input(stream, promptfn)
	promptfn()
	for ln in eachline(stream)
		while length(ln) > 0
			p, ln = split(ln, [' ', '\r', '\n'];limit=2)
			if length(p) > 0
				if haskey(Actions, p)
					produce(Action(p, Actions[p]))
				elseif haskey(RHs, p)
					produce(RH(p, RHs[p]))
				elseif haskey(LHOps, p)
					produce(LH(p, LHs[p]))
				elseif haskey(LHs, p)
					produce(Op(p, Ops[p]))
				elseif isnumber(p)
					produce(Natural(p, parse(Int64, p)))
				elseif !isnull(tryparse(Float64, p))
					produce(Numeric(p, parse(Float64, p)))
				elseif p[1] == ':'
					produce(Lookup(p, symbol(p[2:end])))
				elseif p[1] == '"'
					produce(Assign(p, symbol(p[2:end])))
				elseif p == "~"
					ln = ""
					continue
				else
					produce(Unrecognised(p))
				end
			end
		end
		produce(EOL())
		promptfn()
	end
end


# staahhhppp
end
