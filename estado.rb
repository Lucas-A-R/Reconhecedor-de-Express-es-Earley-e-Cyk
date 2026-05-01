require 'set'

class Estado
  attr_accessor :regra, :ponto, :inicio, :comentario

  def initialize(regra, ponto, inicio, comentario = '')
    @regra = regra
    @ponto = ponto
    @inicio = inicio
    @comentario = comentario
  end

  def completo?
    ponto == regra.direita.length
  end

  def next_symbol
    regra.direita[ponto]
  end

  def advance(k, regra_anterior)
    Estado.new(regra, ponto + 1, inicio, "Scan de S(#{k})(#{regra_anterior})")
  end

  def complete(k, regra1, regra2)
    Estado.new(regra, ponto + 1, inicio, "Completo de #{regra1} e S(#{k})(#{regra2})")
  end

  def ==(other)
    regra.to_s == other.regra.to_s && ponto == other.ponto && inicio == other.inicio
  end

  def eql?(other)
    self == other
  end

  def hash
    [regra.to_s, ponto, inicio].hash
  end

  def to_s
    direita = @regra.direita.join.insert(ponto, '.')
    "#{@regra.esquerda} -> #{direita} (origem #{@inicio})"
  end
end

class S
  attr_reader :estados, :estados_visitados

  def initialize(index, entrada)
    @index = index
    @estados = Set.new
    @estados_visitados = Set.new
    @entrada = entrada
  end

  def <<(element)
    estados << element unless estados_visitados.include?(element)
  end

  def take!
    taken = (estados - estados_visitados).take(1)
    estados_visitados << taken[0]
    taken[0]
  end

  def empty?
    (estados - estados_visitados).empty?
  end

  def to_s
    expressao = @entrada.split('').join.insert(@index, '.')
    out = "==== S(#{@index}): #{expressao} ====\n"
    estados.each do |estado|
      out << "#{estado} | Origem: #{estado.inicio} | #{estado.comentario}\n"
    end
    out
  end
end
