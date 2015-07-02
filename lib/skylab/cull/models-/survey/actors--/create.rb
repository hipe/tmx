module Skylab::Cull

  class Models_::Survey

    class Actors__::Create

      Callback_::Actor.methodic self, :simple, :properties, :properties,

        :survey,
        :dry_run

      define_singleton_method :[], HARD_CALL_METHOD_

      def execute

        # using dry run, check to see that we could create the directory
        # if we wanted to -- that is, that it does not already exist.

        fs = Home_.lib_.filesystem

        fs.normalization.downstream_IO(
          :path, @survey.workspace_path_,
          :is_dry_run, true,  # always true, we are checking only
          :ftype, fs.constants::DIRECTORY_FTYPE,
          & @on_event_selectively ) and

        when_dir
      end

      def when_dir

        # (we used to patch here)

        @survey.flush_persistence_script_

        cfg = @survey.config_for_write_

        if cfg.is_empty
          cfg.add_comment "ohai"
        end

        kn = @dry_run_arg

        @survey.write_( ( kn.value_x if kn.is_known ) )

      end
    end
  end
end
