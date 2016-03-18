module Skylab::Basic

  class Field  # see [#003]

    # ~ narrative pre-order with aesthetic pyramiding

    class << self

      def box * a, & p
        if a.length.zero?
          Box__
        else
          Box__.via_client_and_proc( * a, p )
        end
      end

      def meta_field_factory
        Meta_Field_Factory__
      end

      def N_meta_resolver
        N_Meta_Resolver__
      end

      def reflection * a
        if a.length.zero?
          Field_::Reflection__
        else
          Field_::Reflection__[ * a ]
        end
      end
    end

  class Box__

    class << self

      def [] * a
        bx = new
        bx._init_via_fields a
        bx
      end

      def via_client mod, & p
        via_client_and_proc mod, p
      end

      def via_client_and_proc mod, p

        build_into mod, p
        mod.define_singleton_method :field_box do
          const_get :FIELDS_, false
        end
      end

      def build_into mod, p

        krnl = Kernel__.new mod, self

        _shell = Shell__.
          new  -> * meta_p_a { krnl.concat_metafields meta_p_a },
            -> * field_a { krnl.concat_fields field_a },
            -> p_ { krnl.field_class_instance_methods p_ }

        _shell.instance_exec( & p )

        krnl.flush
      end
    end  # >>

    def initialize
      @bx = Callback_::Box.new
    end

    def _init_via_fields fld_a
      fld_a.each do | fld |
        @bx.add fld.local_normal_name, fld
      end ; nil
    end

    # ~ don't subclass box ever. but the below might be a good case for etc.

    def length
      @bx.length
    end

    def to_name_stream
      @bx.to_name_stream
    end

    def to_value_stream
      @bx.to_value_stream
    end

    def each_value & p
      @bx.each_value( & p )
    end

    def each_pair & p
      @bx.each_pair( & p )
    end

    def at * a
      @bx.at( * a )
    end

    def reduce_by & p
      @bx.to_value_stream.reduce_by do | fld |
        p[ fld ]
      end.to_enum
    end

    def fetch k, & p
      @bx.fetch k, & p
    end

    def accept_field fld
      @bx.add fld.local_normal_name, fld
    end

    def add i, x
      @bx.add i, x
    end

  end  # ..

  Shell__ = Home_.lib_.enhancement_shell %i(
    meta_fields
    fields
    field_class_instance_methods
  )

  class Kernel__

    def initialize host_mod, box_kls
      @metafield_a = [ ] ; @field_a = nil ; @im = nil
      @target = host_mod ; @box_kls = box_kls
    end

    def concat_metafields a
      @metafield_a.concat a
      nil
    end

    def concat_fields a
      ( @field_a ||= [ ] ).concat a
      nil
    end

    def field_class_instance_methods f
      @im and fail "sanity - collision, already had #{ @im }"
      @im = f
      nil
    end

    # `flush` - the fourth center of the universe has been found.
    # see note at [#013] about an infinite stack of metafields.

    def flush
      field_a = @field_a ; @field_a = nil
      metafield_a = @metafield_a ; @metafield_a = nil

      n_meta_resolver = N_Meta_Resolver__.new

      field_a ||= [ ]  # one day we might try to skip over empty field box..
      n_meta_resolver.push field_a, -> x do
        @target.const_set :FIELDS_, x
      end

      n_meta_resolver.push metafield_a, -> x do
        @target.const_set :METAFIELDS_, x
      end, -> x do
        @im and x.send :include, @im.call
        @target.const_set :FIELD_, x
      end

      n_meta_resolver.seed Meta_Field_Factory__

      n_meta_resolver.flush
    end
  end

  class N_Meta_Resolver__  # this is the implementation of [#013]

    def initialize
      @stack = [ ]
    end

    def push fields_a=nil, box_callback=nil, field_callback=nil
      @stack << [ fields_a, box_callback, field_callback ]
      nil
    end

    def seed up_field
      @seed = up_field
    end

    def flush
      count = 0
      if @stack.length.nonzero?
        up_x = @seed ; @seed = nil
        begin
          depth = @stack.length
          fields_a, box_cb, field_cb = @stack.pop ; count += 1
          fields_a or break
          box = up_x.make_field_box fields_a, depth
          box_cb and box_cb[ box ]
          @stack.length.zero? and break
          # don't produce a field class for the set of fields (e.g `is_email`)
          kls = box.produce
          if field_cb
            field_cb[ kls ]
          end
          up_x = kls
        end while true
      end
      count
    end
  end

  Produce_Methods__ = ::Module.new

  class Box__
    include Produce_Methods__

    def produce base=Field
      produce_field_class base, self
    end
  end

  module Produce_Methods__  # #todo - cleanup - (it is hard to follow what the base
                   # class is)

    def produce_field_class base, box
      ::Class.new( base ).class_exec do
        box.frozen? or box = box.dup.freeze  #  ( we don't need `dupe` )
        const_set :FIELDS_, box
        box.each_value do |fld|
          fld.enhance self
        end
        def initialize( (*x_a), depth=1 )
          super( * x_a[ 0..0 ] )
          if 1 < x_a.length
            scn = Home_::List.line_stream x_a
            scn.gets  # toss first match that was handled above
            begin
              i = scn.gets
              fld = fields.fetch i do raise( * key_error( depth, i ) ) end
              fld.mutate self, scn
            end while ! scn.eos?
          end
        end
        self
      end
    end
  end

  # (you are in the field class)

    def initialize nn
      @local_normal_name = nn
    end

    attr_reader :local_normal_name

    class << self

      def make_field_box field_a, depth
        bx = Box__.new
        field_a.each do | x |
          fld = make_field x, depth
          bx.accept_field fld
        end
        bx
      end

      def make_field x_a, depth
        new x_a, depth
      end
    end

    def fields
      self.class.const_get :FIELDS_, false
    end

    def key_error depth, x
      field = "#{ 'meta-' * ( depth ) }field"
      reason = if fields.length.zero?
        "this nerk takes no #{ field }s"
      else
        "expecting #{ fields.to_name_stream.map_by{ |x_| "\"#{ x_ }\"" }.to_a * ' or ' }"
      end
      [ ::KeyError,
        "no such #{ field } \"#{ x }\" - #{ reason } (#{ self.class }) " ]
    end
    private :key_error

    def [] k
      send fields.fetch( k ).as_is_predicate
    end

    def as_host_ivar
      @as_host_ivar ||= :"@#{ @local_normal_name }"
    end


  # each metafield a user defines will be built using one of two classes,
  # based on the meta meta fields of that meta field: - the meta meta
  # field in question is `property`. if the meta field takes a property,
  # its inflection is different (`has_foo` instead of `is_foo`). we implement
  # this different logic with classes and a simple factory pattern.

  Binary__ = ::Module.new
                                         # binary was the first and is still
                                         # the brightest star. this here is
                                         # its simple base impl.
                                         # (we need a basic binary field class
  class Binary__::Field__ < self         # separate from the metafield class
                                         # because binary fields are used to..
    def enhance mod
      i = as_is_predicate
      mod.module_exec do
        attr_reader i
      end
    end                                  # represent the meta meta fields. in
                                         # other words, binary fields are used..
    def as_is_predicate
      @is_predicate ||= :"is_#{ @local_normal_name }"
    end                                  # for both meta fields and meta meta
                                         # fields...

    def absorb_into_client_scan client, _
      client.instance_variable_set as_is_predicate_ivar, true ; nil
    end

    def mutate inst, _scn
      inst.instance_variable_set as_is_predicate_ivar, true ; nil
    end

    def as_is_predicate_ivar
      @is_predicate_ivar ||= :"@#{ as_is_predicate }"
    end
  end

  class Hook_Meta_Meta_Field__ < Binary__::Field__

    def initialize
      super :hook
    end

    def mutate property_metafield, scn
      :mutate == (( i = scn.fetchs )) or fail "sanity - for now #{
         }there is only one hookpoint - #{ i }"
      (( p = scn.fetchs )).respond_to?( :call ) or fail "sanity - proc? #{ p }"
      property_metafield.hook_notify :mutate, p
      nil
    end
  end

  meta_meta_field_box = Box__[
    Binary__::Field__.new( :reflective ),  # this is the first ever Field instance
    Binary__::Field__.new( :property ),
    Hook_Meta_Meta_Field__.new
  ]

  Binary__::Meta_Field__ = meta_meta_field_box.produce Binary__::Field__

  Property__ = ::Module.new

  Property__::Meta_Field__ = meta_meta_field_box.produce

  class Property__::Meta_Field__

    def enhance mod
      i = as_has_predicate
      j = as_value_predicate
      has = as_has_predicate
      val = as_value_ivar
      nn = @local_normal_name
      mod.module_exec do
        attr_reader i
        define_method j do
          if send has
            instance_variable_get val
          else
            raise "\"#{ nn }\" is undefined for \"#{ @local_normal_name }\" #{
              }so this call to `#{ j }` is meaningless - #{
              }use `#{ has }` to check this before calling `#{ j }`."
          end
        end
      end
      nil
    end

    def as_has_predicate
      @has_predicate ||= :"has_#{ @local_normal_name }"
    end

    def as_has_predicate_ivar
      @as_has_predicate_ivar ||= :"@#{ as_has_predicate }"
    end

    def as_value_predicate
      @value_predicate ||= :"#{ @local_normal_name }_value"
    end

    def as_value_ivar
      @value_ivar ||= :"@#{ @local_normal_name }_value"
    end

    def absorb_into_client_iambic client, x_a
      set_val client, x_a.shift ; nil
    end

    def absorb_into_client_scan client, scan
      set_val client, scan.gets_one ; nil
    end

    def mutate inst, scn
      scn.eos? and raise "expecting a property (any value) after :property"
        # if scn is not eos then e.g. hook
      set_val inst, scn.gets
      if has_hooks && (( p = @hook_box.fetch :mutate do end ))
        p[ inst ]
      end ; nil
    end

    def set_val client, x
      client.instance_variable_set as_has_predicate_ivar, true
      client.instance_variable_set as_value_ivar, x
      nil
    end

    def hook_notify name_x, p
      (( @hook_box ||= begin
        @has_hooks = true
        Home_::Box.new
      end )).add name_x, p
      nil
    end

    attr_reader :has_hooks
  end

  class Meta_Field_Factory__ < self  # (we just want some of its class methods)

    def self.make_field( (*x_a), depth )  # we need a factory
      H__[ x_a[ 1 ] || :binary ].make_field x_a, depth
    end
    H__ = {
      binary: Binary__::Meta_Field__,
      reflective: Binary__::Meta_Field__,
      property: Property__::Meta_Field__
    }
    H__.default_proc = -> _, k do
      raise ::KeyError, "no such meta-meta-field \"#{ k }\""
    end
    H__.freeze
  end

    Field_ = self
  end
end
