require_relative '..'

require 'skylab/meta-hell/core'

module Skylab::Face

  %i| Face MetaHell |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  MAARS = MetaHell::MAARS

  extend MAARS

  module API
    extend MAARS
    def self.[] mod
      const_get( :Client, false )._enhance mod
      nil
    end
  end

  module Services

    extend MAARS

    o = { }

    o[:Basic] = -> { Services::Headless::Services::Basic }
      # (its fields are used extensively by the API API)

    o[:Headless] = -> { require 'skylab/headless/core' ; ::Skylab::Headless }
      # (used extensively everywhere)

    o[:Ncurses] = -> { require 'ncurses' ; ::Ncurses }

    o[:OptionParser] = -> { require 'optparse' ; ::OptionParser }
      # (crucial but used in a small number of places)

    o[:Porcelain] = -> { require 'skylab/porcelain/core' ; ::Skylab::Porcelain }
      # (experimentally leveraged for option parser abstract modelling)

    o[:PubSub] = -> { require 'skylab/pub-sub/core' ; ::Skylab::PubSub }
      # (engaged by the API Action API's `emit` facet.)

    define_singleton_method :const_missing do |const|
      if o.key? const
        const_set const, o.fetch( const ).call
      else
        super const
      end
    end
  end

  module Magic_Touch_  # local metaprogramming tightener for this pattern

    # #experimental - what this does is, given
    #   module [ :singleton ] ( :public | :private ) method [ method [..] ]
    # and given a function that loads a library
    #   ** that overrides those methods with new definitions of them **
    # this makes stub definitions for those methods that, when any such method
    # is called it loads the library (which hopefully re-defines this method),
    # and then re-calls the "same" method with the hopefully new definition.
    # i.e this allows us to lazy-load libraries catalyzed by when these
    # particular "magic methods" are called that "wake" the library up.
    # failure of the library to override these methods results in infinite
    # recursion. this feels sketchy but has several benefits to be discussed
    # elsewhere.

    do_private_h = { public: false, private: true }.freeze

    define_singleton_method :enhance do |
      function_that_loads_library, * module_with_magic_methods_a |

      module_with_magic_methods_a.each do | mod, access_i, * meth_i_a |
        (( do_singleton = ( :singleton == access_i ) )) and
          access_i = meth_i_a.shift
        do_private = do_private_h.fetch access_i
        ( do_singleton ? mod.singleton_class : mod ).module_exec do
          meth_i_a.each do |m|
            define_method m do | *a, &b |
              function_that_loads_library.call
              send m, *a, &b  # pray
            end
            do_private and private m
          end
        end
      end
      nil
    end
  end
end
