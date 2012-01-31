require 'stringio'

module Skylab ; end

module Skylab::Dependency
  class MyStringIO < StringIO
    def to_s
      rewind
      read
    end
  end
end

