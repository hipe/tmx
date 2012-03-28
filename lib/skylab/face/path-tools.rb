require 'fileutils'
require 'pathname'
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
    HOME_DIR_RE = %r{\A#{Regexp.escape(ENV['HOME'])}/}
    def pretty_path path
      path.sub(/\A#{Regexp.escape(FileUtils.pwd)}\//, './').sub(HOME_DIR_RE, '~/')
    end
    def escape_path path
      (path.to_s =~ / |\$|'/) ? Shellwords.shellescape(path) : path.to_s
    end
  end
  class MyPathname < Pathname
    def join *a
      self.class.new(super(*a)) # awful! waiting for patch for ruby maybe?
    end
    def pretty
      PathTools.pretty_path to_s
    end
  end
end

