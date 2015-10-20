module Skylab::Basic

  module TestSupport

    module Expect_Normalization

      class << self
        def [] test_ctxt_cls
          # TestSupport_::Expect_Event[ test_ctxt_cls ]  assumed?
          test_ctxt_cls.include Instance_Methods__
          nil
        end
      end  # >>


  module Instance_Methods__

    def normalize_against x

      _cls = subject

      _oes_p = handle_event_selectively

      @input_arg = _mock_argument x

      ok_arg = _cls.normalize_qualified_knownness @input_arg, & _oes_p

      @event_proc_was_called = @ev_a ? true : false  # [br] expect event

      if ok_arg
        @output_value_was_written = true
        @output_arg = ok_arg
        @output_x = ok_arg.value_x
      else
        @output_value_was_written = false
        @result_x = ok_arg
      end

      nil
    end

    def _mock_argument * a
      Mock_arg__[].call_via_arglist a
    end

    def expect_the_passthru_normalization
      event_proc_was_not_called
      output_value_was_written
      @output_arg.object_id.should eql @input_arg.object_id
      nil
    end

    def expect_nothing
      output_value_was_not_written
      event_proc_was_not_called
      @result_x.should be_nil
    end

    def output_value_was_written
      @output_value_was_written.should eql true
    end

    def output_value_was_not_written
      @output_value_was_written.should eql false
    end

    def event_proc_was_called
      @event_proc_was_called.should eql true
    end

    def event_proc_was_not_called
      @event_proc_was_called.should eql false
    end
  end

  Mock_arg__ = Callback_.memoize do

    module Mock_Arg__

      class << self

        def call_via_arglist a
          case a.length
          when 1 ; via_3 a.first, true, nil
          when 2 ; via_3 a.first, true, a.last
          when 3 ; via_3( * a )
          end
        end

        def via_3 value_x, actuals_has_name, any_name_i

          _prop = if any_name_i
            Mock_Property__.new Callback_::Name.via_variegated_symbol name_i
          else
            MOCK_PROPERTY__
          end

          Callback_::Qualified_Knownness.via_value_and_had_and_association(
            value_x, actuals_has_name, _prop )
        end
      end

      class Mock_Property__
        def initialize name
          @nm = name
        end

        def description
          "«#{ name_symbol }»"  # :+#guillemets
        end

        def name_symbol
          @nm.as_variegated_symbol
        end

        def name
          @nm
        end
      end

      MOCK_PROPERTY__ = Mock_Property__.new Callback_::Name.via_variegated_symbol :your_value

      self
    end
  end

    end
  end
end
