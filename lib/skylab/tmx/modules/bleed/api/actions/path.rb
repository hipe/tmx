module Skylab::TMX::Modules::Bleed::API

  module Actions::Path
  end

  class Actions::Path::Get < Action

    emits :path, :error, :notice

    # (#posterity - historical note, above line once lamented the `touch` hack)

    def invoke
      path = config_get_path
      if path
        emit :path, path
      end
    end
  end

  class Actions::Path::Set < Action

    emits :error, :notice, :info, :head, :tail

    def invoke pth
      res = nil
      begin
        config.exist? && config_read or break  # bork on parse failures
        config['bleed'] ||= { }  # create the section called [bleed]
        path = contract_tilde ::File.expand_path( pth )
        prev = config['bleed']['path']
        if prev
          if prev == path
            info "no change to path - #{ path }"
            break
          end
          info "changing bleed.path from #{ prev.inspect } to #{ path.inspect }"
        else
          info "adding bleed.path value to #{ config_path } - #{ path.inspect }"
        end
        config['bleed']['path'] = path
        res = config_write
      end while nil
      res
    end
  end
end
