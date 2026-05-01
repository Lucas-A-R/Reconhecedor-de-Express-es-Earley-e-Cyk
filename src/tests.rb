# Arquivo de testes automatizados para Parsers Earley e CYK

require_relative 'gramatica'
require_relative 'earley'
require_relative 'cyk'
require_relative 'estado'

# Pré-processamento: substitui números por "NUMBER" e quebra em tokens
def preprocess(expr)
  expr.gsub(/\d+/, "NUMBER").scan(/NUMBER|\+|\-|\*|\/|\^|\(|\)/)
end

# -------------------------------
# Configuração da gramática Earley
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

# -------------------------------
# Configuração da gramática CYK
# -------------------------------
gramatica_cyk = Gramatica.new("S")
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

# Operações binárias completas
gramatica_cyk.adiciona_regra(Regra.new("EXPR", ["NUM", "OP"]))
gramatica_cyk.adiciona_regra(Regra.new("OP", ["PLUS", "NUM"]))
gramatica_cyk.adiciona_regra(Regra.new("OP", ["MINUS", "NUM"]))
gramatica_cyk.adiciona_regra(Regra.new("OP", ["MUL", "NUM"]))
gramatica_cyk.adiciona_regra(Regra.new("OP", ["DIV", "NUM"]))
gramatica_cyk.adiciona_regra(Regra.new("OP", ["POW", "NUM"]))

# Parênteses com expressão dentro
gramatica_cyk.adiciona_regra(Regra.new("S", ["LPAR", "EXPRP"]))
gramatica_cyk.adiciona_regra(Regra.new("EXPRP", ["EXPR", "RPAR"]))


# Negação unária
gramatica_cyk.adiciona_regra(Regra.new("S", ["MINUS", "NUM"]))

parser_cyk = CYKParser.new(gramatica_cyk)

# -------------------------------
# Testes automatizados
# -------------------------------
puts "=== Testes Earley ==="
{
  "1+2*3" => true,
  "(1+4)*2" => true,
  "7/(1-3)" => true,
  "-4+2" => true,
  "2^3" => true,
  "9++3" => false,
  "() * 3" => false,
  "^2+4" => false
}.each do |expr, esperado|
  resultado = parser_earley.parse(preprocess(expr))
  puts "#{expr} => #{resultado} (esperado: #{esperado})"
end

puts "\n=== Testes CYK ==="
{
  "1+2" => true,
  "1-2" => true,
  "1*2" => true,
  "1/2" => true,
  "2^3" => true,
  "-4" => true,
  "(1+2)" => true,
  "(2^3)" => true,
  "()" => false,
  "9++3" => false
}.each do |expr, esperado|
  entrada = preprocess(expr)
  parser_cyk.parse(entrada)
  resultado = parser_cyk.aceito?
  puts "#{expr} => #{resultado} (esperado: #{esperado})"
end
