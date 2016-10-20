

@enum CMDS fd forward bk back left lt right rt pu penup pd pendown exit

type Lex
	cmd::CMDS
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
					produce(p)
				end
				
			end
		end
		@printf "%s" prompt
	end
end


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

	