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

        st = sect.assignments.to_value_stream

        while ast = st.gets

          :function == ast.external_normal_name_symbol or next  # for now

          func = Cull_::Models_::Function_.unmarshal(
            ast.value_x, & @on_event_selectively )

          if func
            @call_a.push func
          end
        end
        nil
      end

      def add_function_call func

        @call_a ||= []

        @call_a.push func

        _ensure_persist

        ACHIEVED_
      end

      def remove_function_calls call_a

        ok = true

        @call_a ||= []

        index_pool = @call_a.length.times.to_a

        indexes_to_nil_out_afterwards = []

        call_a.each do | func |

          cat = func.category_symbol
          const = func.const_symbol
          args = func.composition.args

          idx_idx = index_pool.index do | d |

            func_ = @call_a.fetch d

            if cat == func_.category_symbol
              if const == func_.const_symbol
                if args == func_.composition.args
                  true
                end
              end
            end
          end

          if idx_idx

            idx = index_pool.fetch idx_idx
            index_pool[ idx_idx ] = nil
            index_pool.compact!
            indexes_to_nil_out_afterwards.push idx

          else
            __maybe_send_not_found_event func
            ok = false
            break
          end
        end
        if ok && indexes_to_nil_out_afterwards.length.nonzero?
          __remove indexes_to_nil_out_afterwards
        end
        ok and _ensure_persist
        ok
      end

      def __maybe_send_not_found_event func
        maybe_send_event :error, :function_call_not_found do
          build_not_OK_event_with :function_call_not_found,
            :function_identifier, func.marshal
        end
        nil
      end

      include Simple_Selective_Sender_Methods_

      def __remove indexes_to_nil_out_afterwards
        _ensure_persist
        indexes_to_nil_out_afterwards.each do | idx |
          @call_a[ idx ] = nil
        end
        @call_a.compact!

        nil
      end

      def _ensure_persist
        @___once ||= begin
          @survey.add_to_persistence_script_(
            :call_on_associated_entity_, :report, :persist )
          ACHIEVED_
        end
        nil
      end

      def persist

        @section = @survey.config_for_write_.sections.touch_section nil, 'report'

        if @call_a && @call_a.length.nonzero?
          __persist_calls
        else
          ACHIEVED_
        end
      end

      def __persist_calls
        Report_::Actors__::Persist_calls[ @call_a, @section,
          & handle_event_selectively ]
      end

      # ~

      def against st

        if @call_a && @call_a.length.nonzero?

          Report_::Actors__::To_stream[ st, @call_a, & @on_event_selectively ]

        else
          st
        end
      end

      Report_ = self
    end
  end
end
