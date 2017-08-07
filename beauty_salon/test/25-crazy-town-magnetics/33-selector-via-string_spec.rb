require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - selector via string', ct: true do

    TS_[ self ]
    use :memoizer_methods

    it 'magnetic loads' do
      _lower_level_subject_magnetic || fail
    end

    context 'errors (perhaps comprehensively) and some successes' do

      same_rx = %r<\Aexpecting callish identifier \([^)]+\):?\z>

      it 'empty string - says expecting identifier' do

        _against EMPTY_S_
        _fails_with_these_normal_lines do |y|
          y << same_rx
          y << '  '
          y << '  ^'
        end
      end

      it 'bad char for identifier as 1st char - says expecting identifier' do

        _against '%foo'
        _fails_with_these_normal_lines do |y|
          y << same_rx
          y << '  %foo'
          y << '  ^'
        end
      end

      it 'good identifier only - expects open paren' do

        _against 'foo'
        _fails_with_these_normal_lines do |y|
          y << 'expecting open parenthesis:'
          y << '  foo'
          y << '  ---^'
        end
      end

      it 'good identifer then weird char - expects open paren' do

        _against 'foo%'
        _fails_with_these_normal_lines do |y|
          y << 'expecting open parenthesis:'
          y << '  foo%'
          y << '  ---^'
        end
      end

      it 'for now, no space between identifier and open paren' do

        _against 'foo ('
        _fails_with_these_normal_lines do |y|
          y << 'expecting open parenthesis:'
          y << '  foo ('
          y << '  ---^'
        end
      end

      it 'after open paren, expects something' do

        _against 'foo('
        _fails_with_these_normal_lines do |y|
          y << 'expecting identifier or true keyword:'
          y << '  foo('
          y << '  ----^'
        end
      end

      it 'identifier, open paren, true keyword - expects close paren (WILL EXPAND)' do

        _against 'foo( true '
        _fails_with_these_normal_lines do |y|
          y << %q(expecting '==' or close parenthesis:)
          y << '  foo( true '
          y << '  ----------^'
        end
      end

      it 'identifier, open paren, true keyword, close paren YAY' do

        _against "foo( \t true)"
        pt = _produces_parse_tree_while_emitting_nothing
        pt.feature_symbol == :foo || fail
        pt.list_of_boolean_tests && fail
      end

      it 'where you would expect a boolean operator (WILL EXPAND)' do

        _against 'foo( jamma'
        _fails_with_these_normal_lines do |y|
          y << %q(expecting '==':)
          y << '  foo( jamma'
          y << '  ----------^'
        end
      end

      it 'boolean operator midway through (WILL EXPAND)' do

        _against 'foo( jamma ='
        _fails_with_these_normal_lines do |y|
          y << %q(expecting '=':)
          y << '  foo( jamma ='
          y << '  ------------^'
        end
      end

      it 'expecting literal string' do

        _against 'foo( jamma == %'
        _fails_with_these_normal_lines do |y|
          y << %q(expecting open single quote:)
          y << '  foo( jamma == %'
          y << '  --------------^'
        end
      end

      it %q(literal string that doesn't close) do

        _against %q{foo( jamma == '%}
        _fails_with_these_normal_lines do |y|
          y << 'expecting close single quote:'
          y << %q{  foo( jamma == '%}
          y << %q{  ----------------^}
        end
      end

      it 'literal string that closes but no close paren' do

        _against %q{foo( jamma == 'xy'}
        _fails_with_these_normal_lines do |y|
          y << %q(expecting '&&' or '||' or close parenthesis:)
          y << %q{  foo( jamma == 'xy'}
          y << %q{  ------------------^}
        end
      end

      it 'whines about dangling whitespace' do

        _against %q{foo(jam=='xy') }
        _fails_with_these_normal_lines do |y|
          y << %q{expecting end of input:}
          y << %q{  foo(jam=='xy') }
          y << %q{  --------------^}
        end
      end
    end

    context 'parse tree - with just one test component' do

      it 'parses' do
        _parse_tree || fail
      end

      it 'knows the name of the feature symbol' do
        _pt = _parse_tree
        _pt.feature_symbol == :mm_qq || fail
      end

      it 'knows there is one boolean test' do
        _boolean_tests_array.length == 1 || fail
      end

      it 'the boolean tests knows its left had side' do
        _sym = _the_only_test.symbol_symbol
        _sym == :jama || fail
      end

      it 'knows its comparison function name symbol' do
        _sym = _the_only_test.comparison_function_name_symbol
        _sym == :_EQ_ || fail
      end

      it 'knows its literal string' do
        _s = _the_only_test.literal_value
        _s == '%a' || fail
      end

      def _the_only_test
        _boolean_tests_array.first
      end

      shared_subject :_parse_tree do
        _parse_tree_via_string_expecting_success %q{mm_qq( jama == '%a' )}
      end
    end

    context 'parse tree - model case', wip: true do

      it 'parses' do
        _parse_tree || fail
      end

      it 'knows the name of the feature symbol' do
        _guy = _parse_tree
        _guy.feature_symbol == :xx_yy || fail
      end

      it 'knows the several boolean tests' do
        _boolean_tests_array.length == 2 || fail
      end

      it 'each boolean test knows the left hand side' do
        _sym_a = _boolean_tests_array.map( & :symbol_symbol )
        _sym_a == %i( qq_q mm_m ) || fail
      end

      it 'each test knows the comparison function name symbol' do
        _sym_a = _boolean_tests_array.map( & :comparison_function_name_symbol )
        _sym_a.uniq == %i( _EQ_ ) || fail
      end

      it 'plain old strings parse' do
        _s = _boolean_tests_array.first.literal_value
        _s == 'ze ze' || fail
      end

      it 'strings with escaped parts parse' do
        _s = _boolean_tests_array.last.literal_value
        _s == %(i'm "OK") || fail
      end

      shared_subject :_parse_tree do
        _parse_tree_via_string_expecting_success 'xx_yy(  qq_q== "ze ze" &&mm_m =="i\'m \\"OK\\"")'
      end
    end

    # ==

    context 'error 3 - like so', wip: true do

      # NOTE - this goes away and becomes the simpler form WHEN we re-
      # introduce regexp based tests. at that time don't forget to remove
      # the auxiliary method used here too (`_parse_expecting_failure`).

      it 'fails' do
        _fails
      end

      it 'this contextualized expression' do

        _actual = _expect_parse_error_and_give_lines

        expect_these_lines_in_array_ _actual do |y|
          y << 'expecting "==" or "=~":'
          y << '    dd( ee = ff )'
          y << '    -------^'
        end
      end

      shared_subject :_tuple do
        _parse_expecting_failure 'dd( ee = ff )'
      end
    end

    # ==

    def _boolean_tests_array
      _parse_tree.list_of_boolean_tests
    end

    # ==

    def _parse_expecting_failure str

      log = Common_.test_support::Expect_Emission::Log.for self

      _x = _lower_level_subject_magnetic.call_by do |o|
        o.string = str
        o.listener = log.listener
      end

      [ _x, log.flush_to_array ]
    end

    # --

    def _expect_parse_error_and_give_lines

      em = _only_emission
      em.channel_symbol_array == %i( error expression parse_error ) || fail
      em.expression_proc[ [] ]
    end

    def _only_emission
      em_a = _tuple.last
      1 == em_a.length || fail
      em_a[0]
    end

    def _fails
      _x = _tuple.first
      _x && fail  # i don't care nil
    end

    # --

    def _against s
      @STRING = s
    end

    def _JUST_SHOW_ME_THE_MONEY

      lines, _x = __expression_lines_and_result
      $stderr.puts "WEE:"
      $stderr.puts lines
      $stderr.puts "GOODBYE. " ; exit 0
    end

    def _fails_with_these_normal_lines & p

      _lines, _x = __expression_lines_and_result

      _x == false || fail

      expect_these_lines_in_array_ _lines, & p
    end

    def __expression_lines_and_result

      expecting_no_more_emissions = -> * do
        fail
      end

      lines = nil

      p = -> em_p, sym_a do
        :expression == sym_a.first || fail
        lines = []
        _p = if do_debug
          io = debug_IO
          -> line { io.puts line ; lines.push line }
        else
          -> line { lines.push line }
        end
        y = ::Enumerator::Yielder.new( & _p )
        _y_ = nil.instance_exec y, & em_p
        y.object_id == _y_.object_id || fail
        p = expecting_no_more_emissions
      end

      _x = _lower_level_subject_magnetic.call_by do |o|

        o.listener = -> * sym_a, & em_p do
          p[ em_p, sym_a ]
        end

        o.string = remove_instance_variable :@STRING
      end

      [ lines, _x ]
    end

    def _produces_parse_tree_while_emitting_nothing

      _parse_tree_via_string_expecting_success remove_instance_variable :@STRING
    end

    def _parse_tree_via_string_expecting_success string

      x = _lower_level_subject_magnetic.call_by do |o|

        o.listener = -> * do
          fail
        end

        o.string = string
      end
      x || fail
      x
    end

    # --

    def _lower_level_subject_magnetic
      Home_::CrazyTownMagnetics_::Selector_via_String::ParseTree_via_String
    end

    # ==
    # ==
  end
end
