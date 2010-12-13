module Hipe; end
module Hipe::CssConvert
  class << self
    def cli
      Cli.new
    end
  end
  class Cli
    def run(argv)
      if 1 != argv.size
        puts "Usage: #{$PROGRAM_NAME} [file]"
        return 1;
      end
      file = argv.shift
      puts "sure, ok: #{file}"
    end
  end
end
