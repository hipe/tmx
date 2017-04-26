module Skylab::Snag

  class Models_::NodeCollection

    module ExpressionAdapters::ByteStream

      class Magnetics_::EndToEndRewrite_via_Arguments < Common_::SimpleModel  # 1x

        # see [#038]

        def initialize

          @_locks = []

          @downstream_reference = nil
          @is_dry = nil
          @listener = nil
          @subject_entity = nil

          yield self

          @expression_agent = ByteStreamExpressionAgent.new(
            DEFAULT_WIDTH_,
            DEFAULT_SUB_MARGIN_WIDTH_,
            DEFAULT_IDENTIFIER_INTEGER_WIDTH_ )
        end

        attr_writer(
          :collection,
          :downstream_reference,
          :expression_adapter_actor_box,
          :invocation_resources,
          :is_dry,
          :listener,
          :subject_entity,
        )

        def during_locked_write_session  # note-35 (locking, tmpfiles)

          ok = __resolve_and_possibly_lock_the_upstream
          ok &&= __via_upstream_resolve_the_downstream_adapter
          ok &&= __resolve_the_entity_upstream
          if ok

            x = @_downstream_adapter.downstream_lines_during_possibly_locked_session do |dsl|

              @downstream_lines = dsl

              @_controller = Controller__.new self

              yield @_controller
            end
          end
          __release_all_locks
          ok && x
        end

        # --

        def __resolve_and_possibly_lock_the_upstream
          if __resolve_the_upstream
            __possibly_lock_the_upstream
          end
        end

        def __possibly_lock_the_upstream

          case @_BUs_ID.shape_symbol
            when :path
            _attempt_to_lock @_simple_line_upstream
            when :IO
            _attempt_to_lock @_simple_line_upstream.BYTE_STREAM_IO_FOR_LOCKING
            when :string
            ACHIEVED_
          else
            self._COVER_ME__make_these_cases_explicit_for_now
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
            __express_cannot_lock io
            UNABLE_
          end
        end

        def __resolve_the_upstream

          @_BUs_ID = @collection.upstream_reference

          _ = @_BUs_ID.TO_REWOUND_SHAREABLE_LINE_UPSTREAM_EXPERIMENT( & @listener )

          _store :@_simple_line_upstream, _
        end

        def __express_cannot_lock io

          @listener.call :error, :resource_is_busy do

            Common_::Event.inline_not_OK_with( :resource_is_busy,
              :resource, io
            ) do |y, o|

              y << "x."
            end
          end
          NIL
        end

        # --

        def __via_upstream_resolve_the_downstream_adapter

          ds_id = @downstream_reference
          if ! ds_id
            ds_id = @_BUs_ID.to_byte_downstream_reference
          end

          if ds_id.is_same_waypoint_as @_BUs_ID  # #note-85

            _ = @invocation_resources.node_collection_filesystem_adapter

            ds_ad = Tmpfile_Downstream_Adapter___.new @is_dry, ds_id, _, & @listener
          else

            ds_ad = Direct_Downstream_Adapter___.new @is_dry, ds_id
          end

          ok = ds_ad.prepare
          ok and @_downstream_adapter = ds_ad
          ok
        end

        # --

        def __resolve_the_entity_upstream

          _ = Here_::Magnetics_::NodeStream_via_LineStream.via(

            :simple_line_upstream, @_simple_line_upstream,
            :extended_content_adapter, @collection,
            & @listener )

          _store :@entity_upstream, _
        end

        def __release_all_locks

          @_locks.each do | io |
            io.flock ::File::LOCK_UN  # meh
          end
          @_locks.clear
          NIL_
        end

        # --

        def _do_this__mutate_collection_and_subject_entity_by_reappropriation__

          x = Models_::Node::Actions::Open::Try_to_reappropriate.call(
            @subject_entity, @_controller, @invocation_resources, & @listener )

          if x
            _do_this__replace_subject_entity__ x
          else
            x
          end
        end

        def _do_this__against_collection_add_or_replace_subject_entity__

          p = @listener

          if @subject_entity.ID
            @expression_adapter_actor_box::NodeReplacement_via_Session[ @_controller, & p ]
          else
            @expression_adapter_actor_box::NodeAddition_via_Session[ @_controller, & p ]
          end
        end

        def _do_this__subject_entity__
          @subject_entity
        end

        def _do_this__replace_subject_entity__ x  # called here too 1x

          if x
            @subject_entity = x
            ACHIEVED_
          else
            x
          end
        end

        def _do_this__entity_upstream__

          @entity_upstream  # might be failed
        end

        def _do_this__reset_the_entity_upstream__

          _d = @entity_upstream.upstream.rewind  # EEK
          _d.zero?
        end

        def _do_this__write_each_node_until_the_subject_node_is_found__

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

          did_find || self._COVER_ME__did_not_find__
          did_find
        end

        def _do_this__write_each_node_whose_identifier_is_greater_than_that_of_subject__

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

        def _do_this__write_the_subject_node__

          @subject_entity.express_into_under(
            @downstream_lines, @expression_agent )
        end

        def _do_this__write_any_floating_node__

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

        def _do_this__write_the_remaining_nodes__

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

        define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

        attr_reader(
          :expression_agent,
        )

        # ==

        class Tmpfile_Downstream_Adapter___

          def initialize is_dry, x, fsa, & x_p

            @_downstream_ID = x
            @_FS_adapter = fsa
            @_is_dry = is_dry
            @listener = x_p
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

                path = @_downstream_ID.path

                bytes = if @_is_dry
                  0
                else
                  @_FS_adapter.filesystem.copy fh.path, path
                end

                @listener.call :info, :wrote do
                  __build_wrote_event bytes, path
                end

                # ok_x = _bytes ; not this - when you create
                # or reappropriate an entity, result in it.
              end

              ok_x
            end
          end

          def __build_wrote_event d, path

            Home_.lib_.system_lib::Filesystem::Events::Wrote.with(
              :preterite_verb, 'updated',
              :bytes, d,
              :path, path )
          end
        end

        # ==

        class Direct_Downstream_Adapter___

          def initialize is_dry, x
            @_downstream_ID = x
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

            _ = @_downstream_ID.to_minimal_yielder_for_receiving_lines
            _store :@_minimal_yielder, _
          end

          def downstream_lines_during_possibly_locked_session

            yield @_minimal_yielder

            # result is result. nothing to do.
          end

          define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
        end

        # ==

        class Controller__

          # industrial strength silliness: proxy calls to the exposed
          # methods, but once any one of these calls fails, the proxy
          # cannot be used for any further calls.

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
          )

          # --

          define_method :initialize do |up|

            ok = true

            the_list.each do |sym|

              _p = -> * a do
                if ok
                  x = up.send :"_do_this__#{ sym }__", * a
                  if ! x
                    ok = x
                  end
                  x
                else
                  ok
                end
              end

              instance_variable_set :"@#{ sym }", _p
            end
            NIL
          end

          # --

          the_list.each do |sym|

            define_method sym do |*a|

              instance_variable_get( :"@#{ sym }" ).call( *a )
            end
          end
        end

        # ==
        # ==
      end
    end
  end
end
