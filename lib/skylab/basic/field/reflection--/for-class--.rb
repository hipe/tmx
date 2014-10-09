module Skylab::Basic

  module Field::Reflection::For::Class

    # an #experimental generic method-added hack divorced from parent node

    def self.[] kls
      kls.extend MM_
      kls.init_for_basic_field_reflection
      nil
    end

    module MM_

      def inherited kls
        kls.init_for_basic_field_reflection
        kls.const_set :FIELD_PARENT_, self
        kls.extend MM_::Child_Class_Overwrite_
        super
      end

      def init_for_basic_field_reflection
        instance_variable_defined? :@do_record_derived_fields and fail 'no'
        @do_record_derived_fields = false
        @derived_field_i_a = []
        nil
      end

      def derived_fields
        p = @do_record_derived_fields
        @do_record_derived_fields = true
        yield
        @do_record_derived_fields = p
        nil
      end

      def fields
        if const_defined? :FIELDS_, false  # each class has its own copy
          const_get :FIELDS_, false
        else
          const_set :FIELDS_, get_fields
        end
      end

      def get_fields  # #base-version - will be called by children
        _get_fields dsl_fields.dup  # ok because of #api-point [#mh-032]
      end

      module Child_Class_Overwrite_
        def get_fields  # #child-version - will be called by children
          _get_fields const_get( :FIELD_PARENT_, false ).get_fields
        end
      end

    private

      def method_added m
        if @do_record_derived_fields
          @derived_field_i_a << m
        end
        super
      end

      def _get_fields y
        @derived_field_i_a.each do |i|
          y << Derived_Field_.new( i )
        end
        y
      end
    end

    class Derived_Field_
      def initialize normal
        @normal = normal
      end
      attr_reader :normal
    end
  end
end
