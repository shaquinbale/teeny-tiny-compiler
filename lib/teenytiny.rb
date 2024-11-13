require_relative 'lex'

def main
  source = "+- */ >>= = !="
  lexer = Lexer.new(source)

  token = lexer.get_token
  while token.kind != TokenType::EOF
    p token.kind
    token = lexer.get_token
  end
end

main