
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
		args = [a.value.fn(st) for a in c.args]
		@printf STDERR "ARGS %s\n" args
		c.fn(args...)
	end
end

function loaded(c::Action)
	size(c.args)[1] == c.arity
end

function loaded(e::Eq)
	loaded(e.value[1])
end

function loaded(o::Oper)
	size(o.args)[1] == o.arity
end

function loaded(v::Value)
	false
end

function loaded(v::Variable)
	false
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
	

function gotEqZ(top::Eq, e::Eq, o::Oper)
	drainStack("Unexpected operation")
end

function gotEq(top::Eq, e::Eq, v::Variable)
	push!(top.args, e)
end
	
function gotEq(top::Eq, e::Eq, v::Value)
	push!(top.args, e)
end

function gotEq(top::Action, e::Eq, ex::Exp)
	push!(top.args, e)
end

function gotEq(val::Value, e::Eq, op::Oper)
	push!(op.args, pop!(@top().args))
	push!(@top().args, op)
end

function gotEq(var::Variable, e::Eq, op::Oper)
	push!(op.args, pop!(@top().args))
	push!(@top().args, op)
end

function gotEq(top::Oper, e::Eq, op::Oper)
	drainStack("Unexpected Operator")
end

function gotEq(top::Action, e::Eq, op::Oper)
	gotEq(top.args[end].value, e, op)
	push!(top.args, e)
end

function gotEq(top::Action, e::Eq, v::Value)
	if loaded(top)
		gotEq(top.args[end], e, v)
	else
		push!(top.args, e)
	end
end


function gotLexeme(e::Eq)
	gotEq(@top(), e, e.value)
end

function gotAction(top::Action, a::Action)
	if loaded(top)
		push!(stack, a)
		return
	end
	
	drainStack(notEnoughArgs())
end

function gotAction(top::Oper, a::Action)
	if loaded(top)
		push!(stack, a)
		return
	end
	drainStack("Unexpected command $(a.txt) - expected Eqession")
end

function gotLexeme(c::Action)	
	if size(stack)[1] == 0
		push!(stack, c)
		return
	end
	
	gotAction(@top(), c)
end


function gotLexeme(eol::EOL)
	@printf STDERR "ST %s\n" stack
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

for lexeme in Task(()->input(STDIN, prompt))
	println(lexeme)
	gotLexeme(lexeme)
end

