require_relative '../../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] models - font - list" do

    extend TS_
    use :sandboxed_kernels

    context "(some context)" do

      it "the operation produces a stream that produces font objects" do

        @subject_kernel_ = new_mutable_kernel_with_appearance_ appearance_JSON_one_

        call_ :background_font, :list

        st = @result

        x = st.gets

        x.to_primitive_for_component_serialization or fail  # eew

        # (we need something that exerts font shape, but there is very little)

      end

      attr_reader :subject_kernel_
    end
  end
end
