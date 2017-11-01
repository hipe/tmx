# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownMagnetics_::Dispatcher_via_Hooks < Common_::SimpleModel  # 1x

    # this file has several public nodes, all of which are concerned with
    # traversing *either* the children of an AST node (or maybe a structured
    # node wrapping it) while associating each child with its corresponding
    # association *or* traversing just the formal associations of a grammar
    # symbol.
    #
    # traversals can be either "imperative" (each item is yielded to the
    # caller (enumerator-like, like `each`)) or scanner-based (the caller
    # must request each next item, and ask "end of scan?" at each step).

    #
    # The hooks-based dispatcher (traverses entire documents)
    #

    begin

      # receive each AST document node (wrapped so you can see the path).
      # traverse every node of the document recursively, calling the
      # appropriate hooks along the way. be sure to see also:
      #
      #   - [#025.F] (and some after) how we traverse efficiently
      #
      #   - [#021.B] introduction to hooks

      # behavior/implementation wise, we're tryna come to a sensible API:
      #
      #   - only because of the requirement profile, we are mutually
      #     exclusive with all the kinds of hooks. also there must be one
      #     kind of hook. so, we require exactly one kind of hook.
      #
      #   - there is only one report pioneering the would-be detailed
      #     stack API. it's incubating there.

      def initialize

        @_prepare_method = nil

        yield self

        if ! @_prepare_method
          raise MyException_.new :must_be_build_with_some_hooks
        end

        send(
          remove_instance_variable( :@_prepare_method ),
          remove_instance_variable( :@__prepare_value ) )

        @_stack = []
        freeze ; nil
      end

      #
      # Custom
      #

      def custom_stack_hooks= p
        _maybe p, :__will_custom
      end

      def __will_custom define
        define[ self ]
        NIL
      end

      #
      # Type-based
      #

      def type_based_hook_box= bx
        _maybe bx, :__will_type_based
      end

      def __will_type_based bx

        # for each nonterminal node,
        # either there is or isn't a hook associated with this node type.
        # the work of determining this can be cached lazily per grammar
        # symbol. since these characteristics don't change for the lifetime
        # of the parse, it feels clunky  to check them both over and over
        # again at every node we traverse but #open [#007.J] possible
        # optimization: would this be better if did the cache thing?

        p_h = bx.h_ ; bx = nil

        will_push_to_stack_by do |o|
          -> n do
            o.push_stack_via_node n
            p = p_h[ n.type ]
            if p
              # we could just as soon pass a structured node but we don't: #coverpoint2.12
              # _cls = @grammar_symbols_feature_branch.dereference n.type
              # _sn = _cls.via_node_ n ; p[ _sn ]
              p[ n ]
            end
          end
        end

        will_start_with_stack_normally
        will_visit_terminal_normally
        will_finish_with_stack_normally
        NIL
      end

      #
      # Universal
      #

      def universal_hook= p
        _maybe p, :__will_universal
      end

      def __will_universal p

        if 2 == p.arity
          will_push_to_stack_by do |o|
            -> n do
              o.push_stack_via_node n
              p[ o.stack_length, n ]  # ##here1
            end
          end
        else
          will_push_to_stack_by do |o|
            -> n do
              o.push_stack_via_node n
              p[ n ]
            end
          end
        end

        will_start_with_stack_normally
        will_visit_terminal_normally
        will_finish_with_stack_normally
        NIL
      end

      #
      #
      #

      def _maybe x, m
        if x
          if @_prepare_method
            raise MyException_.new :cannot_be_build_with_both_kinds_of_hooks  # ..
          end
          @__prepare_value = x
          @_prepare_method = m
        end
        x
      end

      attr_writer(
        :grammar_symbols_feature_branch,
        :listener,
      )

      # --

      def will_start_with_stack_by & p
        @_start_with_stack = p
      end

      def will_start_with_stack_normally
        @_start_with_stack = MONADIC_EMPTINESS_
      end

      def will_push_to_stack_by
        @_push_to_stack = yield self
      end

      def will_visit_terminal_normally

        # currently nothing is exposed necessitating us to yield this out
        # to any receiver. but: engage the terminal type assertion check

        @_visit_terminal = -> do
          @_stack.last._scanner.current_terminal_AST_node
        end
        NIL
      end

      def will_finish_with_stack_by & p
        @_finish_with_stack = p
      end

      def will_finish_with_stack_normally
        @_finish_with_stack = EMPTY_P_
      end

      # -- read

      def dispatch_wrapped_document_AST__ wrapped_document_AST  # #testpoint

        @_start_with_stack[ wrapped_document_AST.path ]

        n = wrapped_document_AST.ast_
        if n
          __do_dispatch_document_AST n
        else
          self._COVER_ME__this_once_worked_long_ago_like_so__
          @listener.call :info, :expression, :empty_file do |y|
            y << "(file has no code)"
          end
        end

        @_finish_with_stack[]
        @_stack.length.zero? || fail

        NIL
      end

      def __do_dispatch_document_AST document_n

        # implement exactly [#025.F] DIY stack for efficient traversal

        stack = @_stack

        @_push_to_stack[ document_n ]

        begin  # assume stack is not empty
          scn = stack.last._scanner
          if scn.no_unparsed_exists
            __pop_stack
            if stack.length.nonzero?
              redo
            end
            break
          end

          if scn.current_association_is_terminal
            @_visit_terminal[]
            scn.advance_one
            redo
          end

          # association is non-terminal

          n = scn.current_nonterminal_AST_node
          if n
            @_push_to_stack[ n ]
          else
            NOTHING_  # #coverpoint2.11 (tested quite late)
          end

          scn.advance_one
          redo
        end while above
        NIL
      end

      # --

      def push_stack_via_node n
        _push nil, n
      end

      def push_stack_via_node_and_pop_callback_by n, & p
        _push p, n
      end

      def _push p, n
        _cls = @grammar_symbols_feature_branch.dereference n.type
        _scn = _cls.build_qualified_children_scanner_for_ n
        @_stack.push Frame___.new p, _scn
        NIL
      end

      def __pop_stack

        _frame = @_stack.pop
        p = _frame.__pop_hook
        if p
          p[]
        end

        NIL
      end

      def stack_length
        @_stack.length
      end

      attr_reader(
        :grammar_symbols_feature_branch,
      )
    end

    class Frame___
      def initialize p, scn
        @__pop_hook = p
        @_scanner = scn
        freeze
      end
      attr_reader(
        :__pop_hook,
        :_scanner,
      )
    end

    #
    # Traverse the children of an AST (or structured node), qualified to assocation.
    #

    class QualifiedChildrenScanner  # 1x: for build_qualified_children_scanner_for_

      # a scanner that traverses along the children of the node. at any
      # time (except at the end of scan), the current child AST node is
      # available as well as its associated association. note that the
      # association doesn't change with the child IFF it's the any plural
      # (variable-length) run of children. exactly [#025.F]

      # only because the algorithms call for it and/or out of deference to
      # typeism, we make a big deal about whether or not the assoc is
      # terminal.

      # this mechanism is the sole place where [#007.D] any-ness and group
      # affiliation are asserted.

      class << self

        def for n, ai
          cx = n.children
          rc = RangesCompound_via_Count[ cx.length, ai ]
          if rc.is_the_empty_range_compound
            Common_::THE_EMPTY_SCANNER  # #coverpoint2.11 (quite late)
          else
            new rc, cx, ai
          end
        end
        private :new
      end  # >>

      def initialize rc, cx, ai

        scn_a = []
        rc.each_any_range_of_the_three_ranges do |r|
          if r
            scn_a.push r.to_parallel_offset_scanner
          end
        end

        @_scanner_scanner = scn_a  # we don't bother
        @_childs = cx
        @_assocs = ai.associations
        @no_unparsed_exists = false
        _reacquaint
      end

      def advance_one
        scn = _head_scanner
        scn.advance_one
        if scn.no_unparsed_exists
          scn_scn = @_scanner_scanner
          scn_scn.shift  # these are typically so short we assume it's more efficient #open [#007.J]
          if scn_scn.length.zero?
            __close_safely
          else
            _reacquaint
          end
        else
          _reacquaint
        end
      end

      def _reacquaint  # assume some

        asc = @_assocs.fetch _head_scanner.current_association_offset

        if asc.is_terminal
          @current_association_is_terminal = true
          @current_terminal_AST_node = :__current_terminal_initially
          @current_nonterminal_AST_node = nil
        else
          @current_association_is_terminal = false
          @current_terminal_AST_node = nil
          @current_nonterminal_AST_node = :__current_nonterminal_initially
        end

        @current_association = asc ; nil
      end

      def current_nonterminal_AST_node
        send @current_nonterminal_AST_node
      end

      def current_terminal_AST_node
        send @current_terminal_AST_node
      end

      # ~(
      # NOTE - for now:
      #
      #   A) we only validate these two things on node read, because it
      #      seems wrong to throw an assertion failure for a node that
      #      hasn't been read yet
      #
      #   B) to save a buck we do this on every read, whose cost is positive
      #      or negative based on whether traversals either tend to keep
      #      moving or re-read the same nodes. we know it's the former.

      def __current_nonterminal_initially
        n = _current_mixed
        if n
          gi = @current_association.group_information
          if gi && ! gi[ n.type ]
            raise MyException_.new :group_affiliation_not_met
          end
          n
        elsif ! _current_is_any
          raise _build_same_exception
        end
      end

      def __current_terminal_initially
        x = _current_mixed
        if x.nil?
          if ! _current_is_any
            raise _build_same_exception
          end
        else
          @current_association.assert_type_of_terminal_value_ x
          x
        end
      end

      # ~)

      def _build_same_exception
        MyException_.new :missing_expected_child
      end

      def _current_mixed
        @_childs.fetch _head_scanner.current_child_offset
      end

      def _head_scanner
        @_scanner_scanner.fetch 0
      end

      def _current_is_any
        @current_association.is_any
      end

      def current_association_is_terminal
        @current_association_is_terminal
      end

      def current_association
        @current_association
      end

      attr_reader(
        :no_unparsed_exists,
      )

      def __close_safely
        # (paranoid for now)
        remove_instance_variable :@_assocs
        remove_instance_variable :@_childs
        remove_instance_variable :@current_association
        remove_instance_variable :@current_association_is_terminal
        remove_instance_variable :@current_nonterminal_AST_node
        remove_instance_variable :@current_terminal_AST_node
        remove_instance_variable :@_scanner_scanner
        @no_unparsed_exists = true ; freeze
      end
    end

    #
    # EXPERIMENT
    #

    EachQualifiedOffsetCategorized = -> defn_p, sn do  # 1x

      ai = sn.class.association_index

      p_a = [] ; TheseHooks__.new p_a, defn_p
      rc = RangesCompound_via_Count[ sn.AST_node_.children.length, ai ]

      a = ai.associations

      sing = -> recv, scn do
        begin
          recv[ scn.current_child_offset, a.fetch( scn.current_association_offset ) ]
          scn.advance_one
        end until scn.no_unparsed_exists
      end

      fr = rc.first_range
      if fr
        sing[ p_a.fetch( 0 ), fr.to_parallel_offset_scanner ]
      end

      mr = rc.middle_range
      if mr
        scn = mr.to_parallel_offset_scanner
        recv = p_a.fetch( 1 )[ a.fetch( scn.current_association_offset ) ]
        begin
          recv[ scn.current_child_offset ]
          scn.advance_one
        end until scn.no_unparsed_exists
      end

      lr = rc.last_range
      if lr
        sing[ p_a.fetch( 2 ), lr.to_parallel_offset_scanner ]
      end
      NIL
    end

    #
    # Traverse the offsets of associations using 3 categories.
    #

    EachAssociationOffsetCategorized = -> do  # 1x

      run = -> p, scn do
        begin
          p[ scn.current_association_offset ]
          scn.advance_one
        end until scn.no_unparsed_exists
      end

      -> p, ai do

        p_a = [] ; TheseHooks__.new p_a, p
        rc = RangesCompound_via_Count[ ai.associations.length, ai ]

        fr = rc.first_range
        if fr
          run[ p_a.fetch( 0 ), fr.to_parallel_offset_scanner ]
        end

        mr = rc.middle_range
        if mr
          run[ p_a.fetch( 1 ), mr.to_parallel_offset_scanner ]
        end

        lr = rc.last_range
        if lr
          run[ p_a.fetch( 2 ), lr.to_parallel_offset_scanner ]
        end
        NIL
      end
    end.call

    class TheseHooks__
      def initialize a, p
        @a = a ; p[ self ] ; remove_instance_variable :@a  # sanity
      end
      def first_third & p
        @a[0] = p
      end
      def middle_third & p
        @a[1] = p
      end
      def final_third & p
        @a[2] = p
      end
    end

    #
    # Traverse the associations (or mapped to children) with scanners.
    #

    RangesCompound_via_Count = -> num_children, ai do  # #testpoint

      # used all over the place, this relates children offsets with offsets
      # of assocations in a low-level way suitable for multiple applications

      if ai.minimum_number_of_children > num_children
        raise MyException_.new :minimum_number_of_children_not_satisfied
      end

      if (( max = ai.maximum_number_of_children )) && max < num_children
        raise MyException_.new :maximum_number_of_children_exceeded
      end

      if num_children.zero?

        THE_EMPTY_RANGES_COMPOUND__

      elsif ai.associations.length.zero?

        ::Kernel._COVER_ME__ohai__
        THE_EMPTY_RANGES_COMPOUND__

      elsif ai.has_plural_arity_as_index

        first_r = nil
        middle_r = nil
        last_r = nil

        here = ai.offset_of_association_with_plural_arity

        if here.zero?
          NOTHING_  # #coverpoint2.9
        else
          first_r = ParallelRunRange__.new 0, 0, here  # #coverpoint2.7
        end

        num_at_end = ai.number_of_associations_at_the_end

        width_of_middle_run = num_children - here - num_at_end
        if width_of_middle_run.zero?
          NOTHING_  # #coverpoint2.7
        else
          middle_r = PluralRunRange___.new here, width_of_middle_run  # #coverpoint2.8
        end

        if num_at_end.zero?
          NOTHING_  # #coverpoint2.7
        else
          last_r = ParallelRunRange__.new here + width_of_middle_run, here + 1, num_at_end  # #coverpoint2.10
        end

        RangesCompound__.new first_r, middle_r, last_r
      else

        _r = ParallelRunRange__.new 0, 0, num_children
        RangesCompound__.new _r, nil, nil
      end
    end

    # ==

    module THE_EMPTY_RANGES_COMPOUND__ ; class << self
      def is_the_empty_range_compound
        true
      end
    end ; end

    class RangesCompound__

      def initialize first, mid, last
        @first_range = first
        @middle_range = mid
        @last_range = last
        freeze
      end

      def each_any_range_of_the_three_ranges
        yield @first_range
        yield @middle_range
        yield @last_range
        NIL
      end

      attr_reader(
        :first_range,
        :middle_range,
        :last_range,
      )

      def is_the_empty_range_compound
        false
      end
    end

    class PluralRunRange___

      def initialize here, length_of_middle_run
        @here = here
        @length_of_run = length_of_middle_run
        freeze
      end

      def to_parallel_offset_scanner
        PluralRunRangeParallelOffsetScanner___.new(
          @here, @length_of_run )
      end
    end

    class ParallelRunRange__

      def initialize cx_d, asc_d, len
        @offset_of_first_child_in_run = cx_d
        @offset_of_first_association_in_run = asc_d
        @length_of_run = len
        freeze
      end

      def to_parallel_offset_scanner
        ParallelRunRangeParallelOffsetScanner___.new(
          @offset_of_first_child_in_run,
          @offset_of_first_association_in_run,
          @length_of_run,
        )
      end
    end

    Same__ = ::Class.new

    class PluralRunRangeParallelOffsetScanner___ < Same__

      def initialize here, len
        super here, here, len
      end

      def _step_
        @current_child_offset += 1
      end
    end

    class ParallelRunRangeParallelOffsetScanner___ < Same__

      def _step_
        @current_child_offset += 1
        @current_association_offset += 1
      end
    end

    class Same__  # assume length > 1

      def initialize cx_d, asc_d, len

        @__stop_here_SAME = cx_d + len - 1

        @current_child_offset = cx_d
        @current_association_offset = asc_d
      end

      def advance_one
        if @__stop_here_SAME == @current_child_offset
          @no_unparsed_exists = true
          remove_instance_variable :@current_child_offset
          remove_instance_variable :@current_association_offset
        else
          _step_
        end
        NIL
      end

      def current_child_offset
        @current_child_offset
      end

      def current_association_offset
        @current_association_offset
      end

      attr_reader(
        :no_unparsed_exists,
      )
    end

    # ==
    # ==

    # :#here1: ignore result - don't let hooks control our flow
  end
end
# #history-A-7: spike reconconception as "dispatcher via hooks"
# #history-A.6: (meta-tombstone) archived all tombstones for the old methods
# #history-A.5: begin to remove methods obviated by declarative structures
# #history-A.4: extracted longer comments, many mechanics out to own files
# #history-A.3: converted hard-coded hook methods to "expand" nodes via method argument signature
# #history-A.2 (can be temporary): remove last traces of 'ruby_parser'
# #history-A.1: begin refactor from 'ruby_parser' to 'parser'
# #born
