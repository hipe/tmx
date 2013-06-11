module ::Skylab::MetaHell

  module Formal::Attribute

    # (note we accidentallly deprecated this with [#ba-003] Field::Box
    # but we should somehow merge them if for no other reason than
    # the below is amusing. below is tracked with :[#mh-024])

    # What is the esssence of all data in the universe? It starts from
    # within. with metaprogramming.
    #
    # Let's take some arbitrary set of name-value pairs, say
    # an "age" / "sex" / "location" of "55" / "male" / "mom's basement";
    # let those be called 'actual attributes'. You could then say that
    # each pairing of that attribute with that value, (e.g an "age of 35")
    # is one "actual attribute" with "age" e.g. being the "attribute name"
    # and "35" being the "attribute value."
    #
    # Now, when dealing with attributes you might want to speak in terms
    # of them in the abstract -- not those actual values, but other
    # occurences of particular values for those attributes. We use the word
    # "formal" to distinguish this meaning, in contrast to "actual" attributes
    # :[#mh-025].
    #
    # For example, we might want to define 'formal attributes' that define
    # some superset of recognizable or allowable names (and possibly values)
    # for the actual attributes. For each such formal attribute, this
    # library lets you define one `Formal::Attribute::Metadata` that will
    # have metadata representig the particular formal attribute.
    #
    # To represent an associated set of such formal attributes, we use a
    # `Formal::Attribute::Box`, which is something like an ordered set
    # of formal attributes. Think of it as an overwrought method signature,
    # or formal function parameters, or a regular expression etc, or
    # superset definition, or map-reduce operation on all possible data etc wat
    # If the name "box" throws you off, just read it as "collection" whenever
    # you see it.
    #
    # To dig down even deeper, this library also lets you (requires you
    # maybe) to stipulate the ways you define attributes themselves.
    #
    # Those are called `Formal::Attribute::MetaAttribute`s, and there is a box
    # for those too..
    #
    # So, in reverse, from the base: you make a box of meta-attributes.
    # This stipulates the allowable meta-attributes you can use when
    # defining attributes.  With these you will then effective define
    # (usually per class) a box of attributes, having been validated by
    # those meta-attributes. Then when you have object of one such class,
    # it will itself have (actual) attributes.
    #
    # (There is this whole other thing with hooks which is where it gets
    # useful..)
    #
    # To round out the terminology, the object that gets blessed with
    # all the dsl magic to create meta attributes and then attributes
    # (and store them!) is known as the "definer" (`Formal::Attribute::Definer`)
    # which is what your class should extend to tap in.
    #
    # It may be confusing, but the library is pretty lightweight
    # for what it does.  Remember this is metahell!
    #
  end

  module Formal::Attribute::Definer
    def self.extended mod # per pattern [#sl-111]
      mod.extend Formal::Attribute::Definer::Methods
      # no instance methods (that is what metaattribute hooks are for)
    end
  end

  module Formal::Attribute::Definer::Methods
                                  # inspect the attributes defined (directly
                                  # or thru parent) in this definer.

                                  # note this is the only method that is
                                  # public out of the box (also your attributes
                                  # are mutable and not themselves protected.)
    def attributes
      @attributes ||= dupe_ancestor_attr :attributes do
        Formal::Attribute::Box.new
      end
    end

  protected
                                  # define an attribute in detail, or the
                                  # existence of several attributes by name.
    def attribute sym, meta_attributes_h=nil
      existing = attributes.fetch( sym ) { nil }     # is a metadata
      delta = get_attribute_metadata_class.new sym   # is a metadata
      if meta_attributes_h        # the delta actually becomes a delta.
        if existing               # getting this right is important - if we
          delta.merge_against! meta_attributes_h, existing # don't it borks
        else                      # the correct order for hook chains
          delta.merge! meta_attributes_h
        end
      end
      if ! existing               # if this is a new attribute, give it
        merge_defaults_into_delta delta # whatever defaults exist at the time
      end
      if ( bad = delta._order - self.meta_attributes._order ).length.nonzero?
        raise "meta attributes must first be declared: #{
          }#{ bad.map(&:inspect) * ', ' }"
      end
      if existing                 # merge the new meta-attributes into an
        existing.merge! delta     # existing attribute
      else
        on_attribute_introduced delta # create the new attribute by settings
        existing = delta          # the default setter / getters (FOR NOW)
      end
      delta.each do |k, v|
        if respond_to?( m = "on_#{ k }_attribute" )
          send m, sym, existing
        end
      end
      nil
    end

    attr_reader :attribute_metadata_class_is_defined

                                  # set the attribute metadata class.
    class_and_block_are_mutex = -> do
      ArgumentError.new "passing class and block are mutually exclusive."
    end

    define_method :attribute_metadata_class do |klass=nil, &block|
      do_define = -> do
        define_singleton_method :get_attribute_metadata_class do
          klass
        end
        @attribute_metadata_class_is_defined = true
      end
      if klass
        if block
          raise class_and_block_are_mutex[]
        elsif attribute_metadata_class_is_defined
          raise "won't clobber existing custom class (for now)"
        else
          do_define[]
        end
      elsif block
        if klass
          raise class_and_block_are_mutex[]
        elsif const_defined? :Attribute_Metadata, false
          raise "won't assume this and won't clobber it. set it explicitly."
        else
          klass = ::Class.new get_attribute_metadata_class
          const_set :Attribute_Metadata, klass
          klass.class_exec(& block)
          do_define[]
        end
      else
        raise "this is not a getter and you cannot nillify the class."
      end
    end

    def dupe_ancestor_attr meth, &default
      p = ancestors[ (self == ancestors.first ? 1 : 0) .. -1 ].detect do |a|
        ::Class === a and a.respond_to? meth
      end
      if p and a = p.send( meth )
        a.dupe
      else
        default[]
      end
    end
                                  # ugly name b.c dsl
    def get_attribute_metadata_class
      Formal::Attribute::Metadata
    end

    def import_meta_attributes_from_module mod
      if mod.const_defined? :InstanceMethods, false
        include mod::InstanceMethods
      end
      mod.meta_attributes.each do |name, meta|
        if respond_to?( meta.hook_name ) || meta_attributes.has?( name )
          fail "implement me: decide clobber behavior"
        end
        if meta.hook
          define_singleton_method meta.hook_name, & meta.hook
        end
        meta_attributes.accept meta # heh
      end
    end

    def merge_defaults_into_delta attr_delta_metadata
      meta_attributes.each do |k, ma|
        if ma.has_default
          if ! attr_delta_metadata.has? ma.local_normal_name
            attr_delta_metadata.add_default ma.local_normal_name, ma.default_value
          end
        end
      end
      nil
    end

    normalize_meta_attribute_args = -> first, rest, b do
      if rest.length.nonzero?
        if ::Hash === rest.last
          first = rest.pop.merge( _unsanitized_name: first )
        elsif ! b and rest.last.respond_to? :call
          b = rest.pop
        end
      end
      if rest.length.nonzero?
        if b
          raise ::ArgumentError, "with block form, only pass 1 #{
            }meta_attribute, not #{ all.length }"
        end
        rest.reduce( [ [ first ] ] ) do |m, x| m << [ x ] ; m end
      else
        [ [ first, b ] ]
      end
    end

    arg_error = -> x do
      ::ArgumentError.new "cannot define a meta attribute with #{ x.class }"
    end

    define_method :meta_attribute do |first, *rest, &b|
      # (this method signature is heavily overloaded not just to be dsl-ly
      # bc honestly that is kind of annoying here, it is because we want
      # `meta_attributes` (the plural form, with an 's') to be always the
      # getter and never a setter for the same reason of not liking overloaded
      # method signatures. so it is an unintended irony here.)

      meta_attributes = self.meta_attributes # tiny opt. & debugging nicety
      pairs = normalize_meta_attribute_args[ first, rest, b ]
      pairs.each do |attr_ref, func|
        if func
          ::Symbol === attr_ref or raise arg_error[ attr_ref ]
          # truncate the args if for e.g. the hook doesn't need metadata
          limit = func.arity > 0 ? -> a { a[0, func.arity] } : -> a { a }
          define_singleton_method "on_#{ attr_ref }_attribute" do |*a|
            instance_exec( * limit[ a ] , &func)
          end
          meta_attributes.vivify( attr_ref ).hook = func
        else
          case attr_ref
          when ::Symbol          # no block just a name.
            meta_attributes.vivify! attr_ref # this may be too strict
          when ::Hash
            meta_attributes.vivify_from_hash attr_ref  # validates
          when ::Module
            import_meta_attributes_from_module attr_ref
          else
            raise arg_error[ attr_ref ]
          end
        end
      end
      nil
    end
                                  # retrieve the box that represents the
                                  # metaattributes defined for this definer
                                  # creating it lazily.
    def meta_attributes
      @meta_attributes ||= dupe_ancestor_attr :meta_attributes do
        Formal::Attribute::MetaAttribute::Box.new
      end
    end
    public :meta_attributes       # #important - for 2.0.0

    def on_attribute_introduced attr
      attr.local_normal_name.tap do |name|
        if ! method_defined? name
          attr_reader name
          public name
        end
        if ! method_defined? "#{ name }="
          attr_writer name
          public "#{ name }="
        end
      end
      attributes.accept attr
      nil
    end
    public :on_attribute_introduced
  end

                                  # a meta attribute is of course an attribute's
                                  # attribute. users can define them.
                                  # e.g. `default`, `required`, these are
                                  # common meta-attributes.  I know what you're
                                  # thinking and the answer is no.
  class Formal::Attribute::MetaAttribute

    def default= x
      @has_default = true
      @default_value = x
    end

    def default_value
      @has_default or raise 'sanity - no default - check `has_default` first'
      @default_value
    end

    def dupe                      # the definer itself will call this when
      new = self.class.new @local_normal_name # building definitions.
      new.hook = @hook
      new.default = @default_value if @has_default
      new
    end

    attr_reader :has_default

    attr_reader :hook

    def hook= func
      @hook and fail "implement me: clobbering of existing hooks"
      @hook = func
    end

    def hook_name
      "on_#{ @local_normal_name }_attribute"
    end

    attr_reader :local_normal_name

  protected

    def initialize local_normal_name
      @local_normal_name = local_normal_name
      @has_default = nil
      @default_value = nil
      @hook = nil
    end
  end

  # but when you have a collection of meta-attributes, where do *they* go!?
  # note this looks a lot like an attribute metadata, and might as well be
  # one, except that it is for representing collections of meta-attributes
  # that should be applied to all new attributes, which is similar but not
  # the same as an attribute metadata (for one thing it does not have a name
  # associated with it.) but notwithstanding it might should go away. imagine
  # a prototype metadata instead of this..
  class Formal::Attribute::MetaAttribute::Box < Formal::Box

    public :accept                # used in definer logic

    public :dupe                  # used in definer logic

    def vivify attr_ref
      if? attr_ref, -> x { x }, -> { vivify! attr_ref }
    end

    def vivify! attr_ref          # create the new and add it, result is new el
      ma = Formal::Attribute::MetaAttribute.new attr_ref
      add ma.local_normal_name, ma
      ma
    end

    arg_err = -> msg do
     raise ::ArgumentError, msg
    end

    define_method :vivify_from_hash do |h|     # mutates hash `h`
      mattr = nil
      begin
        attr_ref = h.delete :_unsanitized_name
        if ! ( ::Symbol === attr_ref )
          break( arr_err[ "meta_attribute name not provided." ] )
        end
        if h.key? :default
          has_default = true
          default_value = h.delete :default
        end
        if h.size.nonzero?
          break( arg_err[ "unsupported meta-meta-attribute(s) - #{
            }(#{ h.keys.map ', ' }) (the buck must stop somewhere.)" ] )
        end
        mattr = vivify attr_ref
        if has_default
          mattr.default = default_value        # ok to clobber previous default
        end
      end while nil
      mattr
    end
  end
                                  # metadata about an attribute is itself a
                                  # box, it is a box of meta-attributes.
  class Formal::Attribute::Metadata < Formal::Box

    def add_default name, val     # this is internal
      x = dupe_constituent_value val
      add name, x
      nil
    end

    def dupe
      nn = @local_normal_name
      super.instance_exec do
        @local_normal_name = nn
        self
      end
    end

    # merge the hash-like `enum_x` into self whereby for each element if
    # self has? an element with the name, change it else add it.
    def merge! enum_x
      enum_x.each do |k, v|
        if? k,
          -> x { change k, v },
          -> { add k, v }
      end
      nil
    end

    # merge the hash-like `enum_x` into self whereby if the `compare`
    # box already has an element with name, **add** the element iff it
    # != the existing one. this allows us to make minimal deltas, a
    # logical requirement.
    def merge_against! enum_x, compare
      enum_x.each do |k, v|
        compare.if? k,
          -> x { add( k, v ) if x != v }, # will crap out on clobber! #todo
          -> { add k, v }
      end
      nil
    end

    attr_reader :local_normal_name  # used here by `accept`, may also be used by
                                  # subclasses by clients e.g to make a custom
                                  # derived property, like a label.
  protected

    def initialize local_normal_name
      fail "sanity - all metadatas must have a sybolic name" if !
        ( ::Symbol === local_normal_name )
      super()
      @local_normal_name = local_normal_name
      nil
    end
  end

                                  # simply an ordered collection of formal
                                  # attributes. think of it as a method
                                  # signature..
                                  # (sister class: Parameter::Set)
  class Formal::Attribute::Box < Formal::Box

                                  # hash-like convenience constructor allows
                                  # you to make an arbitrary ad-hoc attribute
                                  # set intuitively with familiar primitives.
                                  # note this does not care about metaattibutes.
    def self.[] h_enum            # also there is a sinful "optimization" we
      new = self.new              # throw in just to be jerks.
      new.instance_exec do
        h_enum.each do |k, h|
#         attr = Formal::Attribute::Metadata.new k # this should work but
#         attr.merge! h                            # OHAI HOW ABOUT THIS:
          attr = Formal::Attribute::Metadata.allocate
          attr.instance_exec do
            @local_normal_name = k
            @order = h.keys
            @hash = h
          end                                      # WAT COULD GO WRONG
          accept attr
        end
      end
      new
    end

    public :accept                # (used in definer logic)

    public :dupe                  # definer calls this directly

    # result is a new box whose every element represents every element from
    # this box that has? `metaattribute`. Every element in the result box
    # will have a name that corresponds to the name used for the original
    # element in the original box, but the new element's value is the
    # value of the original box element's `metaattribute` value., .e.g:
    #   Foo.attributes #=>
    #     {:age=>{:default=>1}, :sex=>{:default=>:banana}, :location=>{}}
    #
    #   Foo.attributes.meta_attribute_value_box :default #=>
    #     {:age=>1, :sex=>:banana}
    #

    def meta_attribute_value_box mattr_name
      with( mattr_name ).box_map { |x| x[mattr_name] }
    end

    # `with` - wrapper around: produce a new enumerator that filters for only
    # those attributes that has? `mattr_name`. note it does not care if those
    # meta-attribute values are trueish, only if they `has?` that meta-attribute
    # in the box. (a most common use case is defaults - sometimes defaults are
    # nil or false. this is different than a formal attribute not having
    # a default set.).

    def with mattr_name, &block
      ea = filter -> x { x.has? mattr_name }
      block ? ea.each(& block ) : ea
    end

    # `which` - #experimental (we are considering adding a `with`-like ability
    # to use a mattr name instead of a block, so it would be like a `with`
    # with an extra true-ish check. but only if necessary)
    #

    alias_method :which, :filter

  protected

    # nothing is protected. constructor takes 0 arguments.
  end
end
