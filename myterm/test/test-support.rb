require 'skylab/myterm'
require 'skylab/test_support'

module Skylab::MyTerm::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  class << self
    def [] tcc
      tcc.send :define_singleton_method, :use, Use_method___
      tcc.include Instance_Methods___
    end
  end  # >>

  # -

    Use_method___ = -> sym do
      TS_.__lib( sym )[ self ]
    end

  # -

  module Instance_Methods___

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  class << self

    h = {}
    define_method :__lib do | sym |

      h.fetch sym do

        s = sym.id2name
        const = "#{ s[ 0 ].upcase }#{ s[ 1..-1 ] }".intern

        x = if TS_.const_defined? const, false
          TS_.const_get const, false
        else
          TestSupport_.fancy_lookup sym, TS_
        end
        h[ sym ] = x
        x
      end
    end
  end  # >>

  # --

  module My_API

    def self.[] tcc
      @_ ||= Home_.lib_.zerk.test_support.lib :API
      @_[ tcc ]
      tcc.include self
    end

    def init_result_for_zerk_expect_API x_a, & pp

      @result = Home_::API.call( * x_a, & pp )
      NIL_
    end

    def init_result_and_root_ACS_for_zerk_expect_API x_a, & pp

      @root_ACS = build_root_ACS_

      _ze = Home_.lib_.zerk

      @result = _ze::API.call x_a, @root_ACS, & pp

      NIL_
    end  # •cp1

    def build_root_ACS_
      Home_._build_root_ACS
    end
  end

  Callback_ = ::Skylab::Callback

  Autoloader__ = Callback_::Autoloader

  module Stubs
    Autoloader__[ self ]
  end

  Autoloader__[ self, ::File.dirname( __FILE__ ) ]

  Home_ = ::Skylab::MyTerm

  COMMON_ADAPTER_CONST_ = :Imagemagick
  EMPTY_S_ = Home_::EMPTY_S_
  Lazy_ = Callback_::Lazy
  NIL_ = nil
  NONE_ = nil
  TS_ = self
end
