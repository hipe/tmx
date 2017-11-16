module Skylab::Basic

  module Module  # :[#053].

    class Unbound_via_Module  # [#br-013] is instructive.

      Brazen_ = ::Skylab::Brazen  # assumed

      include Brazen_.branchesque_defaults::Unbound_Methods

      def initialize source, mod
        @silo_module = mod
        @source = source
      end

      # ~ for indexing & UI

      def build_unordered_selection_stream & x_p
        _unbounds_indexation.build_unordered_selection_stream( & x_p )
      end

      def build_unordered_index_stream & x_p
        _unbounds_indexation.build_unordered_index_stream( & x_p )
      end

      def _unbounds_indexation
        @___UI ||= Brazen_::Branchesque::Indexation.new(
          @source, self )
      end

      def name_function
        @___nf ||= __build_name_function
      end

      def __build_name_function
        Brazen_::Nodesque::Name::Build_name_function[ self ]
      end

      def name  # for above
        @___name_s ||= @silo_module.name
      end

      # ~ for invocation, and used by modality interpreters

      def new ke, & x_p
        Bound___.new self, ke, & x_p
      end

      attr_reader :silo_module

      # ==

      class Bound___

        include Brazen_.branchesque_defaults::Bound_Methods

        def initialize unb, ke, & p

          @kernel = ke
          @listener = p
          @unbound = unb
        end

        # ~ indexing & reflection

        def to_unordered_selection_stream
          @unbound.build_unordered_selection_stream( & @listener )
        end

        # ~ invocation & used by modality interpreters

        def accept_parent_node _
          @_USE_ME_could_have_parent_bound = true
          NIL_
        end

        def name
          @unbound.name_function
        end
      end

      # ==
      # ==
    end
  end
end
