module Skylab::Cull

  class Models_::Survey

    class Models__::Report

      def initialize survey, & oes_p

        @call_a = nil

        @survey = survey
        @on_event_selectively = oes_p

        cfg = survey.config_for_read_
        if cfg
          sect = cfg.sections[ :report ] and __unmarshal sect
        end
      end

      def __unmarshal sect

        @call_a = []

        st = sect.assignments.to_stream

        while ast = st.gets

          :function == ast.external_normal_name_symbol or next  # for now

          func, args, category_symbol =
            Models_::Mutator.func_and_args_and_category_via_call_expression(
              ast.value_x, & @on_event_selectively )

          func or next

          @call_a.push [ args, func, category_symbol ]

        end
        nil
      end

      def add_function_call arg_s_a, function_class, function_category

        @call_a ||= []

        @call_a.push [ arg_s_a, function_class, function_category ]

        @___once ||= begin
          @survey.add_to_persistence_script_(
            :call_on_associated_entity_, :report, :persist )
          ACHIEVED_
        end

        ACHIEVED_
      end

      def persist

        @section = @survey.config_for_write_.sections.touch_section nil, :report

        @call_a.each do | arg_s_a, func_class, func_cat |

          __add_FC arg_s_a, func_class, func_cat

        end

        ACHIEVED_
      end

      def __add_FC arg_s_a, func_class, func_cat


        marshalled_s = "#{ func_cat }:#{
          ( Callback_::Name.via_module func_class ).as_slug
        }#{ if arg_s_a and arg_s_a.length.nonzero?
          "(#{ arg_s_a * ', ' })"
        end }"

        maybe_send_event :info, :added_function_call do
          build_event_with :added_function_call,
            :function_call, marshalled_s, :ok, nil
        end

        @section.assignments.add_to_bag_mixed_value_and_name_function(
          marshalled_s,
          NAME___ )

        nil
      end

      NAME___ = Callback_::Name.via_variegated_symbol :function

      include Simple_Selective_Sender_Methods_

      # ~

      def against st

        if @call_a && @call_a.length.nonzero?

          Self_::Actors__::To_stream[ st, @call_a, & @on_event_selectively ]

        else
          st
        end
      end

      Self_ = self
    end
  end
end
