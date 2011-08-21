require 'fileutils'

module Skylab::Tmx::Modules::Cli::PrettyPath
  HomeDirRe = /\A#{Regexp.escape(ENV['HOME'])}/
protected
  def pretty_path path
    path.sub(/\A#{Regexp.escape(FileUtils.pwd)}\//, './').sub(HomeDirRe, '~')
  end
end
