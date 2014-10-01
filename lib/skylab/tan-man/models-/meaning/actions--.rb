module Skylab::TanMan

  class Models_::Meaning

    Brazen_::Model_::Entity[ self, -> do

      o :persist_to, :meaning,

        :required,
        :ad_hoc_normalizer, -> * a do
          Meaning_::Actors__::Edit::Normalize_name.execute_via_arglist a
        end,
        :property, :name,

        :required,
        :ad_hoc_normalizer, -> * a do
          Meaning_::Actors__::Edit::Normalize_value.execute_via_arglist a
        end,
        :property, :value

    end ]

    Actions__ = make_action_making_actions_module

    module Actions__

      Add = make_action_class :Create

      class Add

        Model_::Entity[ self, -> do
          o :required, :property, :input_string,
            :required, :property, :output_string
        end ]
      end

      Ls = make_action_class :List

      class Ls

        Model_::Entity[ self, -> do
          o :required, :property, :input_string
        end ]
      end

      Rm = make_action_class :Delete

    end

    class << self

      def collection_controller
        Meaning_::Collection_Controller__
      end
    end

    Meaning_ = self
    NAME_ = 'name'.freeze
    NEWLINE_ = "\n".freeze
    VALUE_ = 'value'.freeze

  end
end
