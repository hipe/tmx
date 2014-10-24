module Skylab::Basic

  module TestSupport

    module Expect_Normalization

      class << self
        def [] test_ctxt_cls
          test_ctxt_cls.include Instance_Methods__
        end
      end  # >>


  module Instance_Methods__

    def use_event_receiver_against x
      use_two x, event_receiver ; nil
    end

    def use_event_proc_against x
      @event_x_a = nil
      @event_proc_was_called = false
      use_two x, -> * x_a do
        @event_proc_was_called = true
        @event_x_a = x_a
        :sad_from_proc
      end ; nil
    end

    def use_two x, evr_x
      @input_x = x
      _arg = mock_arg x
      @output_value_was_written = false
      @result_x = subject.normalize_via_three _arg,
        -> x_ do
          @output_value_was_written = true
          @output_x = x_
          :happy
        end,
        evr_x
      nil
    end

    def mock_arg *a
      Mock_arg__[].via_arglist a
    end

    def expect_the_passthru_normalization
      event_proc_was_not_called
      output_value_was_written
      @output_x.should eql @input_x
      @result_x.should eql :happy  ; nil
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

  Mock_arg__ = Callback_.memoize[ -> do

    module Mock_Arg__

      class << self

        def via_arglist a
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

          Basic_.trio.new value_x, actuals_has_name, _prop
        end
      end

      class Mock_Property__
        def initialize name
          @nm = name
        end

        def description
          "«#{ name_i }»"  # :+#guillemets
        end

        def name_i
          @nm.as_variegated_symbol
        end

        def name
          @nm
        end
      end
      MOCK_PROPERTY__ = Mock_Property__.new Callback_::Name.via_variegated_symbol :your_value

      self
    end
  end ]

    end
  end
end
