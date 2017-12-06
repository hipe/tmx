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
          st = Scanner_[ arglist ]
          h = self.class::HASH
          @_arglist_ = st
          begin
            send h.fetch st.head_as_is
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
          @feature_branch = Here_::FeatureBranch_via_Hash[ @_arglist_.gets_one ]
          NIL
        end

        def __at_against_branch
          @_arglist_.advance_one
          @feature_branch = @_arglist_.gets_one
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
          :feature_branch,
          :shape_symbol,
        )
      end

#==FROM

    class BranchItem_via_FeatureBranch

      # this "facilitator" has a strange, session-heavy interface because [#052.B]

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

      def feature_branch
        @request.feature_branch
      end

      attr_reader(
        :request,
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
