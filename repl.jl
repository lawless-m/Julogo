
cd(ENV["USERPROFILE"] * "/Documents")
unshift!(LOAD_PATH, abspath("GitHub/Julogo/"))


using Lex

#ActionS["forward"] = (forward, 1)
#ActionS["back"] = (backward, 1)
#ActionS["left"] = (left, 1)
#ActionS["right"] = (right, 1)
Actions["exit"] = (quit, 0)
Actions["print"] = (println, 1)

LHs["*"] = *
LHs["/"] = /

RHs["+"] = +
RHs["-"] = -
RHs["MOD"] = mod

Unarys["ABS"] = abs
Unarys["ARCTAN"] = atan
Unarys["SIN"] = sin
Unarys["COS"] = cos
Unarys["TAN"] = tan

function prompt()
	@printf "%s L> " stack
end

function run(c::Action, st::SymbolTable)
@printf STDERR "RUNNING %s\n" c
	if c.arity == 0
		c.fn()
	else
		args = [evaluate(a, st) for a in c.args]
		@printf STDERR "ARGS %s\n" args
		c.fn(args...)
	end
end

function drainStack(msg)
	warn(msg)
	while size(stack)[1] > 0
		pop!(stack)
	end
end

function top()
	size(stack)[1] > 0 ? stack[end] : nothing
end

function loaded(a::Action)
	size(a.args)[1] == a.arity
end

function notEnoughArgs()
	"No enough arguments for $(top().txt) expecting $(top().arity) got $(size(top().args)[1])"
end

execute = true	
globalst = SymbolTable()
stack = Lexeme[]
	

function gotLexeme(l::Lexeme, u::Unrecognised)
@printf STDERR "%s" "gotLexeme(l::Lexeme, u::Unrecognised)\n"
	drainStack("$(typeof(l)): $(u.txt)")
end

function gotOper(a::Action, eq::Eq, lh::Value, op::RH, rh::Value, o::Binary)
@printf STDERR "%s" "gotOper(a::Action, eq::Eq, lh::Value, op::RH, rh::Value, o::Binary)\n"
	pop!(a.args)
	push!(a.args, Eq(o, eq))
end

function gotOper(a::Action, eq::Eq, o::Oper)
@printf STDERR "%s" "gotOper(a::Action, eq::Eq, o::Oper)\n"
	gotOper(a, eq, eq.lh, eq.op, eq.rh, o)
end

function gotOper(a::Action, v::Value, rh::RH)
@printf STDERR "%s" "gotOper(a::Action, v::Value, rh::RH)\n"
	# v not Eq
	pop!(a.args)
	push!(a.args, Eq(rh, v))
end

function gotOper(a::Action, v::Value, rh::RH)
h@printf STDERR "%s" "gotOper(a::Action, v::Value, rh::RH)\n"
	# v not Eq
	pop!(a.args)
	push!(a.args, Eq(rh, v))
end

function gotOper(a::Action, v::Value, u::Unary)
@printf STDERR "%s" "gotOper(a::Action, v::Value, u::Unary)\n"
	drainStack("Unexpected Unary $(u.txt), expecting Binary")
end

function gotOper(eq::Eq, rh::Void, u::Unary)
@printf STDERR "%s" "gotOper(eq::Eq, rh::Void, u::Unary)\n"
	eq.rh = Eq(u)
end

function gotOper(eq::Eq, rh::Value, u::Unary)
@printf STDERR "%s" "gotOper(eq::Eq, rh::Value, u::Unary)\n"
	drainStack("Unexpected Unary $(u.txt), expecting Binary")
end

function gotOper(a::Action, eq::Eq, u::Unary)
@printf STDERR "%s" "gotOper(a::Action, eq::Eq, u::Unary)\n"
	gotOper(eq, eq.rh, u)
end

function gotLexeme(a::Action, o::Oper)
@printf STDERR "%s" "gotLexeme(a::Action, o::Oper)\n"
	gotOper(a, a.args[end], o)
end

function gotValue(a::Action, eq::Eq, v::Value)
@printf STDERR "gotValue(a::Action [%s], eq::Eq [%s], v::Value [%s])\n" a eq v
	a.args[end].rh = v
end

function gotLexeme(a::Action, v::Value)
@printf STDERR "%s" "gotLexeme(a::Action, v::Value)\n"
	if sizeof(a.args)[1] == 0
		push!(a.args, v)
		return
	end
	
	gotValue(a, a.args[end], v)

	if a.arity == sizeof(a.args)[1]
		drainStack("Unexpected Value, expecting Action")
		return
	end
	
end


function gotLexeme(v::Void, l::Lexeme)	
@printf STDERR "%s" "gotLexeme(v::Void, l::Lexeme)\n"
	drainStack("Expecing Action, got $(typeof(l))")
end

function gotLexeme(v::Void, a::Action)
@printf STDERR "%s" "gotLexeme(v::Void, a::Action)\n"
	push!(stack, a)
end

function gotLexeme(l::Lexeme, eol::EOL)	
@printf STDERR "%s" "gotLexeme(l::Lexeme, eol::EOL\n"
	# l is not an action
	drainStack("Unexpected $(typeof(l))")
end

function gotLexeme(a::Action, eol::EOL)
@printf STDERR "%s\n" "gotLexeme(a::Action, eol::EOL)"
	@printf "ST: %s\n" stack
	if ! loaded(a)	
		drainStack(notEnoughArgs())
		return
	end
	if execute
		while size(stack)[1] > 0
			run(pop!(stack), globalst)
		end
	end
end

gotLexeme(top::Void, eol::EOL) = nothing

for lexeme in Task(()->input(STDIN, prompt))
	println("Got: " * string(lexeme))
	gotLexeme(top(), lexeme)
end

