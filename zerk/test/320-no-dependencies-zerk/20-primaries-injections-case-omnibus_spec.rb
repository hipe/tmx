require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[cm] no deps - primaries injections - case omnibus (1st)" do

    # this whole "grammar" is :#Coverpoint1.5, as referenced by [tmx].
    # created exactly to facilitate [tmx] toplevel help.
    # (incidentally during the "2nd wave" of argument parsing,
    # it was from this and the other that we abstracted the fifth tier #history-A.2

    # the general objective of this help parsing grammar is to expose
    # these sub-functions and their details:
    #
    #   - this note is somewhat redundant with a long note in our client
    #
    #   - once the help primary is encountered in the input scanner, any
    #     tokens after its token that reference in-scope "business features"
    #     will *not* be interpreted as *invocations* of those features.
    #     rather, any first such token *is* interpreted to indicate a
    #     request for help on that feature.
    #
    #     (so appreciate the distinction between token-as-invocation-of vs
    #     token-as-reference-to a feature; a distinction we only ever make
    #     when interpreting help requests: when invoking help, you're not
    #     *calling* feature X, you're asking for help *about* feature X;
    #     the point being the feature tokens look the same for both.)
    #
    #   - haphazardly and for now, help also has its own feature that it
    #     attempts to parse for: a "verbose" flag.
    #
    #     (this introduces an overlapping namespace problem, where one
    #     concern might irrevocably mask the other concern, were it the
    #     case that there were a business feature named "verbose". since
    #     there's not, we just casually avoid thinking about this too much.)
    #
    #     so, recognize those verbose flags intended for us. as their
    #     repetition is meaningful, count their occurrences and whine
    #     when some limit is reached.
    #
    #   - :#Here1: an ambiguous primary after the help primary makes it
    #     look like you were asking for help on one of those primaries.
    #     so we interpret this as a failure to execute on help for a
    #     particular feature, and just allow that whining to be the final
    #     emission here, with no (more general) help emitted.
    #
    #     however in the general, when there's a strange primary,
    #     we don't want it to thwart the attempt at displaying help:
    #     it's common to ask for help when something about the input
    #     tokens is wrong. this way, the user can insert the help
    #     primary towards the beginning of the erroneous input and
    #     still keep their work in the same in-progress buffer, that
    #     persists from invocation to invocation (between help and work).

    TS_[ self ]
    use :memoizer_methods
    use :no_dependencies_zerk
    use :no_dependencies_zerk_features_injections

    context "empty" do

      given do
        args
      end

      it "parses OK" do
        displayed_help_once_
      end
    end

    context "one non-primary-looking token" do

      given do
        args 'wapoozle'
      end

      it "parses OK" do
        displayed_help_once_
      end

      it "did not advance over the token" do
        index_is_at_ 0
      end
    end

    context "one non verpose - strange" do

      given do
        args '-strange'
      end

      it "parses OK" do
        displayed_help_once_
      end

      it "did not advance past" do
        index_is_at_ 0
      end
    end

    context "one non verpose that is valid" do

      given do
        args '-some-valid-primary'
      end

      it "parses OK" do
        displayed_help_once_
      end

      it "saw it, did not advance past" do
        executed_parse_state.my_parser._saw_other_primary___ || fail
        index_is_at_ 0
      end
    end

    context "one ambiguous" do

      # #coverpoint1.4

      given do
        args '-ver'
        expect_failure
      end

      it "whines about ambiguity" do

        log = did_not_parse_

        log = executed_parse_state.log
        em = log.gets
        _em = log.gets
        _em && fail
        _y = em.express_into_under [], expression_agent
        _y == ["ambiguous primary \"-ver\" - #{
          }did you mean -verpose or -verzion?" ] || fail

        em.channel_symbol_array == [ :error, :expression, :primary_parse_error ] || fail
      end

      it 'scanner is still sitting at the first token' do
        index_is_at_ 0
      end
    end

    context "one verpose" do

      given do
        args '-verp'
      end

      it "worked - parsed ONE" do
        parsed_this_many_ 1
        scanner_finished_
      end
    end

    context "two verpose" do

      given do
        args '-verp', '-verp'
      end

      it "worked - parsed TWO" do
        parsed_this_many_ 2
        scanner_finished_
      end
    end

    context "three verpose" do

      given do
        args '-verp', '-verp', '-verp'
        expect_failure
      end

      it "fails talkin bout etc" do
        log = did_not_parse_
        _em = log.gets
        log.gets && fail
        _em.channel_symbol_array.last == :too_much_verpose || fail
      end

      it 'scanner is pointing AT offending token' do
        index_is_at_ 2
      end
    end

    def did_not_parse_
      sta = executed_parse_state
      sta.result == false || fail
      sta.log
    end

    def parsed_this_many_ d
      _parser = displayed_help_once_
      _parser.number_of_verpose == d || fail
    end

    def displayed_help_once_
      sta = executed_parse_state
      sta.result == true || fail
      parser = sta.my_parser
      parser.number_of_times_showed_help_screen == 1 || fail
      parser
    end

    shared_subject :parser_class_ do

      class X_ndz_pico1_LaLa

        def initialize nar

          _PRIMARIES = {
            verpose: :__process_verpose,
            verzion: :__process_verzion,
            some_valid_primary: :__process_XXX,
          }

          @_omni = ::NoDependenciesZerk::ArgumentParsingIdioms_via_FeaturesInjections.define do |fi|
            fi.add_primaries_injection _PRIMARIES, :_inj_2_ze
            fi.add_injector self, :_inj_2_ze
            fi.argument_scanner_narrator = nar
          end

          @argument_scanner_narrator = nar
        end

        def execute

          begin

            if no_unparsed_exists
              _show_help_screen
              break
            end

            if ! match_primary_shaped_token
              _show_help_screen
              break
            end

            if ! look_up_primary_via_match

              if primary_was_ambiguous_or_similar  # see #Here1
                @_ok = false
              else
                _show_help_screen
              end
              break
            end

            if ! __found_primary_was_verpose
              _show_help_screen
              break
            end

          end until __verpose_limit_reached

          remove_instance_variable :@_ok
        end

        def __found_primary_was_verpose
          @_primary_found = release_primary_found
          sym = @_primary_found.primary_match.primary_symbol
          if :verpose == sym
            true
          else
            @_saw_other_primary___ = sym
            false
          end
        end

        def __verpose_limit_reached

          # this is :#Coverpoint1.1, relied upon (& copy-pasted) by [tmx]

          found = @_primary_found
          injr = @_omni.features.injector_via_primary_found found
          injr.object_id == object_id || fail
          _ok = injr.send found.trueish_feature_value
          ! _ok  # hi. #todo
        end

        def _show_help_screen
          ( @number_of_times_showed_help_screen ||= 0 )
          @number_of_times_showed_help_screen += 1
          @_ok = true ; nil
        end

        No_Dependencies_Zerk.lib  # load it
        include ::NoDependenciesZerk::NarratorMethods

        # -- (only because subject is acting as injector)

        def __process_verpose
          ( @number_of_verpose ||= 0 )
          if 2 == @number_of_verpose
            @argument_scanner_narrator.listener.call :error, :expression, :too_much_verpose do |y|
              y << "too much verpose"
            end
            @_ok = false
            UNABLE_
          else
            @argument_scanner_narrator.advance_past_match @_primary_found.primary_match  #[#007.H]
            @number_of_verpose += 1 ; ACHIEVED_
          end
        end

        # -- (end)

        def current_argument_parsing_idioms
          @_omni
        end

        attr_reader(
          :argument_scanner_narrator,
          :number_of_times_showed_help_screen,
          :number_of_verpose,
          :_saw_other_primary___,
        )

        self
      end
    end

    # ==

    # ==

    def expression_agent
      expression_agent_for_nodeps_CLI_
    end
  end
end
# :#tombstone-A.2: as referenced
# #tombstone-A.1: finally got rid of offensive "retreat one" call
