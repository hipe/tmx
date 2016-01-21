require_relative '../../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] models - adapter - list", wip: true do

    extend TS_
    use :sandboxed_kernels

    it "the list produces one particular adapter" do

      _real_list_summary.found or fail
    end

    it "for now, there is only one adapter" do

      _real_list_summary.count.should eql 1
    end

    it "the selected adapter is indicated" do

      @subject_kernel_ = new_mutable_kernel_with_appearance_ appearance_JSON_one_

      call_ :adapter, :list

      st = @result
      begin
        ada = st.gets
        ada or break
        ada.is_selected and break
        redo
      end while nil

      ada.adapter_name.as_slug.should eql 'imagemagick'
    end

    dangerous_memoize_ :_real_list_summary do

      @subject_kernel_ = new_mutable_kernel_with_nothing_persisted_

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

      ADA_List_State = ::Struct.new :found, :count, :target
      ADA_List_State.new found, count, target
    end

    attr_reader :subject_kernel_

  end
end
