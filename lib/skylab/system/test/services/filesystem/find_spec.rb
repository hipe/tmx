require_relative '../../test-support'

module Skylab::System::TestSupport

  describe "[sy] - services - filesystem - find" do

    extend TS_

    it "minimal working example - find one file" do

      args = _parent_subject.find :path, TS_.dir_pathname.to_path,
        :filename, 'find_spec.*',
        :as_normal_value, -> command do
          command.args
        end

      [ * args[ 0, 2 ], 'XX', * args[ 3..-1 ] ].should eql(
        %w'find -f XX -- ( -name find_spec.* )' )
    end

    it "emits an informational event upon request" do

      ev = nil

      _cmd_o = _parent_subject.find(
        :path, 'doozie',
        :filename, '&![]',
        :as_normal_value, -> cmd_o do
          cmd_o
        end ) do | i, *_, & ev_p |
          if :info == i
            ev = ev_p[]
          else
            raise ev.to_exception
          end
          :_no_see_
        end

      ev.find_command_args.should eql _cmd_o.args
    end

    def _parent_subject
      services_.filesystem
    end
  end
end
