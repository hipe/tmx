require 'shellwords'

module Skylab::FileMetrics
  module Common::PathTools
    def escape_path path
      (path =~ / |\$|'/) ? Shellwords.shellescape(path) : path
    end
  end
end
