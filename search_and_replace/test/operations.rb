module Skylab::SearchAndReplace::TestSupport

  module Operations

    def self.[] tcc
      tcc.send :define_singleton_method, :call_by_, Call_by_method___
      tcc.include self
    end

    TestSupport_::Memoization_and_subject_sharing[ self ]

    # -
      Call_by_method___ = -> & p do

        shared_subject :state_ do

          instance_exec( & p )

          _a = remove_instance_variable( :@event_log ).flush_to_array
          _x = remove_instance_variable :@result

          State___.new _x, _a
        end
      end
    # -

    State___ = ::Struct.new :result, :emission_array

    # -

      def call_ * x_a

        _oes_p = event_log.handle_event_selectively
        @result = subject_API.call( * x_a, & _oes_p )
        NIL_
      end

      # ~ setup help

      memoize :_THREE_LINES_FILE do
       'three-lines.txt'
      end

      # --

      def fails_
        result_value_.should __match_result_for_failure
      end

      def __match_result_for_failure
        eql false
      end

      def result_value_
        state_.result
      end
    # -
  end
end
