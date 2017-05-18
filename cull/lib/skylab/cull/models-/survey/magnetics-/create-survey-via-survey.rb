module Skylab::Cull

  class Models_::Survey

    class Magnetics_::CreateSurvey_via_Survey < Common_::Dyadic

      def initialize survey, eek, & p
        @filesystem = eek._microservice_invocation_.invocation_resources.filesystem
        @is_dry_run = eek._simplified_read_ :dry_run  # where available
        @listener = p
        @survey = survey
      end

      def execute

        # using an outside facility and in a :+#non-atomic manner, check to
        # see that we will probably be able to create the directory;
        # that is, that the directory itself does not exist but that its
        # dirname exists and is a directory.

        if __check_the_thing_ding_with_the_thing
          __money
        end
      end

      def __check_the_thing_ding_with_the_thing

        kn = Home_.lib_.system_lib::Filesystem::Normalizations::ExistentDirectory.via(

          :path, @survey.survey_path_,
          :is_dry_run, true,  # always true, we are checking only
          :create,
          :filesystem, @filesystem,
          & @listener )

        if kn

          # the value of the known is a mock directory. for sanity:

          kn.value.to_path or fail
          ACHIEVED_
        end
      end

      def __money

        # (we used to patch here)

        @survey.flush_persistence_script_

        cfg = @survey.config_for_write_

        if cfg.DOCUMENT_IS_EMPTY
          cfg.add_comment "ohai"
        end

        _bytes = @survey.write_ @listener, @is_dry_run

        _bytes  # hi. #todo
      end
    end

    # ~

    Magnetics_::Survey_via_SurveyPath = -> su_path, & p do
      # -

        _config_path = ::File.join su_path, CONFIG_FILENAME_

        cfg = Git_config_[].parse_document_by do |o|
          o.upstream_path = _config_path
          o.listener = p
        end

        if cfg

          Here_.define_sanitized_ do |o|

            o.cfg_for_write = nil
            o.cfg_for_read = cfg
            o.survey_path = su_path
          end
        end
      # -
    end

    # ~
    # ~
  end
end
# #pending-rename: "persist" not "create"
