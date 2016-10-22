module Skylab::TMX

  class Models_::MapModificationIndex

    # a close collaborator with the "map" operation, the subject's job
    # is to store incoming parsed modifiers of an operation request so
    # that they are useful to the procurement of the final result stream
    # (specficially in regards to distinguishing map- versus reduce- ).

    def initialize
    end

    # -- write

    def add_derived__ attr, parser

      _k = attr.derived_from_
      dep_attr = parser.lookup_attribute_via_normal_symbol_ _k
      if dep_attr
        @has_derivations = true
        _touch_attribute_to_parse dep_attr
        __derived_attributes.add attr.normal_symbol, attr
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
      # (probably index the explicit selection too, for CLI eventually)
      ACHIEVED_
    end

    def _touch_attribute_to_parse attr

      attr.is_derived && self._SANITY

      _attributes_to_parse.touch attr.normal_symbol do
        attr
      end
      NIL
    end

    def __derived_attributes
      @__derived_attributes ||= Common_::Box.new
    end

    def _attributes_to_parse
      @__attributes_to_parse ||= Common_::Box.new
    end

    # -- read

    def get_attributes_to_parse__
      @__attributes_to_parse.enum_for( :each_value ).to_a
    end

    def get_derived_attributes__
      @__derived_attributes.enum_for( :each_value ).to_a
    end

    attr_reader(
      :has_derivations,
      :has_reductions,
      :reductions,
    )
  end
end
