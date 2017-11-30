require_relative '../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] operations - mutator - parse args (unit test)", wip: true do

    TS_[ self ]

# (1/N)
    it "minimal no prefix" do

      func = subject.unmarshal_via_string_and_module(
        'remove-empty-actua',
        common_box_module )

      expect( func.const_symbol ).to eql(
        :Remove_empty_actual_properties )
    end

# (2/N)
    it "minimal prefix" do

      func = subject.unmarshal 'mutator:split-and-pr'

      expect( func.const_symbol ).to eql :Split_and_promote_property

      expect( func.category_symbol ).to eql :mutator

      expect( func.composition.args ).to be_nil

    end

# (3/N)
    it "minimal one arg" do

      expect( subject.unmarshal_via_string_and_module(
        'remove-em( -12.3 )',
        common_box_module ).composition.args ).to eql(
          [ -12.3 ] )
    end

# (4/N)
    it "catalyst case" do

      expect( subject.unmarshal_via_string_and_module(
       'remove-em( sophie\'s choice , dingo   , -8, , "," )',
       common_box_module ).composition.args ).to eql(
        [ "sophie's choice", "dingo", -8, nil, "," ] )
    end

    def common_box_module
      Home_::Models_::Mutator::Items__
    end

    def subject
      Home_::Models_::Function_
    end
  end
end
