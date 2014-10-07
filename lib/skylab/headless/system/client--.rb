module Skylab::Headless

  module System

    class Client__  # read [#140] #section-2 introduction to the client

      def which exe_name
        if SAFE_NAME_RX__ =~ exe_name
          wch_exe_safe exe_name
        else
          false
        end
      end
      SAFE_NAME_RX__ = /\A[-a-z0-9_]+\z/i

    private

      def wch_exe_safe exe_name
        out = Headless_::Library_::Open3.popen3 'which', exe_name do |_, o, e|
          err = e.read
          if EMPTY_STRING_ != err
            _msg = "unexpected response from `which` - #{ err }"
            raise ::SystemCallError, _msg
          end
          o.read.strip
        end
        out if EMPTY_STRING_ != out
      end

      Headless_::Lib_::Properties_stack_frame.call self,

        :memoized, :readable, :proc, :any_home_directory_path, -> do
          ::ENV[ 'HOME' ]
        end,

        :memoized, :inline_method, :any_home_directory_pathname, -> do
          s = any_home_directory_path and ::Pathname.new( s )
        end

    end
  end
end
