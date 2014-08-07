require_relative 'test-support'

module Skylab::Brazen::TestSupport::Data_Stores_::Git_Config

  describe "[br] data stores: git config" do

    it "the empty string parses" do
      expect_no_sections_from EMPTY_S_
    end

    it "one space parses" do
      expect_no_sections_from SPACE_
    end

    def expect_no_sections_from str
      conf = Subject_[].parse_string str
      conf.sections.length.should be_zero
    end

    it "some comments and one section parses" do
      with <<-HERE.gsub! MARGIN_RX__, EMPTY_S_

        # it's time
        [scton]

           ; wazoozle
      HERE
      expect_config do |conf|
        conf.sections.length.should eql 1
        conf.sections.first.normalized_name_i.should eql :scton
      end
    end

    it "the subsection name parses" do
      with '[ -.secto-2014.08 "foo \\" \\\\ " ]'
      expect_config do |conf|
        sect = conf.sections.first
        sect.name_s.should eql '-.secto-2014.08'
        sect.subsect_name_s.should eql 'foo " \\ '
      end
    end

    it "two section names parse" do
      with <<-HERE.gsub! MARGIN_RX__, EMPTY_S_
        [ wiz "waz" ]
        [WiZ]
      HERE
      expect_config do |conf|
        conf.sections.map { |x| x.normalized_name_i }.should eql [ :wiz, :wiz ]
      end
    end

    def with s
      @input_string = s ; nil
    end

    def expect_config & p
      conf = Subject_[].parse_string @input_string
      if conf
        block_given? ? yield( conf ) : conf
      else
        fail "expected config to parse, did not."
      end
    end

    MARGIN_RX__ = /^[ ]{8}/
  end
end
