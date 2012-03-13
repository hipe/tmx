require File.expand_path('../../../skylab', __FILE__)

class String
  def unindent
    gsub(%r{^#{Regexp.escape match(/\A[[:space:]]*/)[0]}}, '')
  end
end

module Skylab::TestSupport
  class MyStringIO < ::StringIO
    def to_s
      rewind
      read
    end
    def match x
      to_s.match x
    end
  end
end

