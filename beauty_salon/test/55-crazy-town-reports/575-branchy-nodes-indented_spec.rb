require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy town reports - branchy nodes indented', ct: true do

    TS_[ self ]
    use :memoizer_methods

    # -

      it 'first line is indented with no margin, and is file' do
        _tuple.first =~ /\Afile: [^[:space:]]/ || fail
      end

      it 'these exact lines' do
        _lines = _tuple.last
        expect_these_lines_in_array_ _lines do |y|
          y << '  module: Skylab'
          y << '    class: SimpleCov'
          y << '  module: Skylab::SimpleCov::TestSupport'
          y << '    module: Run_Me'
          y << '      def: blizzo'
          y << '      def: usage'
        end
      end

      shared_subject :_tuple do

        _path = TestSupport_::Fixtures.executable :for_simplecov

        st = _call_subject_magnetic_by do |o|

          o.file_path_upstream = Common_::Stream.via_item _path

          o.filesystem = ::File
        end

        first_line = st.gets
        _the_rest = st.to_a
        [ first_line, _the_rest ]
      end
    # -

    -> do
      report_name = "branchy-nodes-indented"
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
# #born.
