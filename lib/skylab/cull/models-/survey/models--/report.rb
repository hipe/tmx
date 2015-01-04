module Skylab::Cull

  class Models_::Survey

    class Models__::Report

      def initialize survey, & oes_p

        @call_a = nil
        @survey = survey
        @on_event_selectively = oes_p

        cfg = survey.config_for_read_
        if cfg
          sect = cfg.sections[ :report ] and __retrieve sect
        end
      end

      def __retrieve sect

        @call_a = []

        sect.assignments.each do | ast |
          :function == ast.external_normal_name_symbol or next  # for now

          md = RX__.match ast.value_x
          md or next  # meh

          nm = Callback_::Name.via_slug md[ :scheme ]

          _cls = Models__.const_get nm.as_const, false

          func, args = _cls::Function_class_and_args_via_call_expression[
            md[ :rest ],
            & @on_event_selectively ]

          func or next

          @call_a.push [ args, func, nm.as_lowercase_with_underscores_symbol ]

        end
        nil
      end

      RX__ = /\A(?<scheme>[^:]+):(?<rest>.+)/

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

        @section.assignments.add_to_bag_value_string_and_name_function(
          marshalled_s,
          NAME___ )

        nil
      end

      NAME___ = Callback_::Name.via_variegated_symbol :function

      include Simple_Selective_Sender_Methods_

      # ~

      def against st

        @call_a or self._DO_ME_unmarshal

        Self_::Actors__::To_stream[ st, @call_a, & @on_event_selectively ]
      end

      Self_ = self
    end
  end
end
