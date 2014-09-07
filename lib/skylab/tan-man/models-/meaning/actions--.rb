module Skylab::TanMan

  class Models_::Meaning

    Brazen_::Model_::Entity[ self, -> do

      o :persist_to, :meaning,

        :required,
        :ad_hoc_normalizer, -> * a do
          Meaning_::Controller__::Normalize_name.new( a ).execute
        end,
        :property, :name,

        :required,
        :ad_hoc_normalizer, -> * a do
          Meaning_::Controller__::Normalize_value.new( a ).execute
        end,
        :property, :value

    end ]

    O__ = Action_Factory.create_with self, Action_, Entity_

    module Actions__

      Add = O__.make :Add

      class Add

        Model_::Entity[ self, -> do
          o :required, :property, :input_string,
            :required, :property, :output_string
        end ]

        def produce_any_result
          produce_any_result_when_dependencies_are_met
        end
      end

      Ls = O__.make :List

      class Ls

        Model_::Entity[ self, -> do
          o :required, :property, :input_string
        end ]

        def produce_any_result
          produce_any_result_when_dependencies_are_met
        end
      end

      Rm = O__.make :Remove

    end

    Meaning_ = self
    NAME_ = 'name'.freeze
    VALUE_ = 'value'.freeze

  end
end
