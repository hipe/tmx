module Skylab::Snag

  class Models_::Node_Collection

    module Expression_Adapters::Byte_Stream

      Sessions_ = ::Module.new

      class Sessions_::Rewrite_Stream_End_to_End  # see [#038]

        WIDTH__ = 79  # (defaults:)
        SUB_MARGIN_WIDTH__ = ' #open '.length
        IDENTIFIER_INTEGER_WIDTH___ = 3

        def initialize & x_p

          @downstream_identifier = nil

          @expression_agent = Expression_Agent_.new(
            WIDTH__,
            SUB_MARGIN_WIDTH__,
            IDENTIFIER_INTEGER_WIDTH___ )

          @_locks = []

          @on_event_selectively = x_p
        end

        attr_writer :collection, :downstream_identifier

        attr_reader :expression_agent

        attr_writer :filesystem,
                    :subject_entity, :tmpdir_path_proc

        def during_locked_write_session  # note-35 (locking, tmpfiles)

          ok = __resolve_and_possibly_lock_the_upstream
          ok &&= __via_upstream_resolve_the_downstream_adapter
          ok &&= __resolve_the_entity_upstream
          if ok

            x = @_ds_ad.downstream_lines_during_possibly_locked_session do | dsl |

              @downstream_lines = dsl

              yield Controller__.new self
            end
          end
          __release_all_locks
          ok && x
        end

        def __resolve_and_possibly_lock_the_upstream

          bus_id = @collection.upstream_identifier

          @_bus_id = bus_id

          lus = bus_id.to_rewindable_line_stream( & @on_event_selectively )

          if lus

            @_simple_line_upstream = lus

            case bus_id.shape_symbol
            when :path
              _attempt_to_lock lus
            when :IO
              _attempt_to_lock lus.lockable_resource
            else
              ACHIEVED_
            end
          else
            lus
          end
        end

        def _attempt_to_lock io  # :#note-65

          d = io.flock ::File::LOCK_EX | ::File::LOCK_NB
          if d
            if d.zero?
              @_locks.push io
              ACHIEVED_
            else
              raise "unhandled case: filesystem lock error #{ d }"
            end
          else
            __maybe_emit_for_cannot_lock io
            UNABLE_
          end
        end

        def __maybe_emit_for_cannot_lock io

          @on_event_selectively.call :error, :resource_is_busy do

            Callback_::Event.inline_not_OK_with( :resource_is_busy,
              :resource, io
            ) do | y, o |

              y << "x."

            end
          end
          NIL_
        end

        def __via_upstream_resolve_the_downstream_adapter

          ds_id = @downstream_identifier
          if ! ds_id
            ds_id = @_bus_id.to_byte_downstream_identifier
          end

          ds_ad = if ds_id.is_same_waypoint_as @_bus_id  # #note-85

            Tmpfile_Downstream_Adapter___.new(
              ds_id,
              @tmpdir_path_proc,
              @filesystem,
              & @on_event_selectively )

          else

            Direct_Downstream_Adapter___.new ds_id
          end

          ok = ds_ad.prepare
          if ok
            @_ds_ad = ds_ad
            ACHIEVED_
          else
            ok
          end
        end

        def __resolve_the_entity_upstream

          st = BS_::Actors_::Produce_node_upstream.with(

            :simple_line_upstream, @_simple_line_upstream,
            :extended_content_adapter, @collection,
            & @on_event_selectively )

          if st
            @entity_upstream = st
            ACHIEVED_
          else
            st
          end
        end

        def __release_all_locks

          @_locks.each do | io |
            io.flock ::File::LOCK_UN  # meh
          end
          @_locks.clear
          NIL_
        end

        # ~

        def __subject_entity__
          @subject_entity
        end

        def __replace_subject_entity__ x

          if x
            @subject_entity = x
            ACHIEVED_
          else
            x
          end
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

        def __write_the_subject_node__

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

        class Tmpfile_Downstream_Adapter___

          def initialize x, tdpp, fs, & x_p

            @_ds_id = x
            @_FS = fs
            @_tmpdir_path_proc = tdpp
            @on_event_selectively = x_p
          end

          def prepare

            path = @_tmpdir_path_proc[]
            if path

              o = Expression_Adapters::Filesystem::Sessions_::Tmpfile.new

              o.tmpdir_path path
              o.create_at_most_N_directories 2  # etc
              o.using_filesystem @_FS
              @_tmpfile_session_maker = o

              ACHIEVED_
            else
              path
            end
          end

          def downstream_lines_during_possibly_locked_session

            @_tmpfile_session_maker.session do | fh |

              ok_x = yield fh

              fh.close

              if ok_x
                _bytes = @_FS.copy fh.path, @_ds_id.path  # bytes
                ok_x = _bytes
              end

              ok_x
            end
          end
        end

        class Direct_Downstream_Adapter___

          def initialize x
            @_ds_id = x
          end

          def prepare

            y = @_ds_id.to_minimal_yielder
            if y
              @_minimal_yielder = y
              ACHIEVED_
            else
              y
            end
          end

          def downstream_lines_during_possibly_locked_session

            yield @_minimal_yielder

            # result is result. nothing to do.
          end
        end

        class Controller__

          # industrial strength silliness - proxy calls to the exposed
          # methods, but only if everything is still OK. exception like

          Tuple___ = ::Struct.new :name_symbol, :ivar, :local_name_symbol

          the_list = %i(

            subject_entity
            replace_subject_entity

            entity_upstream
            reset_the_entity_upstream

            write_each_node_until_the_subject_node_is_found
            write_each_node_whose_identifier_is_greater_than_that_of_subject

            write_the_subject_node
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

            NIL_
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
