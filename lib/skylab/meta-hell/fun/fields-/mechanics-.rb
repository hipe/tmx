module Skylab::MetaHell

  module FUN::Fields_::Mechanics_

    # this is now the center of metahell. these are the tools of metahell.
    # an extension node - know its implications [#046]. lots of puffers [#048]
    # abstracted from siblings, whence comes its coverage

    def self.touch ; end

  end

  module FUN::Fields_

    #  ~ internal support ~

    Puff_method_ = -> a, p, client do  # #curry-friendly

      # a    ::= flag * <method-name>
      # flag ::= override | private | public
      #
      # define this method with this visibility on this client if possible,
      # without clobbering an existing method of the same name you mean not
      # to clobber (for our definition of "mean" defined below), where
      # "if possible" is determined by what is already defined, where it is
      # defined, and what flags you passed:
      #
      # when method is already defined and the method owner is the selfsame
      # client, no action is ever taken. (for, to redefine existing methods
      # on the same module is never the intended behavior.)
      #
      # when method is already defined by some module in the ancestor chain,
      # behavior depends on whether or not the `override` flag was passed: in
      # the absensce of the `override` flag, no action is taken. otherwise,
      # the puffer will redefine the method setting its visibility to private
      # if indicated, else public (which may be indicated explicitly but is
      # also the default).
      #
      # to understand the utility of the above, consider the case of the
      # `initialize` method, defined by ruby as a private instance method of
      # BasicObject: to (re) defined such a method with the puffer you must
      # pass the `override` flag. (and the visiblity of the newly defined
      # version will be determined by the visibility you do (or don't)
      # indicate).
      #
      # the syntax is such that an infinite number of flags can be provided
      # and (in the case of visiblity) only the last one "wins". the allows
      # for methods that puff to take in arguments from the "outside" that
      # may potentially override defaults provided in the "inside"; so that
      # for e.g. some code may puff a method to be private unless the client
      # (caller) wants it to be public.

      a = [ * a ]  # necessary to dup `a` for when it is curried!
      m = a.pop or fail "sanity - method name is required"
      meth = Method_Attributes_.new
      while a.length.nonzero?
        PUFF_METHOD_OP_H_.fetch( a.shift )[ meth ]
      end
      meth.priv_pub ||= :public
      if client.method_defined? m or client.private_method_defined? m
        if client != client.instance_method( m ).owner
          yes = meth.do_override
        end
      else
        yes = true
      end
      if yes
        client.send :define_method, m, & p
        :private == meth.priv_pub and client.send :private, m
      end
      nil
    end
    #
    Method_Attributes_ = ::Struct.new :priv_pub, :do_override
    #
    PUFF_METHOD_OP_H_ = {
      private: -> method { method.priv_pub = :private },
      public: -> method { method.priv_pub = :public },
      override: -> method { method.do_override = true }
    }.freeze

    Puff_singleton_method_ = -> priv_pub, m, p, client do  # #curry-friendly
      sc = client.singleton_class
      if ! ( sc.method_defined? m or sc.private_method_defined? m )
        client.define_singleton_method m, & p
        :private == priv_pub and sc.send :private, m
      end
      nil
    end

    Puff_client_and_give_box__ =
        -> field_box_const, absorb_method_x, client do
      Puff_field_box_method_[ field_box_const, client ]
      Puff_method_[ [ :private, * absorb_method_x ],
                    Absorb_method_[ field_box_const ], client ]
      Puff_absorb_notify_[ client ]
      Puff_facet_muxer_[ client ]
      Puff_post_absorb_[ client ]
      Puff_const_with_dupe_for_[ -> _ { Box_.new }, field_box_const, client ]
    end
    #
    Puff_field_box_method_ = -> field_box_const, client do
      Puff_method_[
        :field_box, -> { self.class.const_get field_box_const }, client ]
    end
    #
    Absorb_method_ = -> field_box_const do
      -> *a do
        box = self.class.const_get field_box_const
        while a.length.nonzero?
          fld = box[ a[ 0 ] ] or raise ::KeyError, "key not found - #{ a[0] }"
          a.shift
          fld.absorb self, a
        end
        post_absorb_notify
        nil
      end
    end
    #
    Puff_absorb_notify_ = Puff_method_.curry[ :absorb_notify, -> a do
      # (note field can be from either school)
      op_box = field_box
      @last_x = nil
      while a.length.nonzero?
        (( fld = op_box.fetch( a.first ) { } )) or break
        a.shift
        @last_x = (( m = fld.local_normal_name ))
        send m, a
      end
      nil
    end ]
    #
    Puff_const_with_dupe_for_ = -> p, c, mod do
      FUN::Puff_constant_[ false, -> _ do
        if mod.const_defined? c
          mod.const_get( c ).dupe_for mod
        else
          p[ mod ]
        end
      end, c, mod, nil ]
    end
    #
    Puff_facet_muxer_ = Puff_const_with_dupe_for_.curry[
      -> cli do
        Puff_facet_muxer_reader_[ cli ]
        Free_Muxer_.new cli
      end,
      :FIELD_FACET_MUXER_ ]
    #
    Puff_facet_muxer_reader_ = Puff_singleton_method_.
        curry[ :public, :facet_muxer, -> do
      const_get :FIELD_FACET_MUXER_  # inherit
    end ]
    #
    Puff_post_absorb_ = Puff_method_.
        curry[ [ :private, :post_absorb_notify ], -> do
      self.class.facet_muxer.notify :post_absorb, self
      nil
    end ]

    #  ~ lib ~

    CONST_ = :FIELDS_

    Puff_client_and_give_box_ = Puff_client_and_give_box__.curry[ CONST_ ]

    #  ~ "foundation" classes ~

    class Box_ < MetaHell::Services::Basic::Box
      def initialize
        @field_attributes = nil
        super()
        @h.default_proc = -> h, k do
          raise ::ArgumentError, "unrecognized keyword #{ FUN::Parse::
            Strange_[ k ] } - did you mean #{ Lev__[ @a, k ] }?"
        end
      end
      Lev__ = -> a, x do
        MetaHell::Services::Headless::NLP::EN::Levenshtein::
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
        @field_attributes = Field_Attributes_.new( *a )
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
    class Field_Attributes_
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

    class Free_Muxer_
      def initialize client
        @client = client
        @h = nil
      end

      def dupe_for x
        self.class.allocate.base_init x, @h
      end

      def base_init client, h
        @h = ( h.dupe if h )
        @client = client
        self
      end
      protected :base_init

      def notify event_i, agent
        if @h and (( a = @h[ event_i ] ))
          a.each do |p|
            p[ agent ]
          end
        end
        nil
      end

      def add_hook_listener i, p
        ( ( @h ||= { } )[ i ] ||= [ ] ) << p
        nil
      end
    end

    class Method_Added_Muxer_
      # imagine having multiple subscribers to one method added event
      def self.[] mod
        me = self
        mod.module_exec do
          @method_added_muxer ||= begin  # ivar not const! boy howdy watch out
            muxer = me.new self
            singleton_class.instance_method( :method_added ).owner == self and
              fail "sanity - won't overwrite existing method_added hook"
            define_singleton_method :method_added, &
              muxer.method( :method_added_notify )
            muxer
          end
        end
      end
      def initialize mod
        @p = nil
        @mod = mod
      end
      def in_block_each_method_added blk, &do_this
        @p and fail "implement me - you expected this to actually mux?"
        @p = do_this
        @mod.module_exec( & blk )
        @p = nil
      end
    private
      def method_added_notify i
        @p && @p[ i ]
        nil
      end
    end
  end
end
