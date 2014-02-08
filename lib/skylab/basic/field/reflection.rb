module Skylab::Basic::Field::Reflection

  Basic = ::Skylab::Basic

  Reflection = self

  module Reflection

    def self.enhance target
      flsh = Kernel_.new target
      cond = Shell_.new( -> host do
        flsh.host = host
      end )
      if block_given?
        raise ::ArgumentError, "this contained DSL only employs the #{
          }one-off shooter for currently (do not use blocks. call #{
          }`with` on the result of the enhance() call.)"
      else
        Shell_::One_Shot_.new cond, -> { flsh.flush }
      end
    end

    def self.[] kls  # i'm sorry
      self::For::Class[ kls ]
    end
  end

  Shell_ = Basic::Lib_::Enhancement_shell[ %i( with ) ]

  Kernel_ = Basic::Lib_::Functional_methods.call :flush do

    def initialize target
      @host = nil

      @flush = -> do
        ( host = @host ) or fail "sanity"
        host.field_box.init_for_field_reflection_if_necessary

        target.module_exec do
          define_singleton_method :field_reflection_target do host end
        end
        build_into target
        nil
      end
    end

    attr_writer :host

    def build_into target  # assume @host
      host = @host
      im_mod =
      if host.const_defined? :FIELD_BOX_HOST_INSTANCE_METHODS_, false
              host.const_get :FIELD_BOX_HOST_INSTANCE_METHODS_, false
      else    host.const_set :FIELD_BOX_HOST_INSTANCE_METHODS_, (

        ::Module.new.module_exec do

          include Reflection::InstanceMethods

          host::METAFIELDS_.each do |mf|
            mf.is_reflective or next
            i = mf.binary_predicate or next

            define_method "#{ mf.local_normal_name }_fields" do
              field_box.fields_which i
            end

            define_method "#{ mf.local_normal_name }_field_names" do
              field_box.field_names_which i
            end

            define_method "#{ mf.local_normal_name }_fields_bound" do
              fields_bound_which i
            end
          end

          self
        end )
      end
      target.send :include, im_mod
      nil
    end
  end

  Field = Basic::Field

  class Field::Binary::Meta_Field_
    alias_method :binary_predicate, :as_is_predicate
  end

  class Field::Property::Meta_Field_
    alias_method :binary_predicate, :as_has_predicate
  end

  module Reflection::InstanceMethods

    # (this module augments a module with generated methods.)

    # `has_field_box` - make it easy for objects of participating classes
    # to indicate whether or not they have been enhances by fields
    # (and meta-fields)

    def has_field_box
      true
    end

    def field_names
      field_box.field_names
    end

    def fields_which i
      field_box.fields_which i
    end

    def fields_which_not i
      field_box.fields_which_not i
    end

    def field_box
      self.class.field_reflection_target.field_box
    end

    def fields_bound_to_ivars
      fields_bound_to_ivars_which :is_exist
    end

    def fields_bound_to_ivars_which predicate
      ::Enumerator.new do |y|
        field_box.fields_which( predicate ).each do |fld|
          y << Bound_.new( fld, ->{ instance_variable_get fld.as_host_ivar } )
        end
        nil
      end
    end
  end

  class Bound_

    attr_reader :field

    def local_normal_name
      @field.local_normal_name
    end

    Basic::Lib_::Function[ self, :@value_p, :value ]

    def initialize field, value_p
      @field, @value_p = field, value_p
    end
  end

  module Box_Methods  # LOOK

    #    ~ implement the reflection, the core of the whole thing ~
    #       NOTE this is acheived (for now) by monkeypatching,
    #       but should be fine. these methods belong there!

    def init_for_field_reflection_if_necessary
      @fields_which_h ||= begin
        @fields_which_not_h = { }
        @field_names_which_h = { }
        { }  # egads
      end
      nil
    end

    def fields_which predicate
      @fields_which_h.fetch predicate do
        @fields_which_h[ predicate ] = which( & predicate ).to_a.freeze
      end
    end

    def fields_which_not predicate
      @fields_which_not_h.fetch predicate do
        @fields_which_not_h[ predicate ] = which do |fld|
          ! fld.send predicate
        end.to_a.freeze
      end
    end

    def field_names_which predicate
      @field_names_which_h.fetch predicate do
        @field_names_which_h[ predicate ] = which( & predicate ).
          map( & :local_normal_name ).freeze
      end
    end

    def field_names
      field_names_which :is_exist
    end
  end

  # NOTE monkeypatching within the library..

  class Basic::Field
    def is_exist  # convenience for selecting all fields
      true
    end
  end

  class Basic::Field::Box  # NOTE reopen!
    include Box_Methods
  end
end
