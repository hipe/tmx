# frozen_string_literal: true

module Skylab::BeautySalon

  module CrazyTownUnparseMagnetics_::String_via_StructuredNode  # 1x.

    # exactly [#026] unparsing losslessly.

    # it bears mentioning somewhere that a lot of this is aspirational
    # rather than fully jelled. every place where we use a `custom_method`
    # is some place that could be better served by our declarative approach,
    # but as it is we have no easy way of exploiting our declarative
    # approach *under* an imperative approach. #incubating

    BEHAVIOR_VIA_SHAPE___ = {

      # for each type of location map, associate its range items with the
      # child components of AST nodes (actually structured nodes) in terms
      # of what order they occur in with respect to each other. see [#doc]

      # (because we can, we follow a top-down ordering of [#023.D]

      # -- class and module definition

      definition: {
        is_new_way: true,
      },

      # -- method (un)definition

      # -- method calls

      operator: {  # #coverpoint3.4
        method: :__operator,
      },

      send: {
        these: [
          [ :custom_method, :__if_prefixed_method_name_then_etc ],
          [ :assoc, :any_receiver_expression ],
          [ :custom_method, :__if_bracketed_method_name_then_etc ],
          [ :range, :dot ],
          [ :both, :range, :selector, :assoc, :method_name ],
          # [ :range, :operator ],
          [ :range, :begin ],  # '('
          [ :assoc, :zero_or_more_arg_expressions ],
          [ :range, :end ],
        ],
      },

      # -- formal arguments

      # objc_kwarg: nil, # keyword operator argument  probably never gonna use

      # -- expression grouping

      # -- control flow

      condition: {
        these: [

          [ :range, :keyword ],

          [ :assoc, :condition_expression ],

          [ :custom_method, :__if_begin_then_interesting ],
          # [ :range, :begin ],

          [ :assoc, :any_if_true_do_this_expression ],

          [ :custom_method, :__if_else_then_do_them_in_concert ],
          #  :any_else_do_this_expression
          # [ :range, :else ],

          [ :range, :end ],
        ],
      },

      for: nil,  # keyword in begin end
      rescue_body: nil,  # keyword assoc begin
      ternary: nil,  # question colon

      # -- assignment

      variable: {
        these: [
          [ :custom_method, :__for_variable_prepare_customly ],
          [ :both, :range, :name, :assoc, nil ],
          [ :range, :operator ],
          [ :custom_method, :__for_variable_write_right_hand_side ],
        ],
      },

      # -- access

      constant: {
        these: [
          [ :assoc, :any_parent_const_expression ],
          [ :range, :double_colon ],
          [ :both, :range, :name, :assoc, :symbol ],
          [ :custom_method, :__if_operator_cover_me ],
          # [ :range, :operator ],
        ],
      },

      # -- literals

      heredoc: {
        method: :__heredoc_MASSIVE_HACK,
      },

      # -- (very generic)

      collection: {
        is_new_way: true,
      },
      keyword: {
        these: [
          [ :custom_method, :__for_keyword_init ],
          [ :range, :keyword ],
          [ :custom_method, :__for_keyword_condition_slot ],
          [ :range, :begin ],
          [ :custom_method, :__for_keyword_body_slot ],
          [ :range, :end ],
        ],
      },
      map: {
        method: :__for_map_expect_singleton_USUALLY,
      },
    }

    class << self
      def call sn
        Recurse.call(
          structured_node: sn,
          downstream_buffer: ::String.new,
        )
      end
      alias_method :[], :call
    end  # >>

    class Recurse < Common_::MagneticBySimpleModel

      class << self

        def call downstream_buffer: nil, structured_node: nil

          _buffers = __build_buffers structured_node, downstream_buffer

          _d = recurse_(
            buffers: _buffers,
            structured_node: structured_node,
          )
          _d.zero? && hello_fine_mark_my_coverpoint
          downstream_buffer
        end

        def recurse_ buffers: nil, context_by: nil, structured_node: nil

          orig_len = buffers.downstream_buffer.length

          loc = structured_node._node_location_
          beha = Behavior_via_location_class___[ loc.class ]

          _ = if beha.is_new_way
            _cls = Home_::CrazyTownUnparseMagnetics_.const_get beha.const, false
            _cls.call_by do |o|
              o.context_by = context_by
              o.location = loc
              o.structured_node = structured_node
              o.buffers = buffers
            end
          else
            call_by do |o|
              o.__receive_these_two_ beha, structured_node
              o.context_by = context_by
              o.buffers = buffers
            end
          end

          if _ != ACHIEVED_
            investigate ; exit 0
          end

          buffers.downstream_buffer.length - orig_len
        end

        def __build_buffers structured_node, downstream_buffer

          # exactly [#026.D]: figure out the very first starting offset
          # (the implicit assumption being that the whole tree is in one file)

          r = structured_node._node_location_.expression

          Home_::CrazyTownUnparseMagnetics_::String_via_Heredoc::
              Buffers_via_Downstream_and_Upstream_Buffer.new(
            r.begin_pos,
            downstream_buffer,
            r.source_buffer.source,
          )
        end
      end  # >>

      #
      # Assignment & initialization
      #

      def __receive_these_two_ beha, sn

        @_behavior = beha

        @location = sn._node_location_

        @_association_index = sn.class.association_index

        @structured_node = sn
      end

      attr_writer(
        :context_by,
        :buffers,
      )

      #
      # Execute
      #

      def execute

        _ = if @_behavior.is_custom_method_as_behavior
          send @_behavior.method
        else
          __AWFUL_LEGACY_MOVE_ME
        end
        _ == ACHIEVED_ || no  # #spot3.1
        _
      end

      def __AWFUL_LEGACY_MOVE_ME

        # whatever comes of this should go to [#026.E].
        # problems with this as-is:
        #
        #   - it should be extracted out of its current class; the class with
        #     all the custom methods in it should not be the same class that
        #     defines how traversals happen
        #
        #   - more broadly, we don't know if we even want to keep this DSL
        #     (the amount of custom methods make it almost not worth it)

        @_current_state_symbol = :start

        _loc_map_index = remove_instance_variable :@_behavior

        @_semantic_column_scanner = Scanner_[ _loc_map_index.semantic_columns ]

        begin
          col = _gets_one_semantic_column

          if col.is_custom_method
            send col.custom_method_name
            @_semantic_column_scanner.no_unparsed_exists ? break : redo
          end

          _effect_non_method_column col

        end until @_semantic_column_scanner.no_unparsed_exists

        _transition_to_state :end
      end

      #
      # Custom methods
      #

      # -- Operator

      def __operator

        # before descending, flush pending range so our weird child
        # doesn't have to worry about it

        a = @_association_index.associations
        case a.length
        when 1
          _operator_when_one_component a.fetch 0
        when 2
          __operator_with_two_components( * a )
        else ; no
        end
      end

      def __operator_with_two_components left_asc, right_asc

        __operator_this_component left_asc
        __operator_operator
        _operator_when_one_component right_asc
      end

      def _operator_when_one_component asc  # near #here1
        if asc.is_terminal
          if asc.has_truly_plural_arity
            ::Kernel._COVER_ME__etc__
          else
            expr_loc = @structured_node._node_location_.expression
            _write_as_is_to_here expr_loc.begin_pos  # :#here3
            _write_terminal_value_of asc  # #coverpoint3.5
            _be_at_offset expr_loc.end_pos
          end
        else  # #coverpoint3.4
          _recurse_via_nonterminal_association asc
        end
        _be_in_state :did_custom
      end

      def __operator_this_component asc
        if asc.is_terminal
          if asc.has_truly_plural_arity
            ::Kernel._COVER_ME__etc__
          else
            _write_terminal_value_of asc  # #coverpoint3.5
          end
        else
          _recurse_via_nonterminal_association asc
        end
      end

      def __operator_operator
        r = @location.operator
        if r
          _write_as_is_to_here r.end_pos  # #coverpoint3.4
        else
          NOTHING_  # #coverpoint3.5
        end
      end

      # -- Send

      # normally a send is RECEIVER DOT SELECTOR BEGIN ARGS END

      # in an expression like `! @yadda`, this is dressed as a send as:
      #     SELECTOR RECEIVER

      def __if_prefixed_method_name_then_etc
        @_method_name_symbol = @structured_node.method_name
        @_is = @_method_name_symbol =~ /\A[^_[:alpha:]]/
        if @_is
          case @_method_name_symbol
          when :! ; __send_when_operator_prefixed
          end
        end
      end

      def __if_bracketed_method_name_then_etc

        # NOTE - many of these symbols don't have dedicated coverage in
        # tests because they are variations on the theme..

        if @_is
          case @_method_name_symbol
          when :[]
            __send_when_brackets_simple
          when :[]=
            __send_when_brackets_with_assign
          when :==, :<, :>, :<=, :>=, :<=>, :===, :!=
            _send_when_operator_infixed
          when :+, :-, :*, :/
            _send_when_operator_infixed
          when :<<, :>>
            _send_when_operator_infixed
          when :|, :&
            _send_when_operator_infixed
          when :=~, :!~
            _send_when_operator_infixed
          else ;
            self._COVER__theres_an_operator_like_method_name_we_havent_covered_yet__
          end
        end
      end

      def __send_when_operator_prefixed  # #coverpoint3.3

        _send_assert_arg_number 0
        _send_assert_selector_not_operator
        @buffers.recurse_into_structured_node @structured_node.any_receiver_expression
        _send_end
      end

      def __send_when_brackets_with_assign

        key_sd, value_sd = _send_assert_arg_number 2
        _send_assert_selector_and_operator

        # (write the '[ ' and) write the key expression
        @buffers.recurse_into_structured_node key_sd

        # (write the ' ] = ' and) write the value expression
        @buffers.recurse_into_structured_node value_sd

        _send_end
      end

      def _send_when_operator_infixed  # #coverpoint3.6

        _rhs, = _send_assert_arg_number 1
        _send_assert_selector_not_operator
        # (rely on the below to draw all of " == xxx")
        @buffers.recurse_into_structured_node _rhs
        _send_end
      end

      def __send_when_brackets_simple

        _send_assert_selector_not_operator
        listlike = @structured_node.zero_or_more_arg_expressions
        if listlike.length.zero?
          NOTHING_  # #coverpoint3.7
        else
          @buffers.recurse_into_listlike listlike
        end
        _write_as_is_to_here @location.selector.end_pos  # ' ]'
        _send_end
      end

      # ~ support

      def _send_assert_arg_number len

        listlike = @structured_node.zero_or_more_arg_expressions
        len == listlike.length || sanity
        if len.nonzero?
          a = ::Array.new len
          len.times do |d|
            a[ d ] = listlike.dereference d
          end
          a
        end
      end

      def _send_assert_selector_and_operator
        @location.selector || sanity  # '[ 33 ]'
        @location.operator || sanity  # '='
        _send_assert_never_these
      end

      def _send_assert_selector_not_operator
        @location.selector || sanity  # '=='
        @location.operator && sanity
        _send_assert_never_these
      end

      def _send_assert_never_these
        @location.dot && sanity
        @location.begin && sanity
        @location.end && sanity
      end

      def _send_end
        # (if abstract this, rename it "will end early")
        @_semantic_column_scanner = Common_::THE_EMPTY_SCANNER
        _be_in_state :did_custom
      end

      # -- Conditional

      def __if_begin_then_interesting
        if @location.begin
          interesting
        end
      end

      def __if_else_then_do_them_in_concert
        r = @location.else
        sn = @structured_node.any_else_do_this_expression
        if r
          sn || fail
          _write_as_is_to_here r.end_pos
          @buffers.recurse_into_structured_node sn
        else
          sn && fail
        end
      end

      # -- Variable (operator above, Map below)

      def __for_variable_prepare_customly

        # among the many kinds of grammar symbols for variable access and
        # assignment, there is necessary variation in the names used for
        # associated children (see the sanity check structure).

        a = @structured_node.class.association_index.associations
        case a.length
        when 2
          name_asc, _rhs_asc = a
          rhs_m = _rhs_asc.association_symbol
        when 1
          name_asc = a.fetch 0
        else ; never
        end

        name_asc_sym = name_asc.use_symbol_

        # ~(
        exp_sym, exp_sym_ = FOR_VARIABLES_SANITY___.fetch _node_type
        exp_sym == name_asc_sym || sanity
        exp_sym_ == rhs_m || sanity
        # ~)

        @__name_association_symbol = name_asc_sym
        @__right_hand_side_method_symbol = rhs_m
        NIL
      end

      FOR_VARIABLES_SANITY___ = -> do

        # the declarative, structural info here serves no purpose other than
        # to assert that for any given relevant grammar symbol, its relevant
        # components have the names we expect them to have. maybe one day if
        # component names unify #open :[#007.M] we can do away with it.

        common_rhs = :default_value_expression
        zero_or_one = :zero_or_one_right_hand_side_expression
        common = :as_symbol
        short_one = :symbol
        {
          ivasgn: [ :ivar_as_symbol, zero_or_one ],
          lvasgn: [ :lvar_as_symbol, zero_or_one ],
          # --
          kwoptarg: [ common, common_rhs ],
          optarg: [ common, common_rhs ],
          # --
          arg: common,
          blockarg: common,
          procarg0: common,  # #coverpoint3.9
          restarg: :symbol,
          # --
          ivar: short_one,
          lvar: short_one,
        }.freeze
      end.call

      def __for_variable_write_right_hand_side
        m = remove_instance_variable :@__right_hand_side_method_symbol
        if m
          __for_variable_do_write_right_hand_side m
        end
      end

      def __for_variable_do_write_right_hand_side m

        sn = @structured_node.send m
        sn || self._COVER_ME__la_la__

        # _write_as_is_to_here @location.operator.end_pos  # #here3 instead

        @buffers.recurse_into_structured_node sn
        _be_in_state :did_custom  # or other
      end

      # -- Collection

      # (gone)

      # --

      def __heredoc_MASSIVE_HACK  # see #spot1.4

        # (as covered, the vendor location mapping isn't to sufficient granularity)

        _md = %r([ \t]*<<[-~][ \t]*[[:alnum:]_]+)i.match(
          @buffers.upstream_buffer, _cursor )

        _write_as_is_to_here _md.offset(0).last

        @buffers.BIG_FLIP @location.heredoc_end do

          _list = @structured_node.zero_or_more_dynamic_expressions

          me = CrazyTownUnparseMagnetics_::Delimiter_via_String::ONE_FOR_HEREDOC

          _delim_by = -> do
            me  # hi.
          end

          @buffers.recurse_into_listlike _delim_by, _list

          # the end of the heredoc is done by the declaration
        end
      end

      # -- Keyword

      # ~ keyword entrypoints

      def __for_keyword_init
        case _node_type
        when :while ; __for_keyword_init_for_while
        when :if ; __for_keyword_init_for_if
        else ; hi
        end
      end

      def __for_keyword_condition_slot
        send remove_instance_variable :@_keyword_method_for_condition_slot
      end

      def __for_keyword_body_slot
        send remove_instance_variable :@_keyword_method_for_body_slot
      end

      # ~ support above

      def __for_keyword_init_for_while

        _keyword_will_use_these_two_components(
          @structured_node.condition_expression,
          @structured_node.body_expression,
        )

        if _keyword_components_are_forward
          __keywords_will_write_slots_forwardly
        else
          no_problem
        end
      end

      def __for_keyword_init_for_if

        sn = @structured_node
        cond_sn = sn.condition_expression
        then_sn = sn.any_if_true_do_this_expression
        else_sn = sn.any_else_do_this_expression

        _keyword_will_use_these_two_components cond_sn, then_sn

        if _keyword_components_are_forward
          sanity  # isn't the whole Condition structure for this?
        else
          then_sn || sanity
          else_sn && sanity
          __keywords_will_write_slots_backwardly
        end
      end

      def __keywords_will_write_slots_backwardly

        #     normally:         KEYWORD CONDITION BEGIN BODY END
        #     annoyingly:  BODY KEYWORD CONDITION

        _keyword_write_body_component
        @_keyword_method_for_condition_slot = :_keyword_write_condition_component
        @_keyword_method_for_body_slot = :__no_op
      end

      def __keywords_will_write_slots_forwardly
        @_keyword_method_for_condition_slot = :_keyword_write_condition_component
        @_keyword_method_for_body_slot = :_keyword_write_body_component
      end

      def _keyword_will_use_these_two_components cond_sn, then_sn
        @_SN_kw_component_for_condition = cond_sn
        @_SN_kw_component_for_body = then_sn ; nil
      end

      def _keyword_components_are_forward

        _sn = @_SN_kw_component_for_condition
        _sn_ = @_SN_kw_component_for_body
        _d = _sn._node_location_.expression.begin_pos
        _d_ = _sn_._node_location_.expression.begin_pos
        case _d <=> _d_
        when -1 ; true
        when  1 ; false
        else    ; never
        end
      end

      # ~ keyword writing execution

      def _keyword_write_condition_component
        _keyword_write_component :@_SN_kw_component_for_condition
      end

      def _keyword_write_body_component
        _keyword_write_component :@_SN_kw_component_for_body
      end

      def _keyword_write_component ivar
        _sn = remove_instance_variable ivar
        @buffers.recurse_into_structured_node _sn
      end

      # -- Map (the base class)

      def __for_map_expect_singleton_USUALLY
        case _node_type
        when :regopt
          __when_regopt
        else
          @_association_index.length.zero? || oops
          __for_map_expect_singleton
        end
      end

      def __when_regopt
        # (these get a (completely unstructured) "map" location map, so we
        # do them all "by hand") #coverpoint4.4
        sym_a = @structured_node.zero_or_more_symbol_terminals
        sym_a.each do |sym|
          ::Symbol === sym || oops
          @buffers << sym.id2name
        end
        _be_at_offset @location.expression.end_pos
        _be_in_state :did_custom
      end

      def __for_map_expect_singleton

        # (like `nil`, etc)

        _write_as_is_to_here @location.expression.end_pos
        _be_in_state :did_custom
      end

      #
      # Custom methods support
      #

      def _recurse_via_nonterminal_association asc
        sn = @structured_node.send asc.association_symbol
        sn || self._COVER_ME__la_la__
        # (send context for #coverpoint6.3)
        @buffers.recurse_into_structured_node @context_by, sn
      end

      def __if_operator_cover_me
        if @location.operator
          self._COVER_ME__fun_la_la__
        end
      end

      #
      # Traverse the semantic columns
      #

      def _gets_one_semantic_column
        @_semantic_column_scanner.gets_one
      end

      def _effect_non_method_column col
        _have_current_column col
        _transition_to_state col.category_symbol
      end

      def _have_current_column col

        if col.has_assoc
          _asc_index = col.assoc
          x_sym = _asc_index.association_symbol
          _use_sym = if x_sym
            x_sym
          else
            remove_instance_variable :@__name_association_symbol
          end
          asc = @_association_index.dereference _use_sym
        end

        if asc
          @_current_association = asc
        else
          @_current_association = nil
          remove_instance_variable :@_current_association   # for now, catch these early
        end

        @_current_semantic_column = col
        NIL
      end

      def _transition_to_state sym
        _h = METHOD_VIA_TRANSITION___.fetch @_current_state_symbol
        _m = _h.fetch sym
        send _m
      end

      #
      # Transitions
      #

      METHOD_VIA_TRANSITION___ = {
        start: {
          both: :__transition_from_start_to_both,
          assoc: :__transition_from_start_to_assoc,
          range: :__transition_from_start_to_range,
          end: :__transition_from_start_to_end,
        },
        both: {
          assoc: :__transition_from_both_to_assoc,
          range: :__transition_from_both_to_range,
          end: :__transition_from_both_to_end,
        },
        range: {
          both: :__transition_from_range_to_both,
          assoc: :__transition_from_range_to_assoc,
          range: :__transition_from_range_to_range,
          end: :__transition_from_range_to_end,
        },
        did_custom: {
          end: :__transition_from_did_custom_to_end,
        },
      }

      # -- from start

      def __transition_from_start_to_both
        _common_transition_to_both
      end

      def __transition_from_start_to_assoc
        _common_transition_to_assoc
      end

      def __transition_from_start_to_range
        _common_transition_to_range
      end

      def __transition_from_start_to_end
        # collections are like this. we have a custom method for them
        _be_in_state :end
      end

      # -- from both

      def __transition_from_both_to_assoc
        _common_transition_to_assoc
      end

      def __transition_from_both_to_range
        _common_transition_to_range
      end

      def __transition_from_both_to_end
        # nothing to do. assoc printed stuff
        _be_in_state :end
      end

      # -- from range

      def __transition_from_range_to_both
        _common_transition_to_both  # hi.
      end

      def __transition_from_range_to_assoc
        _common_transition_to_assoc
      end

      def __transition_from_range_to_range

        # nothing to do. our pending static string just lengthens. now it
        # spans from the cursor to the end of the new current range. isn't
        # flushed until we leave the range

        ACHIEVED_  # #spot3.1 #coverpoint3.1 (coincidental same number)
      end

      def __transition_from_range_to_end
        _write_to_end_of_current_range
        _be_in_state :end
      end

      # --

      def __transition_from_did_custom_to_end
        _be_in_state :end
      end

      #
      # Transition support
      #

      def _common_transition_to_both
        __flush_to_BEGINNING_of_current_range
        _effect_both
      end

      def _effect_both

        vr = _current_vendor_range

        _write_as_is_to_here vr.begin_pos  # #coverpoint5.1

        __write_terminal_value

        # now that you have output the possibly modified value, this is key:
        # advance the cursor to the character just past etc

        _be_at_offset vr.end_pos

        _be_in_state :both
      end

      def _common_transition_to_assoc  # :#here1

        _m = @_current_association.association_symbol
        x = @structured_node.send _m

        if @_current_association.has_truly_plural_arity
          @buffers.recurse_into_listlike x
        elsif x
          @buffers.recurse_into_structured_node x  # #coverpoint3.1
        else
          NOTHING_  # #coverpoint3.1
        end
      end

      def _common_transition_to_range
        _be_in_state :range
      end

      def _be_in_state sym
        @_current_state_symbol = sym
        ACHIEVED_  # #spot3.1
      end

      #
      # Write terminals #refactor-me (not DRY) #[#007.Q]
      #

      def __write_terminal_value
        _write_terminal_value_of @_current_association
      end

      def _write_terminal_value_of tasc

        tasc.is_terminal || assumption_failed
        if tasc.has_truly_plural_arity
          self._COVER_ME__etc__
        else
          __write_terminal_value_normally tasc
        end
      end

      def __write_terminal_value_normally tasc  # assume not truly plural

        _m = if tasc.has_plural_arity
          tasc.association_symbol  # #coverpoint3.5
        else
          tasc.stem_symbol
        end

        x = @structured_node.send _m

        if x.nil?
          self._COVER_ME__etc__
        end

        case tasc.type_symbol
        when :symbol
          @buffers << x.id2name
        when :integer
          @buffers << ( '%d' % x )
        when :float
          @buffers << x.to_s  # YIKES
            # (stringifying a float is nontrivial - maybe look at `unparse`)
        else
          self._COVER_ME__trivially_easy_probably_but_readme__
        end
      end

      #
      # Flushing parts of the received string
      #

      def __flush_to_BEGINNING_of_current_range
        _vr = _current_vendor_range
        d = _vr.begin_pos
        if _cursor < d
          _write_as_is_to_here d  # #coverpoint3.2
        else
          NOTHING_  # #coverpoint3.2
        end
      end

      def _write_to_end_of_current_range
        vr = _current_vendor_range
        if vr
          _d = vr.end_pos
          _write_as_is_to_here _d
        end
      end

      def _write_as_is_to_here end_d
        @buffers.write_as_is_to_here end_d
      end

      def _be_at_offset d
        @buffers.be_at_offset d
      end

      def _cursor
        @buffers.pos
      end

      def _current_vendor_range  # assume etc
        _vendor_range_via_semantic_column @_current_semantic_column
      end

      def _vendor_range_via_semantic_column sc
        _m = sc.range.range_attr_name
        @location.send _m
      end

      #
      # Lowlevel read-only
      #

      def _node_type
        @structured_node._node_type_
      end

      def __no_op
        NOTHING_
      end

      # --TEMPORARY

      def _DS
        @buffers.downstream_buffer
      end

      def _SN
        @structured_node
      end
    end

    # ==

    Cache_ = -> & p do
      ::Hash.new do |h, key_x|
        x = p[ key_x ]
        h[ key_x ] = x
        x
      end.method :[]
    end

    Behavior_via_location_class___ = Cache_.call do |cls|

      # map the location map class to a "behavior" (one of three classes)

      nf = Common_::Name.via_module cls

      h = BEHAVIOR_VIA_SHAPE___.fetch nf.as_lowercase_with_underscores_symbol

      m = h[ :method ]
      if m
        1 == h.length || fail  # #here2
        BehaviorViaCustomMethod___.new m
      elsif h[ :is_new_way ]
        1 == h.length || fail  # #here2
        _ = nf.as_camelcase_const_string
        BehaviorViaNewWay___.new :"String_via_#{ _ }"
      else
        LocationMapIndex___.new h
      end
    end

    class Writer

      # this is meant to help us transition off the monolith.
      # something about [#026.E]

      def initialize structured_node: nil, buffers: nil
        @association_index = structured_node.class.association_index
        @location = structured_node._node_location_
        @structured_node = structured_node
        @buffers = buffers
      end

      def write_component asc_sym  # #open [#007.Q] not dry with the other
        asc = _association asc_sym
        x = __component asc
        if asc.has_truly_plural_arity
          @buffers.recurse_into_listlike x
        elsif x
          @buffers.recurse_into_structured_node x  # #coverpoint3.1
        else
          NOTHING_  # #coverpoint3.1
        end
        NIL
      end

      def write_terminal vr_sym, asc_sym

        vr = _vendor_range vr_sym

        _write_as_is_to_here vr.begin_pos  # #coverpoint5.1 (hypothetically)

        # #open #[#007.Q] need to DRY this with the other

        tasc = _association asc_sym

        x = __terminal tasc

        _s = case tasc.type_symbol
        when :symbol ; x.id2name
        else ; cover_me_easy
        end

        @buffers.write _s, vr.end_pos
      end

      def write_range vr_sym
        _vr = _vendor_range vr_sym
        _write_as_is_to_here _vr.end_pos
      end

      def _write_as_is_to_here d
        @buffers.write_as_is_to_here d
      end


      def __terminal tasc

        _m = if tasc.has_plural_arity
          self._SEE_ME  # #coverpoint3.5
        else
          tasc.stem_symbol
        end

        @structured_node.send _m
      end

      def __component asc
        _m = asc.association_symbol
        @structured_node.send _m
      end

      def _association asc_sym
        @association_index.dereference asc_sym
      end

      def _vendor_range m
        @location.send m
      end
    end

    # ==

    class LocationMapIndex___

      def initialize h
        1 == h.length || fail  # #here2
        _a = h.fetch :these
        @semantic_columns = _a.map do |row|
          scn = Scanner_[ row ]
          _const = COLUMN_CONST_VIA_SYMBOL___.fetch scn.head_as_is
          _cls = SemanticColumns___.const_get _const, false
          x = _cls.new scn
          scn.no_unparsed_exists || fail
          x
        end.freeze
        freeze
      end

      attr_reader(
        :semantic_columns,
      )
      def is_custom_method_as_behavior
        false
      end
      def is_new_way
        false
      end
    end

    COLUMN_CONST_VIA_SYMBOL___ = {
      assoc: :Assoc,
      custom_method: :CustomMethod,
      both: :Both,
      range: :Range,
    }

    SemanticColumn__ = ::Class.new

    module SemanticColumns___

      class CustomMethod < SemanticColumn__

        def initialize scn
          :custom_method == scn.head_as_is || fail
          scn.advance_one
          @custom_method_name = scn.gets_one
          super
        end

        attr_reader(
          :custom_method_name,
        )

        def is_custom_method
          true
        end
      end

      class Both < SemanticColumn__

        def initialize scn
          :both == scn.head_as_is || fail
          scn.advance_one
          @range = Range.new scn
          @assoc = Assoc.new scn
          super
        end

        attr_reader(
          :assoc,
          :range,
        )

        def category_symbol
          :both
        end

        def has_assoc
          true
        end

        def has_range
          true
        end
      end

      class Assoc < SemanticColumn__

        def initialize scn
          :assoc == scn.head_as_is || fail
          scn.advance_one
          @association_symbol = scn.gets_one
          super
        end

        attr_reader(
          :association_symbol,
        )

        def assoc
          self
        end

        def category_symbol
          :assoc
        end

        def has_assoc
          true
        end

        def has_range
          false
        end
      end

      class Range < SemanticColumn__

        def initialize scn
          :range == scn.head_as_is || fail
          scn.advance_one
          @range_attr_name = scn.gets_one
          super
        end

        def range
          self
        end

        attr_reader(
          :range_attr_name,
        )

        def category_symbol
          :range
        end

        def has_assoc
          false
        end

        def has_range
          true
        end
      end
    end

    class SemanticColumn__

      def initialize _scn
        freeze
      end

      def is_custom_method
        false
      end
    end

    # ==

    class BehaviorViaNewWay___
      def initialize c
        @const = c ; freeze
      end
      attr_reader :const
      def is_new_way
        true
      end
    end

    # ==

    class BehaviorViaCustomMethod___
      def initialize m
        @method = m
      end
      attr_reader :method
      def is_new_way
        false
      end
      def is_custom_method_as_behavior
        true
      end
    end

    # ==
    # ==
  end
end
# #history-A.3: begin extracting existing monolithic "semantic column" support out
# #history-A.2: many fellows abstracted out
# #born.
