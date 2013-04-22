module Skylab::Basic

  class Field  # ( re-opened below )

  end

  #         ~ narrative pre-order with aesthetic pyramiding ~

  class Field::Box < MetaHell::Formal::Box::Open

    def self.enhance host_mod, & def_blk

      box = Field::Box.build_into host_mod, def_blk

      host_mod.define_singleton_method :field_box do box end

    end

    def self.build_into host_mod, def_blk

      mf_box = host_mod.const_set :METAFIELDS_, MetaHell::Formal::Box::Open.new
      box = host_mod.const_set :FIELDS_, new( host_mod )
      fields_a = [ ]

      Conduit_.new(
        ->( * meta_f_a ) do
          meta_f_a.each do |i|
            ::Symbol === i or fail "sanity - metafield? - #{ i.class }"
            mf_box.accept Meta::Field[ i ]
          end
          nil
        end,
        ->( * flds_a ) do
          fields_a = flds_a
          nil
        end
      ).instance_exec( & def_blk )
      mf_box.freeze

      field_class = host_mod.const_set( :FIELD_, Field.produce( mf_box ) )
      fields_a.each do |field_a|
        ::Symbol === field_a.fetch( 0 ) or fail "sanity - #{ field_a[0].class }"
        field = field_class.new( * field_a )
        host_mod.const_set(
          "#{ field.normalized_name.to_s.upcase }_FIELD_", field )
        box.accept field
      end
      box
    end

    Conduit_ = MetaHell::Enhance::Conduit.new %i| meta_fields fields |

    # ( `Field::Box` reopens below .. )
  end

  class Meta::Field

    # ( immutable. )

    class << self
      alias_method :[], :new
    end

    attr_reader :normalized_name, :ivar, :predicate

    def initialize stem
      @normalized_name = stem
      @ivar = "@is_#{ stem }".intern
      @predicate = "is_#{ stem }".intern
      freeze
    end
  end

  class Field

    def self.produce mf_box
      ::Class.new( self ).class_exec do
        mf_box.each do |mf|
          attr_reader mf.predicate
        end
        -> do
          a = [ ] ; h = { }
          mf_box.each do |k, mf|
            a << ( ivar = mf.ivar )
            h[ k ] = -> do
              instance_variable_set ivar, true
            end
          end

          define_method :initialize do |normalized_name, *x_a|
            @normalized_name = normalized_name
            @as_ivar = "@#{ normalized_name }".intern
            a.each { |ivar| instance_variable_set ivar, false }  # TODO
            x_a.each { |k| instance_exec( & h.fetch( k ) ) }
            freeze
            nil
          end
        end.call
        self
      end
    end

    attr_reader :normalized_name, :as_ivar
    alias_method :as_method, :normalized_name

    def is_exist  # convenience for selecting all fields
      true
    end
  end

  module Field::Box::Host

    def self.enhance host_mod
      cnd = Conduit_.new( -> fld_bx do
        host_mod.module_exec do
          define_singleton_method :field_box do fld_bx end
        end
        nil
      end )
      flush = -> do
        build_into host_mod, host_mod.field_box
        nil
      end
      if block_given?
        raise ::ArgumentError, "this contained DSL only employs the #{
          }one-off shooter for currently (do not use blocks. call #{
          }`with` on the result of the enhance() call.)"
      else
        Conduit_::One_Shot_.new cnd, flush
      end
    end

    def self.build_into target_mod, field_box
      host_mod = field_box.host_module
      im_mod =
      if host_mod.const_defined? :FIELD_BOX_HOST_INSTANCE_METHODS_, false
              host_mod.const_get :FIELD_BOX_HOST_INSTANCE_METHODS_, false
      else    host_mod.const_set :FIELD_BOX_HOST_INSTANCE_METHODS_, (
        ::Module.new.module_exec do
          include Field::Box::Host::InstanceMethods

          host_mod::METAFIELDS_.each do |mf|

            pred = mf.predicate

            define_method "#{ mf.normalized_name }_fields" do
              field_box.fields_which pred
            end

            define_method "#{ mf.normalized_name }_field_names" do
              field_box.field_names_which pred
            end

            define_method "#{ mf.normalized_name }_fields_bound" do
              fields_bound_which pred
            end
          end
          self
        end )
      end
      target_mod.send :include, im_mod
      nil
    end

    Conduit_ = MetaHell::Enhance::Conduit.new %i| with |
  end

  module Field::Box::Host::InstanceMethods

    # (this module augments a module with generated methods.)

    def fields_bound_which predicate
      ::Enumerator.new do |y|
        field_box.fields_which( predicate ).each do |fld|
          y << Field::Bound.new( fld, method( fld.as_method ) )
        end
        nil
      end
    end

    def field_box
      self.class.field_box
    end

    def field_names
      field_box.field_names
    end
  end

  class Field::Bound

    attr_reader :field

    def value
      @func.call
    end

    def initialize field, func
      @field, @func = field, func
    end
  end

  class Field::Box  # ( re-opened with focus on utility methods )

    def initialize host_module
      super( )
      @host_module = host_module
      @fields_which_h = { }
      @field_names_which_h = { }
      nil
    end

    attr_reader :host_module

    #         ~ implement the reflection, the core of the whole thing ~

    def field_names_which predicate
      @field_names_which_h.fetch predicate do
        @field_names_which_h[ predicate ] = which( & predicate ).
          map( & :name ).freeze
      end
    end

    def fields_which predicate
      @fields_which_h.fetch predicate do
        @fields_which_h[ predicate ] = which( & predicate ).to_a.freeze
      end
    end

    def field_names
      field_names_which :is_exist
    end
  end
end
