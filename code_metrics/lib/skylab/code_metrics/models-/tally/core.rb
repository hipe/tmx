module Skylab::CodeMetrics

  class Models_::Tally < Brazen_::Action

    def self.entity_enhancement_module
      Brazen_::Modelesque::Entity
    end

    @instance_description_proc = -> y do

      _word = action_reflection.front_properties.fetch :word
      word = par _word

      _path = action_reflection.front_properties.fetch :path
      path = par _path

      y << "find every occurrence of every #{ word } in every file"
      y << "selected by every #{ path } recursively and hackishly.."
      y << nil
      y << "currently uses whole-word search against each #{ word }."
      y << "geared towards finding method calls so it is designed *not* to"
      y << "support regular expressions (for now) and will whine if words"
      y << "are used that contain regexp-y characters."
      y << nil
      y << "uses find and grep because ack wouldn't cut it."
      y << nil
      y << "outputs a report reporting (somehow) the distribution of"
      y << "all the #{ word }s in all the files.."
    end

    def description_proc_for_summary_of_under ada, exp

      # #[#br-002]:A because we reference our own properties in the above,
      # we need to create explicitly our own expag. this is nasty because
      # it jumps down to the agnostic layer and then back up ..

      ada.description_proc_for_summary_of_under__ self, exp
    end

    edit_entity_class(

      :description, -> y do
        y << "(x.)"
      end,
      :argument_arity, :zero,
      :property, :x,

      :description, -> y do
        y << "(y.)"
      end,
      :argument_arity, :one,
      :property, :y,

      :description, -> y do
        y << "(words)"
      end,
      :required,
      :argument_arity, :one_or_more,
      :property, :word,

      :description, -> y do
        y << "(paths)"
      end,
      :required,
      :argument_arity, :one_or_more,
      :property, :path,
    )

    def produce_result

      @on_event_selectively.call :info, :expression, :ping do | y |
        y << "are you ready to party."
      end
      :yep
    end
  end
end
