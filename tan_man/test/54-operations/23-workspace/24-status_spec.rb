require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] models workspace - `status`" do

    TS_[ self ]
    use :models

    it "dir w/o config file - is not failure, result is \"promise\"" do

      call_API :status, :path, dirs

      em = @result
      em.category.should eql [ :info, :resource_not_found ]

      _ev = em.emission_value_proc[]
      _ev and fail

      _em = expect_OK_event :resource_not_found
      _ev = _em.cached_event_value

      black_and_white( _ev ).should eql(
        '"tanman-workspace/config" not found in dirs' )

      expect_no_more_events
    end

    it "partay" do

      call_API :status, :path, dir( :with_freshly_initted_conf ),
        :config_filename, 'tan-man.conf'

      expect_no_events
      em = @result

      em.category.should eql [ :info, :resource_exists ]

      ev = em.emission_value_proc[]

      ev.terminal_channel_symbol.should eql :resource_exists

      _ = black_and_white( ev )

      _.should eql "resource exists - tan-man.conf"
    end
  end
end
# this line is for :+#posterity - "@todo waiting for permute [#056]"