module Skylab::MetaHell

  class Formal::Attribute < Callback_::Box # read [#024] the form. #storypoint-5

    module Definer

      def self.[] mod
        DSL[ mod ]
        mod.module_exec EMPTY_A_, & Bundles::Attributes.to_proc ; nil
      end

      def self.extended mod  # :+#deprecation:until-universal-unification
        DSL[ mod ] ; nil
      end
    end

    module Bundles
      Meta_attributes = -> a do
        DSL[ self ]  # for now
        meta_attribute( * a.shift )
        nil
      end

      Attributes = -> a do  # #idempotent
        include Reflection_IM__
        if a.length.nonzero?
          module_exec a, & Parse_the_attributes__
        end
      end
    end
    #
    Parse_the_attributes__ = -> a do
      g = if const_defined? :Item_Grammar__, false
        self::Item_Grammar__
      else
        const_set :Item_Grammar__, module_exec( & Build_item_grammar___ )
      end

      pa = g.simple_stream_of_items_via_polymorpic_array a

      begin
        sp = pa.gets
        sp or break
        h = { }
        sp.adj and sp.adj.keys.each { |i| h[ i ] = true }
        sp.pp and sp.pp.each_pair { |i, x| h[ i ] = x }
        attribute sp.keyword_value_x, h
        redo
      end while nil
      NIL_
    end

    Build_item_grammar___ = -> do

      mono_i_a = []
      diad_i_a = []

      which_h = {
        1 => mono_i_a,
        2 => diad_i_a
      }

      meta_attributes.each do | matr |

        p = matr.hoop_p

        _d = if p
          p.arity
        else
          1
        end

        which_h.fetch( _d ).push matr.local_normal_name
      end

      MetaHell_.lib_.parse::Item_Grammar.new mono_i_a, :attribute, diad_i_a
    end

    DSL = -> mod do
      mod.extend Formal::Attribute::Definer::Methods
      # no instance methods - that is what meta-attributes are for
      nil
    end
  end

  module Formal::Attribute::Definer::Methods  # #storypoint-10

    def attributes
      @attributes ||= bld_attributes
    end

  private

    def bld_attributes
      dupe_ancestor_attr :attributes do
        Formal::Attribute::Box.new
      end
    end

    def attribute i, matr_h=nil  # #storypoint-15
      exist = attributes[ i ]
      delta = atr_metadata_class.new i
      if matr_h
        if exist
          delta.merge_against! matr_h, exist
        else
          delta.merge! matr_h
        end
      end
      exist or merge_defaults_into_delta delta

     a = delta.a_ - self.meta_attributes.a_
     if a.length.nonzero?
       raise say_matr_not_declared a
     end

      if exist
        exist.merge! delta
      else
        on_attribute_introduced delta
        exist = delta
      end
      delta.each_pair do |k, v|
        m_i = :"on_#{ k }_attribute"
        respond_to? m_i or next
        prcss_hook exist, i, k, m_i
      end ; nil
    end

    def say_matr_not_declared bad_i_a
      "meta attributes must first be declared: #{
        }#{ bad_i_a.map( & :inspect ) * ', ' }"
    end

    def prcss_hook exist, i, k, m_i
      a = [ i ]
      hook = meta_attributes[ k ].hook_p
      if ! (( hook and 2 != hook.arity ))
        a << exist
      end
      send m_i, * a ; nil
    end

    public ; attr_reader :attribute_metadata_class_is_defined ; private

    def attribute_metadata_class cls=nil, &p
      do_define = -> do
        define_singleton_method :atr_metadata_class do
          cls
        end
        @attribute_metadata_class_is_defined = true
      end
      if cls
        if p
          raise Class_and_block_are_mutex__[]
        elsif attribute_metadata_class_is_defined
          raise "won't clobber existing custom class (for now)"
        else
          do_define[]
        end
      elsif p
        if cls
          raise Class_and_block_are_mutex__[]
        elsif const_defined? :Attribute_Metadata, false
          raise "won't assume this and won't clobber it. set it explicitly."
        else
          cls = ::Class.new atr_metadata_class
          const_set :Attribute_Metadata, cls
          cls.class_exec( & p )
          do_define[]
        end
      else
        raise "this is not a getter and you cannot nillify the class."
      end
    end

    Class_and_block_are_mutex__ = -> do
      ArgumentError.new "passing class and block are mutually exclusive."
    end

    def dupe_ancestor_attr meth_i, & else_p
      anc_a = ancestors
      self == anc_a.first and anc_a.shift
      cls = anc_a.detect do |anc|
        ::Class === anc and anc.respond_to? meth_i
      end
      if cls
        x = cls.send meth_i
      end
      if x
        x.dup
      else
        else_p[]
      end
    end

    def atr_metadata_class
      Formal::Attribute
    end

    def merge_defaults_into_delta atr_delta_metadata
      meta_attributes.each_pair do | k, ma |
        if ma.has_default
          if ! atr_delta_metadata.has_name ma.local_normal_name
            atr_delta_metadata.add_dflt ma.local_normal_name, ma.default_value
          end
        end
      end
      nil
    end

    def meta_attribute first, * rest, & p  # #storypoint-30
      matrs = meta_attributes
      pair_a = Normalize_meta_attribute_args__[ first, rest, p ]
      pair_a.each do |atr_x, p_|
        p_ and next prcss_meta_attribute_proc atr_x, p_
        atr_x.respond_to? :id2name and next matrs.touch_matr_w_nm atr_x
        ::Hash.try_convert( atr_x ) and next matrs.touch_matr_w_hash atr_x
        ::Module === atr_x and next imprt_matrs_from_module atr_x
        raise Arg_error__[ atr_x ]
      end ; nil
    end

    Normalize_meta_attribute_args__ = -> first, rest, p do
      if rest.length.nonzero?
        if ::Hash.try_convert rest.last
          first = rest.pop.merge( _unsanitized_name: first )
        elsif ! p and rest.last.respond_to? :call
          p = rest.pop
        end
      end
      if rest.length.nonzero?
        p and  raise ::ArgumentError, "with block form, only pass 1 #{
          }meta_attribute, not #{ all.length }"
        rest.reduce( [ [ first ] ] ) do |m, x| m << [ x ] ; m end
      else
        [ [ first, p ] ]
      end
    end

    def prcss_meta_attribute_proc atr_i, p
      atr_i.respond_to?( :id2name ) or raise Arg_error__[ atr_i ]
        # truncate the args if for e.g. the hook doesn't need metadata
      compress_p = Build_compressor__[ p.arity ]
      define_singleton_method :"on_#{ atr_i }_attribute" do |*a|
        instance_exec( * compress_p[ a ] , & p )
      end
      _matr = meta_attributes.touch_matr_w_nm atr_i
      _matr.set_hook_p p ; nil
    end

    def imprt_matrs_from_module mod
      mod.const_defined?( :InstanceMethods, false ) and
        include mod::InstanceMethods
      matrs = meta_attributes
      mod.meta_attributes.each_pair do |i, matr|
        respond_to?( matr.hook_name ) || matrs.has_name( i ) and
          fail "implement me: decide clobber behavior"
        p = matr.hook_p
        p and define_singleton_method matr.hook_name, p
        matrs.accept_matr matr
      end ; nil
    end

    Arg_error__ = -> x do
      ::ArgumentError.new "cannot define a meta attribute with #{ x.class }"
    end

    Build_compressor__ = -> d do
      if d < 1 then IDENTITY_ else
        -> a { a[ 0, d ] }
      end
    end

  public

    def meta_attributes  # #storypoint-35
      @meta_attributes ||= bld_meta_attributes
    end
  private
    def bld_meta_attributes
      dupe_ancestor_attr :meta_attributes do
        Formal::Attribute::Matrs__.new
      end
    end
  public

    def on_attribute_introduced atr
      is_reader_was_specified = true
      is_reader = atr.fetch :reader do is_reader_was_specified = nil ; true end
      is_reader && ! method_defined?( r_m_i = atr.local_normal_name ) &&
        attr_reader( r_m_i )
      is_writer = atr.fetch :writer do
        ! ( is_reader_was_specified && is_reader )
      end
      is_writer && ! method_defined?( atr.writer_method_name ) &&
        write_attribute_writer( atr )
      attributes.accept_atr atr ; nil
    end

  private

    def write_attribute_writer atr
      attr_writer atr.reader_method_name
    end
  end

  class Formal::Attribute::Matr__  # #storypoint-40

    def initialize local_normal_name
      @default_value = @has_default = nil
      @hook_name = :"on_#{ local_normal_name }_attribute"
      @hook_p = nil
      @local_normal_name = local_normal_name ; nil
    end
    attr_reader :has_default, :hook_name, :hook_p, :local_normal_name

    # ~ :+[#021] a typical base class implementation:
    def dupe
      dup
    end
    def initialize_copy otr
      init_copy( * otr.get_args_for_copy ) ; nil
    end
  protected
    def get_args_for_copy
      [ @default_value, @has_default, @hook_name, @hook_p, @local_normal_name ]
    end
  private
    def init_copy * five
      @default_value, @has_default, @hook_name, @hook_p, @local_normal_name =
        five ; nil
    end
    # ~

  public

    def default_value
      @has_default or raise 'sanity - no default - check `has_default` first'
      @default_value
    end

    def set_hook_p p
      @hook_p and fail "implement me: clobbering of existing hooks"
      @hook_p = p ; nil
    end

    def default= x
      @has_default = true
      @default_value = x
    end
  end

  class Formal::Attribute::Matrs__ < Callback_::Box  # #storypoint-50

    def a_  # read only!
      @a
    end

    def touch_matr_w_hash h  # mutates
      name_i = h.delete(:_unsanitized_name) or raise ::ArgumentError, say_no_nm
      has_default = true
      default_value = h.fetch :default do has_default = false end
      if has_default
        h.delete :default
      end
      h.length.zero? or raise ::ArgumentError, say_buck_stop( h )
      matr = touch_matr_w_nm name_i
      has_default and matr.default = default_value  # clobber OK
      matr
    end
  private
    def say_no_nm
      "meta_attribute name not provided"
    end
    def say_buck_stop h
      "unsupported meta-attribute(s): (#{ h.keys * ', ' })"
    end
  public

    def touch_matr_w_nm atr_i
      touch atr_i do
        Formal::Attribute::Matr__.new atr_i
      end
    end

    def accept_matr matr
      add matr.local_normal_name, matr ; nil
    end
  end

  class Formal::Attribute  #re-open, is a Box subclass  # #storypoint-60

    def initialize local_normal_name
      local_normal_name.respond_to?( :id2name ) or self._sanity_
      @local_normal_name = local_normal_name
      super()
    end

    attr_reader :local_normal_name

    def a_  # read only!
      @a
    end

    def reader_method_name
      @local_normal_name
    end

    def writer_method_name
      @writer_method_name ||= :"#{ @local_normal_name }="
    end

    def ivar
      @ivar ||= :"@#{ @local_normal_name }"
    end

    def is? i
      if has_name i
        self[ i ]
      end
    end

    def merge! enum_x  # #storypoint-75
      enum_x.each_pair do |k, v|
        set k, v
      end
      nil
    end

    def merge_against! enum_x, compare  # will crap out on clobber! #todo

      o = compare.algorithms

      enum_x.each_pair do |k, v|
        o.if_has_name k,
          -> x do
            if x != v
              add( k, v )
            end
          end,
          -> do
            add k, v
          end
      end
      nil
    end

    def add_attribute_attribute atr_atr_i, atr_atr_x
      add atr_atr_i, atr_atr_x ; nil
    end

    def change_attribute_attribute_value atr_atr_i, atr_atr_x
      change atr_atr_i, atr_atr_x ; nil
    end

    def add_dflt name, val
      # add name, MetaHell_.lib_.basic.dup_mixed( val )
      add name, val
    end
  end

  class Formal::Attribute::Box < Callback_::Box  # #storypoint-90

    def self.[] i_h_pair_a  # #storypoint-95
      me = new
      me.init_from_i_h_pair_a i_h_pair_a
      me
    end

    def initialize_copy _otr
      # we need our dup to be one level deeper that what [cb] does (covered)
      super
      @a.each do | sym |
        @h[ sym ] = @h.fetch( sym ).dup
      end
      nil
    end

    def init_from_i_h_pair_a i_h_pair_a
      i_h_pair_a.each do |i, h|
        atr = Formal::Attribute.allocate
        atr.initialize_atr_spcl i, h
        accept_atr atr
      end ; nil
    end

    def accept_atr atr
      add atr.local_normal_name, atr ; nil
    end

    def meta_attribute_value_box matr_i  # #storypoint-105
      bx = Callback_::Box.new
      each_pair do | k, atr |
        if atr.has_name matr_i
          bx.add k, atr[ matr_i ]
        end
      end
      bx
    end

    def reduce_with matr_i, & p  # #storypoint-110
      ea = reduce_by do | x |
        x.has_name matr_i
      end
      p ? ea.each( & p ) : ea
    end

    def reduce_by & p

      # we can't use simply `to_value_stream`[..]`to_enum` because
      # the enumerator needs to be re-runnable (covered)

      ::Enumerator.new do | y |
        st = to_value_stream.reduce_by do | x |
          p[ x ]
        end
        while x = st.gets
          y.yield x
        end
        nil
      end
    end

    def select & p  # covered

      # argument semantics like `reduce_by`, but like ::Array#select and
      # ::Hash#select result in an object of same class as receiver

      otr = self.class.new
      each_pair do | k, x |
        if p[ x ]
          otr.add k, x
        end
      end
      otr
    end

    def map & p  # #only-because-covered
      to_value_stream.map_by( & p ).to_a
    end

    def each_pair & p
      if p
        super
      else
        to_enum :each_pair
      end
    end
  end

  class Formal::Attribute

    def initialize_atr_spcl i, h
      @a = h.keys
      @local_normal_name = i
      @h = h
      nil
    end

    module Reflection_IM__

      def get_names  # #comport to #box-API
        attribute_definer.attributes.get_names
      end
      #
      def fetch i, &p  # #storypoint-135

        atr = attribute_definer.attributes.fetch( i ) { }
        if atr
          x = send atr.reader_method_name
          did = if x.nil?
            atr.has_name :default
          else
            true
          end
        end
        if did then x elsif p then p.call else
          raise ::KeyError.exception "key not found: #{ i.inspect }"
        end
      end

    private

      def get_bound_attribute i
        Bound_Attribute__.
          new get_bound_attribute_reader, formal_attributes.fetch( i )
      end

      def bound_attributes
        to_enum :each_bound_attribute
      end

      def each_bound_attribute
        scn = get_bound_attribute_stream
        while (( ent = scn.gets ))
          yield ent
        end
        nil
      end

      def get_bound_attribute_stream
        Bound_Attributes_Scanner__.
          new formal_attributes, get_bound_attribute_reader
      end

      def get_bound_attribute_reader
        @bound_attr_reader_p ||= -> atr do
          send atr.reader_method_name
        end
      end

      def formal_attributes
        attribute_definer.attributes
      end

      def attribute_definer  # #storypoint-175
        self.class
      end
    end

    class Bound_Attributes_Scanner__
      def initialize atr_box, reader_p
        @p = -> do
          a, h = atr_box._raw_constituency ; d = 0 ; len = a.length
          (( @p = -> do
            if d < len
              atr = h.fetch( a.fetch d ) ; d += 1
              Bound_Attribute__.new reader_p, atr
            end
          end )).call
        end
      end
      def gets ; @p.call end
    end

    class Bound_Attribute__
      def initialize reader_p, atr
        @reader_p = reader_p ; @atr = atr
      end

      def attribute
        @atr
      end

      def value
        @reader_p[ @atr ]
      end

      %i( [] fetch has_name local_normal_name ).each do |i|
        define_method i do |*a, &p|
          @atr.send i, *a, &p
        end
      end
    end
  end
end
