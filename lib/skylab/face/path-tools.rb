require 'fileutils'
require 'shellwords'

module Skylab; end

module Skylab::Face
  module PathTools
    extend self
    def beautify_path path
      path.sub(/\A#{
        Regexp.escape(FileUtils.pwd.sub(/\A\/private\//, '/'))
      }/, '.')
    end
    HomeDirRe = %r{\A#{Regexp.escape(ENV['HOME'])}/}
    def pretty_path path
      path.sub(/\A#{Regexp.escape(FileUtils.pwd)}\//, './').sub(HomeDirRe, '~/')
    end
    def escape_path path
      (path.to_s =~ / |\$|'/) ? Shellwords.shellescape(path) : path.to_s
    end
  end
end
