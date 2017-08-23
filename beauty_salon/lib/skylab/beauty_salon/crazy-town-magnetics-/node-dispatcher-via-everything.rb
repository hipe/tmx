module Skylab::BeautySalon

  class CrazyTownMagnetics_::NodeDispatcher_via_Everything < Common_::MagneticBySimpleModel

    # as part of [#021], primarily this exists as its own node to keep
    # the this lower-level stuff out of the grammar-specific client file.
    #
    # combine the lazy memoization of the following two things:
    #
    #   - universal dispatcher methods either do or don't take a variable
    #     with a [#021.D.2] magic name as the final argument. we implement
    #     this magic here: we awfully reflect on the *NAME* of the formal
    #     parameter in the code to see if it matches this magic name. this
    #     work is cached lazily.
    #
    #     (typically this magic name is employed only on the methods for
    #     "branchy" nodes.)
    #
    #   - either there is or isn't a hook associated with this node type
    #     (either because there is a universal hook or because there is a
    #     type-based hook box). the work of determining this also can be
    #     cached lazily per grammar symbol.
    #
    # since these characteristics don't change for the lifetime of the
    # parse, it's clunky to check them both over and over again at every
    # node we traverse.

    # -

      def initialize
        @_had_branchy_node_hook = false
        super  # hi.
      end

      def type_based_hook_box= bx
        if bx
          h = bx.h_
        end
        @_hook_via_node_type = h ; bx
      end

      def branchy_node_hook= x
        if x
          @_had_branchy_node_hook = true
        end
        @branchy_node_hook = x
      end

      attr_writer(
        :listener,
        :node_processor_via_methods,
        :universal_hook,
      )

      # (we assume #provision1.1 (see various) which to us amounts to:
      #
      #   - `@universal_hook` and `@type_based_hook_box` are mutually
      #     exclusive. it's possible that neither is set. (so 3 permutations.)
      #
      #   - when one of the above is set, `@branchy_node_hook` is either
      #     set or not set (i.e no relation).
      #
      #   - if neither of the above is set, `@branchy_node_hook` must be
      #     set. (so 5 permutations in total). whew!
      # )

      def execute
        __init_stack
        if @universal_hook
          @_work = :__work_when_universal_hook
        elsif @_hook_via_node_type
          @_work = :__work_when_type_based_hooks
        else
          @_had_branchy_node_hook || sanity
          @_work = :_work_when_no_hooks_here
        end
        __finish
      end

      def __finish

        @_traverser = @node_processor_via_methods.new self

        @_cached_work_via_tuple_key = {}
        @_seen_via_method_name = {}
        self
      end

      def __init_stack
        @stack = CrazyTownMagnetics_::Stack_via_BranchyNodeHook.call_by do |o|
          o.branchy_node_hook = remove_instance_variable :@branchy_node_hook
        end
        NIL
      end

      def dispatch_wrapped_document_AST__ wast

        @stack.for_file__ wast do

          # ignoring comments stuff

          ast = wast.ast_
          if ast
            @_traverser._node ast  # VIOLATION
          else
            @listener.call :info, :expression, :empty_file do |y|
              y << "(file has no code)"
            end
          end
        end
        NIL
      end

      # -- NOTE main entrypoint method. see "grammar symbols and methods in detail" [#021.J]

      def pre_descend__ m, n

        compound_key = [ m, n.type ]

        _my_method_name = @_cached_work_via_tuple_key.fetch compound_key do
          x = send @_work, * compound_key
          @_seen_via_method_name[ m ] && fail  # assert uniqueness of method name. see [#doc]
          @_seen_via_method_name[ m ] = true
          @_cached_work_via_tuple_key[ compound_key ] = x
          x
        end

        send _my_method_name, n
      end

      # --

      def __work_when_type_based_hooks m, node_type

        if @_hook_via_node_type[ node_type ]
          if _is_plus_one m
            :__node_type_specific_hook_and_plus_one
          else
            :__node_type_specific_hook_and_not_plus_one
          end
        else
          _work_when_no_hooks_here m
        end
      end

      def __work_when_universal_hook m, _

        if _is_plus_one m
          :__universal_hook_and_plus_one
        else
          :__universal_hook_and_not_plus_one
        end
      end

      def _work_when_no_hooks_here( m, * )

        if _is_plus_one m
          :__plus_one
        else
          :__not_plus_one
        end
      end

      def _is_plus_one m
        _meth = @_traverser.method m
        two = _meth.parameters.last
        two && :self_node == two.last  # see [#021.F]
      end

      def __node_type_specific_hook_and_plus_one n
        ::Kernel._OKAY
      end

      def __node_type_specific_hook_and_not_plus_one n
        @_hook_via_node_type[ n.type ][ n ]
        n.children
      end

      def __universal_hook_and_plus_one n
        @universal_hook[ n ]  # see #here1
        [ * n.children, n ]
      end

      def __universal_hook_and_not_plus_one n
        @universal_hook[ n ]  # see #here1
        n.children
      end

      def __plus_one n
        [ * n.children, n ]
      end

      def __not_plus_one n
        n.children
      end

      attr_reader(
        :stack,
      )
    # -

      # :#here1: ignore result - don't let hooks control our flow

    # ==

    This_crazy_thing = -> mod do

      index = {}
      rx = /\ACHILDREN_OF_/
      mod.constants.each do |c|
        rx =~ c or next
        mod.const_get( c, false ).each_pair do |k, m|
          _a = index.fetch k do
            index[ k ] = []
          end
          _a.push m
        end
      end
      index
    end

    # ==
    # ==
  end
end
# extracted from sibling
