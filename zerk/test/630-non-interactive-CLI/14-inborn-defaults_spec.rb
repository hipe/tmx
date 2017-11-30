require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] niCLI - inborn defaults" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_want_section_coarse_parse

    it "specified as opts (several), overwrites the inborn default" do

      _be_this = output '(files: ["a1", "a2"])'

      expect( argv 'as-opts', '-f', 'a1', '-f', 'a2' ).to _be_this
    end

    it "but it non specified, inborn default is there" do

      expect( argv 'as-opts' ).to output '(files: ["~/defaulto"])'
    end

    # (originally we set out to try to achieve the optional glob argument,
    #  but decided that its expression of this as an option was acceptible.)

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_15_Inborn_Defaults ]
    end
  end
end
