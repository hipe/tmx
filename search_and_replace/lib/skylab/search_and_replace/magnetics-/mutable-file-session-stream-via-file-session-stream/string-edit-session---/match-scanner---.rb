module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class String_Edit_Session___

      class Match_Scanner___

        # each next match, with a memo of the current match

        def initialize s, rx

          pos = 0
          done = nil ; something = nil
          gets = -> do
            md = rx.match s, pos
            if md
              something[ md ]
            else
              done[]
            end
          end

          last = s.length
          something = -> md do
            pos_ = md.offset( 0 ).last
            if last == pos_
              done[]
            elsif pos == pos_
              pos = pos + 1  # covered - zero-width match. or inf. loop
            else
              pos = pos_
            end
            md
          end

          done = -> do
            something = nil
            gets = EMPTY_P_
            NOTHING_
          end

          md = gets[]
          if md
            @has_current_matchdata = true
            @_current_matchdata = -> do
              md
            end
          else
            @has_current_matchdata = false
          end

          @_advance_one = -> do  # assume has current item
            md = gets[]
            if ! md
              @has_current_matchdata = false
              remove_instance_variable :@_current_matchdata
            end
            NIL_
          end
        end

        def gets_one_matchdata
          x = @_current_matchdata[]
          @_advance_one[]
          x
        end

        def current_matchdata
          @_current_matchdata[]
        end

        def advance_one
          @_advance_one[]
        end

        def no_remaining_matchdata
          ! @has_current_matchdata
        end

        attr_reader(
          :has_current_matchdata,
        )
      end
    end
  end
end
