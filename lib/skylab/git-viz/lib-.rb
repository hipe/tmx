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

    class Handlers
      def initialize hash
        p = -> h do
          h.each_pair do |k, x|
            h[ k ] = Node.new( x && p[ x ] )
          end
        end
        p[ hash ]
        @root = Node.new hash
      end
      Node = ::Struct.new :h, :p
      def set * i_a, p
        node = i_a.reduce @root do |m, i|
          m.h.fetch i
        end
        node.p and raise ::KeyError, "won't clobber exiting '#{ i_a.last }'"
        node.p = p ; nil
      end
      def call * i_a, & p
        ex = i_a.pop ; last_p = nil
        node = i_a.reduce @root do |m, i|
          p_ = m.p and last_p = p_
          m.h.fetch i do
            raise ::KeyError, "no '#{ i }' channel, had #{ m.h.keys * ', ' }"
          end
        end
        ( node.p || last_p || p || method( :raise ) )[ ex ]
      end
      def glom other
        p = -> me, otr do
          p_ = otr.p and me.p = p_
          h = me.h ; h_ = otr.h
          h && h_ and h.each_pair do |i, me_|
            otr_ = h_[ i ]
            if otr_
              p[ me_, otr_ ]
            end
          end
        end
        p[ @root, other.root ] ; nil
      end
    protected
      attr_reader :root
    end

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
  end
end
