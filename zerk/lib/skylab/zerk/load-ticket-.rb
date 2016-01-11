module Skylab::Zerk

  class Load_Ticket_

    # the load ticket (as a class) exists to implement custom views - it
    # encapsulates and delivers whatever characteristics are desired for
    # the human-facing client that cannot be expressed or inferred by the
    # ACS, like special hotstrings or custom-made UI components.
    #
    # "load ticket" replaces a role that was formerly served by
    # "qualified knownness" so there remains an amount of delegation that
    # is perhaps conspicuous.

    class Primitive_Custom_View__

      def initialize p

        @_custom_hotstring_pieces = nil

        _a = p[]
        _a.each_slice 2 do | k, x |
          if x.respond_to? :each_pair
            send k, x
          else
            send k, * x
          end
        end
      end

      # -- DSL

      def hotstring_delineation s, s_, s__
        @_custom_hotstring_pieces = [ s, s_, s__ ]
        NIL_
      end

      # --

      def custom_hotstring_structure_for lt
        a = @_custom_hotstring_pieces
        if a
          @_custom_hotstring_pieces = :_used_  # etc..
          Home_::Expression_Adapters_::Buttonesque.new( * a, lt )
        end
      end
    end

    class Compound_Custom_View < Primitive_Custom_View__

      # -- DSL

      def children x
        @custom_tree_for = x ; nil
      end

      def custom_view_controller x
        @_custom_view_controller_proc = x ; nil
      end

      # --

      attr_reader(
        :custom_tree_for,
        :_custom_view_controller_proc,
      )
    end

    def self.[] x, qkn
      if qkn.association.model_classifications.looks_primitivesque
        Prim___.new x, qkn
      else
        Comp___.new x, qkn
      end
    end

    def initialize qkn

      @prepared_ = false
      @_qkn = qkn

      @association = qkn.association
      @name = qkn.name
    end

    def custom_hotstring_structure
      @prepared_ || prepare_
      @_custom_hotstring_structure
    end

    # -- delegations

    def category_symbol
      @association.model_classifications.category_symbol
    end

    def description_proc
      @association.description_proc
    end

    def is_effectively_known
      @_qkn.is_effectively_known
    end

    def is_known_known
      @_qkn.is_known_known
    end

    def value_x
      @_qkn.value_x
    end

    attr_reader(
      :association,
      :name,
    )

    class Prim___ < self

      def initialize customization_x, qkn

        @_customization_x = customization_x
        super qkn
      end

      def prepare_

        x = remove_instance_variable :@_customization_x
        if x
          pcv = Primitive_Custom_View__.new x
          @_custom_hotstring_structure = pcv.custom_hotstring_structure_for self
        else
          @_custom_hotstring_structure = nil
        end
        NIL_
      end

      def looks_primitivesque
        true
      end
    end

    class Comp___ < self

      def initialize customization_x, qkn
        @_customization_x = customization_x
        super qkn
      end

      def compound_custom_view
        @prepared_ or prepare_
        @_ccv
      end

      def prepare_

        @prepared_ = true

        x = remove_instance_variable :@_customization_x
        if x
          ccv = Compound_Custom_View.new x
          @_custom_hotstring_structure = ccv.custom_hotstring_structure_for self
          @custom_view_controller_proc = ccv._custom_view_controller_proc
          @_ccv = ccv
        else
          @_ccv = NIL_
          @_custom_hotstring_structure = nil
        end

        NIL_
      end

      attr_reader(
        :custom_view_controller_proc,
      )

      def looks_primitivesque
        false
      end
    end
  end
end
