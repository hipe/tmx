require_relative '../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] models - mutator - parse args (unit test)" do

    extend TS_

    it "minimal no prefix" do

      func = subject.unmarshal_via_string_and_module(
        'remove-empty-actua',
        common_box_module )

      func.const_symbol.should eql(
        :Remove_empty_actual_properties )
    end

    it "minimal prefix" do

      func = subject.unmarshal 'mutator:split-and-pr'

      func.const_symbol.should eql :Split_and_promote_property

      func.category_symbol.should eql :mutator

      func.composition.args.should be_nil

    end

    it "minimal one arg" do

      subject.unmarshal_via_string_and_module(
        'remove-em( -12.3 )',
        common_box_module ).composition.args.should eql(
          [ -12.3 ] )
    end

    it "catalyst case" do

      subject.unmarshal_via_string_and_module(
       'remove-em( sophie\'s choice , dingo   , -8, , "," )',
       common_box_module ).composition.args.should eql(
        [ "sophie's choice", "dingo", -8, nil, "," ] )
    end

    def common_box_module
      Cull_::Models_::Mutator::Items__
    end

    def subject
      Cull_::Models_::Function_
    end
  end
end
