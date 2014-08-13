module Skylab::Snag

  class Models::Tag

    class Collection__

      class Controller__

        class Rm__ < Edit___

          def rm_i stem_i
            @tag = build_tag stem_i
            if @tag.is_valid
              rm_tag
            else
              @tag.last_callback_result
            end
          end

        private

          def rm_tag
            found_tag = find_existing_tag @tag
            if found_tag
              rm_exising_tag found_tag
            else
              when_not_found
            end
          end

          def when_not_found
            _ev = Not_Found__.new identifier, @tag.render
            _r = @listener.receive_error_event _ev
            _r  # :+[#049] whether this is an error is up to the caller
          end

          Not_Found__ = Event_[].new :identifier, :tag_s do
            message_proc do |y, o|
              y << "#{ val o.identifier.render } is not tagged with #{
                }#{ ick o.tag_s }"
            end
          end

          def rm_exising_tag fly
            tag_s = fly.render
            @s = get_body_s
            @begin = fly.pos
            @width = tag_s.length
            nudge_substring_range_to_remove_any_single_surrounding_spaces
            new = @s.dup
            new[ @begin, @width ] = EMPTY_S_
            set_body_s new
            when_removed tag_s
          end

          def nudge_substring_range_to_remove_any_single_surrounding_spaces
            d = @begin + @width
            if 0 < @begin && SPACE__ == @s.getbyte( @begin - 1 )
              @begin -= 1
            end
            if d < ( @s.length - 1 ) && SPACE__ == @s.getbyte( d )
              @width += 1
            end ; nil
          end

          SPACE__ = ' '.getbyte 0

          def when_removed tag_s
            _ev = Removed__.new tag_s
            @listener.receive_info_event _ev
            ACHIEVED_
          end

          Removed__ = Event_[].new :rendered do
            message_proc do |y, o|
              y << "removed #{ val o.rendered }"
            end
          end

          Snag_::Lib_::Entity[][ self, -> do
            def listener
              merge_listener iambic_property
            end
          end ]
        end
      end
    end
  end
end
