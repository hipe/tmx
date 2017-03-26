module Skylab::Cull

  class Models_::Survey

    class Models__::Report

      class RecomposeSection_via_FunctionCalls_and_Section___ < Common_::Dyadic  # 1x

        # [#005] algorithm decribed in full

        def initialize a, o, & p
          @call_a = a
          @_emit = p
          @section = o
        end

        def execute
          __partition_existing
          __rewrite
        end

        # ~ partition

        def __partition_existing
          @added_nodes = []
          @removed_nodes = []
          @span_a_h = {}  # #note-25
          st = @section.to_node_stream
          current_span = []
          main_node = nil
          while node = st.gets
            if is_node_of_interest node
              if main_node
                add_span main_node, current_span
                current_span = [ node ]
              else
                current_span.push node
              end
              main_node = node
            else
              current_span.push node
            end
          end
          if current_span.length.nonzero?
            add_span main_node, current_span
          end
          nil
        end

        def add_span main_node, node_a

          if main_node
            func = Home_::Models_::Function_.unmarshal(
              main_node.value_x, & @_emit )
            if func
              __add_span func, node_a
            else
              self._UNIMPLEMENTED_handle_unmarshal_error  # per documentation
            end
          else
            self._DO_ME_extra_nodes_with_no_function_node
          end
          nil
        end

        def __add_span func, node_a
          span = Span__.new func, node_a
          composition = func.composition
          @span_a_h.fetch composition do
            @span_a_h[ composition ] = []
          end.push span
          nil
        end

        Span__ = ::Struct.new :func, :node_a

        # ~ rewrite

        def __rewrite
          @nodes = []
          @call_a.each do |func|

            composition = func.composition

            existing_a = @span_a_h[ composition ]

            if existing_a
              span = existing_a.shift
              if existing_a.length.zero?
                @span_a_h.delete composition
              end
              @nodes.concat span.node_a  # reuse the existing nodes
            else
              new_node = @section.build_assignment_via_mixed_value_and_name_function(
                func.marshal,
                NAME__ )

              @added_nodes.push new_node
              @nodes.push new_node
            end
          end

          if @span_a_h.length.nonzero?
            __salvage
          end

          __maybe_emit_events

          @section.replace_children_with_this_array @nodes  # result is number of nodes gained
        end

        def __salvage
          @span_a_h.each_value do | span_a |
            span_a.each do | span |
              span.node_a.each do | node |
                if is_node_of_interest node
                  __memo_removed_node node
                else
                  if :blank_line_or_comment_line == node.category_symbol
                    s, s_ = node.to_line.split '#', 2
                    node = node.class.new( "#{ s }# (from removed function)#{ s_ }" )
                  else
                    self._DO_ME_this_node_is_not_a_comment
                  end
                  @nodes.push node
                end
              end
            end
          end
          nil
        end

        def __memo_removed_node node
          @removed_nodes.push node
          nil
        end

        def is_node_of_interest node
          :assignment == node.category_symbol &&
            :function == node.external_normal_name_symbol
        end

        def __maybe_emit_events
          did = __maybe_emit_removal_event
          did_ = __maybe_emit_add_event
          if ! ( did || did_ )
            self._EMIT_SILENCE
          end
          nil
        end

        def __maybe_emit_removal_event

          case 1 <=> @removed_nodes.length
          when  0
            __when_removed_one
          when -1
            self._PLURAL_FORM_OF_THE_SAME_EVENT
            ACHIEVED_
          end
        end

        def __when_removed_one
          @_emit.call :info, :removed_function_call do
            Build_event_.call(
              :remove_function_call,
              :function_call, @removed_nodes.first.value_x,
              :ok, nil,
            )
          end
          ACHIEVED_
        end

        def __maybe_emit_add_event
          case 1 <=> @added_nodes.length
          when  0
            __when_added_one
          when -1
            self._PLURAL_FORM_OF_THE_SAME_EVENT
            ACHIEVED_
          end
        end

        def __when_added_one
          @_emit.call :info, :added_function_call do
            Build_event_.call(
              :added_function_call,
              :function_call, @added_nodes.first.value_x,
              :ok, nil,
            )
          end
          ACHIEVED_
        end

        NAME__ = Common_::Name.via_variegated_symbol :function

        # ==
        # ==
      end
    end
  end
end
