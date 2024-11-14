require_relative 'lex'
require_relative 'parser'

def main
  puts "Teeny Tiny Compiler"

  if ARGV.length != 1
    abort("Error: Compiler needs a source file as an argument")
  end

  source = File.read(ARGV[0], 'r')

  lexer = Lexer.new
  parser = Parser.new

  parser.program
  puts "Parsing complete."
end

main