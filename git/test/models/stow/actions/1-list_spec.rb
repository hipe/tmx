require_relative '../../../test-support'

module Skylab::Git::TestSupport

  describe "[gi] models - stow - actions - list" do

    extend TS_
    use :models_stow_support

    it "ping" do

      call_API :ping, :zerp, 'hi'

      _ev = expect_OK_event :ping

      black_and_white( _ev ).should eql "(out: hi)"

      expect_no_more_events

      @result.should eql :pingback_from_API
    end

    it "list stows against bad directory" do

      _against no_ent_path_

      _st = @result

      _x = _st.gets
      _x.should be_nil

      ev = expect_not_OK_event :errno_enoent
      ev = ev.to_event
      ev.message_head.should eql "No such file or directory"

      expect_no_more_events
    end

    it "list no stows (empty directory) - vanilla plain (no events)" do

      _against empty_dir_

      _st = @result
      _x = _st.gets
      _x.should be_nil

      expect_no_events
    end

    it "list 2 stows" do

      _against stashiz_path_

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

    def _against path

      call_API( :stow, :list,
        :stows_path, path,
        :filesystem, real_filesystem_,  # glob, directory?
      )
      NIL_
    end
  end
end