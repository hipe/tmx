module Skylab::Zerk

  class InteractiveCLI

    class Load_Ticket_  # read [#039]

      class << self

        def [] x, nt, moda_frame

          _ = Node_ticket_4_category_[ nt ]
          _cls = This_.const_get NT3___.fetch _
          _cls.new x, nt, moda_frame
        end
      end  # >>

      NT3___ = {
        compound: :NonRoot_Compound___,
        entitesque: :Entitesque___,
        operation: :Operation___,
        primitivesque: :Primitivesque___,
      }

      Common_Customization_DSL__ = ::Class.new ::BasicObject

      class Common_Customization_DSL__

        def initialize lt, a_p
          @load_ticket = lt
          @proc = a_p
        end

        def execute

          if 1 == @proc.arity
            __when_newschool
          else
            __when_oldschool
          end
        end

        def __when_newschool
          @proc[ self ]  # wahoo
          NIL_
        end

        def __when_oldschool

          x = @proc.call
          a = ::Array.try_convert x
          a or ::Kernel.raise ___say( x )
          a.each_slice 2 do |k, x_|
            __send__ k, x_
          end
          NIL_
        end

        def ___say x
          "needed array had #{ x.class } for '#{ @load_ticket.name.name_symbol }'"
        end

      # -- DSL

        def hotstring_delineation s_a
          @load_ticket.__receive_custom_hotstring_pieces s_a ; nil
        end

        def on_change x
          @load_ticket.__receive_on_change x ; nil
        end
      end

      COMMON_LEAF_INITIALIZE__ = -> cust_a_p, node_ticket, modality_frame do
        @_customization_a_p = cust_a_p
        @_moda_frame = modality_frame
        @name = node_ticket.name
        @node_ticket = node_ticket
        @_prepare = true
      end

      NonRoot_Methods__ = ::Module.new

      Compound__ = ::Class.new self

      class NonRoot_Compound___ < Compound__

        include NonRoot_Methods__

        define_method :initialize, COMMON_LEAF_INITIALIZE__

        def four_category_symbol
          :compound
        end
      end

      class Root < Compound__

        # (only for when customizations on root frame)

        def initialize a_p
          Compound_Customization_DSL__.new( self, a_p ).execute
        end
      end

      class NonRoot_NonCompound__ < self

        include NonRoot_Methods__

        define_method :initialize, COMMON_LEAF_INITIALIZE__
      end

      module NonRoot_Methods__

        def custom_hotstring_structure
          @_prepare && _prepare
          @_custom_hotstring_structure
        end

        def _prepare
          @_custom_hotstring_structure = nil
          super
        end

        def __receive_custom_hotstring_pieces a
          @_custom_hotstring_structure = Here_::Buttonesque_Expression_Adapter_.new( * a, self )
          NIL_
        end

        def node_ticket
          @node_ticket  # (hi.)
        end

        def name
          @name  # (hi.)
        end
      end

      # --

      class Compound_Customization_DSL__ < Common_Customization_DSL__

        def children x
          @load_ticket.__receive_custom_tree_for x ; nil
        end
      end

      class Compound__

        def __receive_custom_tree_for x
          @custom_tree_hash__ = x ; nil
        end

        def _DSL_class
          Compound_Customization_DSL__
        end

        attr_reader(
          :custom_tree_hash__,
        )
      end

      # --

      class Operation_Customization_DSL___ < Common_Customization_DSL__

        def custom_view_controller x  # this form might deprecate
          @load_ticket._receive_custom_view_controller_proc x ; nil
        end

        def custom_view_controller_by( & p )
          @load_ticket._receive_custom_view_controller_proc p ; nil
        end
      end

      class Operation___ < NonRoot_NonCompound__

        def _DSL_class
          Operation_Customization_DSL___
        end

        def _receive_custom_view_controller_proc p
          @custom_view_controller_proc__ = p ; nil
        end

        attr_reader(
          :custom_view_controller_proc__,
        )

        def four_category_symbol
          :operation
        end
      end

      # --

      Atomesque__ = ::Class.new NonRoot_NonCompound__

      class Entitesque___ < Atomesque__

        def four_category_symbol
          :entitesque
        end
      end

      class Primitivesque___ < Atomesque__

        def four_category_symbol
          :primitivesque
        end
      end

      class Atomesque__

        def initialize cust_x, nt, moda_frame
          @association = nt.association
          super
        end

        # --

        def _DSL_class
          Common_Customization_DSL__
        end

        def __receive_on_change p
          @on_change__ = p ; nil
        end

        # --

        def to_qualified_knownness__
          @_moda_frame.qualified_knownness_for__ @node_ticket
        end

        def to_knownness__
          @_moda_frame.knownness_for__ @node_ticket
        end

        attr_reader(
          :association,
          :on_change__,
        )

        def looks_primitivesque
          true
        end
      end

      # -

        def _prepare

          @_prepare = false  # definitely do this ALWAYS

          _cls = _DSL_class
          x = remove_instance_variable :@_customization_a_p

          if x
            _cls.new( self, x ).execute
          end

          NIL_
        end

      # -

      This_ = self
    end
  end
end
