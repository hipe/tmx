module Skylab::Cull

  class Models_::Survey

    class Associations_::Report

      class << self
        private :new
      end  # >>

      def initialize survey, & p
        Home._REFACTOR__to_take_listener_as_arg__

        @call_a = nil

        @survey = survey
        @_emit = p

        cfg = survey.config_for_read_
        if cfg
          sect = cfg.sections.lookup_softly :report
          if sect
            __unmarshal sect
          end
        end
      end

      def __unmarshal sect

        @call_a = []

        st = sect.assignments.to_stream_of_assignments

        while ast = st.gets

          :function == ast.external_normal_name_symbol or next  # for now

          func = Home_::Models_::Function_.unmarshal(
            ast.value, & @_emit )

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

        @_emit.call :error, :function_call_not_found do
          Build_not_OK_event_.call(
            :function_call_not_found,
            :function_identifier, func.marshal,
          )
        end
        NOTHING_
      end

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

        Me__::RecomposeSection_via_FunctionCalls_and_Section___.call(
          @call_a, @section, & @_emit )
      end

      # ~

      def against st

        if @call_a && @call_a.length.nonzero?

          Me__::EntityStream_via_EntityStream_and_FunctionCalls___[ st, @call_a, & @_emit ]
        else
          st
        end
      end

      Me__ = self
    end
  end
end
