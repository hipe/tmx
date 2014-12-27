module Skylab::Cull

  class Models_::Survey

    class Actors__::Create

      Callback_::Actor.methodic self, :simple, :properties, :properties,

        :dry_run,
        :path

      define_singleton_method :[], COMMON_ACTOR_AREF_METHOD_

      def initialize & edit_p

        instance_exec( & edit_p )

        @deeper_path_arg = @path_arg.with_value(
          ::File.join( @path_arg.value_x, FILENAME_ ) )

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

        workspace_dir = @path_arg.value_x

        Cull_._lib.system.patch(
          :target_directory, workspace_dir,
          :patch_file,
            Cull_.dir_pathname.join( 'data-documents-/create.patch' ).to_path,
          :is_dry_run, @dry_run_arg.value_x,
          & @on_event_selectively ) and

        workspace_dir
      end
    end
  end
end
