require_relative 'lex'

def main
  source = "LET foobar = 123"
  lexer = Lexer.new(source)

  while lexer.peek != "\0"
    puts lexer.current_char
    lexer.next_char
  end
end

main