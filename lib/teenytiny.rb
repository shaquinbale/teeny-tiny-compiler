require_relative 'lex'

def main
  source = "+-123 9.8654*/"
  lexer = Lexer.new(source)

  token = lexer.get_token
  while token.kind != :EOF
    p token.kind
    token = lexer.get_token
  end
end

main