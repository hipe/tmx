require File.expand_path('../../../skylab', __FILE__)
# above is [#bs-010]

require_relative '../meta-hell/core'

class ::String
  # note you will still have a trailing newline, for which u could chop
  def unindent # aka deindent
    gsub(/^#{::Regexp.escape(match(/\A(?<margin>[[:space:]]+)/)[:margin])}/, '')
  end
end


module Skylab::TestSupport

  TestSupport = self

  extend ::Skylab::Autoloader
end
