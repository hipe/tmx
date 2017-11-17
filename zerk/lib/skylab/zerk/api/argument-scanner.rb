module Skylab::Zerk

  module API

    class ArgumentScanner < Home_::ArgumentScanner::CommonImplementation

      # (currently being frontiered by [tmx])

      # so that API and CLI can share some subset of syntax, for custom syntaxes

      class << self
        alias_method :via_array, :new
        undef_method :new
      end  # >>

      def initialize x_a, & l
        @listener = l
        if x_a.length.zero?
          @no_unparsed_exists = true
        else
          __initialize_normally x_a
        end
      end

      def __initialize_normally x_a

        @_scn = Common_::Scanner.via_array x_a
        @no_unparsed_exists = @_scn.no_unparsed_exists
        NIL
      end

      def match_branch * a  # MUST set @current_primary_symbol as appropriate
        _matcher_via_array( a ).gets
      end

      def matcher_for * a
        _matcher_via_array a
      end

      def _matcher_via_array a
        Matcher___.new self, a
      end

      def available_branch_internable_stream_via_feature_branch ob, _

        ob.to_loadable_reference_stream
      end

      def added_primary_normal_name_symbols
        NOTHING_
      end

      def match_integer_
        # 2 defs one call. assume nonempty. caller emits IFF result is nil #[#007.5]
        x = head_as_is
        if x.respond_to? :bit_length
          x
        end
      end

      def head_as_well_formed_potential_primary_symbol_
        _real_scanner_current_token_
      end

      def advance_one
        @_scn.advance_one
        @no_unparsed_exists = @_scn.no_unparsed_exists
      end

      def head_as_normal_symbol
        _real_scanner_current_token_
      end

      def head_as_is
        _real_scanner_current_token_
      end

      def _real_scanner_current_token_
        @_scn.head_as_is
      end

      def __receive_CPS_ sym
        @current_primary_symbol = sym ; nil
      end

      def expression_agent
        API::ArgumentScannerExpressionAgent.instance
      end

      attr_reader(
        :listener,
        :no_unparsed_exists,
      )

      # ==

      class Matcher___

        def initialize as, req_a
          @argument_scanner = as
          @request = Home_::ArgumentScanner::Magnetics::Request_via_Array.new req_a
        end

        def gets
          Search___.new( @request, @argument_scanner ).execute
        end
      end

      # ==

      class Search___

        def initialize req, as

          @argument_scanner = as
          @request = req
          @_ = Home_::ArgumentScanner::Magnetics
          freeze
        end

        def execute  # MUST set @current_primary_symbol as appropriate

          if @argument_scanner.no_unparsed_exists
            @_.whine_about_how_argument_scanner_ended_early self
          else
            __when_argument_scan_is_not_empty
          end
        end

        def __when_argument_scan_is_not_empty

          # replaces: receive_argument_scanner

          o = __well_formed_categorization

          if o.is_well_formed

            __when_well_formed_symbol o.well_formed_symbol
          else
            o.whine_about_how_it_is_not_well_formed self
          end
        end

        def __well_formed_categorization

          x = @argument_scanner._real_scanner_current_token_
          if x.respond_to? :id2name
            @_::WellFormed_via_WellFormedSymbol[ x ]
          else
            @_::NotWellFormed_via_ReasonSymbol[ :expected_symbol ]
          end
        end

        def __when_well_formed_symbol sym

          o = __branch_item_categorization_via_normal_symbol sym

          if o.item_was_found

            __when_item_was_found o.item
          else
            o.whine_about_how_item_was_not_found self
          end
        end

        def __branch_item_categorization_via_normal_symbol k

          trueish_x = @request.feature_branch.lookup_softly k
          if trueish_x

            _obe = Home_::ArgumentScanner::FeatureBranchItem.
              via_user_value_and_normal_symbol trueish_x, k

            @_::ItemFound_via_Item[ _obe ]
          else
            @_::ItemNotFound_via_ReasoningSymbol[ :unknown_primary ]
          end
        end

        def __when_item_was_found item

          @argument_scanner.__receive_CPS_ item.branch_item_normal_symbol

          if @request.do_result_in_value
            item.branch_item_value
          else
            item
          end
        end

        attr_reader(
          :argument_scanner,
          :request,
        )
      end

      # ==
    end
  end
end
# #history: abstracted from [tmx]
