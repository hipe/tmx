require File.expand_path('../../path-tools', __FILE__)

$:.include?(skylab_dir = File.expand_path('../../../..', __FILE__)) or $:.unshift(skylab_dir)
require 'skylab/dependency/primordial'

module Skylab::Face

  module ExternalDependencies

    module DefinerMethods
      def external_dependencies *a, &b
        (a.empty? && b.nil?) and return @external_dependencies
        @external_dependencies ||= begin
          self.class_eval(&CommandDefinitionsBlock)
          Skylab::Dependency::Primordial.new
        end
        @external_dependencies.merge_in!(*a, &b)
        @external_dependencies
      end
      def external_dependencies_inflated
        unless @external_dependencies.inflated?
          @external_dependencies = @external_dependencies.inflate
        end
        @external_dependencies
      end
    end

    CommandDefinitionsBlock = lambda do |_|
      o do |op, req|
        extend PathTools
        item_name = @parent.name
        syntax "#{invocation_string} [opts] [<name> [<name> [..]]]"
        op.banner = <<-HERE.gsub(/^ +/, '')
          For attempting to install and/or inspecting installation of #{item_name}.
          #{usage_string}
          #{hi('options:')}
        HERE
        op.on('-c', '--check',
          "Only check to see if the dependencies are there.") { req[:check] = true }
        op.on('-u', '--update',
          'Where available, search for and install the most recent tarball',
          'using simple heuristics with the release numbers.',
          'Where available, when used in conjuction with --check this will only search not install.'
           ) { req[:update] = true }
        op.on('-v', '--verbose', 'Be verbose.') { req[:verbose] = true }
        op.on
        op.on('-n', '--dry-run',
          "Perform a dry run only (where available).") { req[:dry_run] = true }
        req[:build_dir] =  File.join(ENV['HOME'] || '~', '/build')
        op.on('--build-dir DIR',
          "Specifies build directory. (default: #{pretty_path(req[:build_dir])})") { |bd| req[:build_dir] = bd }
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

module Skylab::Face
  class Command::Namespace
    extend ExternalDependencies::DefinerMethods
  end
end
