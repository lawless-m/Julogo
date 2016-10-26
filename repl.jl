
cd(ENV["USERPROFILE"] * "/Documents")
unshift!(LOAD_PATH, abspath("GitHub/Julogo/"))


using Lex

function prompt()
	@printf "L> "
end

function run(c::Action, st::SymbolTable)
	if c.arity == 0
		c.fn()
	else
		args = [a.fn(st) for a in c.args]
		@printf STDERR "ARGS %s\n" args
		c.fn(args...)
	end
end

function loaded(c::Action)
	size(c.args)[1] == c.arity
end

function loaded(e::Expr)
	loaded(e.value[1])
end

function loaded(o::Oper)
	size(o.args)[1] == o.arity
end

function drainStack(msg)
	warn(msg)
	while size(stack)[1] > 0
		pop!(stack)
	end
end



macro top()
	:( stack[end] )
end

function notEnoughArgs()
	"No enough arguments for $(@top().txt) expecting $(@top().arity) got $(size(@top().args)[1])"
end

execute = true	
globalst = SymbolTable()
stack = Lexeme[]

function gotAction(top::Action, a::Action)
	if loaded(top)
		push!(stack, a)
	else
		drainStack(notEnoughArgs())
	end
end

function gotAction(top::Oper, a::Action)
	if loaded(top)
		push!(stack, a)
		return
	end
	drainStack("Unexpected command $(a.txt)")
end
	
function gotLexeme(c::Action)	
	if size(stack)[1] == 0
		push!(stack, c)
		return
	end
	
	gotAction(@top(), c)
end

function gotExpr(top::Action, e::Expr, v::Expr)
	push!(top.args, e)
end

function gotExpr(top::Action, e::Expr, v::Variable)
	push!(top.args, e)
end

function gotExpr(top::Action, e::Expr, v::Value)
	push!(top.args, e)
end

function gotLexeme(e::Expr)
	if loaded(@top())
		drainStack("Expecting Command")
		return
	end
	gotExpr(@top(), e, e.value)
end

function gotLexeme(eol::EOL)
	if ! loaded(@top())	
		drainStack(notEnoughArgs())
		return
	end
		
	if execute
		while size(stack)[1] > 0
			run(pop!(stack), globalst)
		end
	end
end

for lexeme in Task(()->Lex.input(STDIN, prompt))
	println(lexeme)
	gotLexeme(lexeme)
end

