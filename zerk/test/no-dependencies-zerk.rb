module Skylab::CodeMetrics::TestSupport

  module Primaries_Injections

    def self.[] tcc
      tcc.send :define_singleton_method, :begin_scanner_canon, MM_01___
      tcc.send :define_method, :library_one_, IM_01___
    end

    # -

      MM_01___ = -> do  # `begin_scanner_canon`
        Scanner_canon___[].begin_canon_pool
      end
    # -

    # -

      IM_01___ = -> do
        Library_one___
      end
    # -

    # ==

    Scanner_canon___ = Lazy_.call do

      TestSupport_::Canon.define do |oo|

        oo.writable_module Sandbox___

        oo.add_test :the_empty_scanner_knows_it_is_empty do
          state_0.no_unparsed_exists || fail
        end

        oo.add_sequential_memoization :state_0 do
          build_scanner
        end

        # --

        oo.add_context :subcanon_for_non_primary_head do |o|

          o.add_test :at_the_beginning_the_scanner_knows_it_has_some_unparsed do
            state_0[0].no_unparsed_exists && fail
          end

          o.add_test :the_scanner_does_not_parse_the_primary do
            state_1.first && fail
          end

          o.add_test :the_scanner_emits_that_it_did_not_parse_the_primary do
            em = state_1[2]
            a = em.channel_symbol_array
            a[ 0, 2 ] == [ :error, :expression ] || fail
            sym = a.last
            sym == :primary_parse_error || sym == :parse_error || fail  # for now meh
            _expag = self.expression_agent
            _lines = em.express_into_under [], _expag
            self.expect_that_lines_express_appropriately _lines
          end

          o.add_test :attempting_to_read_the_current_primary_symbol_raises do
            _cls = scanner_class::ScannerIsNotInThatState
            _scn = state_1[1] || fail
            begin
              _scn.current_primary_symbol
            rescue _cls => e
            end
            e.message == "cannot read `current_primary_symbol` from beginning state" || fail
          end

          o.add_test :after_not_parsing_the_primary_the_scanner_is_not_empty do
            state_1[1].no_unparsed_exists && fail
          end

          o.add_sequential_memoization :state_0 do

            log = Common_.test_support::Expect_Emission::Log.for self
            _scn = build_scanner( & log.handle_event_selectively )
            [ _scn, log ]
          end

          o.add_sequential_memoization :state_1 do |state_0|
            scn = state_0[0]
            _yes_or_no = scn.parse_primary
            _em = state_0[1].gets
            [ _yes_or_no, scn, _em ]
          end
        end

        # --

        oo.add_context :subcanon_for_primary_head do |o|

          o.add_test :at_the_beginning_the_scanner_knows_it_has_some_unparsed do
            state_0.no_unparsed_exists && fail
          end

          o.add_test :the_scanner_parses_the_primary do

            tuple = state_1
            tuple.first || fail
            tuple[1].current_primary_symbol == :prim_1 || fail
          end

          o.add_test :after_parsing_the_primary_the_scanner_knows_it_is_empty do
            state_1[1].no_unparsed_exists || fail
          end

          o.add_sequential_memoization :state_0 do
            build_scanner
          end

          o.add_sequential_memoization :state_1 do |scn|
            _yes_or_no = scn.parse_primary
            [ _yes_or_no, scn ]
          end
        end
      end
    end

    # ==

    Sandbox___ = ::Module.new

    # ==

    class ArgumentScannerForTesting

      # strange but valuable: at the moment this is the bleeding edge
      # implementation of our working "canon" specification at [#ze-052.1].
      # its main function at the moment is to stand as a proven baseline
      # implemention of features to show them (and the "cannon tests")
      # working. (note there is hard-coded mock behavior here)
      #
      # but this is also a would-be startingpoint implementation of a
      # scanner for an API-client modality library. but such an effort
      # should be merged in to [ze] and that is well outside of our scope
      # at this second.

      def initialize a, & l
        @_current_primary = :__current_primary_invalid
        @_receive_current_primary = :__receive_first_ever_current_primary
        if a.length.zero?
          @no_unparsed_exists = true
          freeze
        else
          @_array = a
          @_current_index = 0
          @_last_index = a.length - 1
          @_listener = l
        end
      end

      def parse_primary
        sym = head_as_is
        if :_not_a_primary_ == sym
          __whine_about_not_a_primary sym
          false
        else
          send @_receive_current_primary, sym
          advance_one
          true
        end
      end

      def __whine_about_not_a_primary sym
        @_listener.call :error, :expression, :parse_error do |y|
          y << "does not look like a primary: #{ sym.inspect }"
        end
        NIL
      end

      def __receive_first_ever_current_primary sym
        @_current_primary = :__current_primary_normally
        @_receive_current_primary = :__receive_current_primary_normally
        send @_receive_current_primary, sym
      end

      def __receive_current_primary_normally sym
        @__current_primary_value = sym ; nil
      end

      def current_primary_symbol
        send @_current_primary
      end

      def __current_primary_invalid
        raise ScannerIsNotInThatState,
          "cannot read `current_primary_symbol` from beginning state"
      end

      def __current_primary_normally
        @__current_primary_value
      end

      def advance_one
        if @_last_index == @_current_index
          remove_instance_variable :@_array
          remove_instance_variable :@_current_index
          remove_instance_variable :@_last_index
          @no_unparsed_exists = true
          freeze
        else
          @_current_index += 1
        end
        NIL
      end

      def head_as_is
        @_array.fetch @_current_index
      end

      attr_reader(
        :no_unparsed_exists,
      )

      # ===

      ScannerIsNotInThatState = ::Class.new ::RuntimeError

      # ===
    end

    # ==

    module Library_one___

      class Client

        def initialize scn
          @_args = scn
        end

        def _at_color
          @color = @_args.head_as_is
          @_args.advance_one ; true
        end

        attr_reader(
          :color,
        )
      end

      class Operation

        def initialize scn
          @_args = scn
        end

        def _at_shape
          @shape = @_args.head_as_is
          @_args.advance_one ; true
        end

        attr_reader(
          :shape,
        )
      end
    end

    # ==
  end
end
