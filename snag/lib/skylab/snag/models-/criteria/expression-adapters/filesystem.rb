module Skylab::Snag

  class Models_::Criteria

    class Expression_Adapters::Filesystem

      class << self

        def [] * a, & x_p
          new( a, & x_p ).execute
        end
      end  # >>

      def initialize a, & x_p

        @col_x, @word_array, @ent, @tmpfile_sessioner, @FS = a
        x_p and @on_event_selectively = x_p

        @dir_path = @col_x.directory_path
      end

      def execute

        st = __build_a_stream_of_marshalled_words

        @tmpfile_sessioner.session do | fh |

          s = st.gets or raise ::ArgumentError  # empty a
          fh.write s
          begin
            s = st.gets
            s or break
            fh.write " #{ s }"
            redo
          end while nil

          fh.write NEWLINE_
          fh.close

          _dst = ::File.join @dir_path, @ent.natural_key_string

          d = @FS.mv fh.path, _dst
          if d && d.zero?
            __maybe_emit_event
          else
            UNABLE_
          end
        end
      end

      def __build_a_stream_of_marshalled_words

        scn = Callback_::Polymorphic_Stream.via_array @word_array

        Callback_.stream do

          if scn.unparsed_exists

            x = scn.gets_one

            if ! x
              raise ::ArgumentError
            end

            if SPACE_RX___ =~ x
              self._IMPLEMENT_ME_criteria_serialization
            end

            x
          end
        end
      end

      SPACE_RX___ = /[[:space:]]/

      def __maybe_emit_event

        # a criteria getting saved is part of a "macro operation" that also
        # includes the criteria being run. the "slot" of the result value
        # is used for the result of the criteria being run. so we need
        # another way of expressing whether or not the saved worked, because
        # it's otherwise bad design to have this look identitcal to a non-
        # saving criteria run. so we emit something here "manually":

        @on_event_selectively.call :info, :added_entity do

          ACS_[].event( :Component_Added ).new_with(
            :component, @ent,
            :ACS, @col_x,
          )
        end

        ACHIEVED_
      end
    end
  end
end
