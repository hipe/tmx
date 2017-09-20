module Skylab::Zerk::TestSupport

  module No_Dependencies_Zerk

    class << self

      def [] tcc
      tcc.send :define_singleton_method, :begin_scanner_canon, MM_01___
      tcc.include InstaceMethods___
      end

      def lib
        Home_::No_deps[]
      end
    end  # >>

    # -

      MM_01___ = -> do  # `begin_scanner_canon`
        Scanner_canon___[].begin_canon_pool
      end
    # -

    module InstaceMethods___

      def library_one_
        Library_one___
      end

      def subject_library_
        Subject_library_[]
      end
    end

    # ==

    Scanner_canon___ = Lazy_.call do

      TestSupport_::Canon.define do |oo|

        oo.writable_module Sandbox___

        oo.add_test :the_empty_scanner_knows_it_is_empty do
          innermost_scanner_( state_0 ).no_unparsed_exists || fail
        end

        oo.add_sequential_memoization :state_0 do
          build_scanner
        end

        # --

        oo.add_context :subcanon_for_non_primary_head do |o|

          o.add_test :at_the_beginning_the_scanner_knows_it_has_some_unparsed do
            innermost_scanner_( state_0[0] ).no_unparsed_exists && fail
          end

          o.add_test :the_scanner_does_not_parse_the_primary do
            state_1.first && fail
          end

          o.add_test :the_scanner_emits_that_it_did_not_parse_the_primary do
            em = state_1[2]
            a = em.channel_symbol_array
            a[ 0, 2 ] == [ :error, :expression ] || fail
            sym = a[2]
            sym == :primary_parse_error || sym == :parse_error || fail  # for now meh
            _expag = self.expression_agent
            _lines = em.express_into_under [], _expag
            self.expect_that_lines_express_appropriately _lines
          end

          o.add_test :after_not_parsing_the_primary_the_scanner_is_not_empty do
            innermost_scanner_( state_1[1] ).no_unparsed_exists && fail
          end

          o.add_sequential_memoization :state_0 do

            log = Common_.test_support::Expect_Emission::Log.for self
            _scn = build_scanner( & log.handle_event_selectively )
            [ _scn, log ]
          end

          o.add_sequential_memoization :state_1 do |state_0|
            scn = state_0[0]
            _match = scn.procure_primary_shaped_match
            _em = state_0[1].gets
            [ _match, scn, _em ]
          end
        end

        # --

        oo.add_context :subcanon_for_primary_head do |o|

          o.add_test :at_the_beginning_the_scanner_knows_it_has_some_unparsed do
            innermost_scanner_( state_0 ).no_unparsed_exists && fail
          end

          o.add_test :the_scanner_parses_the_primary do

            tuple = state_1
            match = tuple.first
            match.primary_symbol == :prim_1 || fail
            # ..
          end

          o.add_test :after_matching_the_primary_the_scanner_is_still_not_empty do

            state_1.last && fail
          end

          o.add_test :after_accepting_the_match_the_scanner_IS_empty do

            state_2 || fail
          end

          o.add_sequential_memoization :state_0 do
            build_scanner
          end

          o.add_sequential_memoization :state_1 do |nar|

            _match = nar.procure_primary_shaped_match
            _yes = innermost_scanner_( nar ).no_unparsed_exists
            [ _match, nar, _yes ]
          end

          o.add_sequential_memoization :state_2 do |state_1|

            match, nar = state_1
            nar.advance_past_match match
            innermost_scanner_( nar ).no_unparsed_exists
          end
        end
      end
    end

    # ==

    module InstaceMethods___

      def innermost_scanner_ nar
        nar.token_scanner
      end
    end

    Sandbox___ = ::Module.new

    # ==

    module Library_one___

      class Client

        def initialize nar
          @_narrator = nar
        end

        def _at_color feat
          vm = @_narrator.procure_any_match_after_feature_match feat.feature_match
          if vm
            @color = vm.mixed
            @_narrator.advance_past_match vm
          end
        end

        attr_reader(
          :color,
        )
      end

      class Operation

        def initialize nar
          @_narrator = nar
        end

        def _at_shape feat
          vm = @_narrator.procure_any_match_after_feature_match feat.feature_match
          if vm
            @shape = vm.mixed
            @_narrator.advance_past_match vm
          end
        end

        attr_reader(
          :shape,
        )
      end
    end

    # ==

    Subject_library_ = No_deps_zerk_

    # ==
  end
end
