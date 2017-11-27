module Skylab::Basic

  module TestSupport

    module Want_Normalization

      class << self
        def [] test_ctxt_cls
          # TestSupport_::Want_Event[ test_ctxt_cls ]  assumed?
          test_ctxt_cls.include Instance_Methods__
          nil
        end
      end  # >>

  module Instance_Methods__

    def normalize_against_ x

      _cls = subject_normalization_

      _p = handle_event_selectively_

      @input_arg = _mock_argument x

      ok_arg = _cls.normalize_qualified_knownness @input_arg, & _p

      if ok_arg
        @output_value_was_written = true
        @output_arg = ok_arg
        @output_x = ok_arg.value
      else
        @output_value_was_written = false
        @result_x = ok_arg
      end

      nil
    end

    def _mock_argument * a
      Mock_arg__[].call_via_arglist a
    end

    def want_the_passthru_normalization__

      want_no_events

      want_output_value_was_written_

      qkn = @input_arg
      kn = @output_arg

      qkn.is_qualified or fail ___say_not( qkn )
      kn.is_qualified and fail __say( kn )

      expect( qkn.value ).to eql kn.value

      nil
    end

    def ___say_not qkn
      "expected QKN had #{ qkn.class }"
    end

    def ___say kn
     "expected (non-qualified) knownness had #{ kn.class }"
    end

    def want_nothing_

      want_output_value_was_not_written_
      want_no_events
      expect( @result_x ).to be_nil
    end

    def want_output_value_was_written_
      expect( @output_value_was_written ).to eql true
    end

    def want_output_value_was_not_written_
      expect( @output_value_was_written ).to eql false
    end
  end

  Mock_arg__ = Common_.memoize do

    module Mock_Arg__

      class << self

        def call_via_arglist a
          case a.length
          when 1 ; via_3 a.first, true, nil
          when 2 ; via_3 a.first, true, a.last
          when 3 ; via_3( * a )
          end
        end

        def via_3 x, actuals_has_name, any_name_i

          _prop = if any_name_i
            Mock_Property__.new Common_::Name.via_variegated_symbol name_i
          else
            MOCK_PROPERTY__
          end

          Common_::QualifiedKnownness.via_value_and_had_and_association(
            x, actuals_has_name, _prop )
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

      MOCK_PROPERTY__ = Mock_Property__.new Common_::Name.via_variegated_symbol :your_value

      self
    end
  end

    end
  end
end
