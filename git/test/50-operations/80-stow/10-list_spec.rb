require_relative '../../test-support'

module Skylab::Git::TestSupport

  describe "[gi] operations - stow - list" do

    TS_[ self ]
    use :stow

    it "ping" do

      call_API(
        :stow, :ping,
        :zerp, 'hi',
      )

      actual_lines = nil
      want_emission :payload, :expression, :ping do |y|
        actual_lines = y
      end

      actual_lines == [ "(out: hi)" ] || fail

      want_no_more_events

      expect( @result ).to eql :pingback_from_API
    end

    it "list stows against bad directory" do

      _against no_ent_path_

      _st = @result

      _x = _st.gets
      expect( _x ).to be_nil

      _em = want_not_OK_event :enoent

      ev = _em.cached_event_value.to_event

      expect( ev.message_head ).to eql "No such file or directory"

      want_no_more_events
    end

    it "list no stows (empty directory) - vanilla plain (no events)" do

      _against empty_dir_

      _st = @result
      _x = _st.gets
      expect( _x ).to be_nil

      want_no_events
    end

    it "list 2 stows" do

      _against stashiz_path_

      st = @result
      stow = st.gets
      oid = stow.object_id

      expect( ::File.basename( stow.path ) ).to eql 'alpha'

      stow = st.gets

      expect( ::File.basename( stow.path ) ).to eql 'beta'
      expect( stow.object_id ).to eql oid

      expect( st.gets ).to be_nil
      want_no_events
    end

    def _against path

      call_API( :stow, :list,
        :stows_path, path,
      )
      NIL_
    end
  end
end
