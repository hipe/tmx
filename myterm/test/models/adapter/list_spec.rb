require_relative '../../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] models - adapter" do

    extend TS_
    use :danger_memo
    use :future_expect


    it "the list produces one particular adapter" do

      _list.found or fail
    end

    it "for now, there is only one adapter" do

      _list.count.should eql 1
    end

    dangerous_memoize_ :_list do

      call_ :adapter, :list

      count = 0
      st = @result
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

      ADA_Listing_Data = ::Struct.new :found, :count, :target
      ADA_Listing_Data.new found, count, target
    end
  end
end
