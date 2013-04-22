module Skylab::Basic

  class Field

    # immutable

    def self.[] name, * x_a
      new name, * x_a
    end

    attr_reader :name, :as_ivar
    alias_method :as_method, :name

    def is_exist
      true
    end

    class Metafield_

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

    METAFIELDS_ = MetaHell::Formal::Box::Open.new
    METAFIELDS_.accept Metafield_[ :required ]
    METAFIELDS_.accept Metafield_[ :body ]
    METAFIELDS_.freeze
    METAFIELDS_.each do |mf|
      attr_reader mf.predicate
    end

  protected

    -> do
      a = [ ] ; h = { }
      METAFIELDS_.each do |k, mf|
        a << ( ivar = mf.ivar )
        h[ k ] = -> do
          instance_variable_set ivar, true
        end
      end

      define_method :initialize do |name, *x_a|
        @name = name
        @as_ivar = "@#{ name }".intern
        a.each { |ivar| instance_variable_set ivar, false }
        x_a.each { |k| instance_exec( & h.fetch( k ) ) }
        freeze
        nil
      end
    end.call
  end

  class Field::Box < MetaHell::Formal::Box

    def self.[] * field_a_a
      new field_a_a
    end

    def self.of host, box
      host.module_exec do
        include Field::Box::Host::InstanceMethods
        define_singleton_method :field_box do box end
        nil
      end
      nil
    end

    def fields_which predicate
      @fields_which_h.fetch predicate do
        @fields_which_h[ predicate ] = which( & predicate ).to_a.freeze
      end
    end

    def field_names
      field_names_which :is_exist
    end

    def field_names_which predicate
      @field_names_which_h.fetch predicate do
        @field_names_which_h[ predicate ] = which( & predicate ).
          map( & :name ).freeze
      end
    end

  protected

    def initialize field_a_a
      super( )
      @fields_which_h = { }
      @field_names_which_h = { }
      field_a_a.each do |field_a|
        field = Field[ * field_a ]
        add field.name, field
      end
      nil
    end
  end

  module Field::Box::Host
  end

  module Field::Box::Host::InstanceMethods

    def field_box
      self.class.field_box
    end

    def field_names
      field_box.field_names
    end

    Field::METAFIELDS_.each do |mf|

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

    def fields_bound_which predicate
      ::Enumerator.new do |y|
        field_box.fields_which( predicate ).each do |fld|
          y << Field::Bound.new( fld, method( fld.as_method ) )
        end
        nil
      end
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
end
