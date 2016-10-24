module Skylab::TMX

  class Models_::MapModificationIndex

    # a dedicated collaborator for the "map" operation, the subject's job
    # is to store incoming parsed modifiers of an operation request so
    # that they are useful to the procurement of the final result stream
    # (specficially in regards to distinguishing map- versus reduce- ).

    def initialize
      NOTHING_
    end

    # -- write

    def add_derived__ attr, parser

      _k = attr.derived_from_
      dep_attr = parser.lookup_attribute_via_normal_symbol_ _k
      if dep_attr
        @has_derivations = true
        _touch_attribute_to_parse dep_attr
        __add_derived_attribute attr
        ACHIEVED_
      else
        UNABLE_
      end
    end

    def add_reorder_plan plan

      _touch_attribute_to_parse plan.attribute

      @has_reductions = true
      ( @reductions ||= [] ).push plan

      ACHIEVED_
    end

    def add_nonderived_select__ attr

      _touch_attribute_to_parse attr

      # for CLI (as explicated at #spot-1):

      _touch_classification EXPLICITLY_SELECTED__, attr

      ACHIEVED_
    end

    # -- read

    def get_any_explicitly_selected_attributes__  # for CLI
      _any_array EXPLICITLY_SELECTED__
    end

    def get_derived_attributes__
      _some_array DERIVED_ATTRIBUTES__
    end

    def get_attributes_to_parse__
      _some_array ATTRIBUTES_TO_PARSE__
    end

    # -- read/write support

    def _touch_attribute_to_parse attr
      attr.is_derived && self._SANITY
      _touch_classification ATTRIBUTES_TO_PARSE__, attr
      NIL
    end

    def __add_derived_attribute attr
      _add_classification DERIVED_ATTRIBUTES__, attr
      NIL
    end

    def _touch_classification box_ivar, attr

      k = attr.normal_symbol

      _touch_box( box_ivar ).touch k do
        true
      end

      _involved_attributes_box.touch k do
        attr
      end

      NIL
    end

    def _add_classification box_ivar, attr

      k = attr.normal_symbol

      _touch_box( box_ivar ).add k, true

      _involved_attributes_box.touch k do
        attr
      end
      NIL
    end

    def _involved_attributes_box
      _touch_box INVOLVED_ATTRIBUTES__
    end

    def _touch_box box_ivar

      if ! instance_variable_defined? box_ivar
        instance_variable_set box_ivar, Common_::Box.new
      end
      instance_variable_get box_ivar
    end

    def _some_array box_ivar
      _a = _any_array box_ivar
      _a || EMPTY_A_
    end

    def _any_array box_ivar

      if instance_variable_defined? box_ivar
        h = instance_variable_get( INVOLVED_ATTRIBUTES__ ).h_
        instance_variable_get( box_ivar ).a_.map do |k|
          h.fetch k
        end
      end
    end

    # -- simple readers

    attr_reader(
      :has_derivations,
      :has_reductions,
      :reductions,
    )

    # ==

    ATTRIBUTES_TO_PARSE__ = :@___attributes_to_parse
    DERIVED_ATTRIBUTES__ = :@___derived_attributes
    EXPLICITLY_SELECTED__ = :@___explicitly_selected_attributes
    INVOLVED_ATTRIBUTES__ = :@___involved_attributes

    # ==

    EMPTY_A_ = [].freeze
  end
end
