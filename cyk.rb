require_relative 'gramatica'

class CYKParser
  def initialize(gramatica)
    @gramatica = gramatica
    @tabela = []
  end

  def parse(entrada)
    n = entrada.length
    @tabela = Array.new(n) { Array.new(n) { [] } }

    # Passo 1: preencher com regras terminais
    (0...n).each do |i|
      @gramatica.regras.each do |regra|
        if regra.direita.length == 1 && regra.direita[0] == entrada[i]
          @tabela[i][i] << regra.esquerda
        end
      end
    end

    # Passo 2: combinações
    (2..n).each do |l|
      (0..n-l).each do |s|
        (s+1..s+l-1).each do |p|
          @gramatica.regras.each do |regra|
            if regra.direita.length == 2
              b, c = regra.direita
              if @tabela[s][p-1].include?(b) && @tabela[p][s+l-1].include?(c)
                @tabela[s][s+l-1] << regra.esquerda
              end
            end
          end
        end
      end
    end
  end

  def aceito?
    @tabela[0][-1].include?(@gramatica.simbolo_inicial)
  end

end
