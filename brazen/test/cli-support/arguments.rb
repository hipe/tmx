module Skylab::Brazen::TestSupport

  module CLI_Support::Arguments

    def self.[] tcc
      tcc.send :define_singleton_method, :with_class_, With_class___
      tcc.include Instance_Methods___
    end

    # -

      With_class___ = -> & defn_p do

        shared_subject :__n11n do

          _cls = nil.instance_exec( & defn_p )
            # do not evaluate it in the context in which it was
            # defined, but under "no" context (just for sanity)

          _prp_a = _cls.properties.to_value_stream.to_a.freeze

          Subject__[].via_properties _prp_a

        end
      end

    # -

    module Instance_Methods___

      def subject_
        Subject__[]
      end

      def against_ * actual_arg_a

        _n11n_prototype = __n11n

        @__normalization = _n11n_prototype.via_argv actual_arg_a

        @__result = @__normalization.execute

        NIL_
      end

      def want_failure_ event_channel_sym, x_i

        x = @__result
        if x
          x.terminal_channel_symbol == event_channel_sym || fail
          if :missing == event_channel_sym
            x.property.name_symbol.should eql x_i
          else
            x.x.should eql x_i
          end
        else
          fail "expected result, had none"
        end
      end

      def want_success_ * x_a
        a = @__normalization.release_result_iambic
        a.should eql x_a
      end
    end

    Subject__ = -> do
      Home_::CLI_Support::Arguments::Normalization
    end
  end

  module CLI_Support_Arguments_Namespace

    Ent_ = -> do

      Home_::Modelesque::Entity

    end
  end
end
