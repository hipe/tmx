require_relative '..'
require 'skylab/callback/core'

module Skylab::TMX

  Callback_ = ::Skylab::Callback

  -> o, h do

    o[ :bin_path ] = Callback_.memoize do
      Home_.lib_.services.defaults.bin_path
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
    sc = singleton_class
    o = -> i, p do
      sc.send :define_method, i, p
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

  class << self

    define_method :application_kernel_, ( Callback_.memoize do
      Home_.lib_.brazen::Kernel.new Home_
    end )

    def lib_
      @___lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end

  end  # >>

  Autoloader_ = Callback_::Autoloader

  module Lib_

    sidesys, _stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    Brazen = sidesys[ :Brazen ]
  end

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]
  Home_ = self
  NIL_ = nil
  UNABLE_ = false
end
