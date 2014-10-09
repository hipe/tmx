class Skylab::Basic::Field

  Basic = ::Skylab::Basic

  Field = self  # :[#003]

  #         ~ narrative pre-order with aesthetic pyramiding ~

  class Field::Box < Basic::Lib_::Formal_Box_Open[]

    def self.[] *a
      b = new
      a.each do |fld|
        b.accept fld
      end
      b
    end

    def self.enhance host_mod, & def_blk

      build_into host_mod, def_blk

      host_mod.define_singleton_method :field_box do
        const_get :FIELDS_, false
      end

    end

    def self.build_into host_mod, def_blk

      flsh = Kernel_.new host_mod, self

      Shell_.new( ->( * meta_f_a ) { flsh.concat_metafields meta_f_a },
                    ->( * fields_a ) { flsh.concat_fields fields_a },
                    ->( f          ) { flsh.field_class_instance_methods f },
                  ).
        instance_exec( & def_blk )

      flsh.flush
    end

    Shell_ = Basic::Lib_::Enhancement_shell[ %i(
      meta_fields
      fields
      field_class_instance_methods
    ) ]
  end   # ( `Field::Box` reopens below .. )

  class Kernel_

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

      n_meta_resolver = N_Meta_Resolver_.new

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

      n_meta_resolver.seed Meta_Field_Factory_

      n_meta_resolver.flush
    end
  end

  class N_Meta_Resolver_  # this is the implementation of [#013]

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
          fields_a or break  # [#fa-049]
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

  module Produce_
  end

  class Field::Box
    include Produce_

    def produce base=Field
      produce_field_class base, self
    end
  end

  module Produce_  # #todo - cleanup - (it is hard to follow what the base
                   # class is)

    def produce_field_class base, box
      ::Class.new( base ).class_exec do
        box.frozen? or box = box.dup.freeze  #  ( we don't need `dupe` )
        const_set :FIELDS_, box
        box.each do |fld|
          fld.enhance self
        end
        def initialize( (*x_a), depth=1 )
          super( * x_a[ 0..0 ] )
          if 1 < x_a.length
            scn = Basic::List::Scanner[ x_a ]
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

  class Field

    def initialize nn
      @local_normal_name = nn
    end

    attr_reader :local_normal_name

    class << self

      def make_field_box field_a, depth
        b = Field::Box.new
        field_a.each do | x |
          fld = make_field x, depth
          b.accept fld
        end
        b
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
        "expecting #{ fields.names.map { |y| "\"#{ y }\""} * ' or ' }"
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
  end

  # each metafield a user defines will be built using one of two classes,
  # based on the meta meta fields of that meta field: - the meta meta
  # field in question is `property`. if the meta field takes a property,
  # its inflection is different (`has_foo` instead of `is_foo`). we implement
  # this different logic with classes and a simple factory pattern.

  module Binary                          # binary was the first and is still
  end                                    # the brightest star. this here is
                                         # its simple base impl.
                                         # (we need a basic binary field class
  class Binary::Field < Field            # separate from the metafield class
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

  class Hook_Meta_Meta_Field_ < Binary::Field

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

  meta_meta_field_box = Field::Box[
    Binary::Field.new( :reflective ),  # this is the first ever Field instance
    Binary::Field.new( :property ),
    Hook_Meta_Meta_Field_.new
  ]

  Binary::Meta_Field_ = meta_meta_field_box.produce Binary::Field

  module Property
  end

  Property::Meta_Field_ = meta_meta_field_box.produce
  class Property::Meta_Field_

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
        Basic::Box.new
      end )).add name_x, p
      nil
    end

    attr_reader :has_hooks
  end

  class Meta_Field_Factory_ < Field  # (we just want some of its class methods)

    def self.make_field( (*x_a), depth )  # we need a factory
      H_[ x_a[ 1 ] || :binary ].make_field x_a, depth
    end
    H_ = {
      binary: Binary::Meta_Field_,
      reflective: Binary::Meta_Field_,
      property: Property::Meta_Field_
    }
    H_.default_proc = -> _, k do
      raise ::KeyError, "no such meta-meta-field \"#{ k }\""
    end
    H_.freeze
  end
end
