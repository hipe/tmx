module Skylab::GitViz

  module Lib_

    memo = -> p do
      p_ = -> { x = p[] ; p_ = -> { x } ; x }
      -> { p_.call }
    end

    slug = -> i do
      i.to_s.gsub( %r((?<=[a-z])(?=[A-Z])), '-' ).downcase
    end

    sl = -> do
      require_relative '..' ; sl = nil
    end

    subsys = -> i do
      memo[ -> do
        sl && sl[]
        require "skylab/#{ slug[ i ] }/core" ; ::Skylab.const_get i, false
      end ]
    end

    stdlib = -> i do
      memo[ -> do
        require slug[ i ] ; ::Object.const_get i, false
      end ]
    end
    gem = stdlib

    Basic = subsys[ :Basic ]
    DateTime = memo[ -> do require 'date' ; ::DateTime end ]
    Grit = memo[ -> do require 'grit' ; ::Grit end ]
    Headless = subsys[ :Headless ]
    JSON = stdlib[ :JSON ]
    Listen = gem[ :Listen ]
    MetaHell = subsys[ :MetaHell ]
    MD5 = memo[ -> do require 'digest/md5' ; ::Digest::MD5 end ]
    Open3 = stdlib[ :Open3 ]
    OptionParser = memo[ -> do require 'optparse' ; ::OptionParser end ]
    Porcelain = subsys[ :Porcelain ]
    PubSub = subsys[ :PubSub ]
    Set = stdlib[ :Set ]
    Shellwords = stdlib[ :Shellwords ]
    StringScanner = memo[ -> do require 'strscan' ; ::StringScanner end ]
    TestSupport = subsys[ :TestSupport ]
    ZMQ = memo[ -> do require 'ffi-rzmq' ; ::ZMQ end ]

    Oxford = -> separator, none, final_sep, a do
      if a.length.zero?
        none
      else
        p = -> do
          h = { 0 => nil, 1 => final_sep }
          h.default_proc = -> _, _ do separator end
          h.method :[]
        end.call
        last = a.length - 1
        a[ 1 .. -1 ].each_with_index.reduce( [ a.first ] ) do |m, (s, d)|
          m << p[ last - d ] ; m << s ; m
        end * ''
      end
    end

    Oxford_or = Oxford.curry[ ', ', '[none]', ' or ' ]
    Oxford_and = Oxford.curry[ ', ', '[none]', ' and ' ]
  end
end
