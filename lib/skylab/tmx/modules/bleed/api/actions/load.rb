module Skylab::TMX::Modules::Bleed::API

  class Actions::Load < Action

    emits :bash, :error, :notice

    -> do
      script_path = 'script/bleed'

      define_method :invoke do ||
        res = nil
        begin
          config_read or break  # upstram emits
          dir_pth = config_get_path or break  # upstream emits
          dir_pn = ::Pathname.new expand_tilde( dir_pth )
          if ! dir_pn.exist?
            break( error "not a directory, won't add to PATH: #{ dir_pn }" )
          end
          script_pn = dir_pn.join script_path
          if ! script_pn.exist?
            break error "expected to exist, didn't - #{ script_pn }"
          end
          require 'open3'  # meh
          ::Open3.popen3( script_pn.to_s ) do |sin, sout, serr, thread|
            while line = sout.gets
              emit :bash, line.chomp
            end
            res = thread.join.value.exitstatus
          end
        end while nil
        res
      end
    end.call
  end
end
