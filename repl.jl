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
