require 'skylab/face/path-tools' # assumes INCLUDE_PATH "hack" occured (or gems maybe)

module Skylab
  module Dependency
    module Interface ; end
  end
end

module Skylab::Dependency
  module Interface
    CliCommands = lambda do |_|
      o do |op, req|
        extend ::Skylab::Face::PathTools
        item_name = @parent.name
        syntax "#{invocation_string} [opts] [<name> [<name> [..]]]"
        op.banner = <<-HERE.gsub(/^ +/, '')
          For attempting to install and/or inspecting installation of #{item_name}.
          #{usage_string}
          #{hi('options:')}
        HERE
        op.on('-c', '--check',
          "Only check to see if the items appear to be installed on the system.") { req[:check] = true }
        op.on('-u', '--update',
          'If used with --check, search for the the most recent tarball available',
          'using simple heuristics for guessing next possible release numbers using the url.',
          'If used without --check, will install the most recent version found using the above check.'
           ) { req[:update] = true }
        op.on('-n', '--dry-run',
          "Perform a dry run only (where available).") { req[:dry_run] = true }
        req[:build_dir] =  File.join(ENV['HOME'] || '~', '/build')
        op.on('--build-dir DIR',
          "Specifies build directory. (default: #{pretty_path(req[:build_dir])})") { |bd| req[:build_dir] = bd }
        op.on('--name NAME', "only run the child node with the given NAME (debugging)") { |nm| req[:name] = nm }
        op.on('--view-tree', "(debugging feature)") { req[:view_tree] = true }
        op.on('--view-bash', "Supress all output except the bash commands that would be executed (experimental).") { req[:view_bash] = true }
      end
      def install req, *names
        req[:names] = names
        interface.external_dependencies_inflated.run(self, req)
      end
    end
  end
end

