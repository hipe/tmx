require_relative '../../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] operations - map - basics" do

    TS_[ self ]
    use :operations_map

    context "no args - explains" do

      call_by do
        call
      end

      it "explains saying \"expected FOO or BAR\"" do
        _matchdata or fail
      end

      it "list of what is expected is unique" do
        these = _matchdata[1].split " or "
        _these_ = these.uniq
        these == _these_ || fail
      end

      shared_subject :_matchdata do
        _lines = expect_parse_error_emission_lines_ :missing_required_argument
        _rx = /\Aexpecting (:[a-z_]+(?:(?: or |, ):[a-z_]+)*)\z/
        _rx.match _lines.fetch 0
      end
    end

    context "strange arg - tmx turned off for now.." do

      call_by do
        call :zingo
      end

      it "fails" do
        _lines
      end

      it "explains" do
        _lines.first == "unknown operation :zingo" || fail
      end

      it "offers alternatives" do
        _lines.last =~ /\Aavailable operations: .*\bmap\b/ || fail
      end

      shared_subject :_lines do
        expect_parse_error_emission_lines_ :unknown_primary
      end
    end

    context "bad primary" do

      # :#coverpoint-1-E

      call_by do
        ignore_common_post_operation_emissions_
        call :map, :zoingo
      end

      it "fails" do
        _lines
      end

      it "explains" do
        _lines.first == "unknown primary :zoingo" || fail
      end

      it "offers alternatives" do
        _lines.last =~ /\Aexpecting :[a-z_]+(?: or :[a-z_]+)*\z/ || fail
      end

      shared_subject :_lines do
        lines_via_this_kind_of_failure(
          :error, :expression, :parse_error, :unknown_primary )
      end
    end

    context "missing required primary (for now)" do

      call_by do
        ignore_common_post_operation_emissions_
        call :map
      end

      it "fails" do
        _line
      end

      it "explains" do
        _line == "unparsed node stream was not resolved. (use :json_file_stream.)" || fail
      end

      shared_subject :_line do

        only_line_via_this_kind_of_failure(
          :error, :expression, :parse_error, :missing_required_arguments )
      end
    end

    context "no modifiers (except..) - just straight stream of unparsed nodes" do

      call_by do

        ignore_common_post_operation_emissions_

        call :map, :json_file_stream, json_file_stream_01_
      end

      it "you can get the name of the node (order is system order)" do

        _no = _first_node
        _s = _no.get_filesystem_directory_entry_string
        _s == 'zagnut' || fail
      end

      it "there's more than one" do
        _one_two.last.get_filesystem_directory_entry_string || 'frim_frum' || fail
      end

      def _first_node
        _one_two.first
      end

      shared_subject :_one_two do
        st = send_subject_call
        [ st.gets, st.gets ]
      end
    end
  end
end
