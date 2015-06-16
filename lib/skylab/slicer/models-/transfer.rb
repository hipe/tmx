module Skylab::Slicer

  module Models_::Transfer

    Actions = ::Module.new

    class Action__ < Brazen_::Action
      Brazen_::Model::Entity.call self
    end

    class Actions::Ping < Action__

      @is_promoted = true

      def produce_result

        @on_event_selectively.call :info, :expression do | y |
          y << "hello from slicer."
        end
        :hello_from_slicer
      end
    end

    class Actions::Verify_Greenlist < Action__

      @is_promoted = true

      def produce_result

        io = ::File.open(
          ::Skylab.dir_pathname.join( '../../GREENLIST' ).to_path )

        bx = Callback_::Box.new
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

        _tv = Slicer_::Sessions_::Traversal.new
        st = _tv.to_sidesystem_stream

        _TEST_DIR = 'test'

        ok_count = 0

        p = -> do

          begin
            ss = st.gets
            if ss
              path = ::File.join ss.norm, _TEST_DIR
              if ::File.directory? path
                if bx.has_name ss.stem
                  bx.remove ss.stem
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
              @on_event_selectively.call :info, :expression, :all_OK do | y |
                y << "(all #{ ok_count } OK in greenlist)"
              end
            else
              @on_event_selectively.call :error, :expression, :extra do | y |
                y << "in greenlist but not on filesystem: (#{ bx.a_ * ', ' })"
              end
            end
            break
          end while nil
          x
        end

        Callback_.stream do
          p[]
        end
      end
    end

    EMPTY_P_ = -> {}
  end
end
