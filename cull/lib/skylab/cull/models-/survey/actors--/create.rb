module Skylab::Cull

  class Models_::Survey

    class Actors__::Create

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
        @on_event_selectively = oes_p
      end

      def execute

        # using an outside facility and in a :+#non-atomic manner, check to
        # see that we will probably be able to create the directory;
        # that is, that the directory itself does not exist but that its
        # dirname exists and is a directory.

        kn = Home_.lib_.system.filesystem( :Existent_Directory ).with(

          :path, @survey.workspace_path_,

          :is_dry_run, true,  # always true, we are checking only

          :create,

          & @on_event_selectively )

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

        if cfg.is_empty
          cfg.add_comment "ohai"
        end

        kn = @dry_run_arg

        @survey.write_( ( kn.value_x if kn.is_known_known ) )

      end
    end
  end
end
