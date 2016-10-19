
prompt = "L> "

function input()
	@printf "%s" prompt
	for ln in eachline(STDIN)
		while length(ln) > 0
			p, ln = split(ln, [' ', '\r', '\n'];limit=2)
			if length(p) > 0
				produce(p)
			end
		end
		@printf "%s" prompt
	end
end

for t in Task(input)
	if t == "exit"
		quit()
	end
	if t == "to"
		prompt = "TO> "
	end
	if t == "end"
		prompt = "L> "
	end
	@printf "L:%s\n" t
end

	