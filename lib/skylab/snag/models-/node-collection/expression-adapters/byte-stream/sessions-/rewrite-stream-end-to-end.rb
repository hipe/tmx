module Skylab::Snag

  class Models_::Node_Collection

    module Expression_Adapters::Byte_Stream

      Sessions_ = ::Module.new

      class Sessions_::Rewrite_Stream_End_to_End  # see [#038]

        WIDTH__ = 79  # for now
        SUB_MARGIN_WIDTH__ = ' #open '.length  # for now
        IDENTIFIER_INTEGER_WIDTH___ = 3  # for now

        def initialize bx, node, coll, & oes_p

          @collection = coll
          @do_double_buffering = false
          @downstream_identifier = bx && bx[ :downstream_identifier ]

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

        def __subject_entity__ x

          if x
            @subject_entity = x
            ACHIEVED_
          else
            x
          end
        end

        def __resolve_the_entity_upstream

          st = @collection.to_entity_stream( & @on_event_selectively )
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
            __lock_self_during_write do
              o = __build_tmpfile_session
              o.session do | fh |

                ok = yield fh
                ok and __finish_with_tmpfile fh
              end
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

        def __lock_self_during_write

          # ALTHOUGH we accomplish the "write" by writing the full document
          # to a tmpfile and then replacing the main file with the tmpfile,
          # (and although the tmpfile itself is locked during this operation),
          # if multiple processes did this around the same time the last one
          # to finish would clobber the writes of all the others. as a measure
          # against this, we open the main file for writing and lock it even
          # though we will never write to it directly ..

          fh = ::File.open @_target_path, ::File::WRONLY
          es = fh.flock ::File::LOCK_EX | ::File::LOCK_NB
          if es && es.zero?
            x = yield
            fh.flock ::File::LOCK_UN
            x
          else
            self._BUSY  # not covered
          end
        end

        def __build_tmpfile_session

          o = Expression_Adapters::Filesystem::Sessions_::Tmpfile.new

          _path = ::File.join(
            Snag_.lib_.system.defaults.dev_tmpdir_path, 'sn0g' )

          o.tmpdir_path _path
          o.create_at_most_N_directories 2
          o.using_filesystem @_FS
          o
        end

        def __finish_with_tmpfile fh

          fh.close
          @_FS.copy fh.path, @_target_path  # bytes
        end

        def __entity_upstream__

          @entity_upstream  # might be failed
        end

        def __reset_the_entity_upstream__

          _d = @entity_upstream.upstream.rewind  # EEK
          _d.zero?
        end

        def __write_each_node_until_the_subject_node_is_found__

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

        def __write_each_node_whose_identifier_is_greater_than_that_of_subject__

          expag = @expression_agent
          id = @subject_entity.ID or self._SANITY
          st = @entity_upstream
          y = @downstream_lines

          @has_floating = false

          begin

            ent = st.gets
            ent or break

            if id < ent.ID  # this ID is bigger than
              # mine so it goes above me in the file

              ent.express_into_under y, expag
              redo
            end

            @has_floating = true
            @floating = ent
            break
          end while nil

          ACHIEVED_
        end

        def __write_the_new_node__

          @subject_entity.express_into_under(
            @downstream_lines, @expression_agent )
        end

        def __write_any_floating_node__

          if @has_floating

            x = @floating.express_into_under(
              @downstream_lines, @expression_agent )

            @has_floating = false
            @floating = nil
            x
          else
            ACHIEVED_
          end
        end

        def __write_the_remaining_nodes__

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

        class Controller__

          # industrial strength silliness - proxy calls to the exposed
          # methods, but only if everything is still OK. exception like

          Tuple___ = ::Struct.new :name_symbol, :ivar, :local_name_symbol

          the_list = %i(

            subject_entity

            entity_upstream
            reset_the_entity_upstream

            write_each_node_until_the_subject_node_is_found
            write_each_node_whose_identifier_is_greater_than_that_of_subject

            write_the_new_node
            write_any_floating_node
            write_the_remaining_nodes

          ).map do | sym |
            Tuple___.new sym, :"@#{ sym }", :"__#{ sym }__"
          end

          define_method :initialize do | up |

            ok = true

            the_list.each do | tuple |

              instance_variable_set tuple.ivar, -> * a do

                if ok
                  x = up.send tuple.local_name_symbol, * a
                  if ! x
                    ok = x
                  end
                  x
                else
                  ok
                end
              end
            end
          end

          the_list.each do | pair |

            define_method pair.name_symbol do | *a |

              instance_variable_get( pair.ivar ).call( *a )
            end
          end
        end
      end
    end
  end
end
