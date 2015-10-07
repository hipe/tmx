module Skylab::TMX

  # adapters for the [br] reactive model

  module Model_

    class Showcase_as_Unbound

      attr_reader(
        :name_function,
      )

      def initialize nf, ss_mod

        @name_function = nf
        @_ss_mod = ss_mod
      end

      def adapter_class_for moda
        @_last_moda = moda  # ick/meh
        self
      end

      def new _self, bound_parent_action, & x_p

        Home_.const_get( @_last_moda, false ).const_get( :Showcase_as_Bound ).
          new bound_parent_action, @name_function, @_ss_mod, & x_p
      end
    end

    module Common_Bound_Methods

      # because we aren't mucking with brazen reactive node API, redundant

      def is_visible
        true
      end

      def name_value_for_order
        @nf_.as_const  # b.c already calculated
      end

      def after_name_value_for_order
        NIL_
      end

      def has_description
        true
      end

      def name
        @nf_
      end
    end
  end
end
