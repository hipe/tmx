require 'shellwords'

module Skylab
  module Tmx
    module Modules
    end
  end
end

module Skylab::FileMetrics
  module PathTools
    def escape_path path
      (path =~ / |\$|'/) ? Shellwords.shellescape(path) : path
    end
  end
end
