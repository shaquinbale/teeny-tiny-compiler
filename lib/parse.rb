require_relative 'lex'

# Parser object keeps track of current token and checks if the code matches the grammar.
class Parse
  def initialize(lexer)
    @lexer = lexer

    @current_token = nil
    @peek_token = nil
    next_token
    next_token # Run twice to initialize  current and peek token
  end

  # Return true if current token matches
  def check_token(kind)
    @current_token.kind == kind
  end

  # Return true if next token matches
  def check_peek(kind)
    @peek_token.kind == kind
  end

  # Try to match current token. If not, error. Advances the current token.
  def match(kind)
    unless check_token(kind)
      abort("expected #{kind.name}, got #{@current_token.kind}")
    end
    next_token
  end

  # Advances the current token.
  def next_token
    @current_token = @peek_token
    @peek_token = @lexer.get_token
  end

  # Production rules 
  
  # program ::= {statment}
  def program
    puts "PROGRAM"

    until check_token(:EOF)
      
    end
  end
end