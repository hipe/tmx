require_relative '../../../test-support'

module Skylab::Git::TestSupport

  describe "[gi] models - stow - actions - list" do

    extend TS_
    use :models_stow_support

    it "ping" do

      call_API :ping, :zip, 'hi'

      _ev = expect_OK_event :ping

      black_and_white( _ev ).should eql "(out: hi)"

      expect_no_more_events

      @result.should eql :pingback_from_API
    end

    it "list stows against bad directory (no event until unwind)" do

      call_API :stow, :list, :stashes_path,
        TestSupport_::Data::Universal_Fixtures[ :not_here ]

      _st = @result

      _x = _st.gets
      _x.should be_nil

      ev = expect_not_OK_event :errno_enoent
      ev = ev.to_event
      ev.message_head.should eql "No such file or directory"

      expect_no_more_events
    end

    it "list no stows (empty directory) - vanilla plain (no events)" do

      call_API :stow, :list, :stashes_path,
        TestSupport_::Data::Universal_Fixtures[ :empty_esque_directory ]

      _st = @result
      _x = _st.gets
      _x.should be_nil

      expect_no_events
    end

    it "list 2 stows" do

      call_API :stow, :list, :stashes_path, stashiz_path_

      st = @result
      stow = st.gets
      oid = stow.object_id

      ::File.basename( stow.path ).should eql 'alpha'

      stow = st.gets

      ::File.basename( stow.path ).should eql 'beta'
      stow.object_id.should eql oid

      st.gets.should be_nil
      expect_no_events
    end
  end
end
