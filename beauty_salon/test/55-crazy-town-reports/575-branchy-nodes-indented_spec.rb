# covers: crazy-town-magnetics-/node-processor-via-methods.rb
# frozen_string_literal: true

# (the above is :#depencency1.1)

require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy town reports - branchy nodes indented', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :my_reports

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
        _just_make_sure_this_runs '111-literals-and-assignments.rb'
      end

      it 'control flow' do
        _just_make_sure_this_runs '389-control-flow.rb'
      end

      it 'begin rescue end' do
        _just_make_sure_this_runs '500-expression-grouping.rb'
      end

      it 'method definitions and method calls' do
        _just_make_sure_this_runs '777-method-definitions-and-calls.rb'
      end

      it 'modules and classes' do
        _just_make_sure_this_runs '944-class-and-module-definition.rb'
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

        o.argument_paths = [ path ]
      end
    end

    def _call_subject_magnetic_by & p
      call_report_ p, :branchy_nodes_indented
    end

    # ==
    # ==
  end
end
# #born.
