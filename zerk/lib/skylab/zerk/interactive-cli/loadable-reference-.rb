module Skylab::Zerk

  class InteractiveCLI

    class Load_Ticket_  # read [#039]

      class << self

        def [] x, nt, moda_frame

          _ = Node_ticket_4_category_[ nt ]
          _cls = This_.const_get NT3___.fetch _
          _cls._via_three x, nt, moda_frame
        end
      end  # >>

      NT3___ = {
        compound: :NonRoot_Compound___,
        entitesque: :Entitesque___,
        operation: :Operation___,
        primitivesque: :Primitivesque___,
      }

      class Common_Customization_DSL__ < ::BasicObject

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

          if @load_ticket.__is_masked
            NOTHING_
          else
            @load_ticket
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

        def mask _=nil
          @load_ticket.__be_masked ; nil
        end

        def on_change x
          @load_ticket.__receive_on_change x ; nil
        end
      end

      COMMON_LEAF_INITIALIZE__ = -> node_ticket, modality_frame do
        @_moda_frame = modality_frame
        @name = node_ticket.name
        @node_ticket = node_ticket
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

        class << self
          def via_array_proc a_p
            Compound_Customization_DSL__.new( new, a_p ).execute
          end
        end # >>

        # (only for when customizations on root frame)
      end

      class NonRoot_NonCompound__ < self

        include NonRoot_Methods__

        define_method :initialize, COMMON_LEAF_INITIALIZE__
      end

      module NonRoot_Methods__

        def __receive_custom_hotstring_pieces a
          @custom_hotstring_structure = Here_::Buttonesque_Expression_Adapter_.new( * a, self )
          NIL_
        end

        attr_reader :custom_hotstring_structure

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

        def on_load_ticket_pressed

          # only because boolean is primitivesque, the main work for [#044]:

          if :zero == @association.argument_arity
            ___when_pressed_as_flag
          else
            super
          end
        end

        def ___when_pressed_as_flag

          # this is perhaps the only time in the 3 bundled modalities where
          # we are going to implement a toggle:

          rw = @_moda_frame.reader_writer

          kn = rw.read_value @association

          if kn.is_known_known
            x = kn.value_x
          end

          _qkn = Common_::Qualified_Knownness[ ( ! x ), @association ]

          rw.write_value _qkn

          # (we could give feedback but meh in the usual entity item table etc)

          NIL_
        end
      end

      class Atomesque__

        def initialize nt, moda_frame
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

        def __be_masked
          @__is_masked = true ; nil
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
          :__is_masked,
          :on_change__,
        )

        def looks_primitivesque
          true
        end
      end

      # -
        class << self

          def _via_three x, nt, moda_frame
            o = new nt, moda_frame
            if x
              _cls = o._DSL_class
              _cls.new( o, x ).execute
            else
              o
            end
          end

          private :new
        end  # >>

        # --

        def on_load_ticket_pressed

          # the default reaction to having been "pressed" as a "buttonesque"
          # is to build a new appropriate frame and push it on to the stack

          @_moda_frame.event_loop.push_stack_frame_for self
          NIL_
        end

        def __is_masked
          false
        end

      # -

      This_ = self
    end
  end
end
