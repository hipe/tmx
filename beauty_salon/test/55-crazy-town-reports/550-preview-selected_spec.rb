require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy town reports - preview selected', ct: true do

    TS_[ self ]
    use :memoizer_methods

    context 'weird name' do

      it 'says no' do
        _hi = _lines.first
        _hi == 'unrecognized grammar symbol "klass".' || fail
      end

      it 'offers suggestions' do
        _hi = _lines.last
        _hi == %q(did you mean 'class', 'sclass', 'case' or 'hash'?) || fail
      end

      shared_subject :_lines do
        _lines_of_parse_failure_by_call_subject_magnetic_by do |o|
          o.code_selector_string = %q{klass(aa=='bb')}
        end
      end
    end

    context 'name with no meta' do

      it 'says no' do
        _hi = _lines.first
        _hi == %q(currently we don't yet have metadata for grammar symbol 'nth_ref'.) || fail
      end

      it 'offers suggestions' do
        _hi = _lines.last
        _hi =~ /\A\(currently we have it for '[a-z]/ || fail
      end

      shared_subject :_lines do
        _lines_of_parse_failure_by_call_subject_magnetic_by do |o|
          o.code_selector_string = %q{nth_ref(aa=='bb')}
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
        _hi == %q(known component(s): 'method_name')
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

          o.file_path_upstream = Common_::Stream.via_item _path

          o.code_selector_string = %q{send(method_name=='<<')}

          o.filesystem = ::File
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
        yield o
      end

      _x && fail

      em_a = log.flush_to_array
      1 == em_a.length || fail
      em_a[0].expression_proc[ [] ]
    end

    -> do
      report_name = "preview-selected"
    define_method :_call_subject_magnetic_by do |&p|

      _subject_magnetic.call_by do |o|
        o.report_name = report_name
        o.filesystem = NOTHING_
        o.listener = nil
        p[ o ]
      end
    end
    end.call

    def _subject_magnetic
      Home_::CrazyTownMagnetics_::Result_via_ReportName_and_Arguments
    end

    # ==
    # ==
  end
end
