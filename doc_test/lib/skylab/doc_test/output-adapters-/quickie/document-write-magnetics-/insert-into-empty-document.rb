module Skylab::DocTest

  module OutputAdapters_::Quickie

    class DocumentWriteMagnetics_::Insert_into_Empty_Document

        def initialize doc, cx
          @choices = cx
          @document = doc
        end

        attr_writer(
          :example_node,
        )

        def finish

          __index_every_branch_node_finding_the_last_deepest_one
          send @_init_receiving_branch
          __into_receiving_branch_insert
          self
        end

        def __into_receiving_branch_insert

          o = @_receiving_branch.begin_insert_into_empty_branch_session

          o.write_opening_node_and_any_blank_lines

          o.write_blank_line_if_necessary

          o.write_new_example_node @example_node

          o.write_from_the_reference_example_to_end  # closing line

          _nodes = o.finish

          @_receiving_branch.replace__ _nodes
          NIL_
        end

        def last_receiving_branch
          @_receiving_branch
        end

        # -- init receiving branch

        def __when_document
          _init_recv_branch :@document
        end

        def _when_module
          self._TODO_touch_describe
          _when_describe
        end

        def _when_describe
          _init_recv_branch :@_describe
        end

        def _when_context
          _init_recv_branch :@_context
        end

        def _init_recv_branch ivar
          @_receiving_branch = instance_variable_get ivar
          remove_instance_variable :@_init_receiving_branch
          remove_instance_variable :@_module
          remove_instance_variable :@_describe
          remove_instance_variable :@_context ; nil
        end

        # --

        def __index_every_branch_node_finding_the_last_deepest_one

          # "deep" is a bit of a misnomer, but we could do that..

          @_module = @_describe = @_context = nil
          @_deepest_depth = 0

          st = @document.to_branch_stream
          a = BOX__.a_
          h = BOX__.h_
          @_init_receiving_branch = :__when_document
          begin
            @_branch = st.gets
            @_branch || break
            sym = @_branch.category_symbol
            m, m_ = h.fetch sym
            depth = a.index sym
            if depth > @_deepest_depth
              @_init_receiving_branch = m_
              @_deepest_depth = depth
              send m
            end
            redo
          end while nil

          remove_instance_variable :@_branch
          remove_instance_variable :@_deepest_depth
          NIL_
        end

        bx = Common_::Box.new  # order matters:
        bx.add nil, nil  # eew, take up the 0th element
        bx.add :module, [ :__note_module, :_when_module ]
        bx.add :describe, [ :__note_describe, :_when_describe ]
        bx.add :context, [ :__note_context, :_when_context ]
        BOX__ = bx

        def __note_module
          @_module = @_branch
        end

        def __note_describe
          @_describe = @_branch
        end

        def __note_context
          @_context = @_branch
        end
    end
  end
end
