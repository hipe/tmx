require_relative '../../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] operations - map - basics" do

    TS_[ self ]
    use :memoizer_methods
    use :operations

    context "no args - explains" do

      call_by do
        call
      end

      it "fails" do
        fails
      end

      it "explains" do

        em = only_emission
        em.channel_symbol_array[ 2 ] == :parse_error || fail
        _act = em.express_into_under "", expag_
        _act == "expecting { :map or :blah }" || fail
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
        em = only_emission
        em.channel_symbol_array[ 2 ] == :parse_error || fail
        _act = em.express_into_under [], expag_
        _act.first.include? "currently, normal tmx is deacti" or fail
      end
    end

    context "no modifiers - just straight stream of unparsed nodes" do

      call_by do
        call :map
      end

      expect_no_events

      it "you can get the name of the node" do

        _no = _first_node
        _s = _no.get_filesystem_directory_entry_string
        _s =~ /\A[a-z]{3,}(?:_[a-z]+)*\z/ || fail
      end

      it "there's more than one" do
        _one_two.last || fail
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
