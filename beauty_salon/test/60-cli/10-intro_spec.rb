# frozen_string_literal: true

require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe "[bs] CLI - intro" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI

    context '(temporary context for #open [#023])' do
    # ~ begin temporary block

    use :non_interactive_CLI  # (move this up at #open [#023])

    context '0) no args at all' do

      given do
        argv
      end

      it 'first line - splay' do
        expect_splay_of_both_ first_line_string
      end

      it 'second line - invite to base hlep' do
        expect_invite_to_base_help_ second_line_string
      end

      it 'results in failure exitstatus' do
        expect_failure_exitstatus_
      end
    end

    context '1.1) strange arg' do

      given do
        argv 'wajoonga'
      end

      it 'first line - whine' do
        first_line_string == %(unrecognized operator: "wajoonga"\n) || fail
      end

      it 'second line - splay' do
        expect_splay_of_operators_ second_line_string
      end

      it 'third line - invite to base help' do
        expect_invite_to_base_help_ third_and_final_line_string
      end

      it 'results in failure exitstatus' do
        expect_failure_exitstatus_
      end
    end

    context '1.2) strange option' do

      given do
        argv '-x'
      end

      it 'first line - whine' do
        first_line_string == %(unknown primary "-x"\n) || fail
      end

      it 'second line - splay' do
        expect_splay_of_primaries_ second_line_string
      end

      it 'third line - invite to base help' do
        expect_invite_to_base_help_ third_and_final_line_string
      end

      it 'results in failure exitstatus' do
        expect_failure_exitstatus_
      end
    end

    ping_token = 'ping'

    context '1.3) good arg (ping)' do

      given do
        argv ping_token
      end

      it 'first (only) line is styled' do
        _ = first_line_string
        _ == "[bs] says \e[1;32mhello\e[0m\n" || fail
      end

      it 'exitstatus is success' do
        expect_success_exitstatus_
      end
    end

    context '1.4) base help' do

      given do
        argv '-h'
      end

      it 'first section - usage' do
        _ = _section :usage
        _actual_s = _.expect_exactly_one_line
        _ = _expected_operators_string_array * '|'
        _actual_s == "usage: chimmy { #{ _ } } [opts]\n" || fail
      end

      it 'second section - description' do
        _ = _section :description
        _first_line = _.emissions.first.string
        _first_line.include? 'an umbrella node' or fail
      end

      it 'operations section has no extra items' do
        these = _tuple.first
        these and fail "extra items in help screen: (#{ these * ', ' })"
      end

      it 'operations section has no missing items' do

        these = _tuple[1]
        these and fail "missing items in help screen: (#{ these * ', ' })"
      end

      it 'the description lines for the help item look right' do

        _lines = _tuple[2]
        _lines == [ "tests basic wiring. \e[1;32myay.\e[0m" ] || fail
      end

      shared_subject :_tuple do

        # -- setup

        these_lines = nil
        special = {}
        special[ ping_token ] = -> item do
          these_lines = item.desc_string_array
        end

        pool = {}
        _expected_operators_string_array.each do |s|
          pool[ s ] = true
        end

        extra = nil

        # --

        _ = _section :operations
        _idx = _.to_index_of_common_item_list

        _idx.items.each do |item|
          if pool.delete item.label
            # (was `item.mixed_normal_key`. hello to that method)
            p = special.delete item.label
            if p
              p[ item ]
            end
          else
            ( extra ||= [] ).push item.label
          end
        end

        if pool.length.nonzero?
          _missing = pool.keys
        end

        [ extra, _missing, these_lines ]
      end

      def _section sym
        __sections.fetch sym
      end

      shared_subject :__sections do

        string_st = to_errput_line_stream_strictly

        o = Zerk_test_support_[]::CLI::Expect_Section_Fail_Early.define
        h = {}

        o.expect_section 'usage' do |sect|
          h[ :usage ] = sect
        end

        o.expect_section 'description' do |sect|
          h[ :description ] = sect
        end

        o.expect_section 'operations' do |sect|
          h[ :operations ] = sect
        end

        spy = o.finish.to_spy_under self
        io = spy.spying_IO

        begin
          line = string_st.gets
          line || break
          io.puts line
          redo
        end while above

        spy.finish
        h
      end
    end

    # -- assertion

    def expect_splay_of_operators_ s
      _expect_AND_list s, 'operator', _expected_operators_string_array
    end

    def expect_splay_of_primaries_ s
      _expect_AND_list s, 'primary', _expected_primaries_string_array
    end

    def expect_splay_of_both_ s
      _these = [
        * _expected_operators_string_array,
        * _expected_primaries_string_array,
      ]
      _expect_AND_list s, 'operators and primary', _these
    end

    -> do

      operators = [
        ping_token,
      ]

      primaries = %w(
        -help
      )

      define_method :_expected_operators_string_array do
        operators
      end

      define_method :_expected_primaries_string_array do
        primaries
      end
    end.call

    def _expect_AND_list actual_s, lemma_s, these

      _use_noun_phrase = if 1 == these.length
        lemma_s
      else
        lemma_s.sub( %r(y\z), 'ie' ) << 's'  # egads
      end

      _ = Common_::Oxford_and[ these ]

      _expected_s = "available #{ _use_noun_phrase }: #{ _ }\n"

      actual_s == _expected_s || fail
    end

    def expect_invite_to_base_help_ s
      s == "try 'chimmy -h'\n" || fail
    end

    def expect_failure_exitstatus_
      exitstatus == 5 || fail
    end

    def expect_success_exitstatus_
      exitstatus.zero? || fail
    end

    # -- setup

    define_method :invocation_strings_for_expect_stdout_stderr, ( Home_::Lazy_.call do
      [ 'chimmy' ].freeze
    end )

    def subject_CLI
      Home_::CLI2
    end
    end  # ~ end temporary block

    # #open [#023] away the below (old-style tests)

    it "ping" do

      invoke 'ping-orig'
      expect :e, "hello from beauty salon."
      expect_no_more_lines
      @exitstatus.should eql :hello_from_beauty_salon
    end

    it "help screen" do

      invoke '-h'

      _guy = flush_invocation_to_help_screen_tree

      sect = _guy.children[ 1 ]

      _rx = Home_.lib_.zerk::CLI::Styling::SIMPLE_STYLE_RX
      s = sect.x.string.gsub _rx, EMPTY_S_
      s or fail

      4 <= sect.children.length or fail

    end
  end
end
# #history-A.1: begin injecting code for [ze]-era CLI
