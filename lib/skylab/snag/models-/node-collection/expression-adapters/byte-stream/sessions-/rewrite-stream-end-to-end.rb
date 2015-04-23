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

        def session & p

          _ok = __resolve_the_entity_upstream
          _ok && __against_appropriate_internal_session( & p )
        end

        def __resolve_the_entity_upstream

          st = @collection.to_node_stream( & @on_event_selectively )
          st and begin
            @entity_upstream = st
            ACHIEVED_
          end
        end

        def __against_appropriate_internal_session

          __appropriate_temporary_line_downstream do | fh |

            @downstream_lines = fh

            yield Controller__.new self
          end
        end

        def __appropriate_temporary_line_downstream & p

          down_ID = @downstream_identifier
          if down_ID
            __against_downstream_identifier down_ID, & p
          else
            __against_tmpfile( & p )
          end
        end

        def __against_downstream_identifier down_ID

          # result is result. we don't close, we don't flush

          dl = down_ID.to_minimal_yielder
          dl and begin
            yield dl
          end
        end

        def __against_tmpfile

          ok = __resolve_filesystem
          ok &&= __resolve_target_path
          ok && begin
            o = __build_tmpfile_session
            o.session do | fh |

              ok = yield fh
              ok and __finish_with_tmpfile fh
            end
          end
        end

        def __resolve_filesystem

          fs = @collection.filesystem_
          fs and begin
            @_FS = fs
            ACHIEVED_
          end
        end

        def __resolve_target_path

          tp = @collection.upstream_identifier.to_path
          tp and begin
            @_target_path = tp
            ACHIEVED_
          end
        end

        def __build_tmpfile_session

          o = Expression_Adapters::Filesystem::Sessions_::Tmpfile.new

          _path = ::File.join(
            Snag_.lib_.system.defaults.dev_tmpdir_path, 'sn0g' )

          o.tmpdir_path _path
          o.create_at_most_N_directories 2
          o.using_filesystem Snag_.lib_.system.filesystem
          o
        end

        def __finish_with_tmpfile fh

          fh.close
          @_FS.copy fh.path, @_target_path  # bytes
        end

        class Controller__ < ::BasicObject

          # industrial strength silliness - proxy calls to the exposed
          # methods, but only if everything is still OK. exception like

          def initialize down

            ok = true
            wall = -> & p do
              -> do
                ok &&= p[]
              end
            end

            @wen_p = wall.call do
              down.__write_each_node_until_the_subject_node_is_found
            end

            @wnn_p = wall.call do
              down.__write_the_new_node
            end

            @wrn_p = wall.call do
              down.__write_the_remaining_nodes
            end
          end

          def write_each_node_until_the_subject_node_is_found
            @wen_p[]
          end

          def write_the_new_node
            @wnn_p[]
          end

          def write_the_remaining_nodes
            @wrn_p[]
          end
        end

        def __write_each_node_until_the_subject_node_is_found

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

        def __write_the_new_node

          @subject_entity.express_into_under(
            @downstream_lines,
            @expression_agent )
        end

        def __write_the_remaining_nodes

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
      end
    end
  end
end
