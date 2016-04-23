module Skylab::Zerk

  class InteractiveCLI

  class Load_Ticket_

    # the load ticket (as a class) exists to implement custom views - it
    # encapsulates and delivers whatever characteristics are desired for
    # the human-facing client that cannot be expressed or inferred by the
    # ACS, like special hotstrings or custom-made UI components.
    #
    # (a note of history, this existed as a concept before "node ticket".)
    #
    # "load ticket" replaces a role that was formerly served by
    # "qualified knownness" so there remains an amount of delegation that
    # is perhaps conspicuous.

    class << self

      def [] x, nt, moda_frame

        _ = Node_ticket_3_category_[ nt ]
        _cls = This_.const_get NT3___.fetch _
        _cls.new x, nt, moda_frame
      end
    end  # >>

    NT3___ = {
      compound: :Compound___,
      entitesque: :Entitesque___,
      primitivesque: :Primitivesque___,
    }

    # ==

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
          Here_::Buttonesque_Expression_Adapter_.new( * a, lt )
        end
      end
    end

    # ==

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

    # ==

    class Compound___ < self

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

    class Entitesque___ < self

      def prepare_
        _prepare_by_processing_any_customization_as_primitivesque
        NIL_
      end

      def looks_primitivesque
        true
      end
    end

    class Primitivesque___ < self

      def prepare_
        _prepare_by_processing_any_customization_as_primitivesque
        NIL_
      end

      def looks_primitivesque
        true
      end
    end

    # ==
    # -

      def initialize cust_x, nt, moda_frame

        @association = nt.association
        @_customization_x = cust_x
        @_moda_frame = moda_frame
        @name = nt.name
        @_nt = nt
        @prepared_ = false
      end

      def custom_hotstring_structure
        @prepared_ || prepare_
        @_custom_hotstring_structure
      end

      def _prepare_by_processing_any_customization_as_primitivesque
        x = remove_instance_variable :@_customization_x
        if x
          pcv = Primitive_Custom_View__.new x
          @_custom_hotstring_structure = pcv.custom_hotstring_structure_for self
        else
          @_custom_hotstring_structure = nil
        end
        NIL_
      end

      #==== THREE THINGS

      def to_qualified_knownness__
        @_moda_frame.qualified_knownness_for__ @_nt
      end

      def to_knownness__
        @_moda_frame.knownness_for__ @_nt
      end

      #====

      # -- delegations

      def category_symbol
        @association.model_classifications.category_symbol
      end

      def description_proc
        @association.description_proc
      end

      # --

      attr_reader(
        :association,
        :name,
      )
    # -
    # ==

    This_ = self
  end

  end
end
