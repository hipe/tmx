module Skylab::Git

  module Services

    stdlib, subsys = ::Skylab::Subsystem::FUN.
      at :require_stdlib, :require_subsystem
    o = { }
    o[:FileUtils] = stdlib
    o[:Headless] = subsys
    o[:Open3] = stdlib
    o[:OptionParser] = -> _ { require 'optparse' ; ::OptionParser }
    o[:Set] = stdlib
    o[:Shellwords] = stdlib
    o[:StringIO] = stdlib

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
    end
  end
end
