# frozen_string_literal: true

require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town report magnetics - string via etc', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_structured_nodes

    context 'just as an exercise, try this' do

      it 'before node builds' do
        _structured_node_before || fail
      end

      it 'modded node builds' do
        structured_node_ || fail
      end

      it 'say hello to our little magnet friend' do
        subject_magnetic_ || fail
      end

      it 'the replacement lines preserve the indent present in the original document' do
        # #coverpoint3.2
        _thing_ding( 1 ) == 2 || fail
      end

      it 'the first line, however is not indented at all' do
        _thing_ding( 0 ) == 0 || fail
      end

      it 'the last lines does NOT have the trailing newline!' do
        _lines.fetch( 3 ) =~ /\bend\z/ || fail
      end

      it 'the replacements were made (byte-by-byte verification, too)' do

        want_these_lines_in_array_ _lines do |y|

          y << %r(\bmy_lvar = some_method_call  # lvasgn\b)
          y << "  if my_lvar  # conditional, lvar access\n"
          y << "    true  # literal\n"
          y << %r(\A  end$)
        end
      end

      def _thing_ding d
        _lines_ = _lines
        _line = _lines_.fetch d
        md = _line.match %r(\A[ ]+)
        if md
          beg, end_ = md.offset 0
          end_ - beg
        else
          0
        end
      end

      shared_subject :_lines do
        _build_lines
      end

      shared_subject :structured_node_ do

        _sn = _structured_node_before

        _sn2 = _dig_and_change_terminal(
          :zero_or_more_expressions,
          0,
          :lvar_as_symbol,
          :my_lvar,
          _sn,
        )

        _dig_and_change_terminal(
          :zero_or_more_expressions,
          1,
          :condition_expression,
          :symbol,
          :my_lvar,
          _sn2,
        )
      end

      shared_subject :_structured_node_before do
        structured_node_via_string_ <<~O
          # leftmost thing
            _my_lvar = some_method_call  # lvasgn
            if _my_lvar  # conditional, lvar access
              true  # literal
            end
        O
      end
    end

    context 'hello fellows - change a method name' do

      it 'the change effects' do
        structured_node_ || fail
      end

      it 'neat' do
        want_these_lines_in_array_ _build_lines do |y|
          y << "def dadunk foo, bar=nil, baz: nil\n"
          y << "  Const_CHANGED::Const2\n"
          y << 'end'
        end
      end

      shared_subject :structured_node_ do

        _sn = _structured_node_before

        _sn2 = _dig_and_change_terminal(
          :method_name,
          :dadunk,
          _sn,
        )

        _dig_and_change_terminal(
          :any_body_expression,
          :any_parent_const_expression,
          :symbol,
          :Const_CHANGED,
          _sn2,
        )
      end

      shared_subject :_structured_node_before do

        structured_node_via_string_ <<~O
          def chabunk foo, bar=nil, baz: nil
            Const1::Const2
          end
        O
      end
    end

    context 'literals 250 - the escaping hack - cha cha' do  # #coverpoint4.5

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << '"ernexpercted ergumernt \\"berta\\""'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          "ernexpercted ergumernt \\"berta\\""  # hi.
        O
      end
    end

    context 'literals 255 - same as above but for single quot' do  # #coverpoint4.6

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << "'ernexpercted ergumernt \\'berta\\''"
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          'ernexpercted ergumernt \\'berta\\''  # hi.
        O
      end
    end

    context 'literals 500 - double quote with a simple interpolation' do  # #coverpoint5.4

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << '"qux fif gobble: #{ nil }"'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          "qux fif gobble: \#{ nil }"
        O
      end
    end

    context 'literals 750 - literal array of strings' do  # #coverpoint4.3

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << 'frobulate %w(   uno  dos )'
        end
      end

      shared_subject :structured_node_ do

        # intentionally 3, then 2, then 1 meaningless spaces there

        structured_node_via_string_ <<~O
          frobulate %w(   uno  dos )  # hi.
        O
      end
    end

    context 'literals 813 - double-quoted string custom delim' do  # #coverpoint4.7

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << %[%(did'ya mean "foo"?)]
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          %(did'ya mean "foo"?)  # hi.
        O
      end
    end

    context 'literals 829 - double quotes with interpolation' do  # #coverpoint5.3

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << "s = nil\n"
          y << '"\"#{  s   }\""'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          s = nil
          "\\"\#{  s   }\\""
        O
      end
    end

    context '844 - heredocs' do  # #coverpoint5.1

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << "foo <<-HERE.length, 'ohai'\n"
          y << "  one\n"
          y << "  two\n"
          y << "HERE\n"
          y << "line_after"
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          foo <<-HERE.length, 'ohai'
            one
            two
          HERE
          line_after
        O
      end
    end

    context '875 - regexp' do  # #coverpoint4.4

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << '/\Achapo queepo\z/imx'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          /\\Achapo queepo\\z/imx  # no see.
        O
      end

      it 'check this (confirm regression ok)' do  # #coverpoint5.2
        same = '/\Achapo queepo\z/'
        _sn = structured_node_via_string_ same
        wat_s = _money_via _sn
        wat_s == same || fail
        wat_s.object_id == same.object_id && fail
      end
    end

    context '907 - regexp (minimal challenge mode)' do  # #coverpoint5.5

      # things to NOTE here. take for example the backslash newline
      #   - once it gets thru this file, it's 2 chars
      #   - in the xx

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << "_ = nil\n"
          y << '%r(\A#{ _ }\n)'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          _ = nil
          %r(\\A\#{ _ }\\n)
        O
      end
    end

    context '938 - regexp' do  # #coverpoint4.8

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << "_ = nil\n"
          y << '%r(\Aexpercting \{ #{ _ }(?: \| #{ _ }){4,} \}\z)'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          _ = nil
          %r(\\Aexpercting \\{ \#{ _ }(?: \\| \#{ _ }){4,} \\}\\z)
        O
      end
    end

    context 'variables coverage 250 (a regression)' do  # #coverpoint5.6

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << "-> wat do\n"
          y << 'end'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          -> wat do
          end
        O
      end
    end

    context 'variables coverage 375' do  # #coverpoint3.9

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << "frob do |em|\n"
          y << 'end'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          frob do |em|
          end
        O
      end
    end

    context 'variables coverage 500' do  # #coverpoint3.5

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << "def frob * args, & wee\n"
          y << "  @qq_qq = :xx\n"
          y << "  @xx_xx\n"
          y << 'end'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O

          def frob * args, & wee
            @qq_qq = :xx
            @xx_xx
          end
        O
      end
    end

    context 'control flow coverage 500' do

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << "if @xx\n"
          y << "  @yy if @qq\n"
          y << 'end'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          if @xx
            @yy if @qq
          end
        O
      end
    end

    context 'control flow coverage 750' do  # #coverpoint3.7

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << "go = -> ( (foo, bar) ) do\n"
          y << "end\n"
          y << "while go[]\n"
          y << "  hi\n"
          y << 'end'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          go = -> ( (foo, bar) ) do
          end
          while go[]
            hi
          end
        O
      end
    end

    context 'method call coverage 175 - brackets with args' do  # #coverpoint3.8

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << "md = nil\n"
          y << 'md[ :foo ]'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          md = nil
          md[ :foo ]
        O
      end
    end

    context 'method call coverage 250 - prefix operator' do  # #coverpoint3.4

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << 'map( & :wa_hoo )'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          map( & :wa_hoo )
        O
      end
    end

    context 'method call coverage 250 - infix operator' do  # #coverpoint3.6

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << "left_x = nil ; right_x = 3.33  # see\n"
          y << 'left_x == right_x || frob'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          left_x = nil ; right_x = 3.33  # see
          left_x == right_x || frob  # say
        O
      end
    end

    context 'method call coverage 500 - NOT ("!") as send' do  # #coverpoint3.3

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << "! @me"
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          ! @me  # no see
        O
      end
    end

    context 'method call coverage 750' do  # coverpoint3.5

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ _build_lines do |y|
          y << '@jim[ 33 ] = "hi"'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          @jim[ 33 ] = "hi"  # no see
        O
      end
    end

    def _build_lines
      _money.split %r(^)
    end

    def _money
      _sn = structured_node_
      _money_via _sn
    end

    def _money_via sn
      sn.to_code_LOSSLESS_EXPERIMENT__
    end

    def _dig_and_change_terminal * x_a, sn
      sn.DIG_AND_CHANGE_TERMINAL( * x_a )
    end

    def subject_magnetic_
      Home_::CrazyTownReportMagnetics_::String_via_StructuredNode
    end
  end
end
# #born.
