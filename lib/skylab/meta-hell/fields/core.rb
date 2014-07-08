module Skylab::MetaHell

  module Fields  # read [#066] the metahell fields narrative

    # ~ payload as narrative

    def self.box_for_client * x_a, client
      self::Box_for.iambic_and_client x_a, client
    end

    class Box_for
      class << self
        private :new
      end
      def self.client * x_a, client
        new( x_a, client ).execute
      end
      def self.iambic_and_client x_a, client
        new( x_a, client ).execute
      end
      def initialize x_a, client
        @client = client
        @absorber_a = if x_a.length.nonzero?
          Absorbers_.new( x_a ).to_a
        end
        @field_box_const ||= CONST_
      end
      def execute
        tch_field_box_method
        @absorber_a and @absorber_a.each do |ab|
          ab.apply_to_client @client
        end

        Touch_post_absorb__[ @client ]
        Touch_facet_muxer__[ @client ]

        Touch_const_with_dupe_for___[ -> _ { Box__.new },
          @field_box_const, @client ]
      end
    private
      def tch_field_box_method
        field_box_const = @field_box_const
        Method_Touch__.touch :field_box, -> do
          self.class.const_get field_box_const
        end, @client
      end
    end

    class Absorbers_
      def initialize x_a
        @x_a = x_a
      end
      def to_a
        reset ; scanner ; a = []
        while (( x = @scanner.gets )) ; a.push x ; end
        is_at_end or raise ::ArgumentError, say_extra
        a
      end
    private
      def reset
        @d = -1 ; @last = @x_a.length - 1
      end
      def is_at_end
        @d == @last
      end
      def say_extra
        "unparsed: '#{ @x_a[ @d + 1 ] }'"
      end
      def scanner
        @scanner ||= bld_scanner
      end
      def bld_scanner
        MetaHell_::Lib_::Scn[].new do
          new_d, item = Absorber_Method_.unobtrusive_passive_scan @d, @x_a
          if new_d
            @d = new_d
            item
          end
        end
      end
    end

    # ~ #curry-friendly support procs

    Touch_const_with_dupe_for___ = -> p, c, mod do
      FUN::Touch_constant_[ false, -> _ do
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
          client.send :define_method, m, & p
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
        if d < i_a.length - 1 && METHOD_OP_H__.key?( i_a.fetch d + 1 )
          new.unobtrsv_passive_scan d, i_a
        end
      end
      def initialize
        @do_globbing = true
        @do_passive = false
        super()
      end
      METHOD_OP_H__ = METHOD_OP_H__.dup
      METHOD_OP_H__.merge!(
        absorber: :prcss_absorber,
        globbing: :prcss_globbing,
        globless: :prcss_globless,
        passive: :prcss_passive,
      ).freeze
      def unobtrsv_passive_scan d, i_a
        @d = d ; @i_a = i_a ; @is_done = false
        begin
          send METHOD_OP_H__.fetch i_a.fetch @d += 1
        end until @is_done
        @method_name or raise ::ArgumentError, "method name required"
        d = @d ; @i_a = @d = nil
        @p = rslv_some_absorber_method
        [ d, self ]
      end
    private
      def prcss_absorber
        @is_done = true
        @method_name = @i_a.fetch @d += 1 ; nil
      end
      def prcss_globbing
        @do_globbing = true ; nil
      end
      def prcss_globless
        @do_globbing = false ; nil
      end
      def prcss_passive
        @do_globbing = false
        @do_passive = true ; nil
      end

    private
      def rslv_some_absorber_method
        if @do_passive
          ABSORB_IAMBIC_PASSIVELY_METHOD__
        elsif @do_globbing
          GLOBBING_ABSORB_METHOD__
        else
          ABSORB_IAMBIC_FULLY_METHOD__
        end
      end
    end

    # ~ implementations of absorber methods

    GLOBBING_ABSORB_METHOD__ = -> * x_a do
      fb = field_box
      while x_a.length.nonzero?
        fld = fb[ x_a.first ]  # custom default proc that raises custom ex.
        x_a.shift
        fld.absorb_into_client_iambic self, x_a
      end
      post_absorb_notify
    end

    ABSORB_IAMBIC_FULLY_METHOD__ = -> x_a do
      absorb_iambic_passively x_a
      x_a.length.nonzero? and field_box[ x_a.first ]
    end

    ABSORB_IAMBIC_PASSIVELY_METHOD__ = -> x_a do
      box = field_box #  ; @last_x = nil
      while x_a.length.nonzero?
        fld = box.fetch x_a.first do end
        fld or break
        x_a.shift
        # m_i = fld.local_normal_name
        # @last_x = m_i  # #todo
        # send m_i, x_a  # change at [#063]
        fld.absorb_into_client_iambic self, x_a
      end ; nil
    end

    PROCESS_IAMBIC_PASSIVELY_METHOD__ = -> do
      self._NOT_USED_YET  # #todo
      fb = field_box
      while @x_a.length.nonzero?
        fld = fb.fetch @x_a.first do end
        fld or break
        @x_a.shift
        send fld.local_normal_name
      end ; nil
    end

    # ~ "foundation" classes ~

    class Box__ < MetaHell::Library_::Basic::Box
      def initialize
        @field_attributes = nil
        super()
        @h.default_proc = -> h, k do
          raise ::ArgumentError, "unrecognized keyword #{ FUN::Parse::
            Strange_[ k ] } - did you mean #{ Lev__[ @a, k ] }?"
        end
      end
      Lev__ = -> a, x do
        MetaHell::Library_::Headless::NLP::EN::Levenshtein::
          Or_with_closest_n_items_to_item.curry[ 3, a, x ]
      end
      def dupe
        a = @a ; h = @h
        self.class.allocate.instance_exec  do
          @field_attributes = nil
          @a = a.dup ; @h = h.dup
          self
        end
      end
      def dupe_for _
        dupe
      end
      def set next_field, *a
        :next_field == next_field or raise ::ArgumentError, 'no'
        @field_attributes and fail "sanity - clobber field attributes?"
        @field_attributes = Field_Attributes__.new( *a )
        nil
      end
      def delete_field_attributes
        if (( fa = @field_attributes ))
          @field_attributes = nil
          fa
        end
      end
      def has_field_attributes
        @field_attributes
      end
    end
    #
    class Field_Attributes__
      MetaHell::FUN.fields[ self, :desc ]
      attr_reader :desc
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
      attr_accessor :desc_p
    end

    # ~ facet muxer (e.g to implement a required fields check hook)

    Touch_post_absorb__ = Method_Touch__.curry :private, :post_absorb_notify,
      -> do
        self.class.facet_muxer.notify :post_absorb, self ; nil
      end

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

    CONST_ = :FIELDS_

  end
end
