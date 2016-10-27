
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

Unary["ABS"] = abs
Unary["ARCTAN"] = atan
Unary["SIN"] = sin
Unary["COS"] = cos
Unary["TAN"] = tan

function prompt()
	@printf "%s L> " stack
end

function run(c::Action, st::SymbolTable)
	if c.arity == 0
		c.fn()
	else
		args = [a.value.fn(st) for a in c.args]
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
	drainStack("$(typeof(l)): $(u.txt)")
end

function gotLexeme(a::Action, v::Value)
	if a.arity == 0
		drainStack("Unxpected Operation, expecting Action")
		return
	end
	
end

function gotLexeme(a::Action, v::Value)
	if a.arity == 0
		drainStack("Unexpected Value, expecting Action")
		return
	end
	# ok, just waiting for a value
	if sizeof(a.args)[1] == 0
		push!(a.args, Eq(v))
		return
	end
	
	# we already have a value but no op
	if a.args[end].op == nothing
		drainStack("Unexpected Value")
		return
	end
	
	
end

function gotLexeme(v::Void, l::Lexeme)	
	drainStack("Expecing Action, got $(typeof(l))")
end

function gotLexeme(v::Void, a::Action)
	push!(stack, a)
end

function gotLexeme(l::Lexeme, eol::EOL)	
	drainStack("Unexepcted $(typeof(l))")
end

function gotLexeme(a::Action, eol::EOL)
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

