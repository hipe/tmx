require_relative '../../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] models - font - list" do

    extend TS_
    use :sandboxed_kernels

    context "(some context)" do

      it "the operation produces a stream that produces strings" do

        @subject_kernel_ = new_mutable_kernel_with_appearance_ appearance_JSON_one_

        call_ :background_font, :list

        st = @result

        x = st.gets

        x.respond_to?( :ascii_only? ) or fail

        # why be more stringent -- etc
      end

      attr_reader :subject_kernel_
    end
  end
end
