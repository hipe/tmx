require_relative 'test-support'

module Skylab::Headless::TestSupport::System::Services::Filesystem

  describe "[hl] system - services - filesystem - find" do

    it "minimal working example - find one file" do

      _cmd_s = parent_subject.find :path, TS_.dir_pathname.to_path,
        :filename, 'find_spec.*',
        :as_normal_value, -> command do
          command.string
        end

      _pretty_s = _cmd_s.sub %r((?<=\Afind )[^ ]+), 'ohai'

      _pretty_s.should eql 'find ohai \( -name find_spec.\* \)'
    end


    it "emits an informational event upon request" do
      ev = nil
      _cmd_o = parent_subject.find :path, 'doozie',
        :filename, '&![]',
        :on_event_selectively, -> i, *_, & ev_p do
          if :info == i
            ev = ev_p[]
          else
            raise ev.to_exception
          end
          :_no_see_
        end,
        :as_normal_value, -> cmd_o do
          cmd_o
        end

      _cmd_s = _cmd_o.string
      ev.command_string.should eql _cmd_s
    end

    def parent_subject
      Headless_.system.filesystem
    end
  end
end
