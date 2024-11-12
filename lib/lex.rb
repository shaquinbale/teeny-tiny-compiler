class Lexer
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
    
  end
end