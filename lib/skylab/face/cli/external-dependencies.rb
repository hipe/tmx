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
        syntax "#{invocation_string} [opts] [<name> [<name> [..]]]"
        op.banner = <<-HERE.gsub(/^ +/, '')
          install the dependencies
          #{usage_string}
          #{hi('options:')}
        HERE
        op.on('-c', '--check',
          "Only check to see if the dependencies are there.") { req[:check] = true }
        req[:build_dir] =  File.join(ENV['HOME'] || '~', '/build')
        op.on('--build-dir DIR',
          "Specifies build directory. (default: #{pretty_path(req[:build_dir])})") { |bd| req[:build_dir] = bd }
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
