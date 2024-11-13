require_relative 'lex'

def main
  source = "IF+-123 foo*THEN/"
  lexer = Lexer.new(source)

  token = lexer.get_token
  while token.kind != :EOF
    p token.kind
    token = lexer.get_token
  end
end

main