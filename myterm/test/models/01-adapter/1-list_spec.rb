require_relative '../../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] models - adapter - list" do

    TS_[ self ]
    use :my_API

    context "ask what the adapter is when no adapter is activated" do

      call_by do
        call :adapter
      end

      it "result is effectively unknown (but qualified)" do

        qk = root_ACS_result
        qk.is_known_known or fail
        qk.name.as_variegated_symbol.should eql :adapter
        qk.value_x.should be_nil
      end

      def event_log
        NONE_
      end
    end

    context "list the adapters" do

      call_by do
        call :adapters, :list
      end

      shared_subject :_custom_state do

        _st = root_ACS_result
        __call_this_one_time_only _st
      end

      it "works" do
        _custom_state.found or fail
      end

      it "lists one adapter" do
        _custom_state.count.should eql 1
      end

      def event_log
        NIL_
      end
    end

    define_method :__call_this_one_time_only do |st| # (avoid warnings re: consts)

      count = 0
      target = 'imagemagick.rb'

      begin
        o = st.gets
        o or break
        count += 1
        if target == ::File.basename( o.path )
          found = true
          break
        end
        redo
      end while nil

      if found
        while st.gets
          count += 1
        end
      end

      ADA_List_State = ::Struct.new :found, :count
      ADA_List_State.new found, count
    end
  end
end
