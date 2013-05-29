#!/usr/bin/env ruby -w

module Foo

end

class Bar

  prepend Foo

  define_method :wiz do
  end

  private :wiz  # why does this generate warnings?
  # ruby 2.0.0p0 (2013-02-24 revision 39474) [x86_64-darwin11.4.2]

end
