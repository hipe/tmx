$:.include?(skylab_dir = File.expand_path('../../../..', __FILE__)) or $:.unshift(skylab_dir)
# require 'skylab/dependency/primordial' # @todo:#099
require 'skylab/dependency/interface/cli-commands'

module Skylab::Face

  module ExternalDependencies

    module DefinerMethods
      def external_dependencies *a, &b
        @external_dependencies ||= nil
        (a.empty? && b.nil?) and return @external_dependencies
        if @external_dependencies.nil?
          self.class_eval(&Skylab::Dependency::Interface::CliCommands)
          @external_dependencies = nil # @todo in #099 Skylab::Dependency::Primordial.new
        end
        # @external_dependencies.merge_in!(*a, &b) # @todo in #099
        nil
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
