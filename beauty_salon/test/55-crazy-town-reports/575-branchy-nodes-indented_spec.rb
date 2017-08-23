# covers: crazy-town-magnetics-/node-processor-via-methods.rb

# (the above is :#depencency1.1)

require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy town reports - branchy nodes indented', ct: true do

    TS_[ self ]
    use :memoizer_methods

    # -

    context '(detailed case)' do

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

        st = _line_stream_for_path _path

        first_line = st.gets
        _the_rest = st.to_a
        [ first_line, _the_rest ]
      end
    end

    context '(coverage)' do

      it 'literals and assignment' do
        _just_make_sure_this_runs '083-literals-and-assignment.rb'
      end

      it 'control flow' do
        _just_make_sure_this_runs '250-control-flow.rb'
      end

      it 'begin rescue end' do
        _just_make_sure_this_runs '417-begin-rescue-end.rb'
      end

      it 'method definitions and method calls' do
        _just_make_sure_this_runs '583-method-definitions-and-method-calls.rb'
      end

      it 'modules and classes' do
        _just_make_sure_this_runs '750-modules-and-classes.rb'
      end

      it 'special and edge' do
        _just_make_sure_this_runs '917-special-and-edge.rb'
      end
    end

    def _just_make_sure_this_runs tail
      _path = fixture_file_ruby_MRI_ tail
      st = _line_stream_for_path _path
      if do_debug
        io = debug_IO
        line = st.gets
        begin
          io.puts "wee: #{ line.inspect }"
        end while line=st.gets
      else
        line = st.gets
        line || fail  # at least one line
        nil while line = st.gets
      end
    end

    def fixture_file_ruby_MRI_ tail
      ::File.join TS_.dir_path, 'fixture-files', 'ruby-current-version', tail
    end

    def _line_stream_for_path path

      _call_subject_magnetic_by do |o|

        o.file_path_upstream = Common_::Stream.via_item path

        o.filesystem = ::File
      end
    end

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
