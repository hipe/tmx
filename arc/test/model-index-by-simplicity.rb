module Skylab::Arc::TestSupport

  module Model_Index_By_Simplicity

    def self.[] tcc
      tcc.include self
    end

    # -

      # -- assert

      def fails_
        tuple_.last && fail  # we are indifferent
      end

      # -- setup

      def expect * chan, & p
        __spy_MIBS.expect_emission p, chan
        NIL
      end

      def execute
        remove_instance_variable( :@SPY ).execute_under self
      end

      def __spy_MIBS
        @SPY ||= __build_spy_MIBS
      end

      def __build_spy_MIBS

        spy = Common_.test_support::Expect_Emission_Fail_Early::Spy.new

        spy.call_by do |p|
          _interpret_entity_MIBS p
        end

        spy
      end

      def interpret_entity_
        _interpret_entity_MIBS nil
      end

      def _interpret_entity_MIBS p

        _upstream = remove_instance_variable :@UPSTREAM
        Home_::AssociationToolkit::Entity_by_Simplicity_via_PersistablePrimitiveNameValuePairStream.call_by do |o|
          o.persistable_primitive_name_value_pair_stream = _upstream
          o.model_class = subject_class_
          o.listener = p
        end
      end

      def call_subject_module_
        subject_module_[ subject_class_ ]
      end

      def given_upstream_ * x_a
        @UPSTREAM = Common_::Stream.via_times( x_a.length / 2 ).map_by do |d|
          d_ = d * 2
          Common_::QualifiedKnownKnown.via_value_and_symbol x_a.fetch( d_+1 ), x_a.fetch( d_ )
        end
        NIL
      end

      def ignore_emissions_whose_terminal_channel_is_in_this_hash
        nil  # NOTHING_
      end

      def subject_module_
        Home_::Magnetics_::ModelIndexBySimplicity_via_ModelClass
      end

    # -

  end
end
# #born
