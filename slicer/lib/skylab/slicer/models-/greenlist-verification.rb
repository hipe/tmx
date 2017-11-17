module Skylab::Slicer

  module Models_::Greenlist_Verification

    Actions = ::Module.new

    class Actions::Verify_Greenlist < Action_

      @is_promoted = true

      @instance_description_proc = -> y do
        y << "(currently defunct but we will bring it back!)"
      end

      def produce_result

        self._NOT_USED_probably

        _path = ::File.expand_path '../../GREENLIST', ::Skylab.dir_path

        io = ::File.open _path

        bx = Common_::Box.new
        rx = /[[:space:]]+/
        begin
          line = io.gets
          line or break
          line.chomp!
          line.split( rx ).each do | s |
            bx.add s, true
          end
          redo
        end while nil

        _tv = Home_::Sessions_::Traversal.new
        st = _tv.to_sidesystem_stream

        _TEST_DIR = 'test'

        ok_count = 0

        p = -> do

          begin
            ss = st.gets
            if ss
              path = ::File.join ss.norm, _TEST_DIR
              if ::File.directory? path
                if bx.has_key ss.entry_string
                  bx.remove ss.entry_string
                  ok_count += 1
                  redo
                end
                x = "on filesystem but not in greenlist: #{ path }"
                break
              end
              redo
            end
            p = EMPTY_P_
            x = if bx.length.zero?
              @listener.call :info, :expression, :all_OK do | y |
                y << "(all #{ ok_count } OK in greenlist)"
              end
            else
              @listener.call :error, :expression, :extra do | y |
                y << "in greenlist but not on filesystem: (#{ bx.a_ * ', ' })"
              end
            end
            break
          end while nil
          x
        end

        Common_.stream do
          p[]
        end
      end
    end

    EMPTY_P_ = -> {}
  end
end
