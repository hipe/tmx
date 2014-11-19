require_relative '../test-support'

module Skylab::Brazen::TestSupport::Data_Stores::Git_Config::Mutable

  describe "[br] data stores: git config mutable integration" do

    extend TS_

    TestLib_::Expect_Event[ self ]

    with_a_document_with_a_section_called_foo

    it "add a variable with an invalid name - it's not atomic" do
      sect = touch_section 'wizzie'
      _x = sect[ :fum_fum ] = 'he he'
      expect_document_content "[foo]\n[wizzie]\n"
      _x.should eql 'he he'
      expect_one_event :invalid_variable_name do |ev|
        ev.invalid_variable_name.should eql 'fum_fum'
      end
    end

    it "add a variable with a valid name" do
      sect = touch_section 'wizzie'
      _x = sect[ :'fum-fum' ] = 'he he'
      expect_document_content "[foo]\n[wizzie]\nfum-fum = he he\n"
      _x.should eql 'he he'
      expect_one_event :added_value do |ev|
        ev.new_assignment.external_normal_name_symbol.should eql :fum_fum
        ev.new_assignment.value_x.should eql 'he he'
      end
    end
  end
end
