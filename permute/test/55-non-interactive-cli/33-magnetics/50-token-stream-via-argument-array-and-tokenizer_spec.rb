require_relative '../../test-support'

module Skylab::Permute::TestSupport

  describe "[pe] non-interactive CLI - magnetics - [magnet #2]" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event

    context "no args" do

      shared_subject :_this do
        _against
      end

      it "fails" do
        fails
      end

      it "explains" do
        expect_emission :error, :expression, :parse_error do |y|
          y == [ "expecting categories and values" ] || fail
        end
      end
    end

    context "leading help" do

      shared_subject :_this do
        _against '-h', 'whatever', 'anything', '-h'
      end

      it "result is nothing" do
        result_is_nothing
      end

      it "emits help directive" do
        expect_emission :extra_functional, :help do |xx|
          xx == :_no_data_from_help_for_now_ || fail
        end
      end

      it "removes the first but not the last switch" do
        _argv_after == %w( whatever anything -h ) || fail
      end
    end

    context "trailing help" do

      shared_subject :_this do
        _against '--wuzzy', '-d', '-h'
      end

      it "result is nothing, emits help directive" do

        result_is_nothing

        expect_emission :extra_functional, :help do |xx|
          xx == :_no_data_from_help_for_now_ || fail
        end
      end

      it "removes the first but not the last switch" do
        _argv_after == %w( --wuzzy -d ) || fail
      end
    end

    context "unqualified short" do

      shared_subject :_this do
        _against '-c', 'hi'
      end

      it "fails" do
        fails
      end

      it "event has a bunch of meta-data" do

        _em = only_emission
        ev = _em.cached_event_value
        ev.x == '-c' || fail
        ev.had_more || fail
        ev.error_category == :argument_error || fail
        ev.ok && fail
      end

      it "event explains" do

        expect_emission :error, :case, :no_available_state_transition do |ev|
          _lines = black_and_white ev
          _lines == 'expecting long switch at "-c"' || fail
        end
      end
    end

    context "ok" do

      shared_subject :_this do
        __expect_no_emission_against '--longer', 'l1', '-s', 'short'
      end

      it "result has tags of lexical category type" do

        _actual = _result_as_array.map( & :name_symbol )
        _expected =  %i( long_switch value short_switch value )
        _actual == _expected || fail
      end

      it "result has the argv strings as-is" do

        _result_as_array.map( & :value ) == %w( --longer l1 -s short )
      end

      def _result_as_array
        _this.result  # (hide the secret that we don't result in a stream here)
      end

      it "clears out argv" do
        _argv_after.length == 0 || fail
      end
    end

    def _against * argv  # result in state

      _oes_p = event_log.handle_event_selectively
      x = _send _oes_p, argv
      x && Home_._PROBABLY_NOT
      _em_a = remove_instance_variable( :@event_log ).flush_to_array
      _State.new argv, x, _em_a
    end

    def __expect_no_emission_against * argv  # result in state

      _x = _send Expect_no_emission_, argv
      _State.new argv, _x
    end

    def _send oes_p, argv
      Home_::CLI::Magnetics_::TokenStream_via_ArgumentArray_and_Tokenizer[ argv, & oes_p ]
    end

    def _argv_after
      _this._argv
    end

    shared_subject :_State do
      TS_::X_nicli_mags_tsvaaats = ::Struct.new :_argv, :result, :emission_array
    end

    def state_for_expect_emission
      _this
    end
  end
end
