require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - selector via string', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_PARSY_TOWN

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
          y << %q(expecting '==' or '=~' or close parenthesis:)
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
          y << %q(expecting '==' or '=~':)
          y << '  foo( jamma'
          y << '  ----------^'
        end
      end

      it 'boolean operator midway through (WILL EXPAND)' do

        _against 'foo( jamma ='
        _fails_with_these_normal_lines do |y|
          y << %q(expecting '=' or '~':)
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

      it %q(you can't do matchy with a string) do

        _against %q(foo(jam =~ 'xx'))
        _fails_with_these_normal_lines do |y|
          y << %q(expecting open forward slash:)
          y << %q(  foo(jam =~ 'xx'))
          y << %q(  -----------^)
        end
      end
    end

    context 'parse tree - with just one test component - a literal value test' do

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

    context 'parse tree - with just one test component - a regexp test' do

      it 'parses' do
        _parse_tree || fail
      end

      it 'knows the name of the feature symbol' do
        _pt = _parse_tree
        _pt.feature_symbol == :zz_xx || fail
      end

      it 'knows there is one boolean test' do
        _boolean_tests_array.length == 1 || fail
      end

      it 'the boolean tests knows its left had side' do
        _sym = _the_only_test.symbol_symbol
        _sym == :mammer || fail
      end

      it 'knows its comparison function name symbol' do
        _sym = _the_only_test.comparison_function_name_symbol
        _sym == :_RX_ || fail
      end

      it 'knows its literal string (CAPTURE BROKEN CASE)' do
        _s = _the_only_test.regexp_body_string
        _s == 'A[a-z]' || fail
      end

      def _the_only_test
        _boolean_tests_array.first
      end

      shared_subject :_parse_tree do
        _parse_tree_via_string_expecting_success %q{zz_xx( mammer =~ /\\A[a-z]/ )}
      end
    end

    context 'parse tree - model case' do

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

      it 'knows that the list of tests is AND vs OR' do
        _parse_tree.list_is_AND_list_not_OR_list == true || fail
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

        _parse_tree_via_string_expecting_success(
          %q{xx_yy(  qq_q== 'ze ze' &&mm_m =='i\\'m "OK"')}
        )
      end
    end

    # --

    def _boolean_tests_array
      _parse_tree.list_of_boolean_tests
    end

    # --

    def _produces_parse_tree_while_emitting_nothing

      expect_success_against_ remove_instance_variable :@STRING
    end

    def _against s
      @STRING = s
    end

    alias_method :_fails_with_these_normal_lines, :fails_with_these_normal_lines_

    alias_method :_parse_tree_via_string_expecting_success, :expect_success_against_

    # --

    def _lower_level_subject_magnetic
      main_magnetics_::Selector_via_String::ParseTree_via_String
    end

    alias_method :parsy_subject_magnetic_, :_lower_level_subject_magnetic

    # ==
    # ==
  end
end
# #history-A.2: finished removing pre-ragel tests
