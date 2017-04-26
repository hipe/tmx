module Skylab::Cull

  class Models_::Survey

    class Magnetics_::CreateSurvey_via_Survey

      ATTRIBUTES = Attributes_.call(
        survey: nil,  # order - this one first :(
        dry_run: nil,
      )

      class << self
        define_method :_call, HARD_CALL_METHOD_
        alias_method :[], :_call
        alias_method :call, :_call
        alias_method :begin_session__, :new
        undef_method :new
      end  # >>

      def initialize & oes_p
        @_emit = oes_p
      end

      def execute

        # using an outside facility and in a :+#non-atomic manner, check to
        # see that we will probably be able to create the directory;
        # that is, that the directory itself does not exist but that its
        # dirname exists and is a directory.

        kn = Home_.lib_.system_lib::Filesystem::Normalizations::ExistentDirectory.via(

          :path, @survey.workspace_path_,
          :is_dry_run, true,  # always true, we are checking only
          :create,
          :filesystem, Home_.lib_.system.filesystem,
          & @_emit )

        if kn

          # the value of the known is a mock directory. for sanity:

          kn.value_x.to_path or fail

          __money
        else
          kn
        end
      end

      def __money

        # (we used to patch here)

        @survey.flush_persistence_script_

        cfg = @survey.config_for_write_

        if cfg.DOCUMENT_IS_EMPTY
          cfg.add_comment "ohai"
        end

        kn = @dry_run_arg

        @survey.write_( ( kn.value_x if kn.is_known_known ) )

      end
    end
  end
end