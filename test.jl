
cd(ENV["USERPROFILE"] * "/Documents")
unshift!(LOAD_PATH, abspath("GitHub/Julogo/"))

using Lex

st = SymbolTable()

e = Eq(RH("+", +), Natural("1", 1), Eq(RH("*", *), Numeric("2.2", 2.2), Natural("3", 3)))

println(evaluate(e, st))

