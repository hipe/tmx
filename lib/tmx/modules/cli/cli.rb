module Skylab::Tmx::Modules::Cli
  class Cli < Skylab::Face::Cli
    namespace :cli do
      o :pull do |op, req|
        syntax "#{invocation_string} [opts] <source>"
        op.banner = "pull cli source code files from <source>\n#{usage_string}"
        op.on('-d', '--diff', 'Show diffs.') { req[:diff] = true }
        op.on('-n', '--dry-run', 'Dry Run.') { req[:dry_run] = true }
        op.on('-F', '--force', 'Clobber local files.') { req[:force] = true }
        op.on('--name REGEX', 'Limit to files whose short name matches REGEX.') { |x| req[:pattern] = x }
      end
      def pull req, source
        require "#{File.dirname(__FILE__)}/api"
        Api::Pull.run(self, source, req)
      end
      o :push do |op, req|
        syntax "#{invocation_string} [opts] <target>"
        op.banner = "push cli source code files to <target>\n#{usage_string}"
        op.on('-d', '--diff', 'Show diffs.') { req[:diff] = true }
        op.on('-n', '--dry-run', 'Dry run.') { req[:dry_run] = true }
        op.on('-F', '--force', 'Clobber local files.') { req[:force] = true }
        op.on('--name REGEX', 'Limit to files whose short name matches REGEX.') { |x| req[:pattern] = x }
      end
      def push req, target
        require "#{File.dirname(__FILE__)}/api"
        Api::Push.run(self, target, req)
      end
    end
  end
end
