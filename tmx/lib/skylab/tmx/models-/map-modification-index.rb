module Skylab::TMX

  class Models_::MapModificationIndex

    # a close collaborator with the "map" operation, the subject's job
    # is to store incoming parsed modifiers of an operation request so
    # that they are useful to the procurement of the final result stream
    # (specficially in regards to distinguishing map- versus reduce- ).

    def initialize
    end

    # -- write

    def add_reorder_plan plan

      _touch_effective_selection plan.attribute

      @has_reductions = true
      ( @reductions ||= [] ).push plan

      ACHIEVED_
    end

    def add_select attr

      _touch_effective_selection attr
      # (probably index the explicit selection too, for CLI eventually)
      ACHIEVED_
    end

    def _touch_effective_selection attr

      _box = ( @_effectively_selected_box ||= Common_::Box.new )

      _box.touch attr.normal_symbol do
        attr
      end
      NIL
    end

    # -- read

    def get_attributes_effectively_selected
      @_effectively_selected_box.enum_for( :each_value ).to_a
    end

    attr_reader(
      :has_reductions,
      :reductions,
    )
  end
end
