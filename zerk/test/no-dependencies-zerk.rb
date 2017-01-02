module Skylab::Zerk::TestSupport

  module No_Dependencies_Zerk

    def self.[] tcc
      tcc.send :define_singleton_method, :begin_scanner_canon, MM_01___
      tcc.include InstaceMethods___
    end

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
        Subject_library__[]
      end
    end

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

    Argument_scanner_for_testing = Lazy_.call do

      # there are parts of the argument scanner "canon" that we don't
      # actually want to bother implementing in the API argument scanner.
      # so for now we make a subclass of that with stub implementations
      # to get a sense for how it would look.

      Subject_library__[]

      class ArgumentScannerForTesting___ < ::NoDependenciesZerk::API_ArgumentScanner

        def parse_primary
          sym = head_as_is
          if :_not_a_primary_ == sym
            __whine_about_not_a_primary sym
            false
          else
            super
          end
        end

        def __whine_about_not_a_primary sym
          @listener.call :error, :expression, :parse_error do |y|
            y << "does not look like a primary: #{ sym.inspect }"
          end
          NIL
        end

        self
      end
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

    Subject_library__ = Lazy_.call do
      require 'no-dependencies-zerk'
      ::NoDependenciesZerk
    end

    # ==
  end
end
