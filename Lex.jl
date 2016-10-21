unshift!(LOAD_PATH, ".")
using Turtles

const CMDS = Dict{AbstractString, Tuple{Function, Int64}()


CMDS['forward'] = (forward, 1)
CMDS['back'] = (backward, 1)
CMDS['left'] = (left, 1)
CMDS['right'] = (right, 1)
CMDS['exit'] = (quit, 0)

type Expr
	op::Function
	es::Vector{Union{Expr, Float64, Symbol}}
	Expr(op::Function) = new(op, Expr[])
	Expr(n::Float64) = new((x)->x, Expr[n])
	Expr(op::Function, e) = new(op, Expr[e])
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

function pushExpr!(c::Cmd, e::Expr)
	if loaded(c)
		error("Too many arguments for $(c.txt)")
	end
	push!(c.args, e)
end

type SymbolTable
	parent::SymbolTable
	symbols::Dict{AbstractString, Union{Float64, AbstractString}}
	SymbolTable() = new(nothing, Dict{AbstractString, Union{Float64, AbstractString}}()
	SymbolTable(p) = new(p, Dict{AbstractString, Union{Float64, AbstractString}}()
end

type CmdBlock
	cmds::Vector{Cmd}
	symbols::SymbolTable
	CmdBlock(c, s) = new(c, s)
	CmdBlock(s) = new(Vector{Cmd}(), s)
	CmdBlock() = new(SymbolTable())
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

function evaluate(e::Expr, s::SymbolTable)
	e.op(map(f(e)->evaluate(e, s), c.es)...)
end

function execute(c::Cmd, s::SymbolTable)
	c.fn(map(f(e)->evaluate(e, s), c.es)...)
end

function execute(s::CmdBlock)
	for pc = 1:size(s.cmds)
		execute(s.scmds[pc], s.symbols)
	end
end

prompt = "L> "
function input()
	@printf "%s" prompt
	for ln in eachline(STDIN)
		while length(ln) > 0
			p, ln = split(ln, [' ', '\r', '\n'];limit=2)
			if length(p) > 0
				produce(p)
				#=
				if typeof(eval(Symbol(p))) == CMDS
					produce(Lex(eval(Symbol(p))))
				else
					if isnumber(p)
						produce(Expr(parse(Float64, p)))
					end
				end				
				=#
			end
		end
		@printf "%s" prompt
	end
end

glob = CmdBlock()
@enum EXPECTS Ecmd Ecmd_or_expr Eexpr Eop_or_expr
@enum GLOBSTATE execute compile
globstate = execute

scope = glob

expecting = Ecmd
stack = Union{Cmd, Expr}[]

for t in Task(input)
	if expecting == Ecmd
		c = Cmd(t)
	elseif expecting == Expr
		push!(stack, Expr(t))
		pushExpr!(c, stack[end])
		expecting = Ecmd_or_expr
	end
	
	if typeof(stack[end]) == Cmd
		if loaded(Cmd)
			if globstate == execute
				execute(pop!(stack))
				expecting = Ecmd
			end
		end
	end
	
end

