module Skylab::Autonomous_Component_System::TestSupport

  module Expect_Root_ACS

    def self.[] tcc
      tcc.include self
    end

    def root_ACS_customized_result
      root_ACS_state.__customized_result
    end

    def root_ACS_result
      root_ACS_state.result
    end

    def root_ACS
      root_ACS_state.root
    end

    def root_ACS_state_via result, root_ACS

      # like: flush_event_log_and_result_to_state @result

      if instance_variable_defined? :@event_log
        _a = remove_instance_variable( :@event_log ).flush_to_array
      end

      Custom_State___.new result, _a, root_ACS
    end

    class Custom_State___

      def initialize * a
        @result, @emission_array, @root = a
      end

      attr_reader( :result, :emission_array, :root )

      def to_state_with_customized_result x
        State_with_Customized_Result___[ x, @emission_array, @root ]
      end
    end

    State_with_Customized_Result___ = ::Struct.new(
      :__customized_result, :emission_array, :root )

    def build_root_ACS  # *is* `build_cold_root_ACS`

      # NOTE - define your own version of this if you're using
      # it to test production root ACS nodes

      subject_root_ACS_class.new_cold_root_ACS_for_expect_root_ACS
    end
  end
end
