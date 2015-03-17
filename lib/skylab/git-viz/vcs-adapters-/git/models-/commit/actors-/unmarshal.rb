module Skylab::GitViz

  module VCS_Adapters_::Git

    class Models_::Commit

      class Actors_::Unmarshal  # broad algorithm narrated in [#012], storypoints in [#009]

        Callback_::Actor.call self, :properties,

          :ci, :upstream

        def execute

          __process_SHA_line
          __process_ISO_8601_datetime_line
          NEWLINE_ == @upstream.gets or raise ::ArgumentError
          __process_line_items

          ACHIEVED_  # all failure is exceptional here
        end

        def __process_SHA_line
          @ci.SHA = Models_::SHA.via_normal_string( @upstream.gets.chomp!.freeze )
          NIL_
        end

        def __process_ISO_8601_datetime_line

          _date, _time, _zone =
            GIT_STYLE_ISO8601_RX___.match( @upstream.gets.chomp! ).captures

          _s = "#{ _date }T#{ _time }#{ _zone }"  # [#009]:#storypoint-36 git might have an issue

          @ci.author_datetime = GitViz_.lib_.date_time.iso8601 _s  # raised a.e

          NIL_
        end

        GIT_STYLE_ISO8601_RX___ =

        /\A(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}:\d{2}) ([-+]\d{4})\z/

        def __process_line_items  # :[#012]:#line-item.

          fc_a = []

          begin
            line = @upstream.gets
            line or break
            line.chomp!
            fc_a.push Models_::Filechange.via_normal_string line
            redo
          end while nil

          @ci.filechanges = fc_a.freeze

          NIL_
        end
      end
    end
  end
end
