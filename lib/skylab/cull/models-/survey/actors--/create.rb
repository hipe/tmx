module Skylab::Cull

  class Models_::Survey

    class Actors__::Create

      # #todo in next ci - fix and standardize actor/model interface

      Callback_::Actor.call self, :properties, :survey

      def initialize

        @is_dry_run = false  # future

        super

        @path_arg = @survey.path_arg

        @deeper_path_arg = @path_arg.with_value(
          ::File.join( @path_arg.value_x, FILENAME_ ) )

        @on_event_selectively = @survey.handle_event_selectively

        @build_eigen_event = @survey.method( :to_event )
      end

      def execute

        Cull_._lib.filesystem.normalization.downstream_IO(
          :path_arg, @deeper_path_arg,
          :is_dry_run, true,  # always true, we are checking only
          :ftype, DIR_FTYPE_,
          :on_event_selectively, @on_event_selectively ) and

        when_dir
      end

      def when_dir

        Cull_._lib.system.patch(
          :target_directory, @path_arg.value_x,
          :patch_file,
            Cull_.dir_pathname.join( 'data-documents/create.patch' ).to_path,
          :is_dry_run, @is_dry_run,
          & @on_event_selectively )
      end
    end
  end
end
