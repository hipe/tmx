module Skylab::TMX::Modules::Bleed::API

  class Actions::Load < Action

    listeners_digraph :bash, :error, :notice

    -> do
      script_path = 'script/bleed'

      define_method :invoke do ||
        res = nil
        begin
          config_read or break
          dir_pth = config_get_path or break
          dir_pn = ::Pathname.new expand_tilde( dir_pth )
          if ! dir_pn.exist?
            break( send_error_string "not a directory, won't add to PATH: #{ dir_pn }" )
          end
          script_pn = dir_pn.join script_path
          if ! script_pn.exist?
            break send_error_string "expected to exist, didn't - #{ script_pn }"
          end
          require 'open3'  # meh
          ::Open3.popen3( script_pn.to_s ) do |sin, sout, serr, thread|
            while line = sout.gets
              call_digraph_listeners :bash, line.chomp
            end
            res = thread.join.value.exitstatus
          end
        end while nil
        res
      end
    end.call
  end
end
