require_relative 'gramatica'
require_relative 'earley'
require_relative 'cyk'
require_relative 'estado'

# Pré-processamento: substitui números por "NUMBER" e quebra em tokens
def preprocess(expr)
  expr.gsub(/\d+/, "NUMBER").scan(/NUMBER|\+|\-|\*|\/|\^|\(|\)/)
end

# -------------------------------
# Parte 1: Earley
# -------------------------------
gramatica_earley = Gramatica.new("Expr")
gramatica_earley.adiciona_regra(Regra.new("Expr", ["Expr", "+", "Term"]))
gramatica_earley.adiciona_regra(Regra.new("Expr", ["Expr", "-", "Term"]))
gramatica_earley.adiciona_regra(Regra.new("Expr", ["Term"]))
gramatica_earley.adiciona_regra(Regra.new("Term", ["Term", "*", "Factor"]))
gramatica_earley.adiciona_regra(Regra.new("Term", ["Term", "/", "Factor"]))
gramatica_earley.adiciona_regra(Regra.new("Term", ["Term", "^", "Factor"]))
gramatica_earley.adiciona_regra(Regra.new("Term", ["Factor"]))
gramatica_earley.adiciona_regra(Regra.new("Factor", ["(", "Expr", ")"]))
gramatica_earley.adiciona_regra(Regra.new("Factor", ["-", "Factor"])) # negação unária
gramatica_earley.adiciona_regra(Regra.new("Factor", ["NUMBER"]))

parser_earley = EarleyParser.new(gramatica_earley)

validas = ["1+2*3", "(1+4)*2", "7/(1-3)", "-4+2", "2^3"]
invalidas = ["9++3", "() * 3", "^2+4"]

puts "=== Teste Earley ==="
validas.each { |expr| puts "#{expr} => #{parser_earley.parse(preprocess(expr))}" }
invalidas.each { |expr| puts "#{expr} => #{parser_earley.parse(preprocess(expr))}" }

# -------------------------------
# Parte 2: CYK
# -------------------------------
gramatica_cyk = Gramatica.new("S")

# Terminais
gramatica_cyk.adiciona_regra(Regra.new("NUM", ["NUMBER"]))
gramatica_cyk.adiciona_regra(Regra.new("PLUS", ["+"]))
gramatica_cyk.adiciona_regra(Regra.new("MINUS", ["-"]))
gramatica_cyk.adiciona_regra(Regra.new("MUL", ["*"]))
gramatica_cyk.adiciona_regra(Regra.new("DIV", ["/"]))
gramatica_cyk.adiciona_regra(Regra.new("POW", ["^"]))
gramatica_cyk.adiciona_regra(Regra.new("LPAR", ["("]))
gramatica_cyk.adiciona_regra(Regra.new("RPAR", [")"]))

# Regras binárias
gramatica_cyk.adiciona_regra(Regra.new("S", ["NUM", "EXPR"]))
gramatica_cyk.adiciona_regra(Regra.new("EXPR", ["PLUS", "NUM"]))
gramatica_cyk.adiciona_regra(Regra.new("EXPR", ["MINUS", "NUM"]))
gramatica_cyk.adiciona_regra(Regra.new("EXPR", ["MUL", "NUM"]))
gramatica_cyk.adiciona_regra(Regra.new("EXPR", ["DIV", "NUM"]))
gramatica_cyk.adiciona_regra(Regra.new("EXPR", ["POW", "NUM"]))

# Parênteses
gramatica_cyk.adiciona_regra(Regra.new("S", ["LPAR", "RPAR"]))

# Negação unária
gramatica_cyk.adiciona_regra(Regra.new("S", ["MINUS", "NUM"]))

parser_cyk = CYKParser.new(gramatica_cyk)

puts "\n=== Teste CYK ==="
["1+2", "1-2", "1*2", "1/2", "2^3", "-4"].each do |expr|
  entrada = preprocess(expr)
  parser_cyk.parse(entrada)
  puts "Entrada: #{expr} => Aceito? #{parser_cyk.aceito?}"
end

