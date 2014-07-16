module Skylab::MetaHell

  module Fields  # read [#066] the metahell fields narrative

    # ~ payload as narrative

    class << self
      def box_for_client * x_a, client
        Box_for.iambic_and_client x_a, client
      end
      def start_shell
        Box_for.new EMPTY_A_, nil
      end
    end

    class Box_for
      def self.client client
        new( EMPTY_A_, client ).flush
      end
      def self.iambic_and_client x_a, client
        new( x_a, client ).flush
      end
      def initialize x_a, client
        @absorber_a = nil
        @client_class = client
        @ext_mod_a = nil
        @field_box_const = CONST_
        x_a.length.nonzero? and prs_iambic_unobtrusive_fully x_a
      end
      def initialize_copy otr
        @absorber_a = otr.absorber_a.dup
        @ext_mod_a = (( a = otr.ext_mod_a )) && a.dup
        @field_box_const = otr.field_box_const
        # when we dup, client_class and definee_module are not duped
        nil
      end
      attr_reader :absorber_a, :ext_mod_a, :field_box_const
      attr_accessor :client_class
      attr_accessor :definee_module # xx
      def frozen * x_a
        prs_iambic_unobtrusive_fully x_a
        freeze
      end
      def freeze
        @absorber_a.freeze
        super
      end
      def with_client client
        @client_class = client
        self
      end
      def with * x_a
        prs_iambic_unobtrusive_fully x_a
        self
      end
      def with_iambic_unobtrusive_fully x_a
        prs_iambic_unobtrusive_fully x_a
        self
      end
    private
      def prs_iambic_unobtrusive_fully x_a
        @x_a = x_a ; @d = 0 ; @len = x_a.length
        while @d < @len
          d, abs = Absorber_Method_.unobtrusive_passive_scan @d, @x_a
          if d
            @d = d ; ( @absorber_a ||= [] ).push abs
            next
          end
          scn_some_other
        end ; nil
      end
      def scn_some_other
        m = OP_H__.fetch @x_a.fetch @d
        @d += 1
        send m
      end
      OP_H__ = {
        client_class: :prs_client_cls,
        definee_module: :prs_definee_mod,
        field_box_const: :prs_fld_bx_const,
        use_o_DSL: :prs_o_DSL
      }.freeze
      def prs_client_cls
        @client_class = @x_a.fetch @d ; @d += 1 ; nil
      end
      def prs_definee_mod
        @definee_module = @x_a.fetch @d ; @d += 1 ; nil
      end
      def prs_fld_bx_const
        @field_box_const = @x_a.fetch @d ; @d += 1 ; nil
      end
      def prs_o_DSL
        ( @ext_mod_a ||= [] ) << Experimental_DSL__ ; nil
      end
    public
      def flush
        @absorber_a and @absorber_a.each do |ab|
          ab.apply_to_client @client_class
        end
        Touch_facet_muxer__[ @client_class ]
        @ext_mod_a and aply_ext_mod_a
        @client_class.send :include, Client_Methods
        tch_field_box_method
        tch_field_box
      end
    private
      def aply_ext_mod_a
        @ext_mod_a.each do |mod|
          @client_class.extend mod
        end ; nil
      end
      def tch_field_box_method
        fld_bx_const = @field_box_const
        Method_Touch__.touch :field_box, -> do
          self.class.const_get fld_bx_const
        end, @client_class ; nil
      end
      def tch_field_box
        if @client_class.const_defined? @field_box_const
          if @client_class.const_defined? @field_box_const, false
            @client_class.const_get @field_box_const
          else
            _box = @client_class.const_get( @field_box_const ).dup
            @client_class.const_set @field_box_const, _box
          end
        else
          @client_class.const_set @field_box_const, bld_fld_box
        end
      end
      def bld_fld_box
        box = MetaHell_::Library_::Basic::Box.new
        box._h.default_proc = -> h, k do
          raise ::ArgumentError, say_xtra( h.keys, k )
        end ; box
      end
      def say_xtra a, x
        "unrecognized keyword #{ MetaHell_::Lib_::Strange[ x ] }#{
         } - did you mean #{ Lev__[ a, x ] }?"
      end
      Lev__ = -> a, x do
        MetaHell_::Library_::Headless::NLP::EN::Levenshtein::
          Or_with_closest_n_items_to_item.curry[ 3, a, x ]
      end
    end

    # ~ #curry-friendly support procs

    Touch_const_with_dupe_for___ = -> p, c, mod do
      MetaHell_::FUN::Touch_constant_[ false, -> _ do
        if mod.const_defined? c
          mod.const_get( c ).dupe_for mod
        else
          p[ mod ]
        end
      end, c, mod, nil ]
    end

    Touch_singleton_method____ = -> priv_pub, m, p, client do  # #curry-friendly
      sc = client.singleton_class
      if ! ( sc.method_defined? m or sc.private_method_defined? m )
        client.define_singleton_method m, & p
        :private == priv_pub and sc.send :private, m
      end ; nil
    end

    class Method_Characteristics__
      def initialize
        @do_chainable = @do_override = @do_private = nil
      end
      METHOD_OP_H__ = {
        chainable: :prcss_chainable,
        overriding: :prcss_overriding,
        private: :prcss_private
      }.freeze
    private
      def prcss_chainable
        @do_chainable = true
      end
      def prcss_overriding
        @do_override = true
      end
      def prcss_private
        @do_private = true
      end
    public
      def apply_to_client client
        m = @method_name
        _yes = if client.method_defined? m or client.private_method_defined? m
          client != client.instance_method( m ).owner && @do_override
        else
          true
        end
        if _yes
          p = @p
          @do_chainable and p = Make_chainable__[ p ]
          client.send :define_method, m, p
          @do_private and client.send :private, m
        end ; nil
      end
      Make_chainable__ = -> p do
        -> *a do
          instance_exec( *a, &p )
          self
        end
      end

      def to_proc
        me = self
        -> client do
          me.apply_to_client client
        end
      end
    end

    class Method_Touch__ < Method_Characteristics__
      def self.curry * i_a, p
        new( i_a, p ).to_proc
      end
      def self.touch * i_a, p, client
        new( i_a, p ).apply_to_client client ; nil
      end
    private
      def initialize i_a, p
        @p = p
        super()
        absrb_iambic_fully i_a
      end
      def absrb_iambic_fully i_a
        last_flag_index = i_a.length - 2
        -2 == last_flag_index and raise ::ArgumentError, "method name required"
        d = -1
        while d < last_flag_index
          send METHOD_OP_H__.fetch i_a.fetch d += 1
        end
        @method_name = i_a.last ; nil
      end
    end

    class Absorber_Method_ < Method_Characteristics__  # is [#060]

      def self.unobtrusive_passive_scan d, i_a
        if METHOD_OP_H__.key? i_a.fetch d
          new.unobtrsv_passive_scan d, i_a
        end
      end
      def initialize
        @do_argful = false
        @do_destructive = false
        @do_globbing = false
        @do_passive = false
        super()
      end
      METHOD_OP_H__ = METHOD_OP_H__.dup
      METHOD_OP_H__.merge!(
        absorber: :prcss_absorber,
        argful: :prcss_argful,
        destructive: :prcss_destructive,
        globbing: :prcss_globbing,
        passive: :prcss_passive,
      ).freeze
      def unobtrsv_passive_scan d, i_a
        @d = d ; @i_a = i_a ; @is_done = false
        begin
          m_i = METHOD_OP_H__.fetch i_a.fetch @d
          @d += 1
          send m_i
        end until @is_done
        @method_name or raise ::ArgumentError, "method name required"
        @i_a = nil
        @p = rslv_some_absorber_method
        [ @d, self ]
      end
    private
      def prcss_absorber
        @is_done = true
        @method_name = @i_a.fetch @d ; @d += 1 ; nil
      end
      def prcss_argful
        @do_argful = true ; nil
      end
      def prcss_destructive
        @do_destructive = true ; nil
      end
      def prcss_globbing
        @do_globbing = true ; nil
      end
      def prcss_passive
        @do_globbing = false
        @do_passive = true ; nil
      end

    private
      def rslv_some_absorber_method
        parse = Parse__.new @do_argful, @do_destructive, @do_passive
        if @do_globbing
          -> * x_a do
            parse.for_client( self ).parse_x_a_from_beginning x_a
          end
        else
          -> x_a do
            parse.for_client( self ).parse_x_a_from_beginning x_a
          end
        end
      end
    end

    class Parse__
      def initialize arg, dest, passive
        @do_arg = arg ; @do_destructive = dest ; @do_passive = passive
        @adapter_method_i = if dest
          :build_destructive_parse_adapter_for_iambic
        else
          :build_peaceful_parse_adapter_for_iambic
        end
        @fld_method_i = if arg
          if dest
            :absorb_into_client_iambic
          else
            :accept_into_client_scan
          end
        else
          :notify_client_of_scan
        end
      end
      def for_client client
        dup.with_client client
      end
      def with_client client
        @client = client
        self
      end
      def parse_x_a_from_beginning x_a
        prepare x_a
        fld = true ; fb = @client.field_box
        while @scan.unparsed_exist
          fld = fb.fetch( @scan.first_unparsed_arg ) { }
          fld or break
          @scan.advance_one
          fld.send @fld_method_i, @client, * @field_arg_a
        end
        if fld || @do_passive
          @client.post_absorb_iambic_args_notify
        else
          @client.unexpected_unparsable_iambic_args_were_encountered
        end
      end
    private
      def prepare x_a
        @scan = @client.send @adapter_method_i, x_a
        @field_arg_a = if @do_arg
          if @do_destructive
            [ x_a ]
          else
            [ @scan ]
          end
        else
          [ @scan ]
        end
      end
    end

    module Client_Methods  # see #client-methods
      def build_destructive_parse_adapter_for_iambic x_a
        @x_a = x_a
        @iambic_scan = Destructive_Parse_Adapter__.new x_a
      end
      def build_peaceful_parse_adapter_for_iambic x_a
        @x_a = x_a ; @d = 0 ; @x_a_length = x_a.length
        @iambic_scan = Peaceful_Parse_Adapter__.new self
      end
      def unparsed_peaceful_iambic_exists
        @d < @x_a_length
      end
      def gets_one_peaceful_iambic
        x = @x_a.fetch @d ; @d += 1 ; x
      end
      def first_unparsed_peaceful_iambic
        @x_a.fetch @d
      end
      def advance_one_peaceful_iambic
        @d += 1 ; nil
      end
      def unexpected_unparsable_iambic_args_were_encountered
        field_box[ @iambic_scan.first_unparsed_arg ]
      end
      def post_absorb_iambic_args_notify
        self.class.facet_muxer.notify :post_absorb, self ; nil
      end
    end

    class Peaceful_Parse_Adapter__
      def initialize client
        @client = client
      end
      def unparsed_exist
        @client.unparsed_peaceful_iambic_exists
      end
      def gets_one
        @client.gets_one_peaceful_iambic
      end
      def first_unparsed_arg
        @client.first_unparsed_peaceful_iambic
      end
      def advance_one
        @client.advance_one_peaceful_iambic
      end
    end

    class Destructive_Parse_Adapter__
      def initialize x_a
        @x_a = x_a
      end
      def unparsed_exist
        @x_a.length.nonzero?
      end
      def gets_one
        x = @x_a.fetch 0 ; @x_a[ 0, 1 ] = EMPTY_A_ ; x
      end
      def advance_one
        @x_a[ 0, 1 ] = EMPTY_A_ ; nil
      end
      def first_unparsed_arg
        @x_a.fetch 0
      end
    end

    module Experimental_DSL__
    private
      def o * x_a
        (( @fld_attrs_x_a_a ||= [] )) << x_a ; nil
      end
    public
      attr_reader :fld_attrs_x_a_a
      def release_any_next_fld_attrs
        if (( x = fld_attrs_x_a_a ))
          @fld_attrs_x_a_a = nil ; x
        end
      end
    end

    class Aspect_  # (apprentice/redux of Basic::Field)
      def initialize method_i, block=nil
        @method_i = method_i
        @ivar = :"@#{ method_i }"
        @as_slug = method_i.to_s.gsub '_', '-'
        block and block[ self ]
        freeze  # dupe with impunity
      end
      attr_reader :method_i, :ivar, :as_slug
      alias_method :local_normal_name, :method_i
      attr_reader :is_required  # where available

      def x_a_a_full x_a_a  # #experimental
        x_a_a.each do |x_a|
          @x_a = x_a
          begin
            send :"prs_#{ x_a.shift }"
          end while x_a.length.nonzero?
        end
        @x_a = nil
      end
    end

    # ~ facet muxer (e.g to implement a required fields check hook)

    FIELD_FACET_MUXER_CONST__ = :FIELD_FACET_MUXER_

    Touch_facet_muxer__ = Touch_const_with_dupe_for___.curry[
      -> client do
        Touch_facet_muxer_reader__[ client ]
        Free_Muxer__.new client
      end,
      FIELD_FACET_MUXER_CONST__ ]

    Touch_facet_muxer_reader__ = Touch_singleton_method____.curry[
      :public, :facet_muxer, -> do
        const_get FIELD_FACET_MUXER_CONST__ # inherit
      end ]

    class Free_Muxer__

      def initialize client
        @client = client
        @h = nil
      end

      # ~ :+[#021] custom implementation:
      def dupe_for client
        otr = dup
        otr.init_copy_ client
        otr
      end
      def initialize_copy otr
        init_copy( * otr.get_args_for_copy ) ; nil
      end
    private
      def init_copy h
        @h = ( h.dup if h ) ; nil
      end
    protected
      def get_args_for_copy
        [ @h ]
      end
    public
      def init_copy_ client
        @client = client ; nil
      end
      # ~

      def notify event_i, agent
        if @h and (( a = @h[ event_i ] ))
          a.each do |p|
            p[ agent ]
          end
        end ; nil
      end

      def add_hook_listener i, p
        (( @h ||= {} )[ i ] ||= [] ).push p ; nil
      end
    end

    # ~

    def self.contoured * x_a
      if x_a.length.zero?
        self::Contoured__
      else
        self::Contoured__.from_iambic_and_client x_a, x_a.shift
      end
    end

    # ~

    CONST_ = :FIELDS_

  end
end
