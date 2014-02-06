module Skylab::GitViz

  module VCS_Adapters_::Git

    class Repo_::Hist_Tree__  # part of [#012]

      def initialize repo, listener
        @listener = listener ; @repo = repo
      end

      def build_bunch
        self.class::Bunch__.build_bunch self, @listener
      end

      # ~ for the children

      attr_reader :repo

      class Simple_Agent_  # see [#008] #defining-agents-in-this-context
        class << self
          alias_method :orig_new, :new
          def new * i_a, & p
            ::Class.new( Simple_Agent_ ).class_exec do
              class << self ; alias_method :new, :orig_new end
              const_set :IVARS__, i_a.map { |i| :"@#{ i }" }.freeze
              p and class_exec( & p )
              self
            end
          end
          def [] * a
            new( a ).execute
          end
        end
        def initialize a
          self.class::IVARS__.each_with_index do |ivar, d|
            instance_variable_set ivar, a.fetch( d )
          end ; nil
        end
      end

      SILENT_ = nil
    end
  end
end
