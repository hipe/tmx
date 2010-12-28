module Hipe::CssConvert
  require ROOT + '/interface-reflector'
  class CoreInterface
    extend InterfaceReflector
    class << self
      def build_interface
        RequestParser.new do |o|
          o.on('-v', '--version', 'Display version information.')
          o.on('-h', '--help',    'Display help screen.'        )
        end
      end
    end
    def build_context
      ExecutionContext.new
    end
    def version_string
      require ROOT + '/version'
      VERSION
    end
    def run_convert
      @exit_ok and return
      @c.out.puts "ok whatever: #{@argv.inspect}"
    end
  end
end
