require File.expand_path('../../../skylab', __FILE__)

class String
  def unindent
    gsub(%r{^#{Regexp.escape match(/\A[[:space:]]*/)[0]}}, '')
  end
end

module Skylab::TestSupport
  extend Skylab::Autoloader
end

