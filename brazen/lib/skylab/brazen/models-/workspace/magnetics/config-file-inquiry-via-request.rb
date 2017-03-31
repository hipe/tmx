module Skylab::Brazen

  class Models_::Workspace

    class Magnetics::ConfigFileInquiry_via_Request < Common_::MagneticBySimpleModel

      # a fresh take on this, not yet integrated in [br] but being developed
      # for [tm] and meant to fold back in to here:
      #
      #   - be generally frozen
      #
      #   - (except for a reference to a file lock)
      #
      #   - so determine state at construction time
      #
      #   - so produce and cache pertinent events for later doo-hitily

      # -

        def initialize
          @_can_expand_path = false
          yield self
          @max_num_dirs_to_look ||= 1  # for now not all clients are required to pass this
          @system = Home_.lib_.system  # for now. just for abs path stuff.
          @__mutex_for_execute_once = nil
        end

        def yes_can_expand_path
          @_can_expand_path = true
        end

        attr_writer(
          :max_num_dirs_to_look,
          :filesystem,
          :listener,
          :path_head,
          :path_tail,
        )

        def execute
          remove_instance_variable :@__mutex_for_execute_once
          __inquire
          freeze
        end

        def __inquire
          if __path_is_absolute
            _do_inquire
          elsif @_can_expand_path
            __expand_path
            _do_inquire
          else
            __whine_about_non_absolute_path
          end
        end

        def __path_is_absolute

          if @system.path_looks_absolute @path_head
            @_absolute_path_head = @path_head ; true
          else
            @_UNSANITIZED_PATH_PATH = path ; false
          end
        end

        def _do_inquire

          chan = nil ; ev = nil

          sct = Home_.lib_.system_lib::Filesystem::Walk.via(

            :max_num_dirs_to_look, @max_num_dirs_to_look,
            :start_path, @_absolute_path_head,
            :filename, @path_tail,
            :filesystem, @filesystem,
            :do_lock, true,  # effects result shape

          ) do |*chan_, &ev_p|
            ev = ev_p[]  # ..
            chan = chan_ ; :_no_see_BR_
          end

          if sct
            @locked_IO = sct.locked_IO
            @surrounding_path = sct.surrounding_path
            @file_exists = true
          else
            @unsanitized_path = ::File.join @_absolute_path_head, @path_tail
            @_event = :__event ; @__event = ev
            @channel = chan
            @file_exists = false
          end
          NIL
        end

        # -- read

        def event
          send @_event
        end

        def __event
          @__event
        end

        attr_reader(
          :channel,
          :file_exists,
          :locked_IO, # as applicable
          :path_tail,  # for creating workspace, echo it back
          :surrounding_path,  # as applicable
          :unsanitized_path,  # as applicable
        )
      # -
    end
  end
end
# #history: lived in model file for a few clicks. DNA is ~2.5 years older than file
