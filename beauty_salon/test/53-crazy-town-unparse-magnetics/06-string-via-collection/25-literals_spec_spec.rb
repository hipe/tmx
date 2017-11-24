# frozen_string_literal: true

require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town unparse magnetics - ', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_unparsing

    it 'symbols fancy (125)' do  # #covertpoint6.6
      same = %q(:"foo_Bar baz 123")
      _sn = structured_node_via_string_ same
      _have = to_code_losslessly_ _sn
      _have == same || fail
    end

    context 'literals 250 - the escaping hack - cha cha' do  # #coverpoint4.5

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ build_lines_ do |y|
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
        want_these_lines_in_array_ build_lines_ do |y|
          y << "'ernexpercted ergumernt \\'berta\\''"
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          'ernexpercted ergumernt \\'berta\\''  # hi.
        O
      end
    end

    it '(regression) SINGLE QUOTE ESCAPING GETS SMART (378)' do
      # same = '"\"\n"'
      same = %q('"\"\n"')

      _sn = structured_node_via_string_ same
      _have = to_code_losslessly_ _sn
      _have == same || fail
    end

    context 'literals 500 - double quote with a simple interpolation' do  # #coverpoint5.4

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ build_lines_ do |y|
          y << '"qux fif gobble: #{ nil }"'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          "qux fif gobble: \#{ nil }"
        O
      end
    end

    it 'symbol list (625)' do  # #coverpoint6.5

      same = '%i@  foo   bar    @'
      _sn = structured_node_via_string_ same
      _have = to_code_losslessly_ _sn
      _have == same || fail
    end

    context 'literals 750 - literal array of strings ("word list")' do  # #coverpoint4.3

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ build_lines_ do |y|
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
        want_these_lines_in_array_ build_lines_ do |y|
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
        want_these_lines_in_array_ build_lines_ do |y|
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

    context '875 - regexp' do  # #coverpoint4.4

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ build_lines_ do |y|
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
        wat_s = to_code_losslessly_ _sn
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
        want_these_lines_in_array_ build_lines_ do |y|
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
        want_these_lines_in_array_ build_lines_ do |y|
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

    context 'literals 969 - array (ideal)' do

      it 'builds' do
        structured_node_ || fail
      end

      it 'unparses' do
        want_these_lines_in_array_ build_lines_ do |y|
          y << '[ 1  ,   2    ,     3      ]'
        end
      end

      shared_subject :structured_node_ do

        structured_node_via_string_ <<~O
          [ 1  ,   2    ,     3      ]
        O
      end
    end

    it 'hash - this one' do  # #coverpoint6.3 (see)

      same = 'frob a: :A, b: :B'
      _sn = structured_node_via_string_ same
      _have = to_code_losslessly_ _sn
      _have == same || fail
    end

  end
end
# #extracted.
