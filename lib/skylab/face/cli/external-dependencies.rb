$:.include?(skylab_dir = File.expand_path('../../../..', __FILE__)) or $:.unshift(skylab_dir)
require 'skylab/dependency/primordial'
require 'skylab/dependency/interface/cli-commands'

module Skylab::Face

  module ExternalDependencies

    module DefinerMethods
      def external_dependencies *a, &b
        (a.empty? && b.nil?) and return @external_dependencies
        @external_dependencies ||= begin
          self.class_eval(&Skylab::Dependency::Interface::CliCommands)
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
 end
end

module Skylab::Face
  class Command::Namespace
    extend ExternalDependencies::DefinerMethods
  end
end

