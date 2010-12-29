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

        o.arg('<first-req>', 'A file with directives in it.')
        o.arg('<sec-req>', 'Another arg')
        o.arg('[<third-req>]', 'Another arg')
        o.arg('[<fourth-req>]', 'Another arg')
        o.arg('[<fifth-req>]', 'Another arg')
        o.arg('<sixth-req>', 'Another arg')
      end
    end
    def build_context
      ExecutionContext.new
    end
    def version_string
      require ROOT + '/version'
      VERSION
    end
    def on_directives
      @exit_ok = true
      @c[:show_parsed_directives] = true
    end
    def run_convert
      @exit_ok and return
      @c.out.puts "ok whatever: #{@c.inspect}"
    end
  end
end
