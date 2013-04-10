module Skylab::Cull

  class CLI::Client < Face::CLI

    option_parser do |o|
      o.banner = "#{ hi 'description:' } wanktasktic awesomeness"
      o.on '-n', '--dry-run', 'dry-run.' do
        @param_h[ :dry_run ] = true
      end
    end

    def init path=nil
      @param_h[:path] = path
      @out.puts "hi: #{ @param_h.inspect }"
      @y << 'wayoo'
      ok
    end

  protected

    def initialize( * )
      super
      @param_h = { }
    end

    def ok
      0  # exit code
    end
  end
end
