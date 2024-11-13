require 'set'

class Lexer
  attr_reader :current_char

  def initialize(source)
    @source = source + "\n" # Source code to lex as a string. Adds a newline to simplify lexing/parsing the last token/statement
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
    puts message
    exit(1)
  end

  # Skip whitespace, except for newlines, which indicate the end of the statement
  def skip_whitespace
    while @current_char == ' ' || @current_char == "\t" || @current_char == "\r"
      self.next_char
    end
  end

  # Skip comments in code
  def skip_comments
    if @current_char == '#'
      while @current_char != "\n"
        next_char
      end
    end
  end

  # Return next token
  def get_token
    skip_whitespace
    skip_comments
    token = nil
  
    case @current_char
    when '+'
      token = Token.new(@current_char, :PLUS)
    when '-'
      token = Token.new(@current_char, :MINUS)
    when '*'
      token = Token.new(@current_char, :ASTERISK)
    when '/'
      token = Token.new(@current_char, :SLASH)
    when "\n"
      token = Token.new(@current_char, :NEWLINE)
    when "\0"
      token = Token.new(@current_char, :EOF)
    when '='
      # Check whether token is = or ==
      if peek == '='
        last_char = @current_char
        @current_char = next_char
        token = Token.new((last_char + @current_char), :EQEQ)
      else
        token = Token.new(@current_char, :EQ)
      end
    when '<'
      # Check whether token is < or <=
      if peek == '='
        last_char = current_char
        @current_char = next_char
        token = Token.new((last_char + @current_char), :LTEQ)
      else
        token = Token.new(@current_char, :LT)
      end
    when '>'
      # Check whether token is > or >=
      if peek == '='
        last_char = current_char
        @current_char = next_char
        token = Token.new((last_char + @current_char), :GTEQ)
      else
        token = Token.new(@current_char, :GT)
      end
    when '!'
      if peek == '='
        last_char = current_char
        @current_char = next_char
        token = Token.new((last_char + @current_char), :NOTEQ)
      else
        abort("Expected '!+', got  !#{@current_char}")
      end
    when '"'
      next_char
      start_position = @current_pos

      while @current_char != '"'
        if ["\r", "\n", "\t", "\\", "%"].include?(@current_char)
          abort("Illegal character: #{current_char}")
        end
        next_char
      end

      tok_text = @source[start_position...@current_pos]
      token = Token.new(tok_text, :STRING)
    when /[0-9]/
      start_position = @current_pos

      while peek =~ /[0-9]/
        next_char
      end
      if peek == '.'
        next_char

        if peek !~ /[0-9]/
          abort("Illegal character in number")
        end
        while peek =~ /[0-9]/
          next_char
        end
      end

      tok_number = @source[start_position..@current_pos] # This might be buggy later, idk if i did it right
      token = Token.new(tok_number, :NUMBER)
    when /[a-zA-z]/
      start_position = @current_pos
      while peek =~ /[a-zA-z0-9]/
        next_char
      end

      tok_text = @source[start_position..@current_pos]
      token = TokenType.keyword?(tok_text) ? Token.new(tok_text, tok_text.to_sym) : Token.new(tok_text, :IDENT)
    else
      # Unknown Token
      abort("Unknown token #{@current_char}")
    end
    next_char
    token
  end
end

class Token
  attr_accessor :text, :kind

  def initialize(token_text, token_kind)
    @text = token_text
    @kind = token_kind
  end
end

module TokenType
  EOF = :EOF
  NEWLINE = :NEWLINE
  NUMBER = :NUMBER
  IDENT = :IDENT
  STRING = :STRING

  # Keywords
  LABEL = :LABEL
  GOTO = :GOTO
  PRINT = :PRINT
  INPUT = :INPUT
  LET = :LET
  IF = :IF
  THEN = :THEN
  ENDIF = :ENDIF
  WHILE = :WHILE
  REPEAT = :REPEAT
  ENDWHILE = :ENDWHILE

  # Operators
  EQ = :EQ
  PLUS = :PLUS
  MINUS = :MINUS
  ASTERISK = :ASTERISK
  SLASH = :SLASH
  EQEQ = :EQEQ
  NOTEQ = :NOTEQ
  LT = :LT
  LTEQ = :LTEQ
  GT = :GT
  GTEQ = :GTEQ

  KEYWORDS = Set.new([LABEL, GOTO, PRINT, INPUT, LET, IF, THEN, ENDIF, WHILE, REPEAT, ENDWHILE])

  def self.keyword?(token_type)
    KEYWORDS.include?(token_type.to_sym)
  end
end