module Skylab::Snag

  class Models_::Criteria

    class ExpressionAdapters::Filesystem

      class << self

        def call * a, & x_p
          new( a, & x_p ).execute
        end
      end  # >>

      def initialize a, & p_p

        @col_x, @word_array, @ent, @tmpfile_sessioner, @FS = a

        if p_p
          @_listenerer = p_p
        end

        @dir_path = @col_x.startingpoint_path
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

        scn = Common_::Scanner.via_array @word_array

        Common_.stream do

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

        _p = @_listenerer[ self ]

        _p.call :info, :added_entity do

          _nf = @col_x.to_model_name  # why we added [#sy-008.2] (for us)

          _linked_list = Home_.lib_.basic::List::Linked[ nil, _nf ]

          ACS_[]::Events::ComponentAdded.with(
            :component, @ent,
            :context_as_linked_list_of_names, _linked_list,
          )
        end

        ACHIEVED_
      end
    end
  end
end
