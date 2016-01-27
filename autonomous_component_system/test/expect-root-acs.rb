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

    def build_root_ACS  # *is* `build_cold_root_ACS`

      if block_given?
        raise ::ArgumentError, ___say_use_other
      end

      cls = subject_root_ACS_class
      if ! cls.respond_to? LONG_NAME__
        raise ::ArgumentError, ___say_etc( cls )
      end
      cls.send LONG_NAME__
    end

    def ___say_etc cls
      "to reinforce #[#002]Tenet1, define #{ cls.name }.#{ LONG_NAME__ }"
    end

    LONG_NAME__ = :new_cold_root_ACS_for_expect_root_ACS

    def ___say_use_other
      "this builds cold ACS's only - use `build_hot_root_ACS` instead"
    end

    def build_hot_root_ACS & oes_p

      self._COVER_ME

      if ! oes_p
        el = event_log
        if el
          oes_p = el.handle_event_selectively
        else
          @event_log ||= nil
          oes_p = No_events_
        end
      end

      _cls.new( & oes_p )
    end
  end
end
