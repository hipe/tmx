module Skylab::TanMan

  class ModelMagnetics_::OneEntity_via_NaturalKey_Fuzzily < Common_::MagneticBySimpleModel

    # -

      def initialize
        super
      end

      attr_writer(
        :natural_key_head,
        :entity_stream_by,
        :listener,
        :model_module,
      )

      def execute

        a = __reduce_to_array_against_natural_key_fuzzily
        case a.length <=> 1
        when -1 ; __when_zero_entities
        when  0 ; a.fetch 0
        when  1 ; __when_more_than_one_entity a  # #open [#012] not implemented
        end
      end

      # -- C

      def __when_zero_entities

        self._CODE_SKETCH__seems_legit_but_probably_has_typos__

        @listener.call :error, :component_not_found do
          __build_zero_entities_found_event
        end

        UNABLE_
      end

      def __build_zero_entities_found_event

        Event_via___.call_by do |o|
          o.natural_key_head = @natural_key_head
          o.entity_stream = @entity_stream_by.call
          o.model_module = @model_module
        end
      end

      # -- B

      def __reduce_to_array_against_natural_key_fuzzily

        _a = Home_.lib_.basic::Fuzzy.call_by do |o|

          o.string = @natural_key_head

          o.stream = @entity_stream_by.call

          o.string_via_item = -> ent do
            ent.natural_key_string  # hi.
          end

          o.result_via_matching = -> ent do
            ent.duplicate_as_flyweight_  # hi.
          end
        end
        _a  # hi. #todo
      end

    # -

    # ==

    class Event_via___ < Common_::MagneticBySimpleModel

      attr_writer(
        :entity_stream,
        :model_module,
        :natural_key_head,
      )

      def execute

        _a_few = __a_few.freeze

        Common_::Event.inline_not_OK_with(
          :component_not_found,
          :name_string, @natural_key_head,
          :a_few_entities, _a_few,
          :model_module, @model_module,
        ) do |y, o|
          o.dup.extend( Express___ ).__express_into_under_ y, self
        end
      end

      def __a_few
        # (we used to have a `take` method on streams #tombstone-D before #history-A)
        st = remove_instance_variable :@entity_stream
        Common_::Stream.via_times A_FEW___ do
          fly = st.gets
          fly && fly.duplicate_as_flyweight_
        end.to_a
      end
    end

    # ==

    module Express___

      def __express_into_under_ y, expag
        @line_yielder = y ; @expression_agent = expag ; execute
      end

      def execute

        @_model_lemma_string =
          Common_::Name.via_module( @model_module ).as_human  # ..

        buff = ""
        buff << "#{ @_model_lemma_string } not found:"
        buff << " #{ @expression_agent.ick_mixed @natural_key_head }"
        buff << " (#{ __weee })"
        @line_yielder << buffer
      end

      def __weee
        case @a_few_entities.length <=> 1
        when -1 ; __say_there_are_zero_entities
        when  0 ; __say_there_is_one_entity @a_few_entities.fetch 0
        when  1 ; __say_there_is_more_than_one_entity
        end
      end

      def __say_there_is_more_than_one_entity

        scn = Scanner_[ @a_few_entities ]
        lem = @_model_lemma_string

        @expression_agent.simple_inflection do

          buff = oxford_join scn do |ent|
            me._say ent
          end

          "some known #{ n lem }: #{ buff }"
        end
      end

      def __say_there_is_one_entity ent
        "the only known #{ @_model_lemma_string } is #{ _say ent }"
      end

      def __say_there_are_zero_entities

        lem = @_model_lemma_string
        @expression_agent.simple_inflection do
          write_count_for_inflection 0
          "there are no #{ n lem }"
        end
      end

      def _say ent
        @expression_agent.calculate do
          ick_mixed ent.natural_key_string
        end
      end
    end

    # ==

    A_FEW__ = 3

    # ==
    # ==
  end
end
# #history-A: abstracted from what is currently the "model" file; rewritten
