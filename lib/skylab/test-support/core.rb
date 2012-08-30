require File.expand_path('../../../skylab', __FILE__)
require_relative '../meta-hell/core'

class ::String
  # note you will still have a trailing newline, for which u could chop
  def unindent # aka deindent
    gsub(/^#{::Regexp.escape(match(/\A(?<margin>[[:space:]]+)/)[:margin])}/, '')
  end
end

module Skylab::TestSupport
  extend ::Skylab::Autoloader
end
