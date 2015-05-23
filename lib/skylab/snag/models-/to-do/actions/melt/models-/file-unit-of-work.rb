module Skylab::Snag

  class Models_::To_Do

    class Actions::Melt

      Models_ = ::Module.new

      class Models_::File_Unit_of_Work  # see [#068]:#note-110

        class << self

          alias_method :new_prototype, :new
          private :new
        end  # >>

        def initialize
          yield self
          freeze
        end

        attr_writer :is_dry,
          :filesystem_conduit,
          :kernel,
          :on_event_selectively,
          :sessioner,
          :system_conduit

        def new match_ary, path
          dup.__init match_ary, path
        end

        protected def __init match_a, path

          @_match_a = match_a
          @_path = path
          self
        end

        def OMG_try  # #note-40

          @_patch = Snag_.lib_.system.patch.new_via_file_content_before(
            @filesystem_conduit.open @_path )

          ok = true
          _x = @sessioner.during_locked_write_session do | sess |

            @_sess = sess
            @_match_a.each do | match |
              @_match = match
              ok = __via_the_match_create_the_node
              ok &&= __add_the_node_to_the_collection
              ok &&= __add_the_single_line_change_to_the_mutable_patch
              ok or break
            end
          end

          if ok
            ok = __apply_the_patch
          end

          ok
        end

        def __via_the_match_create_the_node

          s = @_match.chomped_post_tag_string.dup
          s.strip!

          @_node_message = s

          node = Snag_::Models_::Node.edit_entity(
            # note an identifier is not set
            :append, :string, @_node_message
          )
          if node
            @_node = node
            @_sess.replace_subject_entity node
            ACHIEVED_
          else
            node
          end
        end

        def __add_the_node_to_the_collection  # assume node is subject entity

          sess = @_sess
          sess.mutate_collection_and_subject_entity_by_reappropriation
          sess.against_collection_add_or_replace_subject_entity
        end

        def __add_the_single_line_change_to_the_mutable_patch  # (was #note-170)

          match = @_match
          line = match.full_source_line.dup
          edit_r = match.body_range.begin ... ( line.length - 1 )  # assume NEWLINE_

          # don't let the length of the replacement string exceed the length
          # of the substring being replaced - given the length of the latter,
          # subtract from it the length taken up by expressing the identifer
          # of the new node and the (e.g) open tag. with any remaining
          # available length, fill it up with an (ellipsied IFF necessary)
          # form of the message substring from the string being replaced.

          d = edit_r.end - edit_r.begin  # available length

          id_s = @_node.ID.express_into_under "", @sessioner.expression_agent
          tag_s = '#open '  # hard-coded for now

          d -= tag_s.length
          d -= id_s.length
          d -= SPACE_.length  # the separator btwn identifier and message

          if 0 < d

            _ = Snag_.lib_.basic::String.ellipsify @_node_message, d
            _tail_s = "#{ SPACE_ }#{ _ }"
          end

          line[ edit_r ] = "#{ tag_s }#{ id_s }#{ _tail_s }"

          @_patch.change_line match.line_number, line
        end

        def __apply_the_patch

          @_patch.apply_to_path_on_system(
            :is_dry_run, @is_dry,
            @_path,
            @system_conduit,
            & @on_event_selectively )
        end
      end
    end
  end
end
