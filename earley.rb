require 'set'
require_relative 'gramatica'
require_relative 'estado'

class EarleyParser
  attr_reader :gramatica
  
  def initialize(gramatica)
    @gramatica = gramatica
    # Adiciona regra inicial artificial
    @gramatica.regras.unshift(Regra.new(gramatica.simbolo_inicial, [gramatica.simbolo_inicial]))
  end

  def parse(entrada)
    @tabela = Array.new(entrada.length + 1) { |indice| S.new(indice, entrada) }
    predict(Estado.new(@gramatica.regras[0], 0, 0, "Regra inicial"), 0)

    (0..entrada.size).each do |index|
      until @tabela[index].empty?
        estado = @tabela[index].take!
        if estado.completo?
          complete(estado, index)
        else
          if estado.next_symbol == entrada[index]
            scan(estado, index)
          else
            predict(estado, index)
          end
        end
      end
    end
    final_is_valid?(@tabela[entrada.length])
  end

  private

  def final_is_valid?(estado)
    estado.estados.any? do |e|
      e.regra.esquerda == gramatica.simbolo_inicial && e.completo? && e.inicio == 0
    end
  end

  def predict(estado, index)
    @gramatica.regras.each do |regra|
      if regra.esquerda == estado.next_symbol
        @tabela[index] << Estado.new(regra, 0, index, "Predito de #{estado}")
      end
    end
  end

  def scan(estado, index)
    @tabela[index + 1] << estado.advance(index, estado)
  end

  def complete(estado, index)
    @tabela[estado.inicio].estados.each do |candidato|
      if candidato.next_symbol == estado.regra.esquerda
        @tabela[index] << candidato.complete(index-1, estado, candidato)
      end
    end
  end

  
end
