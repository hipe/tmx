require 'shellwords'

module Skylab::FileMetrics
  module Common::PathTools end
  module Common::PathTools::InstanceMethods
    def escape_path path
      (path =~ / |\$|'/) ? Shellwords.shellescape(path) : path
    end
  end
end
