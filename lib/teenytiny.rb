require_relative 'lex'
require_relative 'parse'

def main
  puts "Teeny Tiny Compiler"

  if ARGV.length != 1
    abort("Error: Compiler needs a source file as an argument")
  end

  source = File.read(ARGV[0])

  lexer = Lexer.new(source)
  parser = Parse.new(lexer)

  parser.program
  puts "Parsing complete."
end

main