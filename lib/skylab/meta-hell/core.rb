require_relative '..'

module Skylab

  module MetaHell                 # welcome to meta hell

    MetaHell = self

    EMPTY_A_       =  [ ].freeze  # #ocd
    EMPTY_P_       = ->   {   }
    IDENTITY_      = -> x { x }
    MONADIC_TRUTH_ = -> _ { true }

    def self.Function host, *rest
      self::Function._make_methods host, :public, :method, rest
    end

    DASH_          = '-'.getbyte 0

    # ARE YOU READY TO EAT YOUR OWN DOGFOOD THAT IS MADE OF YOUR BODY

    #                  ~ auto-trans-substantiation ~

    module Autoloader
      include ::Skylab::Autoloader  # explained in depth at [#041]
      ::Skylab::Autoloader[ self ]
    end

    ( MAARS = Autoloader::Autovivifying::Recursive )[ self ]

      # a name so long that is used so often deserves its own acronym.

    Funcy = -> cls do             # a class that is interfaced with like a proc
      def cls.[] * x_a
        new( * x_a ).execute
      end
    end
  end
end
