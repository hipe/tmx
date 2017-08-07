require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy town reports - preview selected', ct: true, wip: true do

    TS_[ self ]
    use :memoizer_methods

    context 'weird name' do

      it 'says no' do
        _hi = _lines.first
        _hi == 'unrecognized grammar symbol "klass".' || fail
      end

      it 'offers suggestions' do
        _hi = _lines.last
        _hi == %q(did you mean 'class', 'sclass', 'case' or 'lasgn'?) || fail
      end

      shared_subject :_lines do
        _lines_of_parse_failure_by_call_subject_magnetic_by do |o|
          o.code_selector_string = 'klass(aa=="bb")'
        end
      end
    end

    context 'name with no meta' do

      it 'says no' do
        _hi = _lines.first
        _hi == %q(currently we don't yet have metadata for grammar symbol 'colon2'.) || fail
      end

      it 'offers suggestions' do
        _hi = _lines.last
        _hi =~ /\A\(currently we have it for '[a-z]/ || fail
      end

      shared_subject :_lines do
        _lines_of_parse_failure_by_call_subject_magnetic_by do |o|
          o.code_selector_string = 'colon2(aa=="bb")'
        end
      end
    end

    context 'bad component' do

      it 'says no' do
        _hi = _lines.first
        _hi == %q(grammar symbol 'call' has no component "method_namezz".) || fail
      end

      it 'offers suggestions' do
        _hi = _lines.last
        _hi == %q(known component(s): 'method_name')
      end

      shared_subject :_lines do
        _lines_of_parse_failure_by_call_subject_magnetic_by do |o|
          o.code_selector_string = 'call(method_namezz=="bb")'
        end
      end
    end

    # context "operator literal mismatch"..

      it 'x.' do

        _path = TestSupport_::Fixtures.executable :for_simplecov

        _st = _call_subject_magnetic_by do |o|

          o.file_path_upstream = Common_::Stream.via_item _path

          o.code_selector_string = 'call(method_name=="<<")'

          o.filesystem = ::File
        end

        puts _st.gets.inspect
        puts _st.gets.inspect
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
