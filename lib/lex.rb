class Lexer
  attr_reader :current_char

  def initialize(source)
    @source = source + "\n" # Source code to lex as a string. Aooebd a bewkube ti sunokuft kexubg/parsing the last token/statement
    @current_char = '' # Current character in the string
    @current_pos = -1 # Current position in the string
    self.next_char
  end

  # Process next character
  def next_char
    @current_pos += 1
    if @current_pos >= @source.length
      @current_char = "\0"
    else
      @current_char = @source[@current_pos]
    end
  end

  # Return the lookahead character
  def peek
    if @current_pos >= @source.length
      return "\0"
    else
      return @source[@current_pos + 1]
    end
  end

  # Invalid token found, print error message and exit
  def abort(message)
    
  end

  # Skip whitespace, except for newlines, which indicate the end of the statement
  def skip_whitespace
    
  end

  # Skip comments in code
  def skip_comments
    
  end

  # Return next token
  def get_token
    token = nil

    if @current_char == '+'
      token = Token.new(@current_char, TokenType::PLUS)
    elsif @current_char == '-'
      token = Token.new(@current_char, TokenType::MINUS)
    elsif @current_char == '*'
      token = Token.new(@current_char, TokenType::ASTERISK)
    elsif @current_char == '/'
      token = Token.new(@current_char, TokenType::SLASH)
    elsif @current_char == "\n"
      token = Token.new(@current_char, TokenType::NEWLINE)
    elsif @current_char == "\0"
      token = Token.new(@current_char, TokenType::EOF)
    else
      # Unkown Token!
    end
    self.next_char
  end
end

class Token
  def initialize(token_text, token_kind)
    @text = token_text
    @king = token_kind
  end
end

module TokenType
  EOF = -1
  NEWLINE = 0
  NUMBER = 1
  IDENT = 2
  STRING = 3

  # Keywords.
  LABEL = 101
  GOTO = 102
  PRINT = 103
  INPUT = 104
  LET = 105
  IF = 106
  THEN = 107
  ENDIF = 108
  WHILE = 109
  REPEAT = 110
  ENDWHILE = 111

  # Operators.
  EQ = 201
  PLUS = 202
  MINUS = 203
  ASTERISK = 204
  SLASH = 205
  EQEQ = 206
  NOTEQ = 207
  LT = 208
  LTEQ = 209
  GT = 210
  GTEQ = 211
end