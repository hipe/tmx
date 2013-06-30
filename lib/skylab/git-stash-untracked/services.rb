module Skylab::GitStashUntracked

  module Services

    o = { }
    stdlib = MetaHell::FUN.require_stdlib
    o[:FileUtils] = stdlib
    o[:Open3] = stdlib
    o[:OptionParser] = -> _ { require 'optparse' ; ::OptionParser }
    o[:Shellwords] = stdlib
    o[:StringIO] = stdlib

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
    end
  end
end
