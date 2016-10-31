module Lex

# Lexemes
export Lexeme, Unrecognised, EOL
export Oper, RH, LH, Unary, Binary
export Value, Natural, Numeric, Variable, Eq
export Action, Assign
export Actions, LHs, RHs, Unarys
export SymbolTable, evaluate, assign, input

abstract Lexeme

type Unrecognised <: Lexeme
	txt::AbstractString
end

type EOL <: Lexeme
end

abstract Oper <: Lexeme

abstract Binary <: Oper

type LH <: Binary
	txt::AbstractString
	fn::Function
end

type RH <: Binary
	txt::AbstractString
	fn::Function
end

type Unary <: Oper
	txt::AbstractString
	fn::Function
end

abstract Value <: Lexeme

type Eq <: Value
	op::Union{Oper, Void}
	lh::Union{Value, Void}
	rh::Union{Value, Void}
	Eq(op, lh, rh) = new(op, lh, rh)
	Eq(op, v) = new(op, v, nothing)
	Eq(val::Value) = new(nothing, val, nothing)
	Eq(op::Oper) = new(op, nothing, nothing)
end

abstract Literal <: Value

type Natural <: Literal
	txt::AbstractString
	value::Int64
end

type Numeric <: Literal
	txt::AbstractString
	value::Float64
end

type Variable <: Value
	txt::AbstractString
	s::Symbol
end

type Assign <: Lexeme
	txt::AbstractString
	s::Symbol
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

function tprint(t, a)
	@printf "%s is a %s = %s\n" t typeof(a) a.txt
end

function evaluate(op::Binary, lh::Value, rh::Value, st::SymbolTable)
	op.fn(evaluate(lh, st), evaluate(rh, st))
end

function evaluate(op::Unary, lh::Value, rh::Void, st::SymbolTable)
	op.fn(evaluate(lh, st))
end

function evaluate(v::Literal, st::SymbolTable)
	v.value
end

function evaluate(v::Variable, st::SymbolTable)
	evaluate(v.value, st)
end

function evaluate(e::Eq, st::SymbolTable)
	if e.op == nothing
		return evaluate(e.lh, st)
	end
	return evaluate(e.op, e.lh, e.rh, st)
end

function evaluate(s::Symbol, st::SymbolTable)
	if st==nothing
		warn("$s not found")
		nothing
	elseif haskey(st, s)
		st[s]
	else
		evaluate(s, st.parent)
	end
end

function assign(s::Symbol, st::SymbolTable, v)
	st[s] = v
end

Actions = Dict{AbstractString, Tuple{Function, Int64}}()
LHs = Dict{AbstractString, Function}()
RHs = Dict{AbstractString, Function}()
Unarys = Dict{AbstractString, Function}()


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
				elseif haskey(LHs, p)
					produce(LH(p, LHs[p]))
				elseif haskey(Unarys, p)
					produce(Unary(p, Ops[p]))
				elseif isnumber(p)
					produce(Natural(p, parse(Int64, p)))
				elseif !isnull(tryparse(Float64, p))
					produce(Numeric(p, parse(Float64, p)))
				elseif p[1] == ':'
					produce(Variable(p, Symbol(p[2:end])))
				elseif p[1] == '"'
					produce(Assign(p, Symbol(p[2:end])))
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
