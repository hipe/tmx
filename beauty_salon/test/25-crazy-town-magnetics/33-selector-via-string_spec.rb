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

      it 'after open paren, expects something (WILL EXPAND)' do

        _against 'foo('
        _fails_with_these_normal_lines do |y|
          y << 'expecting true keyword:'
          y << '  foo('
          y << '  ----^'
        end
      end

      it 'identifier, open paren, true keyword - expects close paren (WILL EXPAND)' do

        _against 'foo( true '
        _fails_with_these_normal_lines do |y|
          y << 'expecting close parenthesis:'
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

      def _boolean_tests_array
        _parse_tree.AND_list_of_boolean_tests
      end

      shared_subject :_parse_tree do
        _parse_tree_via_string_expecting_success 'xx_yy(  qq_q== "ze ze" &&mm_m =="i\'m \\"OK\\"")'
      end
    end

    context 'error 1 - here', wip: true do

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

    context 'error 2 - this', wip: true do

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

    context 'error 3 - like so', wip: true do

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

    context 'error 4 - watch me work this', wip: true do

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

      x = _lower_level_subject_magnetic.call_by do |o|

        o.listener = -> * do
          fail
        end

        o.string = remove_instance_variable :@STRING
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
