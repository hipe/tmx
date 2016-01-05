module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class << self
      def [] up, & p
        Sessioner___.new( up, & p ).execute
      end
    end  # >>

    class Sessioner___

      def initialize up, & oes_p

        @_oes_p = oes_p
        @_values = up
      end

      def execute

        __init_values_via_dependency
        _ok = __resolve_replacement_function
        _ok && self
      end

      def __init_values_via_dependency

        x = @_values.max_file_size_for_multiline_mode
        if ! x
          x = DEFAULT_MAX_FILE_SIZE_FOR_MULTIINE_MODE__
        end
        @max_file_size_for_multiline_mode = x

        rx = @_values.ruby_regexp
        @rx_opts = Home_.lib_.basic::Regexp.options_via_regexp rx
        @ruby_regexp = rx

        NIL_
      end

          DEFAULT_MAX_FILE_SIZE_FOR_MULTIINE_MODE__ = 463296

          # as a stab in the dark we arrived at this number by taking our
          # largest current file (~1.8K SLOC) and multiplying it arbitrarily
          # by 8, which gets you to around 15K lines of platform code.
          # what the "right" cutoff point is totally system dependent and not
          # really of interest to us here, which is why we take this field
          # a parameter and provide this just as a last-line catchall.

      def __resolve_replacement_function

        px = @_values.replacement_parameters
        if px
          s = px.replacement_expression
          dir = px.functions_directory
        end

        if s
          x = Home_::Magnetics_::Replace_Function_via_String_and_Functions_Dir.call(
            s,
            dir,
            & @_oes_p )

          if x
            @_replacement_function = x
            ACHIEVED_
          else
            x
          end
        else
          # (then you'll have to provide your own string for the replacement)
          @_replacement_function = nil
          ACHIEVED_
        end
      end

      def produce_file_session_via_ordinal_and_path d, path

        stat = ::File.stat path  # noent meh

        if stat.size <= @max_file_size_for_multiline_mode

          ___when_multiline_OK d, path

        elsif @rx_opts.is_multiline

          self._COVER_ME
        else

          self._COVER_ME
        end
      end

      def ___when_multiline_OK d, path

        io = ::File.open path, ::File::RDONLY
        big_string = io.read
        io.close

        es = Here___::String_Edit_Session___.new(
          big_string,
          @_replacement_function,
          @ruby_regexp,
        )
        es.set_path_and_ordinal path, d
        es
      end
    end  # sessioner

    Here___ = self
  end
end
