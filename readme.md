# Projeto: Parsers Earley e CYK

Este projeto implementa dois algoritmos clássicos de análise sintática:

- **Earley Parser**: trabalha com gramáticas livres de contexto gerais (GLC).
- **CYK Parser**: exige gramáticas na Forma Normal de Chomsky (FNC).

---

### 📂 Estrutura do Projeto
/src
├── earley.rb       # Implementação do parser Earley
├── cyk.rb          # Implementação do parser CYK
├── estado.rb       # Estruturas de estado para Earley
├── gramatica.rb    # Classe Gramatica e Regra
├── main.rb         # Execução dos testes principais
├── tests.rb        # Testes automatizados
└── debug.rb        # Script auxiliar para visualizar o processo de análise

---

## 📖 Gramáticas

### Gramática GLC (Earley)
Aceita expressões matemáticas gerais:
- Operadores: `+`, `-`, `*`, `/`, `^`
- Parênteses
- Números (`NUMBER`)
- Negação unária

**Regras principais:**
Expr -> Expr + Term
Expr -> Expr - Term
Expr -> Term
Term -> Term * Factor
Term -> Term / Factor
Term -> Term ^ Factor
Term -> Factor
Factor -> ( Expr )
Factor -> - Factor
Factor -> NUMBER


### Gramática FNC (CYK)
Aceita expressões simples em Forma Normal de Chomsky:
- Operadores: `+`, `-`, `*`, `/`, `^`
- Parênteses
- Números (`NUMBER`)
- Negação unária

**Regras principais:**
NUM -> NUMBER
PLUS -> +
MINUS -> -
MUL -> *
DIV -> /
POW -> ^
LPAR -> (
RPAR -> )

S -> NUM EXPR
EXPR -> PLUS NUM
EXPR -> MINUS NUM
EXPR -> MUL NUM
EXPR -> DIV NUM
EXPR -> POW NUM

S -> LPAR EXPRP
EXPRP -> EXPR RPAR

S -> MINUS NUM


---

## ▶️ Execução
No terminal, dentro da pasta `src`:
```bash
ruby main.rb

Para rodar os testes automatizados:
ruby tests.rb

---

## 🐛 Modo Debug

O script `debug.rb` permite visualizar o processo de análise de uma expressão pelos dois parsers.

### Como executar
No terminal:
```bash
ruby debug.rb

O que é mostrado
Earley: imprime os tokens e mostra a leitura passo a passo.

CYK: constrói uma tabela triangular simplificada, exibindo os símbolos reconhecidos em cada célula.

Ao final, indica se a tabela levou a uma análise VÁLIDA ou INVÁLIDA.

Exemplo de saída:

=== Debug Earley ===
Expressão: 1+2
Tokens: ["NUMBER", "+", "NUMBER"]
Resultado final: Aceito
  [Earley] Posição 0: lendo NUMBER
  [Earley] Posição 1: lendo +
  [Earley] Posição 2: lendo NUMBER

=== Debug CYK ===
Expressão: 1+2
Tokens: ["NUMBER", "+", "NUMBER"]
Resultado final: Aceito

Tabela CYK detalhada:
[0,0] = {NUM}
[0,1] = {PLUS}
[0,2] = {EXPR, S}
[1,1] = {PLUS}
[1,2] = {}
[2,2] = {NUM}

Tabela indica que a expressão é VÁLIDA (S encontrado em [0,2])

Esse modo é útil para fins didáticos, permitindo acompanhar como cada parser interpreta a expressão.
