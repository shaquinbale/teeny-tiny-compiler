require_relative 'lex'
require_relative 'emit'
require 'set'

# Parser object keeps track of current token and checks if the code matches the grammar.
class Parse
  def initialize(lexer, emitter)
    @lexer = lexer
    @emitter = emitter

    @symbols = Set.new
    @labels_declared = Set.new
    @labels_gotoed = Set.new

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
    @emitter.header_line("#include <stdio.h>")
    @emitter.header_line("int main(void){")

    # Skip excess newlines in the grammar
    while check_token(:NEWLINE)
      next_token
    end

    # Parse all statements in the program
    until check_token(:EOF)
      statement
    end

    # Wrap things up
    @emitter.emit_line("return 0;")
    @emitter.emit_line("}")

    @labels_gotoed.each do |label|
      unless @labels_declared.include?(label)
        abort("Attempting to GOTO to undeclared label: #{label}")
      end
    end
  end

  def statement
    # Check the first token to see what kind of statement this is
 
    # "PRINT" (expression | string)
    if check_token(:PRINT)
      next_token

      if check_token(:STRING)
        # Simple string
        @emitter.emit_line("printf(\"#{@current_token.text}\\n\");")
        next_token
      else
        # Expect an expression
        @emitter.emit("printf(\"%.2f\\n\", (float)(")
        expression
        @emitter.emit_line("));")
      end

    # "IF" comparison "THEN" nl {statement} "ENDIF" nl
    elsif check_token(:IF)
      next_token
      @emitter.emit("if(")
      comparison

      match(:THEN)
      nl
      @emitter.emit_line("){")

      until check_token(:ENDIF)
        statement
      end

      match(:ENDIF)
      @emitter.emit_line("}")

    # "WHILE" comparison "REPEAT" nl {statement nl} "ENDWHILE" nl
    elsif check_token(:WHILE)
      next_token
      @emitter.emit("while(")
      comparison

      match(:REPEAT)
      nl
      @emitter.emit_line("){")

      until check_token(:ENDWHILE)
        statement
      end

      match(:ENDWHILE)
      @emitter.emit_line("}")

    # "LABEL" ident
    elsif check_token(:LABEL)
      next_token

      if @labels_declared.include?(@current_token)
        abort("Label already declared: #{@current_token.text}")
      end
      @labels_declared.add(@current_token.text)

      @emitter.emit_line("#{@current_token.text}:")
      match(:IDENT)

    # "GOTO" ident
    elsif check_token(:GOTO)
      next_token
      @labels_gotoed.add(@current_token.text)
      @emitter.emit_line("goto #{@current_token.text};")
      match(:IDENT)

    # "LET" ident "=" expression
    elsif check_token(:LET)
      next_token

      # Check if ident exists in the symbol table. If not, declare it
      unless @symbols.include?(@current_token.text)
        @symbols.add(@current_token.text)
        @emitter.header_line("float #{@current_token.text};")
      end

      @emitter.emit("#{@current_token.text} = ")
      match(:IDENT)
      match(:EQ)

      expression
      @emitter.emit_line(";")

    # "INPUT" ident
    elsif check_token(:INPUT)
      next_token

      # If the variable doesnt exist, declare it
      unless @symbols.include?(@current_token.text)
        @symbols.add(@current_token.text)
        @emitter.header_line("float #{@current_token.text};")
      end

      @emitter.emit_line("if(0 == scanf(\"%f\", &#{@current_token.text})) {")
      @emitter.emit_line("#{@current_token.text} = 0;")
      @emitter.emit("scanf(\"%")
      @emitter.emit_line("*s\");")
      @emitter.emit_line("}")
      match(:IDENT)

    # Invalid statement, throw an error
    else
      abort("Invalid statement at #{@current_token}(#{@current_token.text})")
    end

    nl
  end

  # comparison ::= expression (("==" | "!=" | ">" | ">=" | "<" | "<=") expression)+
  def comparison
    expression

    if comparison_operator?
      @emitter.emit(@current_token.text)
      next_token
      expression
    else
      abort("Expected comparison operator at #{@current_token.text}")
    end

    while comparison_operator?
      @emitter.emit(@current_token.text)
      next_token
      expression
    end
  end

  # Return true if the current token is a comparison operator.
  def comparison_operator?
    check_token(:GT) || check_token(:GTEQ) || check_token(:LT) || check_token(:LTEQ) || check_token(:EQ) || check_token(:EQEQ)
  end

  # expression ::= term {( "-" | "+" ) term}
  def expression
    term
    while check_token(:PLUS) || check_token(:MINUS)
      @emitter.emit(@current_token.text)
      next_token
      term
    end
  end

  # term ::= unary {( "/" | "*" ) unary}
  def term
    unary
    while check_token(:SLASH) || check_token(:ASTERISK)
      @emitter.emit(@current_token.text)
      next_token
      unary
    end
  end

  # unary ::= ["+" | "-"] primary
  def unary
    if check_token(:PLUS) || check_token(:MINUS)
      @emitter.emit(@current_token.text)
      next_token
    end
    primary
  end

  # primary ::= number | ident
  def primary
    if check_token(:NUMBER)
      @emitter.emit(@current_token.text)
      next_token

    elsif check_token(:IDENT)
      # Ensure the variable already exists
      unless @symbols.include?(@current_token.text)
        abort("Referencing variable before assignment: #{@current_token.text}")
      end

      @emitter.emit(@current_token.text)
      next_token

    else
      abort("Unexpected token at #{@current_token.text}")
    end
  end

  # nl ::= '\n'+
  def nl
    match(:NEWLINE)
    while check_token(:NEWLINE)
      next_token
    end
  end
end