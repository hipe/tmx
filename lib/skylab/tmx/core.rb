require_relative '..'
require 'skylab/callback/core'

module Skylab::TMX

  Callback_ = ::Skylab::Callback

  -> o, h do

    o[ :bin_pathname ] = Callback_.memoize do
      Autoloader_.require_sidesystem( :System ).services.defaults.bin_pathname
    end

    o[ :binfile_prefix ] = Callback_.memoize do
      'tmx-'.freeze
    end

    o[ :supernode_binfile ] = Callback_.memoize do
      'tmx'.freeze
    end

    h
  end.call( * -> do

    h = {}
    o = -> i, p do
      singleton_class.send :define_method, i, p
      h[ i ] = p
    end
    o.singleton_class.send :alias_method, :[]=, :call
    [ o, h ]

  end.call ).tap do |h|

    define_singleton_method( :at ) do |* i_a|
      i_a.map do |i|
        h.fetch( i ).call
      end
    end
  end

  Autoloader_ = Callback_::Autoloader

  module CLI  # #stowaway
    def self.new *a
      self::Client.new( *a )
    end
    Autoloader_[ self ]
  end

  CLI_Client_ = -> do
    Lib_::Face__[]::CLI::Client
  end

  module Lib_
    sidesys = Autoloader_.build_require_sidesystem_proc
    Constantize = -> i do
      Callback_::Name.lib.constantize i
    end
    Distill = -> i do
      Callback_::Distill_[ i ]
    end
    Face__ = sidesys[ :Face ]
    MetaHell__ = sidesys[ :MetaHell ]
    Proxy_lib = -> do
      Callback_::Proxy
    end
    Pathnames = -> do
      Subsystem__[]::PATHNAMES
    end
  end

  DASH_ = '-'.freeze
  EMPTY_S_ = ''.freeze
  TMX = self  # not 'TMX_', just for aesthetics

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]
end
