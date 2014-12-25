module Skylab::Cull

  class Models_::Survey

    class Actors__::Create

      Callback_::Actor.call self, :properties, :survey

      def initialize
        super
        @path_arg = @survey.path_arg

        @deeper_path_arg = @path_arg.with_value(
          ::File.join( @path_arg.value_x, FILENAME_ ) )

      end

      def execute

        _ = Cull_._lib.filesystem.normalization.downstream_IO(
          :path_arg, @deeper_path_arg,
          :is_dry_run, true,  # always true, we are checking only
          :ftype, DIR_FTYPE_,
          :on_event_selectively, @survey.handle_event_selectively )

        _ and when_dir
      end

      def when_dir

        _whole_patch = ::File.read(
          Cull_.dir_pathname.join( 'data-documents/create.patch' ).to_path )

        maybe_emit = -> path do
          @survey.handle_event_selectively.call :info, :created_file do
            Brazen_.event.inline_neutral_with :created_file, :path, path
          end
        end

        first_file = nil

        matchdata = -> md do
          first_file = File.join @path_arg.value_x, md.post_match
          matchdata = -> md_ do
            maybe_emit[ ::File.join( @path_arg.value_x, md.post_match ) ]
          end
          maybe_emit[ first_file ]
        end

        rx = /\Apatching file /

        p = -> str_ do
          p = -> str do
            md = rx.match str
            if md
              matchdata[ md ]
            end
          end
        end

        @status = Cull_._lib.system.patch.directory(
          _whole_patch,
          @path_arg.value_x,
          false,  # dry run
          true,  # be verbose
          -> str do
            p[ str ]
          end )

        if @status.exitstatus.zero?
          @survey.config_path = first_file
          ACHIEVED_
        else
          self._COVER_ME
        end
      end
    end
  end
end
