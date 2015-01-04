require_relative '../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] models - mutator - parse args (unit test)" do

    extend TS_

    it "minimal no prefix" do

      f, = subject.func_and_args_via_call_expression_and_module(
        'remove-empty-actua',
        common_box_module )

      f.name.should eql "Remove_empty_actual_properties"
    end

    it "minimal prefix" do

      f, a, i = subject.func_and_args_and_category_via_call_expression(
        'mutator:split-and-pr' )

      f.name.should eql 'Split_and_promote_property'
      a.should be_nil
      i.should eql :mutator
    end

    it "minimal one arg" do

      f, a = subject.func_and_args_via_call_expression_and_module(
        'remove-em( -12.3 )',
        common_box_module )

      f.nil?.should eql false
      a.should eql [ -12.3 ]
    end

    it "catalyst case" do

      _, a = subject.func_and_args_via_call_expression_and_module(
        'remove-em( sophie\'s choice , dingo   , -8, , "," )',
        common_box_module )

      a.should eql [ "sophie's choice", "dingo", -8, nil, "," ]
    end

    def common_box_module
      Cull_::Models_::Mutator::Items__
    end

    def subject
      Cull_::Models_::Mutator
    end
  end
end
