require_relative 'gramatica'
require_relative 'earley'
require_relative 'cyk'

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
gramatica_earley.adiciona_regra(Regra.new("Factor", ["-", "Factor"]))
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

gramatica_cyk.adiciona_regra(Regra.new("EXPR", ["NUM", "OP"]))
gramatica_cyk.adiciona_regra(Regra.new("OP", ["PLUS", "NUM"]))
gramatica_cyk.adiciona_regra(Regra.new("OP", ["MINUS", "NUM"]))
gramatica_cyk.adiciona_regra(Regra.new("OP", ["MUL", "NUM"]))
gramatica_cyk.adiciona_regra(Regra.new("OP", ["DIV", "NUM"]))
gramatica_cyk.adiciona_regra(Regra.new("OP", ["POW", "NUM"]))

gramatica_cyk.adiciona_regra(Regra.new("S", ["LPAR", "EXPRP"]))
gramatica_cyk.adiciona_regra(Regra.new("EXPRP", ["EXPR", "RPAR"]))
gramatica_cyk.adiciona_regra(Regra.new("S", ["MINUS", "NUM"]))

parser_cyk = CYKParser.new(gramatica_cyk)

# -------------------------------
# Debug de uma expressão
# -------------------------------
expr = "1+2"
tokens = preprocess(expr)

puts "\n=== Debug Earley ==="
puts "Expressão: #{expr}"
puts "Tokens: #{tokens.inspect}"
resultado_earley = parser_earley.parse(tokens)
puts "Resultado final: #{resultado_earley ? 'Aceito' : 'Rejeitado'}"
tokens.each_with_index do |t, i|
  puts "  [Earley] Posição #{i}: lendo #{t}"
end

puts "\n=== Debug CYK ==="
puts "Expressão: #{expr}"
puts "Tokens: #{tokens.inspect}"
resultado_cyk = parser_cyk.parse(tokens)
puts "Resultado final: #{resultado_cyk ? 'Aceito' : 'Rejeitado'}"

# Construção da tabela CYK (simplificada para debug)
n = tokens.size
table = Array.new(n) { Array.new(n) { [] } }

# Preenche a diagonal com regras terminais
(0...n).each do |i|
  case tokens[i]
  when "NUMBER" then table[i][i] << "NUM"
  when "+"      then table[i][i] << "PLUS"
  when "-"      then table[i][i] << "MINUS"
  when "*"      then table[i][i] << "MUL"
  when "/"      then table[i][i] << "DIV"
  when "^"      then table[i][i] << "POW"
  when "("      then table[i][i] << "LPAR"
  when ")"      then table[i][i] << "RPAR"
  end
end

# Combinações simples: NUM + NUM vira EXPR
(0...n-2).each do |i|
  if table[i][i].include?("NUM") && table[i+1][i+1].include?("PLUS") && table[i+2][i+2].include?("NUM")
    table[i][i+2] << "EXPR"
    table[i][i+2] << "S" # marca que é uma sentença válida
  end
end

# Impressão da tabela triangular
puts "\nTabela CYK detalhada:"
(0...n).each do |i|
  (i...n).each do |j|
    puts "[#{i},#{j}] = {#{table[i][j].join(', ')}}"
  end
end

# Verificação final
if table[0][n-1].include?("S")
  puts "\nTabela indica que a expressão é VÁLIDA (S encontrado em [0,#{n-1}])"
else
  puts "\nTabela indica que a expressão é INVÁLIDA (S não encontrado em [0,#{n-1}])"
end
