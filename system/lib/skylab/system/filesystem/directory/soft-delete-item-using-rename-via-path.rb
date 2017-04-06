module Skylab::System

  module Filesystem

    class Directory::SoftDeleteItemUsingRename_via_Path < Common_::MagneticBySimpleModel

      # given a file with a name like "foo.bar", "delete" the file by
      # trying to rename the file to a name like "foo.bar.previous". if that
      # name is unavailable, try "foo.bar.2.previous". if that name is
      # unavailable, try "foo.bar.3.previous", and so on to infinity until
      # you find a name that is available.
      #
      # :[#008.4] #borrow-coverage from [sn]

      # -
        attr_writer(
          :confirm_by,
          :association,
          :filesystem,
          :listener,
          :path,
        )

        def execute

          __initialize_the_first_name

          while __the_current_name_is_not_available
            _will_try_the_next_name
          end

          __use_the_current_name
        end

        def __use_the_current_name

          _ok = @filesystem.mv @path, @_current_path, & @listener
          _ok && @confirm_by[]
        end

        def __the_current_name_is_not_available

          _yes = @filesystem.file? @_current_path
          _yes  # hi. #todo
        end

        def __initialize_the_first_name

          @__next_tail = Next_tailer___[]

          @__dirname = ::File.dirname @path
          @__head = ::File.basename @path

          _will_try_the_next_name
        end

        def _will_try_the_next_name

          @_current_path = ::File.join @__dirname, "#{ @__head }#{ @__next_tail[] }"
          NIL
        end
      # -

      # ==

      Next_tailer___ = Lazy_.call do

        Basic_[]::String::Successorer.via(

          :beginning_width, 2,
          :first_item_does_not_use_number,

          :template, "{{ sep if ID }}{{ ID }}{{ tail }}",

          :sep, DOT_,
          :tail, '.previous',
        )
      end

      # ==
      # ==
    end
  end
end
# #history-A: broke out of (at the time) "operator branch via directory". years older
