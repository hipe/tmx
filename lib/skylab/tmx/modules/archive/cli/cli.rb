module Skylab::TMX::Modules::CLI

  class CLI < ::Skylab::Face::CLI

    use :hi
    set :desc, -> y do
      y << "#{ hi 'description:' } this used to \"install\" an early-ass"
      y << "  version of our CLI client places .. i don't even.."
      y << "  it was something like for moving things between diff repos."
    end

    def initialize( * )
      super
      @param_h = { }
    end

    def ping
      @y << "hello from cli."
      :hello_from_cli
    end

    option_parser do |op|
      req = @param_h ; usage_string = @mechanics.last_hot.usage_line
      op.banner = "pull cli source code files from <source>\n#{usage_string}"
      op.on('-d', '--diff', 'Show diffs.') { req[:diff] = true }
      op.on('-n', '--dry-run', 'Dry Run.') { req[:dry_run] = true }
      op.on('-F', '--force', 'Clobber local files.') { req[:force] = true }
      op.on('--name REGEX', 'Limit to files whose short name matches REGEX.') { |x| req[:pattern] = x }
    end

    def pull source
      req = @param_h
      require "#{File.dirname(__FILE__)}/api"
      API::Pull.run(self, source, req)
    end

    option_parser do |op|
      req = @param_h
      usage_string = @mechanics.last_hot.usage_line
      op.banner = "push cli source code files to <target>\n#{usage_string}"
      op.on('-d', '--diff', 'Show diffs.') { req[:diff] = true }
      op.on('-n', '--dry-run', 'Dry run.') { req[:dry_run] = true }
      op.on('-F', '--force', 'Clobber local files.') { req[:force] = true }
      op.on('--name REGEX', 'Limit to files whose short name matches REGEX.') { |x| req[:pattern] = x }
    end

    def push target
      require "#{File.dirname(__FILE__)}/api"
      API::Push.run(self, target, req)
    end
  end
end
