# frozen_string_literal: true

require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy town reports - preview selected', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :my_reports

    context 'weird name' do

      it 'says no' do
        _hi = _lines.first
        _hi == 'unrecognized grammar symbol "kwoptarggo".' || fail
      end

      it 'offers suggestions' do

        # as long as this keeps chaning while we add classes during the
        # structured uber alles era (while open [#022.E2],
        # we don't care to cover this to a level of detail so tight that
        # the exact constituency is asserted. it is enough just to assert
        # that what is expressed looks right, roughly.

        _hi = _lines.last
        _rest = %r(\Adid you mean '(.+)'\?\z).match( _hi )[1]
        _these = _rest.split %r(', '|' or ')
        count = 0 ; strange = nil
        _these.each do |type_s|
          if type_s.include? 'arg'
            count += 1
          else
            ( strange ||= [] ).push type_s
          end
        end
        # -- the below changes as necessary
        2 == count || fail
        strange && fail
      end

      shared_subject :_lines do
        _lines_of_parse_failure_by_call_subject_magnetic_by do |o|
          o.code_selector_string = %q{kwoptarggo(aa=='bb')}
        end
      end
    end

    context 'bad component' do

      it 'says no' do
        _hi = _lines.first
        _hi == %q(grammar symbol 'send' has no component "method_namezz".) || fail
      end

      it 'offers suggestions' do
        _hi = _lines.last
        _hi == %q(the only known component: 'method_name') || fail
      end

      shared_subject :_lines do
        _lines_of_parse_failure_by_call_subject_magnetic_by do |o|
          o.code_selector_string = %q{send(method_namezz=='bb')}
        end
      end
    end

    # context "operator literal mismatch"..

    context 'wahoo jimmy jam this shammy' do

      it 'first line talkin bout dat file' do
        _first_line = _tuple.first
        _first_line =~ /\Afile: [^[:space:]]/ || fail
      end

      it 'middle lines talkin bout those matches' do

        # assert that there is more than one code line talked about
        # assert that at least one of the lines talks about more than one feature
        # assert that each line number is always greater than the previous line number

        middle_lines = _tuple[1]

        3 < middle_lines.length || fail

        seen_num_features = {}

        lowest_line = 0

        middle_lines.each do |line|

          md = /\A(?<num>\d+) feature( |s) on line[ ]+(?<lineno>\d+):[ ]+[^[:space:]]/.match line

          seen_num_features[ md[ :num ].to_i ] = nil

          lineno = md[ :lineno ].to_i

          lowest_line < lineno || fail
          lowest_line = lineno
        end

        1 < seen_num_features.length || fail
      end

      it 'last line talkin bout dat summary' do
        _last_line = _tuple.last
        _last_line =~ /\A# \(\d total match\(es\) in 1 file\(s\)\)\z/ || fail
      end

      shared_subject :_tuple do

        _path = TestSupport_::Fixtures.executable :for_simplecov

        st = _call_subject_magnetic_by do |o|

          o.argument_paths = [ _path ]

          o.code_selector_string = %q{send(method_name=='<<')}
        end

        first_line = st.gets
        middle_lines = st.to_a

        [ first_line, middle_lines, middle_lines.pop ]  # look
      end
    end

    def _lines_of_parse_failure_by_call_subject_magnetic_by

      log = Common_.test_support::Expect_Emission::Log.for self

      _x = _call_subject_magnetic_by do |o|
        o.listener = log.listener
        o.argument_paths = EMPTY_A_  # can be written with more stuff
        yield o
      end

      _x && fail

      em_a = log.flush_to_array
      1 == em_a.length || fail
      _expag = expression_agent
      _expag.calculate [], & em_a[0].expression_proc
    end

    def _call_subject_magnetic_by & p
      call_report_ p, :preview_selected
    end

    def expression_agent
      # (same as My_API -- .. -- .. -- )
      ::NoDependenciesZerk::API_InterfaceExpressionAgent.instance
    end

    # ==
    # ==
  end
end
