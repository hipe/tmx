# frozen_string_literal: true

module Skylab::BeautySalon

  module CrazyTownReportMagnetics_::String_via_StructuredNode  # 1x. exactly [#023]

    META_MAPPINGS___ = {

      # (because we can, we follow a top-down ordering of [#023.D]

      # -- class and module definition

      # -- method calls

      send: {
        these: [
          [ :assoc, :any_receiver_expression ],
          [ :custom_method, :__if_bracketed_method_name_then_etc ],
          [ :range, :dot ],
          [ :both, :range, :selector, :assoc, :method_name_symbol_terminal ],
          # [ :range, :operator ],
          [ :range, :begin ],  # '('
          [ :assoc, :zero_or_more_arg_expressions ],
          [ :range, :end ],
        ],
      },

      # -- method (un)definition

      # -- formal arguments

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

      # -- literals

      # -- (very generic)

      collection: {
        these: [
          [ :custom_method, :__for_collection ],
        ],
      },
      map: {
        these: [
          [ :custom_method, :__for_map_expect_singleton ],
        ],
      },
    }

    class << self
      def call sn
        buff = ::String.new
        _d = Recurse__.call_by do |o|
          o.structured_node = sn
          o.byte_downstream = buff
          o.__init_seed_values
        end
        _d.nonzero? || sanity
        buff
      end
      alias_method :[], :call
    end  # >>

    class Recurse__ < Common_::MagneticBySimpleModel

      #
      # Assignment & initialization
      #

      def structured_node= sn

        loc = sn.node_location
        @_loc_map_index = LOC_MAP_INDEX_VIA_CLASS___[ loc.class ]
        @location = loc

        cls = sn.class
        @_my_association_index = ASC_INDEX_VIA_CLASS___[ cls ]
        @_association_index = cls.association_index

        @structured_node = sn
      end

      def __init_seed_values  # assume some attributes are already set!

        # exactly [#026.D]: figure out the very first starting offset

        r = @structured_node.node_location.expression
        _be_at_offset r.begin_pos
        @source_buffer_string = r.source_buffer.source
        NIL
      end

      attr_writer(
        :byte_downstream,
        :current_pending_start_offset_to_flush,
        :source_buffer_string,
      )

      #
      # Execute
      #

      def execute

        @_current_state_symbol = :start

        @_semantic_column_scanner = Common_::Scanner.via_array(
          @_loc_map_index.semantic_columns )

        begin
          col = _gets_one_semantic_column

          if col.is_custom_method
            send col.custom_method_name
            @_semantic_column_scanner.no_unparsed_exists ? break : redo
          end

          _effect_non_method_column col

        end until @_semantic_column_scanner.no_unparsed_exists

        _transition_to_state :end

        remove_instance_variable :@current_pending_start_offset_to_flush
      end

      #
      # Custom methods
      #

      # -- Send

      # normally a send is RECEIVER DOT SELECTOR BEGIN ARGS END
      # here is is RECEIVER OPEN ARGS CLOSE

      def __if_bracketed_method_name_then_etc

        sym = @structured_node.method_name
        if /\A[^_[:alpha:]]/ =~ sym
          case sym
          when :[] ; __send_as_brackets_simple
          when :[]= ; __send_as_brackets_cha_cha
          else ; self._COVER__WEE__
          end
        end
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
          _write_static_string_to_here r.end_pos
          _recurse_into_structured_node sn
        else
          sn && fail
        end
      end

      # -- Variable (opeartor above, Map below)

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

        name_asc_sym = name_asc.association_symbol

        # ~(
        exp_sym, exp_sym_ = FOR_VARIABLES_SANITY___.fetch _node_type
        exp_sym == name_asc_sym || sanity
        exp_sym_ == rhs_m || sanity
        # ~)

        @__name_association_symbol = name_asc_sym
        @__right_hand_side_method_symbol = rhs_m
        NIL
      end

      FOR_VARIABLES_SANITY___ = -> do  # could probably be distilled
        zero_or_one = :zero_or_one_right_hand_side_expression
        short_one = :symbol_terminal
        {
          lvasgn: [ :lvar_as_symbol_symbol_terminal, zero_or_one ],
          # --
          lvar: short_one,
        }.freeze
      end.call

      def __for_variable_write_right_hand_side
        m = remove_instance_variable :@__right_hand_side_method_symbol
        if m
          sn = @structured_node.send m
          sn || self._COVER_ME__la_la__
          _recurse_into_structured_node sn
          _be_in_state :did_custom  # or other
        end
      end

      # -- Collection

      def __for_collection
        if __has_one_child_association
          if __child_association_is_truly_plural
            __collection_when_plural
          else
            __collection_when_terminal
          end
        else
          case _node_type
          when :block ; __collection_when_block
          else ; cover_me
          end
        end
      end

      def __collection_when_plural

        beg_r = @location.begin
        if beg_r
          has_begin = true
        end
        end_r = @location.end
        if end_r
          has_end = true
        end

        exp_m, exp = FOR_COLLECTION_FOR_PLURALS___.fetch _node_type
        case exp
        when :it_varies
          if has_begin
            has_end || sanity
            yes = true
          else
            has_end && sanity
          end
        when :nope
          has_begin && sanity
          has_end && sanity
        when :yep
          has_begin || sanity
          has_end || sanity
          yes = true
        else ; no end

        m = @_child_association.association_symbol
        exp_m == m || sanity

        list_like = @structured_node.send m

        # --

        if yes
          _write_static_string_to_here beg_r.end_pos
        end

        _recurse_into_listlike list_like

        if yes
          _write_static_string_to_here end_r.end_pos
        end
      end

      FOR_COLLECTION_FOR_PLURALS___ = -> do
        common = :zero_or_more_expressions
        {
          args: [ :zero_or_more_argfellows, :it_varies ],  #  the '|' uses as doo-hahs
          array: [ common, :yep ],
          begin: [ common, :it_varies ],
          dstr: [ :zero_or_more_dynamic_expressions, :yep ],
        }.freeze
      end.call

      def __child_association_is_truly_plural
        asc = remove_instance_variable( :@_assocs ).fetch 0
        @_child_association = asc
        asc.has_truly_plural_arity
      end

      def __has_one_child_association
        @_assocs = @_association_index.associations
        1 == @_assocs.length
      end

      # -- Map (the base class)

      def __for_map_expect_singleton

        # (like `nil`, etc)

        @_my_association_index.length.zero? || oops
        _write_static_string_to_here @location.expression.end_pos
        _be_in_state :did_custom
      end

      #
      # Custom methods support
      #

      def _recurse_into_listlike listlike
        listlike.length.times do |d|
          _sn = listlike.dereference d
          _recurse_into_structured_node _sn
        end
        NIL
      end

      def _recurse_into_structured_node sn

        _d = self.class.call_by do |o|  # Recurse__
          o.structured_node = sn
          o.current_pending_start_offset_to_flush = @current_pending_start_offset_to_flush
          o.byte_downstream = @byte_downstream
          o.source_buffer_string = @source_buffer_string
        end

        _be_at_offset _d
        NIL
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
          _d = @_my_association_index.fetch _use_sym
          asc = @_association_index.associations.fetch _d
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
        _m = _h[ sym ]
        if ! _m
          self._COVER_ME__probably_easy__
        end
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
          range: :__transition_from_both_to_range,
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

      def __transition_from_both_to_range
        _common_transition_to_range
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

        NOTHING_  # #coverpoint3.1
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

        # flush the static string up to the beginning of the current range
        # (of this column). write the terminal value (TODO). make a note of
        # the range (that points to the original string).

        __flush_to_BEGINNING_of_current_range
        _effect_both
      end

      def _effect_both

        tasc = @_current_association
        tasc.is_terminal || assumption_failed

        _m = if tasc.has_plural_arity  # ..
          tasc.association_symbol
        else
          tasc.stem_symbol
        end

        x = @structured_node.send _m

        case tasc.type_symbol
        when :symbol
          @byte_downstream << x.id2name
        else
          self._COVER_ME__fun_and_easy__
        end

        # now that you have output the possibly modified value, this is key:
        # advance the cursor to the character just past etc

        _vr = _current_vendor_range
        _be_at_offset _vr.end_pos

        _be_in_state :both
      end

      def _common_transition_to_assoc  # :#here1

        _m = @_current_association.association_symbol
        x = @structured_node.send _m

        if @_current_association.has_truly_plural_arity
          _recurse_into_listlike x
        elsif x
          _recurse_into_structured_node x  # #coverpoint3.1
        else
          NOTHING_  # #coverpoint3.1
        end
      end

      def _common_transition_to_range
        _be_in_state :range
      end

      def _be_in_state sym
        @_current_state_symbol = sym ; nil
      end

      #
      # Flushing parts of the received string
      #

      def __flush_to_BEGINNING_of_current_range
        _vr = _current_vendor_range
        d = _vr.begin_pos
        if _cursor < d
          _write_static_string_to_here d  # #testpoint3.2
        else
          NOTHING_  # #testpoint3.2
        end
      end

      def _write_to_end_of_current_range
        vr = _current_vendor_range
        if vr
          _d = vr.end_pos
          _write_static_string_to_here _d
        end
      end

      def _write_static_string_to_here end_d
        beg_d = @current_pending_start_offset_to_flush
        case beg_d <=> end_d
        when -1
          _r = beg_d ... end_d
          @byte_downstream << @source_buffer_string[ _r ]
          _be_at_offset end_d
        when 0 ; NOTHING_
        else ; oops
        end
      end

      def _be_at_offset d
        @current_pending_start_offset_to_flush = d ; nil
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
        @structured_node.node_type
      end

      def _cursor
        @current_pending_start_offset_to_flush
      end
    end

    # ==

    LOC_MAP_INDEX_VIA_CLASS___ = ::Hash.new do |h, cls|
      _nf = Common_::Name.via_module cls
      _k = _nf.as_lowercase_with_underscores_symbol
      _xx = META_MAPPINGS___.fetch _k
      x = LocationMapIndex___.new _xx
      h[ cls ] = x
      x
    end

    ASC_INDEX_VIA_CLASS___ = ::Hash.new do |h, cls|
      a = cls.association_index.associations
      h_ = {}
      a.each_with_index do |asc, d|
        h_[ asc.association_symbol ] = d
      end
      h[ cls ] = h_.freeze
      h_
    end

    # ==

    class LocationMapIndex___

      def initialize x
        _a = x.fetch :these
        @semantic_columns = _a.map do |row|
          scn = Common_::Scanner.via_array row
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
    # ==
  end
end
# #born.
