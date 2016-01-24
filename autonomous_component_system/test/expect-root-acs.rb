module Skylab::Autonomous_Component_System::TestSupport

  module Expect_Root_ACS

    def self.[] tcc
      tcc.include self
    end

    def root_ACS_result
      _sta = root_ACS_state
      _sta.result
    end

    def root_ACS
      root_ACS_state.root
    end

    def root_ACS_state_via result, root_ACS

      # like: flush_event_log_and_result_to_state @result

      _a = remove_instance_variable( :@event_log ).flush_to_array

      Custom_State___[ result, _a, root_ACS ]
    end

    Custom_State___ = ::Struct.new :result, :emission_array, :root

    def build_root_ACS & oes_p

      _cls = subject_root_ACS_class

      if ! oes_p
        oes_p = event_log.handle_event_selectively
      end

      _cls.new( & oes_p )
    end
  end
end
