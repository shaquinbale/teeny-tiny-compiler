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
      statement
    end
  end

  def statement
    # Check the first token to see what kind of statement this is
 
    # "PRINT" (expression | string)
    if check_token(:PRINT)
      puts "STATEMENT-PRINT"
      next_token

      if check_token(:STRING)
        # Simple string
        next_token
      else
        # Expect an expression
        expression
      end
    # "IF" comparison "THEN" nl {statement} "ENDIF" nl
    elsif check_token(:IF)
      puts "STATEMENT-IF"
      next_token
      comparison

      match(:THEN)
      nl

      until check_token(:ENDIF)
        statement
      end

      match(:ENDIF)
    # "WHILE" comparison "REPEAT" nl {statement nl} "ENDWHILE" nl
    elsif check_token(:WHILE)
      puts "STATEMENT-WHILE"
      next_token
      comparison

      match(:REPEAT)
      nl

      until check_token(:ENDWHILE)
        statement
      end

      match(:ENDWHILE)
    # "LABEL" ident
    elsif check_token(:LABEL)
      puts "STATEMENT-LABEL"
      next_token
      match(:IDENT)
    # "GOTO" ident
    elsif check_token(:GOTO)
      puts "STATEMENT-GOTO"
      next_token
      match(:IDENT)
    # "LET" ident "=" expression
    elsif check_token(:LET)
      puts "STATEMENT-LET"
      next_token
      match(:IDENT)
      match(:EQ)
      expression
    # "INPUT" ident
    elsif check_token(:INPUT)
      puts "STATEMENT-INPUT"
      next_token
      match(:IDENT)
    # Invalid statement, throw an error
    else
      abort("Invalid statement at #{@current_token}(#{@current_token.text})")
    end

    nl
  end

  # comparison ::= expression (("==" | "!=" | ">" | ">=" | "<" | "<=") expression)+
  def comparison
    puts "COMPARISON"

    expression
    if comparison_operator?
      next_token
      expression
    else
      abort("Expected comparison operator at #{@current_token.text}")
    end

    while comparison_operator?
      next_token
      expression
    end
  end

  # Return true if the current token is a comparison operator.
  def comparison_operator?
    check_token(:GT || :LT || :EQ || :GTEQ || :LTEQ || :EQEQ || :NOTEQ)
  end

  # expression ::= term {( "-" | "+" ) term}
  def expression
    puts "EXPRESSION"

    term
    while check_token(:PLUS) || check_token(:MINUS)
      next_token
      term
    end
  end

  # term ::= unary {( "/" | "*" ) unary}
  def term
    puts "TERM"

    unary
    while check_token(:SLASH) || check_token(:ASTERISK)
      next_token
      unary
    end
  end

  # unary ::= ["+" | "-"] primary
  def unary
    puts "UNARY"

    if check_token(:PLUS) || check_token(:MINUS)
      next_token
    end
    primary
  end

  # primary ::= number | ident
  def primary
    puts "PRIMARY #{@current_token.text}"

    if check_token(:NUMBER)
      next_token
    elsif check_token(:IDENT)
      next_token
    else
      abort("Unexpected token at #{@current_token.text}")
    end
  end

  # nl ::= '\n'+
  def nl
    puts ("NEWLINE")

    match(:NEWLINE)
    while check_token(:NEWLINE)
      next_token
    end
  end
end