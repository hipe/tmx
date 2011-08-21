require 'fileutils'

module Skylab; end

module Skylab::Face
  module PathTools
    extend self
    HomeDirRe = %r{\A#{Regexp.escape(ENV['HOME'])}/}
    def pretty_path path
      path.sub(/\A#{Regexp.escape(FileUtils.pwd)}\//, './').sub(HomeDirRe, '~/')
    end
  end
end
