module Skylab::TestSupport

  class Servers::Static_File_Server

    class Rainbow_Kick___  # as [#gv-021]

      def initialize & p
        @_oes_p = p
      end

      attr_writer(
        :doc_root,
        :filesystem,
        :PID_path,
        :port,
      )

      def execute

        __first_look
        ok = __resolve_rack_app
        ok &&= __resolve_rack_handler
        ok && __last_look
        ok && __fork
      end

      def __first_look
        @filesystem or self._SANITY
        @PID_path or self._SANITY
        @port or self._SANITY
        NIL_
      end

      def __resolve_rack_app

        Home_::Library_.touch :Adsf, :Rack

        doc_root = @doc_root

        _builder = ::Rack::Builder.new do
          use ::Rack::CommonLogger
          use ::Rack::ShowExceptions
          use ::Rack::Lint
          use ::Adsf::Rack::IndexFileFinder, root: doc_root
          run ::Rack::File.new doc_root
        end

        x = _builder.to_app
        if x
          @_rack_app = x
          ACHIEVED_
        else
          UNABLE_
        end
      end

      def __resolve_rack_handler

        # @_rack_handler = ::Rack::Handler::Mongrel  #(we used to rescue load error)
        # ::Rack::Handler.get

        @_rack_handler = ::Rack::Handler::WEBrick

        ACHIEVED_
      end

      def __last_look

        @_rack_app or self._SANITY
        @_rack_handler or self._SANITY
        NIL_
      end

      def __fork

        child_PID = fork
        if child_PID
          @_child_PID = child_PID
          __when_parent
        else
          __when_child
        end
      end

      def __when_parent

        child_PID = @_child_PID
        d = nil
        path = @PID_path

        @filesystem.open path, ::File::WRONLY | ::File::CREAT do | io |
          d = io.write "#{ child_PID  }\n"
        end

        @_oes_p.call :info, :expression, :ok do | y |

          y << "(wrote #{ path } (#{ d } bytes))"

          y << "(parent (#{ ::Process.pid }) detaching from child (#{ child_PID }))"
        end

        ::Process.detach @_child_PID

        ACHIEVED_
      end

      def __when_child

        trap :INT do

          @_oes_p.call :info, :expression, :goodbye do | y |
            y << "received interrupt signal. goodbye."
          end

          exit! 0
        end

        @_rack_handler.run @_rack_app, :Port => @port  # Errno::EADDRINUSE

        self._NEVER_SEE
      end
    end
  end
end
