module Skylab::Snag

  class Models_::NodeCollection

    module ExpressionAdapters::ByteStream

      class Magnetics_::EndToEndRewrite_via_Arguments  # see [#038]

        def initialize & x_p

          @downstream_identifier = nil

          @expression_agent = ByteStreamExpressionAgent.new(
            DEFAULT_WIDTH_,
            DEFAULT_SUB_MARGIN_WIDTH_,
            DEFAULT_IDENTIFIER_INTEGER_WIDTH_ )

          @is_dry = nil

          @_locks = []

          @on_event_selectively = x_p
        end

        attr_writer :collection, :downstream_identifier,

                    :expression_adapter_actor_box

        attr_reader :expression_agent

        attr_writer :FS_adapter,
                    :is_dry,
                    :subject_entity

        def during_locked_write_session  # note-35 (locking, tmpfiles)

          ok = __resolve_and_possibly_lock_the_upstream
          ok &&= __via_upstream_resolve_the_downstream_adapter
          ok &&= __resolve_the_entity_upstream
          if ok

            x = @_ds_ad.downstream_lines_during_possibly_locked_session do | dsl |

              @downstream_lines = dsl

              @_self = Controller__.new self

              yield @_self
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

            Common_::Event.inline_not_OK_with( :resource_is_busy,
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
              @is_dry,
              ds_id,
              @FS_adapter,
              & @on_event_selectively )

          else

            Direct_Downstream_Adapter___.new @is_dry, ds_id
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

          st = Here_::Magnetics_::NodeStream_via_LineStream.with(

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

        def __mutate_collection_and_subject_entity_by_reappropriation__

          _ = Models_::Node::Actions::Open::Try_to_reappropriate

          x = _[ @subject_entity, @_self, & @on_event_selectively ]
          if x
            __replace_subject_entity__ x
          else
            x
          end
        end

        def __against_collection_add_or_replace_subject_entity__

          x_p = @on_event_selectively

          if @subject_entity.ID
            @expression_adapter_actor_box::NodeReplacement_via_Session[ @_self, & x_p ]
          else
            @expression_adapter_actor_box::NodeAddition_via_Session[ @_self, & x_p ]
          end
        end

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

          def initialize is_dry, x, fsa, & x_p

            @_ds_id = x
            @_FS_adapter = fsa
            @_is_dry = is_dry
            @on_event_selectively = x_p
          end

          def prepare

            o = @_FS_adapter.tmpfile_sessioner
            if o
              @__tmpfile_sessioner = o
              ACHIEVED_
            else
              path
            end
          end

          def downstream_lines_during_possibly_locked_session

            @__tmpfile_sessioner.session do | fh |

              ok_x = yield fh

              fh.close

              if ok_x

                path = @_ds_id.path

                bytes = if @_is_dry
                  0
                else
                  @_FS_adapter.filesystem.copy fh.path, path
                end

                @on_event_selectively.call :info, :wrote do
                  __build_wrote_event bytes, path
                end

                # ok_x = _bytes ; not this - when you create
                # or reappropriate an entity, result in it.
              end

              ok_x
            end
          end

          def __build_wrote_event d, path

            Home_.lib_.system_lib::Filesystem::Events::Wrote.new_with(
              :preterite_verb, 'updated',
              :bytes, d,
              :path, path )
          end
        end

        class Direct_Downstream_Adapter___

          def initialize is_dry, x
            @_ds_id = x
            @_is_dry = is_dry
          end

          def prepare
            if @_is_dry
              self._DESIGN_ME
            else
              __resolve_yielder
            end
          end

          def __resolve_yielder

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

            mutate_collection_and_subject_entity_by_reappropriation
            against_collection_add_or_replace_subject_entity
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
