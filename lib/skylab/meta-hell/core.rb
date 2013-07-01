require_relative '..'

module Skylab

  module MetaHell                 # welcome to meta hell

    MetaHell = self               # (so we can reach up then down from below)

    Autoloader_ = Autoloader      # the toplevel one (which will probably move
                                  # here one day) we will refer to internally
                                  # as this. NOW..

    EMPTY_A_ =  [ ].freeze        # ocd
    EMPTY_P_ =  ->   {   }
    IDENTITY_ = -> x { x }

    # ARE YOU READY TO EAT YOUR OWN DOGFOOD THAT IS MADE OF YOUR BODY

    #                    ~ auto-trans-substantiation ~

    module Autoloader             # we have our own module called this.
      extend Autoloader_          # confusingly extend it with this,
    end                           # now it itself is a basic autoloader.

                                  # but what we really want is not to ourselves
                                  # be a basic autoloader and not to ourselves
                                  # be an autovivifing autoloader, but for us
                                  # ourselves to be a full-on, balls-out,
                                  # recusive auto-vivifying autoloader.

    MAARS = Autoloader::Autovivifying::Recursive

    extend MAARS                  # which is such a long name you never want
                                  # to have to say it more than once.

    # --*--
                                  # sugar for this very popular enhancement
    #
    def self.Function host, *rest
      self::Function._make_methods host, :public, :method, rest
    end
  end
end
