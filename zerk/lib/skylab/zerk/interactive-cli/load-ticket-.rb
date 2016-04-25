module Skylab::Zerk

  class InteractiveCLI

    class Load_Ticket_

      # the load ticket stands as an adapter between ACS component and the
      # (mostly generated) human-facing client, for the exact purpose of
      # interpreting, representing and delivering characteristics that the
      # latter is concerned with that the former does not itself express,
      # like special hotstrings or custom-made UI components.
      #
      # it is called "load ticket" because (like a ticket to see a movie at
      # the movie theatre) it represents a means of getting to a particular
      # thing, but it does not embody the thing itself; rather it will load
      # the thing for you (perhaps lazily). (a movie ticket is the sole
      # means through which you get to the movie, but it is not the case
      # that the movie ticket *is* the movie.)
      #
      # (a note of history, this existed as a concept before "node ticket",
      # but is almost indiscernably similar in its description.)

      class << self

        def [] x, nt, moda_frame

          _ = Node_ticket_4_category_[ nt ]
          _cls = This_.const_get NT3___.fetch _
          _cls.new x, nt, moda_frame
        end
      end  # >>

      NT3___ = {
        compound: :Compound___,
        entitesque: :Entitesque___,
        operation: :Operation___,
        primitivesque: :Primitivesque___,
      }

      # <-

    ## ==== the custom view implementors (they implemet that one DSL)

    # ==

    class Common_Custom_View__

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

    private  # DSL

      def hotstring_delineation s, s_, s__
        @_custom_hotstring_pieces = [ s, s_, s__ ]
        NIL_
      end

    public

      def custom_hotstring_structure_for lt
        a = @_custom_hotstring_pieces
        if a
          @_custom_hotstring_pieces = :_used_  # etc..
          Here_::Buttonesque_Expression_Adapter_.new( * a, lt )
        end
      end
    end

    # ==

    class Compound_Custom_View < Common_Custom_View__

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

    ## ==== the subjects

    class Compound___ < self

      def compound_custom_view
        @_prepare && _prepare
        @_ccv
      end

      def _prepare

        @_prepare = false

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

      def description_proc  # as #here
        @node_ticket.association.description_proc
      end

      attr_reader(
        :custom_view_controller_proc,
      )

      def looks_primitivesque
        false
      end
    end

    class Operation___ < self

      def _prepare
        _prepare_commonly
      end

      def four_category_symbol
        :operation
      end

      def looks_primitivesque
        false
      end
    end

    Atomesque__ = ::Class.new self

    class Entitesque___ < Atomesque__
      # (hi.)
    end

    class Primitivesque___ < Atomesque__
      # (hi.)
    end

    class Atomesque__

      def initialize cust_x, nt, moda_frame
        @association = nt.association
        super
      end

      def _prepare
        _prepare_commonly
      end

      def to_qualified_knownness__
        @_moda_frame.qualified_knownness_for__ @node_ticket
      end

      def to_knownness__
        @_moda_frame.knownness_for__ @node_ticket
      end

      def description_proc  # :#here
        @association.description_proc
      end

      def four_category_symbol
        @association.model_classifications.category_symbol
      end

      attr_reader(
        :association,
      )

      def looks_primitivesque
        true
      end
    end

    # ==

    # ->

      def initialize cust_x, nt, moda_frame

        @_customization_x = cust_x
        @_moda_frame = moda_frame
        @name = nt.name
        @node_ticket = nt
        @_prepare = true
      end

      def custom_hotstring_structure
        @_prepare && _prepare
        @_custom_hotstring_structure
      end

      def _prepare_commonly

        @_prepare = false
        x = remove_instance_variable :@_customization_x
        if x
          _ = Common_Custom_View__.new x
          @_custom_hotstring_structure = _.custom_hotstring_structure_for self
        else
          @_custom_hotstring_structure = nil
        end
        NIL_
      end

      # --

      attr_reader(
        :name,
        :node_ticket,
      )

      This_ = self
    end
  end
end
