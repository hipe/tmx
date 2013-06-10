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

    # Magic_Touch_ is an #experimental facility for lazy-loading libraries
    # based on when particular methods are called. how it works is, given:
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

  class Set_  # general purpose application tree configuration API.
    # you create one SET_ function at the top-ish of your library, after you've
    # you've declared some proxy classes or mechanical classes (the workhorses
    # of the matryoshka doll [#040] stack.) you create it by giving it an
    # ordered list of symbolic names representing your proxy classes, and then
    # a hash with the classes themselves keyed to those names:
    #
    #     SET_ = Set_.new( [:hi, :mid, :lo], hi: App, mid: NS, lo: Cmd )
    #
    # when you want to add a field to your stack, you call your SET_ function
    # with a symbolic name for the field, perhaps a default, and perhaps a
    # `highest` and `lowest` markers (using the symbolic names for the proxy
    # classes you set above), indicating the top and bottom of the call chain:
    #
    #     SET_[ :timeout, :lowest, :mid, :default, 30 ]
    #
    # the call to the SET_ function will then **add methods** to your proxy
    # classes to manage making them locally settable and globally accessible
    # to each other as appropriate. in the example above, the classes `App`
    # and `NS` are both given setters named `set_timeout_value( x )`. `Cmd`
    # is not touched because it was not within the range that was determined
    # at the bottom end by the `lowest` directive, which said `mid`, which is
    # `NS`.
    #
    # `NS` is then given a getter method `get_timeout_value` which results
    # in the value of its ivar `@timeout_value` IFF one is defined. if such
    # an ivar does not exist, the `NS` will delegate the call upwards..
    #
    # (#todo more on this..)
    #
    # to quote that guy from Mackelmore, this is really quite awesome.
    #

    -> do  # `initialize`

      xtra = add_default_methods = add_top_methods = add_mid_methods = nil

      define_method :initialize do |a, h|
        a.length < 2 and fail "this will need some further development"
        @call = -> i, *pairs do
          has_default, default, highest_i, lowest_i = xtra[ pairs ]
          highest_i ||= a.first ; lowest_i ||= a.last
          highest_n = cursor = a.index( highest_i ) or fail "sanity"
          last = a.index( lowest_i ) or fail "sanity"
          done = last + 1
          if has_default
            add_default_methods[ i, h.fetch( highest_i ), default ]
            cursor += 1
          end
          while done != cursor
            level_i = a.fetch cursor
            if highest_n == cursor
              add_top_methods[ i, h.fetch( level_i ) ]
            else
              add_mid_methods[ i, h.fetch( level_i ) ]
            end
            cursor += 1
          end
        end
        nil
      end
      xtra = -> do  # ..
        op_h = {
          default: -> a, b do
            a[0] = true ; a[1] = b.fetch( 0 ) ; b.shift ; nil
          end,
          highest: -> a, b do
            a[2] = b.fetch( 0 ) ; b.shift ; nil
          end,
          lowest: -> a, b do
            a[3] = b.fetch( 0 ) ; b.shift ;  nil
          end
        }.freeze
        -> pairs do
          a = [ ]
          while pairs.length.nonzero?
            op_h.fetch( pairs.shift )[ a, pairs ]
          end
          a
        end
      end.call
      getify = -> i { :"#{ i }" }  # if you are careful ..
      ivarize = -> i { :"@#{ i }_value" }
      add_default_methods = -> i, kls, x do
        ivar = ivarize[ i ]
        kls.class_exec do
          define_method getify[ i ] do
            if instance_variable_defined? ivar
              instance_variabe_get ivar
            else
              x
            end
          end
        end
        nil
      end
      add_top_methods = -> i, kls do
        fail 'do me'  # #todo
        nil
      end
      add_mid_methods = -> i, kls do
        ivar = ivarize[ i ] ; get = getify[ i ]
        kls.class_exec do
          define_method get do
            @provider.call.instance_exec do
              if instance_variable_defined? ivar
                instance_variable_get ivar
              else
                parent_services[ get ]
              end
            end
          end
        end
        nil
      end
    end.call
    def [] *a
      @call[ *a ]
    end
  end

  class Services_  # ( basically a miniature version of Headless::Plugin..
    # because it is used by CLI and we want to use it in API we put it here,
    # elsewise why are you using face !? ^_^)

    Services_Ivar_ = nil
    class << self
      alias_method :orig, :new

      def enhance host_mod, & defn_blk
        pxy = ( if host_mod.const_defined? :Services_, false
          host_mod.const_get :Services_, false
        else
          host_mod.const_set :Services_, Services_.new
        end )
        pxy.send :absorb_services_defn_blk, defn_blk  # we want to be private
        sam = pxy::Services_Accessor_Method_
        siv = pxy::Services_Ivar_ || :@services
        if ! ( host_mod.method_defined? sam or
                host_mod.private_method_defined? sam ) then
          host_mod.module_exec do
            define_method sam do |*a|
              svcs = if instance_variable_defined? siv then
                instance_variable_get siv
              else
                instance_variable_set siv, self.class::Services_.new( self )
              end
              svcs.send sam, *a
            end
            private sam
          end
        end
        nil
      end

      def new &defn_blk
        ::Class.new( self ).class_exec do
          class << self ; alias_method :new, :orig end
          initialize
          defn_blk and absorb_services_defn_blk defn_blk
          self
        end
      end

      def ___provider
        @provider.call
      end

    private

      -> do  # `initialize`
        mf_h = {
          ivar: -> i, ivar=nil do
            ivar ||= "@#{ i }".intern
            -> { @ivar[ ivar ] }
          end,
          method: -> i, method=nil do
            method ||= i
            -> { @self_send[ method ] } if method != i
          end,
          up: -> i do
            -> { @up[ i ] }
          end
        }.freeze
        define_method :initialize do
          sam = siv = did_sam = did_siv = nil ; svc_queue_a = [ ]
          @absorb_services_defn_blk = -> blk do
            Conduit_.new(
              -> i do
                siv and fail "won't clobber existing #{
                  } services ivar - #{ @svc_ivar }"
                siv = i
              end,
              -> i do
                sam and fail "won't clobber existing #{
                  } services accessor method: #{ sam }"
                sam = i
              end,
              -> a { svc_queue_a.concat a ; nil }
            ).instance_exec( & blk )
            if ! did_siv && siv
              did_siv = true
              const_set :Services_Ivar_, siv
            end
            if ! did_sam && sam
              did_sam = true
              const_set :Services_Accessor_Method_, sam
              define_method sam do |*a|
                if 1 == a.length then __send__ a.fetch( 0 )
                else a.map { |i| __send__ i } end
              end
            end
            while svc_queue_a.length.nonzero?
              i, mf, *rest = svc_queue_a.shift
              if ! mf_h.key? mf
                AT_ == mf.to_s.getbyte( 0 ) or fail "syntax - ivar? #{ mf }"
                rest.unshift mf
                mf = :ivar
              end
              blk = mf_h.fetch( mf )[ i, * rest ]
              define_method i, & blk if blk
            end
            nil
          end
          nil
        end
        AT_ = '@'.getbyte 0
        class Conduit_
          def initialize siv, sam, svs
            @h = { siv: -> i { siv[ i ] },
                   sam: -> i { sam[ i ] },
                   svs: -> a { svs[ a ] } }
          end
          def services_ivar i ; @h[:siv][ i ] end
          def services_accessor_method i ; @h[:sam][ i ] end
          def services *a ; @h[:svs][ a ] end
        end
      end.call

      def absorb_services_defn_blk blk
        @absorb_services_defn_blk[ blk ]
      end
    end

    def initialize provider
      @ivar = -> ivar do
        if provider.instance_variable_defined? ivar
          provider.instance_variable_get ivar
        else
          raise "will not access ivar that is not defined (#{ ivar }) of #{
            }#{ provider.class }"
        end
      end
      @self_send = -> meth do
        __send__ meth, provider
      end
      @up = -> i do
        sam = self.class::Services_Accessor_Method_
        @up = provider.instance_exec do
          -> sym do
            parent_services.__send__ sam, sym
          end
        end
        @up[ i ]
      end
      @provider = -> { provider }
      nil
    end
  end
end
