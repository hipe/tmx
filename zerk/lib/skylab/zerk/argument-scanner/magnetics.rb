module Skylab::Zerk

  module ArgumentScanner

    module Here_::MagneticsScratchSpace__
      class Monadic
        class << self
          alias_method :call, :new
          alias_method :[], :call
          private :new
        end  # >>
      end
    end

    module Magnetics

      class << self

        def whine_about_how_argument_scanner_ended_early search
          Here_::When::Argument_scanner_ended_early_via_search[ search ]
        end
      end  # >>

      same = MagneticsScratchSpace__::Monadic

      class Request_via_Array

        def initialize arglist
          st = Common_::Polymorphic_Stream.via_array arglist
          h = self.class::HASH
          @_arglist_ = st
          begin
            send h.fetch st.current_token
          end until st.no_unparsed_exists
          remove_instance_variable :@_arglist_
          freeze
        end

        HASH = {
          against_branch: :__at_against_branch,
          against_hash: :__at_against_hash,
          business_item: :_accept_shape_symbol,
          passively: :__at_passively,
          primary: :_accept_shape_symbol,
          value: :__at_value,
        }

        def __at_against_hash
          @_arglist_.advance_one
          @operator_branch = Here_::OperatorBranch_via_Hash[ @_arglist_.gets_one ]
          NIL
        end

        def __at_against_branch
          @_arglist_.advance_one
          @operator_branch = @_arglist_.gets_one
          NIL
        end

        def _accept_shape_symbol
          @shape_symbol = @_arglist_.gets_one ; nil
        end

        def __at_passively
          @_arglist_.advance_one
          @be_passive = true ; nil
        end

        def __at_value
          @_arglist_.advance_one
          @do_result_in_value = true ; nil
        end

        attr_reader(
          :be_passive,
          :do_result_in_value,
          :operator_branch,
          :shape_symbol,
        )
      end

#==FROM

    class BranchItem_via_OperatorBranch

      # this "facilitator" has a strange, session-heavy interface because [#052] #note-1

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize arglist, request_class
        @request = request_class.new arglist
      end

      def receive_argument_scanner as
        @argument_scanner = as ; nil
      end

      # ~

      def whine_about_how_item_was_not_found
        _always_whine_in_the_same_way  # hi.
      end

      # ~

      def item
        @__item_structure
      end

      attr_reader :item_was_found

      # --

      def operator_branch
        @request.operator_branch
      end

      attr_reader(
        :request,
      )
    end

    class PrimaryValue_via_ParseRequest < Common_::Actor::Dyadic

      def initialize as, req

        sym = req.typeish_symbol
        m = req.use_method
        yes = req.must_be_trueish

        # (for now, kiss)
        if sym
          yes || m and self._COVER_ME_not_like_this_not_for_now  # #todo
        end

        @argument_scanner = as
        @must_be_trueish = yes
        @typeish_symbol = sym
        @use_method =  m
      end

      def execute
        if @argument_scanner.no_unparsed_exists
          __when_argument_value_not_provided
        else
          __when_argument_is_provided
        end
      end

      def __when_argument_value_not_provided
        Here_::When::Argument_value_not_provided[ @argument_scanner ]
      end

      def __when_argument_is_provided
        if @typeish_symbol
          send THESE___.fetch @typeish_symbol
        else
          __when_no_typeish_symbol
        end
      end

      THESE___ =  {
        integer_that_is_postive_nonzero: :__positive_nonzero_integer__,
        integer_that_is_non_negative: :__non_negative_integer__,
      }

      def __positive_nonzero_integer__
        _integer_which do |d|
          0 < d
        end
      end

      def __non_negative_integer__
        _integer_which do |d|
          0 <= d
        end
      end

      def _integer_which
        d = __parse_integer
        if d
          if yield d
            d
          else
            _loc = caller_locations( 1, 1 ).fetch 0  # CAREFUL
            __when_integer_did_not_match d, _loc
          end
        end
      end

      def __when_integer_did_not_match d, loc

        # e.g "non negative integer"
        # e.g "positive nonzero integer"

        _slug = /\A__(.+)__\z/.match( loc.base_label )[ 1 ]
        _human = _slug.gsub UNDERSCORE_, SPACE_

        @argument_scanner.listener.call :error, :expression, :invalid_integer_value do |y|
          y << "needed #{ _human }, had #{ d }"
        end
        self._THE_ABOVE_IS_A_CODE_SKETCH_THAT_NEEDS_TO_BE_COVERED  # #todo
        UNABLE_
      end

      def __parse_integer

        # (super hacky - if client results in `false`, she emitted.
        # if nil, we must emit.)

        d = @argument_scanner.parse_integer_
        if d
          d
        elsif d.nil?
          self._COVER_ME_we_gotta_emit_that_it_wasnt_an_integer
        else
          d
        end
      end

      def __when_no_typeish_symbol
        x = __peek_head
        if @must_be_trueish
          if x
            _final_value x
          else
            __when_supposed_to_be_trueish_but_is_not
          end
        else
          _final_value Common_::Known_Known[ x ]
        end
      end

      def __when_supposed_to_be_trueish_but_is_not
        _sym = @argument_scanner.current_primary_symbol
        _x = @argument_scanner.head_as_is
        self._COVER_ME_falseish_argument_value_when_expected_trueish
      end

      def __peek_head
        if @use_method
          @argument_scanner.send @use_method
        else
          @argument_scanner.head_as_is
        end
      end

      def _final_value x
        @argument_scanner.advance_one
        x
      end
    end

    class ParseRequest_via_Array < Common_::Actor::Monadic

      def initialize x_a
        @__typeish_mutex = nil
        @option_array = x_a
      end

      def execute
        if __has_options
          __process_options
        end
        freeze
      end

      def __has_options
        x_a = remove_instance_variable :@option_array
        if x_a.length.nonzero?
          @_scn = Common_::Polymorphic_Stream.via_array x_a
          ACHIEVED_
        end
      end

      def __process_options
        begin
          send OPTIONS___.fetch @_scn.current_token
        end until @_scn.no_unparsed_exists
        remove_instance_variable :@_scn
        NIL
      end

      OPTIONS___ = {
        integer_that_is_postive_nonzero: :_typeish_slot,
        integer_that_is_non_negative: :_typeish_slot,
        must_be_trueish: :__flag,
        use_method: :__takes_one_argument,
      }

      def _typeish_slot
        remove_instance_variable :@__typeish_mutex
        @typeish_symbol = @_scn.gets_one
        NIL
      end

      def __flag
        instance_variable_set :"@#{ @_scn.gets_one }", true
      end

      def __takes_one_argument
        instance_variable_set :"@#{ @_scn.gets_one }", @_scn.gets_one
      end

      attr_reader(
        :must_be_trueish,
        :use_method,
        :typeish_symbol,
      )
    end
#==TO

      # ==

      ItemNotFound_via_ReasoningSymbol = -> sym do

        _rsn = Here_::SimpleStructuredReason.new sym
        ItemNotFound_via_Reasoning[ _rsn ]
      end

      class ItemNotFound_via_Reasoning < same

        def initialize rsn
          @reasoning = rsn
        end

        def whine_about_how_item_was_not_found sea
          Here_::When::Unified_whine_via_reasoning[ @reasoning, sea ]
        end

        def item_was_found
          false
        end
      end

      module ITEM_NOT_FOUND_WITHOUT_REASONING___ ; class << self

        def whine_about_how_item_was_not_found sea
          ::Kernel._K
        end

        def item_was_found
          false
        end
      end ; end

      class ItemFound_via_Item < same

        def initialize x
          @item = x
        end

        attr_reader :item

        def item_was_found
          true
        end
      end

      # ==

      class NotWellFormed_via_ReasonSymbol < same

        def initialize sym
          @reasoning = Here_::SimpleStructuredReason.new sym
        end

        def is_well_formed
          false
        end

        def whine_about_how_it_is_not_well_formed sea
          Here_::When::Unified_whine_via_reasoning[ @reasoning, sea ]
        end
      end

      class WellFormed_via_WellFormedSymbol < same

        # replaces: well_formed_potential_symbol_knownness=

        def initialize sym
          @well_formed_symbol = sym
        end

        attr_reader :well_formed_symbol

        def is_well_formed
          true
        end
      end

      # ==
    end
  end
end
