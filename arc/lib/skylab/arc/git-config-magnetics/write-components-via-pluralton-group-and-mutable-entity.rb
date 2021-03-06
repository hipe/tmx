module Skylab::Cull

  class Models_::Survey

    class Associations_::Report

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
          # NOTE - the below was associated with the LEGACY comment at [#024] "note-25", which will go away..
          @span_a_h = {}
          st = @section.to_stream_of_all_elements
          current_span = []
          main_node = nil
          while node = st.gets
            if Is_node_of_interest__[ node ]
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
              main_node.value, & @_emit )
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

              _s = func.marshal
              new_node = @section.build_assignment _s, NAME_SYMBOL_FOR_ASSIGNMENT___

              @added_nodes.push new_node
              @nodes.push new_node
            end
          end

          if @span_a_h.length.nonzero?
            __salvage
          end

          __maybe_emit_events

          @section.REPLACE_ALL_ELEMENTS @nodes  # result is number of nodes gained
        end

        def __salvage

          crazy_comment_hack = -> el do

            s, s_ = el.TO_LINE_AS_BLANK_LINE_OR_COMMENT_LINE.split '#', 2

            el = el.class.new "#{ s }# (from removed function)#{ s_ }"

            @nodes.push el
          end

          @span_a_h.each_value do |span_a|

            span_a.each do |span|

              span.node_a.each do |el|

                if Is_node_of_interest__[ el ]

                  __memo_removed_node el

                elsif el.is_blank_line_or_comment_line

                  crazy_comment_hack[ el ]

                else
                  self.__COVER_ME__unexpected_element_category__
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
              :function_call, @removed_nodes.first.value,
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
              :function_call, @added_nodes.first.value,
              :ok, nil,
            )
          end
          ACHIEVED_
        end

        # ==

        Is_node_of_interest__ = -> node do
          if node.is_assignment
            :function == node.external_normal_name_symbol
          end
        end

        # ==

        NAME_SYMBOL_FOR_ASSIGNMENT___ = :function

        # ==
        # ==
      end
    end
  end
end
# #tombstone-A.1: sunsetted detached note reference
