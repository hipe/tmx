require_relative '../callback/core'

module Skylab::Face  # read [#011] the top node narrative

  Callback_ = ::Skylab::Callback
  Autoloader_ = Callback_::Autoloader

  module API
    def self.[] mod
      const_get( :Client, false ).enhance_anchor_mod mod
      nil
    end

    Autoloader_[ self ]
  end

  Face_ = self
  Lib_ = ::Module.new

  module CLI

    def self.reparenthesize
      self::Client::Reparenthesize
    end

    def self.stylify
      Lib_::Stylify_proc
    end

    module Lib_
      include Face_::Lib_
      Stylify_proc = -> do
        Headless__[]::CLI::Pen::FUN::Stylify
      end
      include Face_::Lib_
    end

    Autoloader_[ self ]
  end

  module Library_  # :+[#su-001]

    stdlib = Autoloader_.method :require_stdlib
    o = { }
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Open3 ] =
    o[ :Set  ] =
    o[ :StringIO ] = stdlib

    define_singleton_method :const_missing do |i|
      p = o[ i ] or super i
      const_set i, p[ i ]
    end
  end

  module Lib_

    memo, sidesys = Autoloader_.at :memoize, :build_require_sidesystem_proc

    Arity_space_create = -> p, p_ do
      Headless__[]::Arity::Space.create p, & p_
    end

    Basic_Fields = -> * x_a do
      MetaHell__[]::Basic_Fields.via_iambic x_a
    end

    Basic__ = sidesys[ :Basic ]

    Box_class = -> do
      Basic__[]::Box
    end

    Box = -> do
      Basic__[]::Box.new
    end

    Counting_yielder = -> p do
      Basic__[]::Yielder::Counting.new( & p )
    end

    DSL_DSL_story = -> * a do
      MetaHell__[]::DSL_DSL::Story_.new( * a )
    end

    EN_add_private_methods_to_module = -> i_a, mod do
      Headless__[]::SubClient::EN_FUN[ mod, :private, i_a ]
    end

    EN_oxford_or = -> s_a do
      Callback_::Oxford_or[ s_a ]
    end

    Field_box_enhance = -> x, p do
      Basic__[]::Field::Box.enhance x, & p
    end

    Field_class = -> do
      Basic__[]::Field
    end

    Fields = -> mod, * field_i_a do
      MetaHell__[]::Basic_Fields.with :client, mod,
        :globbing, :absorber, :initialize,
        :field_i_a, field_i_a
    end

    Fields_from_methods = -> *a, p do
      MetaHell__[]::Fields::From.methods.iambic_and_block a, p
    end

    Funcy_globful = -> mod do
      MetaHell__[].funcy_globful mod
    end

    Headless__ = sidesys[ :Headless ]

    MetaHell__ = sidesys[ :MetaHell ]

    Module_mutex_proc = -> do
      MetaHell__[]::Module::Mutex
    end

    Module_accessors = -> x, p=nil do
      MetaHell__[]::Module::Accessors.enhance x, & p
    end

    Name_from_constant = -> i do
      Headless__[]::Name::Function::From::Constant.new i
    end

    Name_from_symbol = -> i do
      Headless__[]::Name::Function.new i
    end

    Name_module_moniker = -> x do
      Headless__[]::Name::FUN::Module_moniker[ x ]
    end

    Name_slugulate = -> i do
      Callback_::Name.from_variegated_symbol( i ).as_slug
    end

    Nice_proxy = -> * i_a do
      MetaHell__[]::Proxy::Nice.new( * i_a )
    end

    NLP_aggregated_list_articulation = -> a, p do
      Basic__[]::List::Aggregated::Articulation a, & p
    end

    NLP_evented_list_articulation = -> a, p do
      Basic__[]::List::Evented::Articulation a, & p
    end

    Open_box = -> do
      MetaHell__[]::Formal::Box::Open.new
    end

    Parse_series = -> * a do
      MetaHell__[]::Parse.series.via_argument_list a
    end

    Plugin_lib = -> do
      Face_::Plugin
    end

    Procs_as_methods = -> * i_a do
      MetaHell__[]::Function::Class.new( * i_a )
    end

    Scanner_for_array = -> a do
      Basic__[]::List::Scanner::For::Array.new a
    end

    Strange_proc = -> do
      MetaHell__[].strange.to_proc
    end

    System_IO = memo[ -> do
      Headless__[]::System::IO
    end ]

    Text_is_perhaps_a_sentence = -> s do
      Headless__[]::CLI::FUN::Looks_like_sentence[ s ]
    end

    Touch_proc = -> do
      MetaHell__[]::Module::Accessors::Touch
    end
  end

  Some_ = -> x { x && x.length.nonzero? }

  module Magic_Touch_  # [#046] #magic-touch (in [#011])

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

  class Vertical_Fields_  # see [#011]:#vertical-fields

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

  class Services_
    # (either deprected or due for a cleanup. used by CLI & API. [#hl-070])

    SERVICES_IVAR_ = nil
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
        siv = pxy::SERVICES_IVAR_ || :@services
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
            Shell_.new(
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
              const_set :SERVICES_IVAR_, siv
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
        class Shell_
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

    class Iambic
      class << self
        alias_method :orig_new, :new
      private
        def collapse ; end
      public
        def new * formal_a
          from_iambic formal_a
        end
      end
      def self.from_iambic formal_a
        ::Class.new( self ).class_exec do
          @formal_arg_a = formal_a
          def self.collapse
            super
            a = @formal_arg_a ; @formal_arg_a = nil
            box = const_set :SERVICES_, Lib_::Box[]
            begin
              box.add (( i = a.shift )), a.shift
              define_method( i ) { self[ i ] }
            end while a.length.nonzero?
            class << self
              remove_method :collapse
              def collapse ; end
              remove_method :new
              alias_method :new, :orig_new
            end
            nil
          end
          def self.new kernel, * actual_a
            collapse
            new kernel, * actual_a
          end
          self
        end
      end

      def initialize kernel
        @kernel_p = -> { kernel }
        nil
      end

      def [] i
        @kernel_p[].instance_exec( & self.class::SERVICES_.fetch( i ) )
      end

      def at * i_a
        k = @kernel_p[]
        i_a.map { |i| k.instance_exec( & self.class::SERVICES_.fetch( i ) ) }
      end

      def to_a
        at( * self.class::SERVICES_._a )
      end

      def members
        self.class.members
      end

      def self.members
        self::SERVICES_._a.dup
      end
    end


  Name_ = Callback_::Name

  MONADIC_TRUTH_ = -> _ { true }

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  stowaway :TestSupport, 'test/test-support'  # [#045] part of our public API
end
