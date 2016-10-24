require_relative '../../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] operations - map - basics" do

    TS_[ self ]
    use :operations_map

    context "no args - explains" do

      call_by do
        call
      end

      it "fails" do
        fails
      end

      it "explains" do

        em = expect_parse_error_emission_
        _act = em.express_into_under "", expag_
        _act == "expecting :map" || fail
      end
    end

    context "strange arg - tmx turned off for now.." do

      call_by do
        call :zingo
      end

      it "fails" do
        fails
      end

      it "explains" do

        em = expect_parse_error_emission_
        _act = em.express_into_under [], expag_
        _act.first.include? "currently, \"map\" is the only operation" or fail
      end
    end

    context "bad primary" do

      call_by do
        call :map, :zoingo
      end

      it "fails" do
        fails
      end

      it "explains" do
        _lines.first == "unrecognized primary :zoingo" || fail
      end

      it "offers alternatives" do
        _lines.last =~ /\Aexpecting :[a-z_]+(?: or :[a-z_]+)*\z/ || fail
      end

      shared_subject :_lines do
        _em = expect_parse_error_emission_
        _em.express_into_under [], expag_
      end
    end

    context "missing required primary (for now)" do

      call_by do
        call :map
      end

      it "fails" do
        fails
      end

      it "explains" do
        em = expect_parse_error_emission_
        _act = em.express_into_under "", expag_
        _act == "unparsed node stream was not resolved. (use :json_file_stream.)" || fail
      end
    end

    context "no modifiers (except..) - just straight stream of unparsed nodes" do

      call_by do
        call :map, :json_file_stream, json_file_stream_01_
      end

      expect_no_events

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

        _tu = operations_call_result_tuple
        st = _tu.result
        [ st.gets, st.gets ]
      end
    end
  end
end
