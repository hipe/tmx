require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[cm] no deps - primaries injections - case omnibus (1st)" do

    TS_[ self ]
    use :memoizer_methods
    use :no_dependencies_zerk
    use :no_dependencies_zerk_features_injections

    # created exactly to facilitate [tmx] toplevel help

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

      # #nodeps-coverpoint-3

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
        executed_parse_state.parser._SAW_OTHER_PRIMARY_ || fail
        index_is_at_ 0
      end
    end

    context "one ambiguous" do

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

      it "scanner remains advanced like normal" do
        index_is_at_ 1
      end
    end

    context "one verpose" do

      given do
        args '-verp'
      end

      it "worked - parsed ONE" do
        parsed_this_many_ 1
        index_is_at_ 1
      end
    end

    context "two verpose" do

      given do
        args '-verp', '-verp'
      end

      it "worked - parsed TWO" do
        parsed_this_many_ 2
        index_is_at_ 2
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

      it "scanner is pointing PAST offending guy" do
        index_is_at_ 3
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
      parser = sta.parser
      parser.number_of_times_showed_help_screen == 1 || fail
      parser
    end

    shared_subject :parser_class_ do

      class X_ndz_pico1_LaLa

        def initialize args

          _PRIMARIES = {
            verpose: :__process_verpose,
            verzion: :__process_verzion,
            some_valid_primary: :__process_XXX,
          }

          @omni = ::NoDependenciesZerk::ParseArguments_via_FeaturesInjections.define do |fi|
            fi.add_primaries_injection _PRIMARIES, self
            fi.argument_scanner = args
          end

          @args = args
        end

        def execute

          # (this whole "grammar" is #nodeps-Coverpoint-5, as referenced by [tmx])

          begin
            if __argument_scanner_is_empty
              _show_help_screen
              break
            end
            if ! __parse_primary_softly
              _show_help_screen
              break
            end
            __lookup_primary
            if __lookup_was_ambiguous
              break
            end
            if ! __primary_was_found
              _retreat_one
              _show_help_screen
              break
            end
            if ! __found_primary_was_verpose
              _retreat_one
              _show_help_screen
              break
            end
            if __verpose_limit_is_reached
              __whine_about_too_many_verpose
              break
            end
            redo
          end while above
          remove_instance_variable :@_ok
        end

        def __argument_scanner_is_empty
          @args.no_unparsed_exists
        end

        def __parse_primary_softly
          @args.parse_primary_softly
        end

        def __lookup_primary
          @_lookup = @omni.lookup_current_primary_symbol_semi_softly
          NIL
        end

        def __lookup_was_ambiguous
          did = @_lookup.had_unrecoverable_error_which_was_expressed
          did && @_ok = false
          did
        end

        def __primary_was_found
          @_lookup.was_found
        end

        def __found_primary_was_verpose
          if :verpose == @_lookup.primary_symbol
            true
          else
            @_SAW_OTHER_PRIMARY_ = @_lookup.primary_symbol
            false
          end
        end

        def __verpose_limit_is_reached

          # this is :#nodeps-Coverpoint-1-1, relied upon (& copy-pasted) by [tmx]

          found = remove_instance_variable :@_lookup
          injr = @omni.injector_via_primary_found found
          injr.object_id == object_id || fail
          _ok = injr.send found.trueish_item_value
          ! _ok
        end

        def __whine_about_too_many_verpose
          NOTHING_ # (did)
        end

        def _retreat_one
          @args.retreat_one
          NIL
        end

        def _show_help_screen
          ( @number_of_times_showed_help_screen ||= 0 )
          @number_of_times_showed_help_screen += 1
          @_ok = true ; nil
        end

        # -- (only because subject is acting as injector)

        def __process_verpose
          ( @number_of_verpose ||= 0 )
          if 2 == @number_of_verpose
            @args.listener.call :error, :expression, :too_much_verpose do |y|
              y << "too much verpose"
            end
            @_ok = false
            UNABLE_
          else
            @number_of_verpose += 1 ; ACHIEVED_
          end
        end

        # -- (end)

        attr_reader(
          :args,
          :number_of_times_showed_help_screen,
          :number_of_verpose,
          :_SAW_OTHER_PRIMARY_,
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
