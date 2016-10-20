
@enum CMDS fd forward bk back left lt right rt pu penup pd pendown exit

type Cmd
	fn::Function
	es::Vector{Expr}
	Cmd(fn) = new(fn, Expr[])
end

type Expr
	op::Function
	es::Vector{Union{Expr, Float64}}
	Expr(op::Function) = new(op, Expr[])
	Expr(n::Float64) = new((x)->x, Expr[n])
	Expr(op::Function, e) = new(op, Expr[e])
end

function evaluate(e::Expr)
	e.op(map(evaluate, e.es))
end

function execute(c::CmdA1)
	c.fn(map(evaluate, c.es)...)
end

prompt = "L> "

function input()
	@printf "%s" prompt
	for ln in eachline(STDIN)
		while length(ln) > 0
			p, ln = split(ln, [' ', '\r', '\n'];limit=2)
			if length(p) > 0
				if typeof(eval(Symbol(p))) == CMDS
					produce(Lex(eval(Symbol(p))))
				else
					if isnumber(p)
						produce(Expr(parse(Float64, p)))
					end
				end
				
			end
		end
		@printf "%s" prompt
	end
end

stack = []


for t in Task(input)
	
	if typeof(t) == Lex
		if t.cmd == exit
			quit()
		end
	end
	if t == "to"
		prompt = "TO> "
	end
	if t == "end"
		prompt = "L> "
	end
	@printf "L:%s - %s\n" t typeof(t)
end

