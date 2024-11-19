require_relative 'lex'
require_relative 'parse'
require_relative 'emit'

def main
  puts "Teeny Tiny Compiler"

  if ARGV.length != 1
    abort("Error: Compiler needs a source file as an argument")
  end

  source = File.read(ARGV[0])

  lexer = Lexer.new(source)
  emitter = Emitter.new("out.c")
  parser = Parse.new(lexer, emitter)

  parser.program
  emitter.write_file
  puts "Compiling completed."
end

main