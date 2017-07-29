require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - selector via string', ct: true do

    TS_[ self ]
    use :memoizer_methods

    it 'magnetic loads' do
      _lower_level_subject_magnetic || fail
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

      def _boolean_tests_array
        _parse_tree.AND_list_of_boolean_tests
      end

      shared_subject :_parse_tree do
        _parse_tree_via_string_expecting_success 'xx_yy(  qq_q== "ze ze" &&mm_m =="i\'m \\"OK\\"")'
      end
    end

    context 'error 1 - here' do

      it 'fails' do
        _fails
      end

      it 'this contextualized expression' do

        _actual = _expect_parse_error_and_give_lines

        expect_these_lines_in_array_ _actual do |y|
          y << 'expecting close parens:'
          y << '    xx_yy(  qq_q== "ze ze"  FOOFIE'
          y << '    ------------------------^'
        end
      end

      shared_subject :_tuple do
        _parse_expecting_failure 'xx_yy(  qq_q== "ze ze"  FOOFIE'
      end
    end

    context 'error 2 - this' do

      it 'fails' do
        _fails
      end

      it 'this contextualized expression' do

        _actual = _expect_parse_error_and_give_lines

        expect_these_lines_in_array_ _actual do |y|
          y << 'expecting end of string:'
          y << '    a(b=="c")  # wahoo'
          y << '    ---------^'
        end
      end

      shared_subject :_tuple do
        _parse_expecting_failure 'a(b=="c")  # wahoo'
      end
    end

    # ==

    context 'error 3 - like so' do

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

    context 'error 4 - watch me work this' do

      it 'fails' do
        _fails
      end

      it 'this contextualized expression' do

        _actual = _expect_parse_error_and_give_lines

        expect_these_lines_in_array_ _actual do |y|
          y << 'string is still open at end of input'
        end
      end

      shared_subject :_tuple do
        _parse_expecting_failure 'qq( xx == "yy'
      end
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

    def _parse_tree_via_string_expecting_success str
      _lower_level_subject_magnetic.call_by do |o|
        o.string = str
      end
    end

    def _lower_level_subject_magnetic
      Home_::CrazyTownMagnetics_::Selector_via_String::ParseTree_via_String
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

    # ==
    # ==
  end
end
