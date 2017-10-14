module Skylab::BeautySalon

  class CrazyTownMagnetics_::DocumentProcessors_via_Definition < Common_::MagneticBySimpleModel

    # see "our take on an AST processsor" specifically
    # "what is this 'document processor'?" [#021.B]

    # -

      def initialize
        @document_processors_hash = {}
        @__mutex_for_on_each_file_path = nil
        @__mutex_for_after_last_file = nil
        yield self
        @document_processors_hash.freeze
        freeze
      end

      def define_document_processor k, & two_p

        @document_processors_hash[ k ] && fail
        @document_processors_hash[ k ] = :__locked__

        _dp = DocumentProcesSOR_via_Definition___.call_by do |o|
          yield o  # hi.
        end

        @document_processors_hash[ k ] = _dp ; nil
      end

      def on_each_file_path & p
        remove_instance_variable :@__mutex_for_on_each_file_path
        @receive_each_file_path__ = p ; nil
      end

      def after_last_file & p
        remove_instance_variable :@__mutex_for_after_last_file
        @proc_for_after_last_file__ = p ; nil
      end

      def execute
        self
      end

      attr_reader(
        :receive_each_file_path__,
        :document_processors_hash,
        :proc_for_after_last_file__,
      )
    # -

    # ==

    class DocumentProcesSOR_via_Definition___ < Common_::MagneticBySimpleModel

      def initialize

        @on_each_node = :__on_each_node_initially

        @on_this_one_type_of_node = :__on_this_type_of_node_initially

        @__mutex_for_custom_stack_hooks = nil

        @__mutex_for_before_each_file = nil

        @__mutex_for_after_each_file = nil

        yield self
      end

      # ~  type-based node hooks cannot currently be used with an
      #    "on each node" type hook (by design). shut out the other
      #    the first time you get one of these.  ##here1 (a provision)

      def on_this_one_type_of_node k, & p  # 1x
        send @on_this_one_type_of_node, p, k
      end

      def __on_this_type_of_node_initially p, k

        @_has_type_based_hooks_ = true
        @_type_based_hook_box_ = Common_::Box.new
        remove_instance_variable :@on_each_node  # (shut out the other way)
        @on_this_one_type_of_node = :__on_this_one_type_of_node_normally
        send @on_this_one_type_of_node, p, k
      end

      def __on_this_one_type_of_node_normally p, k
        @_type_based_hook_box_.add k, p
        NIL
      end

      # ~  the "on each node" type of hook (by design):
      #
      #    - cannot be used in conjunction with type-based hooks (because
      #      how should the two work in concert? it is not immediately,
      #      intuitively clear: does the one trump the other? come before?
      #      come after? which one trumps which one?)
      #
      #    - cannot be defined multiple times (for the same reason: does the
      #      subsequent definition clobber the previous or are they a list
      #      to be executed in sequence?)
      #
      #    so shut out etc.  ##here1 (a provision)

      def on_each_node & p
        send @on_each_node, p
      end

      def __on_each_node_initially p

        remove_instance_variable :@on_this_one_type_of_node  # (shut out the other way)
        remove_instance_variable :@on_each_node  # (shut out self from subsequent calls)
        @_has_universal_hook_ = true
        @_universal_hook_ = p ; nil
      end

      # ~

      def customize_stack_hooks_by__ & p

        remove_instance_variable :@__mutex_for_custom_stack_hooks
        @_custom_stack_hooks_ = p
      end

      def before_each_file & p
        remove_instance_variable :@__mutex_for_before_each_file
        @_before_each_file_ = p ; nil
      end

      def after_each_file & p
        remove_instance_variable :@__mutex_for_after_each_file
        @_after_each_file_ = p ; nil
      end

      attr_writer(
        :listener,
        :named_listeners,
      )

      def execute

        DocumentDispatcher___.new( self ).execute
      end

      attr_reader(
        :_after_each_file_,
        :_before_each_file_,
        :_custom_stack_hooks_,
        :_has_type_based_hooks_,
        :_has_universal_hook_,
        :listener,
        :named_listeners,
        :_type_based_hook_box_,
        :_universal_hook_,
      )
    end

    # ==

    class DocumentDispatcher___

      def initialize o
        @_ = o
      end

      def execute

        __decide_whether_or_not_you_have_to_parse_each_file

        __decide_whether_or_not_to_use_the_ensure_block

        @__before_each_file = @_._before_each_file_ || MONADIC_EMPTINESS_
        @__after_each_file = @_._after_each_file_ || MONADIC_EMPTINESS_

        remove_instance_variable :@_
        freeze
      end

      def __decide_whether_or_not_you_have_to_parse_each_file

        # (spelled out in longform for now..)

        if @_._has_type_based_hooks_
          yes = true
        elsif @_._has_universal_hook_
          yes = true
        elsif @_._custom_stack_hooks_
          yes = true
        end
        if yes
          __go_big
        else
          @_into_each_file = MONADIC_EMPTINESS_  # assume before/after hooks only
        end

        NIL
      end

      def __go_big

        disp = __flush_dispatcher

        @_into_each_file = -> potential_AST do

          _wrapped_AST = potential_AST.sexp

          disp.dispatch_wrapped_document_AST__ _wrapped_AST
        end
        NIL
      end

      def __flush_dispatcher

        _fb = CrazyTownMagnetics_::StructuredNode_via_Node.structured_nodes_as_feature_branch

        CrazyTownMagnetics_::Dispatcher_via_Hooks.define do |o|

          o.type_based_hook_box = @_._type_based_hook_box_
          o.universal_hook = @_._universal_hook_
          o.custom_stack_hooks = @_._custom_stack_hooks_

          # NOTE here is where for now we hard-code this syntax-specific
          # thing. maybe one day etc. #[#007.B]

          o.grammar_symbols_feature_branch = _fb

          o.listener = @_.listener
        end
      end

      def __decide_whether_or_not_to_use_the_ensure_block

        # `ensure` clauses are annoying to get bumped into when, for example,
        # you just want to exit, or you're step-debugging

        nl = @_.named_listeners

        if nl
          oeo_p = nl.on_error_once
        end
        if oeo_p
          @process_document = :__process_document_with_ensure
          @__on_error_once = oeo_p
        else
          @process_document = :_process_document_without_ensure
        end
      end

      def process_document potential_AST
        send @process_document, potential_AST
      end

      def __process_document_with_ensure potential_AST

        _process_document_without_ensure potential_AST
        ok = true
      ensure
        if ! ok
          @__on_error_once[]  # (can't remove because frozen. meh.)
        end
        NIL
      end

      def _process_document_without_ensure potential_AST

        @__before_each_file[ potential_AST ]
        @_into_each_file[ potential_AST ]
        @__after_each_file[ potential_AST ]

        NIL
      end
    end

    # ==
    # ==

    # :#here1: (a provision) we assume this provision which to us amounts to:
    #
    #   - `~universal_hook` and `~type_based_hook_box` are mutually
    #     exclusive. it's possible that neither is set. (so 3 permutations.)
    #
    #   - when one of the above is set, `~branchy_node_hook` is either
    #     set or not set (i.e no relation).
    #
    #   - if neither of the above is set, `~branchy_node_hook` must be
    #     set. (so 5 permutations in total). whew!
    # )
  end
end
# #broke out of sibling
