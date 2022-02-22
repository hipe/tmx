module Skylab::DocTest

  class RecursionMagnetics_::ProbablyParticipatingFileStream_via_ArgumentPath

    # as hashed out in [#005], we are simply building a find command like:
    #
    #     find /the/argument/path -name test -prune -o -name '*.kode' -print
    #

    # non-declared parameters: name_conventions
    # currently hard-coded: the_find_service

    class << self

      def of rsx
        call(
          rsx.argument_path,
          rsx.name_conventions,
          rsx.system_conduit,
          & rsx.listener_
        )
      end

      def call *a, &p
        new( *a, &p ).execute
      end

      alias_method :[], :call
      private :new
    end  # >>

    def initialize ap, nc, sc, & p
      @argument_path = ap
      @name_conventions = nc
      @_on_event_selectively = p
      @system_conduit = sc
      @the_find_service = Home_.lib_.system.find  # module
    end

    def execute
      ok = true
      ok &&= __resolve_valid_infix_thing
      ok &&= __resolve_valid_filenames
      ok && __init_find_things
      ok && __greporino
    end

    # == GREP

    def __greporino

      # useless

      @the_grep_service ||= Home_.lib_.system.grep  # module

      proto = @the_grep_service.with(
        :grep_extended_regexp_string, '[^[:space:]][ ]+# =>',
        :freeform_options, %w( --files-with-matches ),
        :system_conduit, @system_conduit,
        & @_on_event_selectively
      ).finish

      asset_path_st = remove_instance_variable :@_find_stream

      _CHUNK_SIZE = 30  # see [#here.B] if you dare
      next_chunk = -> do
        path = asset_path_st.gets
        if path
          chunk = [ path ]
          count = 1
          begin
            if _CHUNK_SIZE == count
              break
            end
            path = asset_path_st.gets
            if ! path
              next_chunk = EMPTY_P_
              break
            end
            chunk.push path
            count += 1
            redo
          end while above
          chunk
        else
          next_chunk = EMPTY_P_
          path
        end
      end

      p = nil
      main_p = -> do
        files = next_chunk[]
        if files

          st = proto.new_with(
            :paths, files,
          ).to_output_line_content_stream

          p = -> do
            path = st.gets
            if path
              path
            else
              p = main_p
              p[]
            end
          end
          p[]
        else
          p = EMPTY_P_
          files
        end
      end
      p = main_p

      Common_.stream do
        p[]
      end
    end

    # == FIND

    def __init_find_things

      find = @the_find_service.statuser_by( & @_on_event_selectively )

      _command = @the_find_service.with(
        :path, @argument_path,
        :filenames, remove_instance_variable( :@__valid_filenames ),
        :freeform_query_infix_words, remove_instance_variable( :@__infix ),
        :freeform_query_postfix_words, [ '-print' ],
        :when_command, IDENTITY_,
        & find
      )

      _st = _command.path_stream_probably_ordered_via @system_conduit
      # #history-B.1

      _st || self._SANITY  # even when noent
      @_find_status = find
      @_find_stream = _st
      NIL
    end

    # -- the find command is sent directly to the system, not thru a shell
    #    so in theory any string should be OK and not break the syntax.

    def __resolve_valid_filenames
      s = @name_conventions.asset_filename_pattern__
      if s && s.length.nonzero?
        @__valid_filenames = [ s ]
        ACHIEVED_
      else
        s && UNABLE_
      end
    end

    def __resolve_valid_infix_thing
      s = @name_conventions.test_directory_entry_name
      if s && s.length.nonzero?
        @__infix = [ '-name', s, '-prune', '-o', '-type', 'f' ]
        ACHIEVED_
      else
        s && UNABLE_
      end
    end
  end
end
# #history-B.1: target Ubuntu not OS X
