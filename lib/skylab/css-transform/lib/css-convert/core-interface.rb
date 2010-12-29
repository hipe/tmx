module Hipe::CssConvert
  require ROOT + '/interface-reflector'
  class CoreInterface
    extend InterfaceReflector
    def self.build_interface
      InterfaceReflector::RequestParser.new do |o|
        o.on('-d', '--directives',
          '(debugging) Show sexp of parsed directives file.')
        o.on('-v', '--version', 'Display version information.')
        o.on('-h', '--help',    'Display help screen.'        )
        o.arg('<directives-file>', 'A file with directives in it.')
      end
    end
  protected
    def default_action; :run_convert           end
    def build_context
      c = ExecutionContext.new
      c[:tmpdir] = ROOT + '/tmp'
      c
    end
    def on_version
      require ROOT + '/version'
      @c.err.puts "#{program_name} #{VERSION}"
      @exit_ok = true
    end
    def on_directives
      @c[:show_parsed_directives] = true
    end
    def run_convert
      sexp = parse_directives_in_file(@c[:directives_file]) or return
      if @c[:show_parsed_directives]
        require 'pp'
        PP.pp(sexp, @c.err)
        return
      end
      @c.out.puts "ok whatever"
    end
    def parse_directives_in_file path
      require ROOT + '/directives-parser'
      begin
        DirectivesParser.new(@c).parse_file(path)
      rescue DirectivesParser::RuntimeError => e
        return error(style('error: ', :error) << e.message)
      end
    end
  end
end

