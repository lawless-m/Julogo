
cd(ENV["USERPROFILE"] * "/Documents")
unshift!(LOAD_PATH, abspath("GitHub/Julogo/"))


using Lex: Cmd, Oper, SymbolTable

function prompt()
	@printf "L> "
end

function run(c::Cmd, st::SymbolTable)
	if c.arity == 0
		c.fn()
	else
		args = [a.fn(st) for a in c.args]
		@printf STDERR "ARGS %s\n" args
		c.fn(args...)
	end
end

function loaded(c::Cmd)
	size(c.args)[1] == c.arity
end
	
execute = true	
globalst = SymbolTable()
stack = Union{Cmd, Oper}[]
	
for t in Task(()->Lex.input(STDIN, prompt))
	println(t)
	if size(stack)[1] > 0
		if typeof(stack[end]) == Cmd
			if loaded(stack[end])
				if execute
					while size(stack)[1] > 0
						run(pop!(stack), globalst)
					end
				end
			else
				if typeof(t) == Oper
					@printf STDERR ">C %s\n" t
					push!(stack[end].args, t)
					if execute && loaded(stack[end])
						run(pop!(stack), globalst)
					end
				else
					error("No enough arguments for $(stack[end].txt) expecting $(stack[end].arity) got $(size(stack[end].args)[1])")
				end
			end
		end
	elseif typeof(t) == Oper
		error("Expecting Cmd got Oper")
	elseif execute && loaded(t)
		run(t, globalst)
	else
		@printf STDERR ">S %s\n" t
		push!(stack, t)
	end	
end

#=



prompt()
for ln in eachline(STDIN)
	if cmd(ln)
		prompt()
	end
end

type Expr
	op::Union{Function, Void}
	es::Vector{Union{Expr, Float64, Symbol}}
	Expr(op::Function) = new(op, Expr[])
	Expr(n::Float64) = new((x)->x, Expr[n])
	Expr(op::Function, e) = new(op, Expr[e])
	Expr(e) = new(nothing, Expr[e])
end

type Cmd
	txt::AbstractString
	fn::Function
	arity::Int64
	args::Vector{Expr}
	Cmd(t, fn, a) = new(t, fn, a, Vector{Expr}())
	function Cmd(a::AbstractString)
		if haskey(CMDS, a)
			return new(a, CMDS[a][1], CMDS[a][2])
		end
		error("No such command: $a")
	end
end

function loaded(c::Cmd)
	size(c.args)[1] == c.arity
end

function loaded(e::Expr)
	e.op != nothing && ((e.op.unary && sizeof(e.es)[1] == 1) || (!e.op.unary && sizeof(e.es)[1] == 2))
end

function pushExpr!(c::Cmd, e::Expr)
	if loaded(c)
		error("Too many arguments for $(c.txt)")
	end
	push!(c.args, e)
end

type CmdBlock
	cmds::Vector{Cmd}
	symbols::SymbolTable
	CmdBlock(c, s) = new(c, s)
	CmdBlock(s) = new(Vector{Cmd}(), s)
	CmdBlock() = new(Vector{Cmd}(), SymbolTable())
end


function evaluate(e::Expr, s::SymbolTable)
	e.op(map((e)->evaluate(e, s), c.es)...)
end

function execute(c::Cmd, s::SymbolTable)
	c.fn(map((e)->evaluate(e, s), c.es)...)
end

function execute(s::CmdBlock)
	for pc = 1:size(s.cmds)
		execute(s.scmds[pc], s.symbols)
	end
end


glob = CmdBlock()
@enum EXPECTS Ecmd Ecmd_or_expr Eexpr Eop_or_expr
@enum GLOBSTATE GSexecute GScompile
globstate = GSexecute

scope = glob

expecting = Ecmd
stack = Union{Cmd, Expr}[]

for t in Task(input)
	if stack[end].loaded()
		if typeof(t) == Expr
			error("Unexpected Expression, expecting Command")
		end
		push!(stack, t)
		continue
	end
	
	if typeof(t) == Cmd
		error("Unexpected Command, expecting Expression")
	end

	
end
	






	if expecting == Ecmd
		c = Cmd(t)
	elseif expecting == Expr
		push!(stack, Expr(t))
		pushExpr!(c, stack[end])
		expecting = Ecmd_or_expr
	end
	
	if typeof(stack[end]) == Cmd
		if loaded(Cmd)
			if globstate == GSexecute
				execute(pop!(stack))
				expecting = Ecmd
			end
		end
	end
	
end




include("Turtle.jl")
using Turtles

function prompt()
	@printf "JL> "
end

stack = Any[]

const CMDS = ["~" "FD" "FORWARD" "BK" "BACK" "LEFT" "LT" "RIGHT" "RT" "PU" "PENUP" "PD" "PENDOWN" "EXIT"]


function expr(ln)
	tok, lnz = split(ln, [' ', '\n']; limit=2)
	p = parse(tok)
	if tok == "~"
		if ln != "\n"
			@printf STDERR "unexpected ~\n"
			return ""
		end
		return lnz
	end
	if typeof(p) == Symbol
		@printf STDERR "symbol %s" p
		return lnz
	end
	if isnumber(p)
		@printf STDERR "numeric %f" p
		return lnz
	end
	
	@printf STDERR "expecting expr"
	return ""
end

function cmd(ln)
	tok, lnz = split(ln, [' ', '\n']; limit=2)
	@printf STDERR "t:%s \n" tok
	if ! (string(tok) in CMDS)
		@printf STDERR "Expecting one of: %s\n" CMDS
		return true
	end
	if tok == "~"
		return false
	end
	if tok == "EXIT"
		quit()
	end
	if ln == ""
		@printf STDERR "expecting expression, got BLANK"
		return true
	end
	lnz = expr(lnz)
	if ln != ""
		return cmd(lnz)
	end
	return true
end


prompt()
for ln in eachline(STDIN)
	if cmd(ln)
		prompt()
	end
end
=#