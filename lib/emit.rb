class Emitter
  def initialize(full_path)
    @full_path = full_path
    @header = ""
    @code = ""
  end

  def emit(code)
    @code += code
  end

  def emit_line(code)
    @code += code + "\n"
  end

  def header_line(code)
    @header += code + "\n"
  end

  def write_file
    File.open(@full_path, 'w') do |output_file|
      output_file.write(@header + @code)
    end
  end
end