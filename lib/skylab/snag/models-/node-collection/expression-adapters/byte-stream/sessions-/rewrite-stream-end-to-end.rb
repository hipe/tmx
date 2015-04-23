module Skylab::Snag

  module Models_::Node_Collection

    module Expression_Adapters::Byte_Stream

      Sessions_ = ::Module.new

      class Sessions_::Rewrite_Stream_End_to_End  # see [#038]

        WIDTH__ = 79  # for now
        SUB_MARGIN_WIDTH__ = ' #open '.length  # for now
        IDENTIFIER_INTEGER_WIDTH___ = 3  # for now

        def initialize bx, node, coll, & oes_p

          @collection = coll
          @do_double_buffering = false
          @downstream_identifier = bx[ :downstream_identifier ]
          @expression_agent = Expression_Agent_.new(
            WIDTH__,
            SUB_MARGIN_WIDTH__,
            IDENTIFIER_INTEGER_WIDTH___ )
          @on_event_selectively = oes_p
          @subject_entity = node
        end

        def start_the_output_stream

          ok = __resolve_the_entity_upstream
          ok and begin
            down_ID = @downstream_identifier
            if down_ID
              dl = down_ID.to_minimal_yielder
              dl and begin
                @downstream_lines = dl
                ACHIEVED_
              end
            else
              @do_double_buffering = true
              self._TEMPFILE
            end
          end
        end

        def __resolve_the_entity_upstream

          st = @collection.to_node_stream( & @on_event_selectively )
          st and begin
            @entity_upstream = st
            ACHIEVED_
          end
        end

        def write_each_node_until_the_subject_node_is_found

          expag = @expression_agent
          id = @subject_entity.ID or self._SANITY
          st = @entity_upstream
          y = @downstream_lines

          did_find = false
          begin

            ent = st.gets
            ent or break

            _same = id == ent.ID
            if _same
              did_find = true
              @equivalent_entity = ent
              break
            end

            ent.express_into_under y, expag

            redo
          end while nil

          if did_find
            ACHIEVED_
          else
            self._DID_NOT_FIND
          end
        end

        def write_the_new_node

          @subject_entity.express_into_under(
            @downstream_lines,
            @expression_agent )
        end

        def write_the_remaining_nodes

          expag = @expression_agent
          st = @entity_upstream
          y = @downstream_lines

          ok = true
          begin

            ent = st.gets
            ent or break
            ok = ent.express_into_under y, expag
            ok or break

            redo
          end while nil

          ok
        end

        def finish_the_output_stream

          if @do_double_buffering
            self._FUN

          else
            ACHIEVED_
          end
        end
      end
    end
  end
end
