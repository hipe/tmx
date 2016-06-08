module Skylab::Brazen

  class CLI

    # ~ for [#066] a modality-only action adapter

    Backless = ::Module.new

    class Backless::Backless_Unbound_Action

      def initialize ada_cls

        @_ada_cls = ada_cls
        @name_function = Common_::Name.via_module ada_cls
      end

      attr_reader :name_function

      def silo_module
        NIL_
      end

      def is_branch
        false
      end

      def adapter_class_for _
        NIL_
      end

      # ~

      def new bnd, & x_p
        @_ada_cls::Backless_Bound_Action.new bnd, self, & x_p
      end
    end

    class Backless::Backless_Bound_Action

      include Home_::Nodesque::Methods::Bound_Methods

      def initialize bnd, mock_unb, & x_p
        @_bnd = bnd
        @_mock_unb = mock_unb
        @_x_p = x_p
      end

      def accept_parent_node x
        @_par_nod = x
        NIL_
      end

      def description_proc
        @___dp ||= ___build_description_proc
      end

      def ___build_description_proc

        me = self
        -> y do
          me.describe_into_under y, self  # #hook-out
        end
      end

      def formal_properties
        @__fp ||= produce_formal_properties
      end

      def name
        @_mock_unb.name_function
      end
    end
  end
end
