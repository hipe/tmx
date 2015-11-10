module Skylab::MyTerm

  module Models_::Adapter

    # this is our experimental frontier of "factory pattern" under ACS:

    # the scope of this "node" is
    #   1) list available adapters,
    #   2) be the custodian of and express which adapter is selected and
    #   3) to process requests to change the selected adapter.

    # it's annoying to attempt all of this with one component (near state
    # changes and serialization) so we attempt a factory pattern. however,
    # our client need not be aware (directly) that we switch classes.

    # creating an inheritance hierarchy for this is both problematic in
    # theory and helpful in practice.

    class << self

      def interpret_component st, acs, & p

        adapters = acs.method :adapters

        if st.unparsed_exists

          Selected__._new_entity( adapters, & p ).
            _interpret_self_through_selected_adapter_name st.gets_one

        else
          Selection___._new_controller adapters, & p
        end
      end
    end  # >>

    Common__ = ::Class.new

    class Selection___ < Common__

      class << self
        alias_method :_new_controller, :new
        private :new
      end  # >>

      # inherit these actions:

      def __list__component_operation
        super
      end

      def __set__component_operation
        super
      end
    end

    class Selected__ < Common__

      class << self
        alias_method :_new_entity, :new
        private :new
      end  # >>

      def _interpret_self_through_selected_adapter_name s

        # assume this is for all of your constructions. if you don't resolve
        # an adapter from the name, you cannot exist as a "selected."

        ada  = @_adapters[].touch_adapter_via_string__ s
        if ada
          ada = ada.flush_to_selected_adapter
          @selected_adapter = ada
          self
        else
          ada
        end
      end  # >>

      # inherit these actions:

      def __list__component_operation
        super
      end

      def __set__component_operation
        super
      end

      # ~ for [#br-035] expressive events

      def description_under expag

        ada = @selected_adapter
        expag.calculate do
          nm ada.adapter_name
        end
      end

      # for ACS serialization

      def to_primitive_for_component_serialization
        @selected_adapter.adapter_name.as_slug
      end

      # ~ entity-like exposures

      def selected_adapter__
        @selected_adapter
      end
    end

    class Common__

      def initialize adapters_p, & oes_p

        @_adapters = adapters_p
        @_oes_p = oes_p
      end

      # ~ the "set" operation

      def __set__component_operation

        yield :description, -> y do
          y << "set the adapter"
        end

        yield :parameter, :adapter, :description, -> y do
          y << "the name of the adapter to use"
          y << "(see `list` for a list of adapters)"   # etc
        end

        method :__receive_set_adapter_name
      end

      def __receive_set_adapter_name adapter

        sel = Selected__._new_entity( @_adapters, & @_oes_p ).
          _interpret_self_through_selected_adapter_name adapter

        if sel

          # here is the horcrux (i mean crux) of our factory pattern: we
          # signal to any listening client that "we" should be replaced
          # with this new value. in some cases this means effectively
          # changing the class of the component, in other cases not.

          @_oes_p.call :component, :change do | y |

            y.yield :new_component, sel
          end
        else
          sel
        end
      end

      # ~ the "list" operation

      def __list__component_operation

        yield :description, -> y do
          y << "list the available adapters"
        end

        -> do
          @_adapters[].to_adapter_stream_for_list__
        end
      end
    end

    class Visiting_Association

      # for [#003]:#storypoint-1 (in-situ)

      class << self
        alias_method :new_prototype, :new
        private :new
      end

      def initialize ada
        @adapter_ = ada
      end

      def new asc
        dup.__init asc
      end

      def __init asc
        @real_association_ = asc
        self
      end

      def name
        @real_association_.name
      end

      def component_model
        @real_association_.component_model
      end

      def category
        @real_association_.category
      end

      attr_reader(
        :adapter_,
        :real_association_,
      )

      def sub_category
        :visiting
      end
    end

    NULL_GLYPH__ = '  '
    SELECTED_GLYPH__ = '• '
  end
end
