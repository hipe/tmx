require_relative '../../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] models - survey create" do

    Expect_event_[ self ]

    extend TS_

    it "loads" do

      Cull_::API

    end

    it "ping the top" do
      x = Cull_::API.call :ping, :on_event_selectively, handle_event_selectively
      expect_neutral_event :ping, "hello from cull."
      expect_no_more_events
      x.should eql :hello_from_cull
    end

    it "ping the model node" do
      call_API :survey, :ping
      expect_OK_event :ping, 'cull says (highlight "hello")'
      expect_no_more_events
      @result.should eql :_hi_again_
    end

    if false

    as :creating_done,
      %r{creating #{ PN_ } \.\. done \(\d\d bytes\)\.\z}i, :nonstyled

    it "from inside an empty directory, explains the situation" do

      from_inside_empty_directory do |d|

        invoke 'init'

        expect :creating_done

      end
    end

    as :exists,
      %r{\Awtvr init: exists, skipping - #{ PN_ }\z}, :nonstyled

    it "from inside a directory with a nerk, explains it all" do

      from_inside_a_directory_with( :some_config_file ) do

        invoke 'init'

        expect :exists

      end
    end
    end
  end
end
