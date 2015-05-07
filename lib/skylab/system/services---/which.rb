module Skylab::System


    class Services___::Which

      def initialize _services
      end

      def call exe_name
        if SAFE_NAME_RX__ =~ exe_name
          wch_exe_safe exe_name
        else
          false
        end
      end
      SAFE_NAME_RX__ = /\A[-a-z0-9_]+\z/i

      def wch_exe_safe exe_name
        out = System_.lib_.open3.popen3 'which', exe_name do |_, o, e|
          err = e.read
          if EMPTY_S_ != err
            _msg = "unexpected response from `which` - #{ err }"
            raise ::SystemCallError, _msg
          end
          o.read.strip
        end
        if EMPTY_S_ != out
          out
        end
      end
    end

end
