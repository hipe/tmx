module Skylab::Zerk

  module ArgumentScanner

    Magnetics = ::Module.new

    class Magnetics::BranchItem_via_OperatorBranch

      # this "facilitator" has a strange, session-heavy interface because [#052] #note-1

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize arglist, request_class
        @request = request_class.new arglist
      end

      # ~(

      class Request

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
          @operator_branch = OperatorBranch_via_Hash___.new @_arglist_.gets_one
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

      # )~

      def receive_argument_scanner as
        @argument_scanner = as ; nil
      end

      def whine_about_how_argument_scanner_ended_early
        @_custom_behaivor_was_provided = false
        case @request.shape_symbol
        when :primary
          @_terminal_channel_symbol = :missing_required_primary
        when :business_item
          @_terminal_channel_symbol = :missing_required_argument
        end
        _always_whine_in_the_same_way
      end

      # ~

      def well_formed_potential_symbol_knownness= kn

        if kn.is_known_known

          @is_well_formed = true
          @__well_formed_known_known = kn
        else

          @is_well_formed = false
          _receive_known_unknown_reasoning kn.reasoning
        end

        kn
      end

      def whine_about_how_it_is_not_well_formed
        _always_whine_in_the_same_way  # hi.
      end

      def well_formed_symbol
        @__well_formed_known_known.value_x
      end

      attr_reader(
        :is_well_formed,
      )

      # ~

      def item_knownness= kn
        if kn.is_known_known
          @item_was_found = true
          @__item_structure = kn.value_x
        else
          @item_was_found = false
          rsn = kn.reasoning
          if rsn
            _receive_known_unknown_reasoning rsn
          end
          # (otherwise assume passive mode)
        end
        kn
      end

      def whine_about_how_item_was_not_found
        _always_whine_in_the_same_way  # hi.
      end

      # ~

      def item
        @__item_structure
      end

      attr_reader :item_was_found

      # --

      def _receive_known_unknown_reasoning rsn
        p = rsn.behavior_by
        if p
          @_custom_behaivor_was_provided = true
          @__behavior_by = p
        else
          @_custom_behaivor_was_provided = false
          @_terminal_channel_symbol = rsn.reason_symbol
        end
        NIL
      end

      def _always_whine_in_the_same_way
        if @_custom_behaivor_was_provided
          _user_x = @__behavior_by[ @argument_scanner.listener ]
          _user_x  # #todo
        else
          __whine_in_the_typical_fashion
        end
      end

      def __whine_in_the_typical_fashion

        req = @request
        ob = req.operator_branch
        shape_sym = req.shape_symbol
        req = nil

        o = Here_::When::UnknownBranchItem.begin

        if ! @argument_scanner.no_unparsed_exists
          o.strange_value_by = @argument_scanner.method :head_as_is
        end

        if ob

          _p = @argument_scanner.method :available_branch_item_name_stream_via_operator_branch

          o.available_item_name_stream_by = -> do
            _p[ ob, shape_sym ]
          end
        else
          NOTHING_  # #feature-island #scn-coverpoint-2
        end

        o.shape_symbol = shape_sym

        o.terminal_channel_symbol = @_terminal_channel_symbol

        o.listener = @argument_scanner.listener

        o.execute
      end

      def operator_branch
        @request.operator_branch
      end

      attr_reader(
        :request,
      )
    end

    class Magnetics::BranchItem_via_OperatorBranch::OperatorBranch_via_Hash___

      def initialize h
        @hash = h
      end

      def lookup_softly k
        @hash[ k ]
      end

      def entry_value k
        @hash.fetch k
      end

      def to_pair_stream
        h = @hash
        to_normal_symbol_stream do |k|
          Common_::Pair.via_value_and_name h.fetch( k ), k
        end
      end

      def to_normal_symbol_stream & p
        Stream_[ @hash.keys, & p ]
      end
    end

    class Magnetics::PrimaryValue_via_ParseRequest < Common_::Actor::Dyadic

      def initialize as, req
        @argument_scanner = as
        @must_be_trueish = req.must_be_trueish
        @use_method = req.use_method
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

        m = @use_method

        x = if m
          @argument_scanner.send m
        else
          @argument_scanner.head_as_is
        end

        if @must_be_trueish
          if x
            @argument_scanner.advance_one  # #here
            x
          else
            __when_supposed_to_be_trueish_but_is_not
          end
        else
          @argument_scanner.advance_one  # #here
          Common_::Known_Known[ x ]
        end
      end

      def __when_supposed_to_be_trueish_but_is_not
        _sym = @argument_scanner.current_primary_symbol
        _x = @argument_scanner.head_as_is
        self._COVER_ME_falseish_argument_value_when_expected_trueish
      end
    end

    class Magnetics::ParseRequest_via_Array < Common_::Actor::Monadic

      def initialize x_a
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
        must_be_trueish: :__flag,
        use_method: :__takes_one_argument,
      }

      def __flag
        instance_variable_set :"@#{ @_scn.gets_one }", true
      end

      def __takes_one_argument
        instance_variable_set :"@#{ @_scn.gets_one }", @_scn.gets_one
      end

      attr_reader(
        :must_be_trueish,
        :use_method,
      )
    end
  end
end
