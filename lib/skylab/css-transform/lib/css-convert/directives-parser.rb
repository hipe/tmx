class Hipe::CssConvert::DirectivesParser
  class RuntimeError < ::RuntimeError; end
  def initialize ctx
    @c = ctx
  end
  def parse_file path
    path && File.exist?(path) or
      return error("directives file not found: #{path.inspect}")
    { :foo => 'bar' }
  end
private
  def error msg
    raise RuntimeError.new(msg)
  end
end
