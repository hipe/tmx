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

        Cull_.lib_.filesystem.normalization.downstream_IO(
          :path, @survey.workspace_path_,
          :is_dry_run, true,  # always true, we are checking only
          :ftype, DIR_FTYPE_,
          :on_event_selectively, @on_event_selectively ) and

        when_dir
      end

      def when_dir

        # (we used to patch here)

        @survey.flush_persistence_script_

        cfg = @survey.config_for_write_

        if cfg.is_empty
          cfg.add_comment "ohai"
        end

        @survey.write_ @dry_run_arg.value_x

      end
    end
  end
end
