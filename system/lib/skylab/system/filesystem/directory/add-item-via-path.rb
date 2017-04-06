module Skylab::System

  module Filesystem

    class Directory::AddItem_via_Path < Common_::MagneticBySimpleModel

      # -
        attr_writer(
          :confirm_by,
          :directory_is_assumed_to_exist,
          :filename_pattern,
          :filesystem,
          :listener,
          :path,
        )

        def execute
          ok = true
          ok &&= __validate_entry_name
          ok &&= __resolve_directory
          ok &&= @confirm_by[]
          ok
        end

        # -- B

        def __resolve_directory
          @_dirname = ::File.dirname @path
          if @filesystem.directory? @_dirname
            ACHIEVED_
          elsif @directory_is_assumed_to_exist
            __when_no_directory
          else
            __make_two_directories_meh
          end
        end

        def __when_no_directory
          @listener.call :error, :expression, :noent do |y|
            y << "no. (sy-xyzzy)."
          end
          UNABLE_
        end

        def __make_two_directories_meh
          _ok = __make_second_dirname
          _ok && __maybe_make_first_dirname
        end

        def __maybe_make_first_dirname
          if @_dirname == @_second_dirname
            ACHIEVED_
          else
            @filesystem.mkdir @_dirname
          end
        end

        def __make_second_dirname
          @_second_dirname = ::File.dirname @_dirname
          if @filesystem.directory? @_second_dirname
            ACHIEVED_
          else
            @filesystem.mkdir @_second_dirname  # -p meh
          end
        end

        # -- A

        def __validate_entry_name
          @_natural_key_string = ::File.basename @path
          if @filename_pattern
            __validate_entry_name_via_filename_pattern
          else
            ACHIEVED_
          end
        end

        def __validate_entry_name_via_filename_pattern
          if @filename_pattern =~ @_natural_key_string
            ACHIEVED_
          else
            __when_does_not_match
          end
        end

        def __when_does_not_match
          s = @_natural_key_string
          @listener.call :error, :expression, :invalid_name do |y|
            y << "invalid name #{ ick_mixed s }"
          end
          UNABLE_
        end
      # -

      # ==
      # ==
    end
  end
end
# #history-A broke out of what is currently "operator branch via directory" years later
