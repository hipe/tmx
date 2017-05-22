module Skylab::Cull

  class Models_::Survey

    class Magnetics_::CreateSurvey_via_Survey < Common_::MagneticBySimpleModel

      def initialize
        @is_re_persist = nil
        super  # hi.
      end

      attr_writer(
        :is_dry_run,
        :is_re_persist,
        :listener,
        :filesystem,
        :survey,
      )

      def execute

        # using an outside facility and in a :+#non-atomic manner, check to
        # see that we will probably be able to create the directory;
        # that is, that the directory itself does not exist but that its
        # dirname exists and is a directory.

        ok = __maybe_check_that_directory_exists
        ok &&= __write_things_other_than_the_config_file
        ok && __write_the_config_file
      end

      # -- D

      def __write_things_other_than_the_config_file

        st = @survey.to_stream_of_qualified_components__
        ok = true
        begin
          qk = st.gets
          qk || break
          @_current_qualified_component = qk
          ok = if qk.is_known_known
            __write_component
          else
            __maybe_delete_component
          end
        end while ok
        ok
      end

      def __maybe_delete_component
        qk = @_current_qualified_component
          # (cleanup assets..)
          $stderr.puts "IGNORING CLEAN UP ASSETS FOR NOW in [cu] (for #{ qk.name.as_const })"
          ACHIEVED_
      end

      def __write_component
        qc = @_current_qualified_component
        _asc = qc.association
        _asc_mod = _asc.module
        _ok = _asc_mod::WriteComponent_via_Component_and_Survey.call(
          qc, @survey, & @listener )
        _ok  # hi. #todo
      end

      # -- C

      def __write_the_config_file

        cfg = @survey.config_for_write_  # ..

        if cfg.DOCUMENT_IS_EMPTY
          cfg.add_comment "ohai"
        end

        dir = @survey.survey_path_

        _path = ::File.join dir, CONFIG_FILENAME_

        if ! @is_re_persist
          ::Dir.mkdir dir  # dry? atomic? failure? meh
        end

        @survey.flush_persistence_script_  # goes away momentarily

        _bytes = cfg.write_to_path_by do |o|
          o.path = _path
          o.is_dry = @is_dry_run
          o.listener = @listener
        end  # number of bytes

        _bytes  # hi. #todo
      end

      # -- B

      def __maybe_check_that_directory_exists
        if @is_re_persist
          # (we assume that the directory hasn't been removed since ..)
          ACHIEVED_
        else
          __check_that_directory_exists
        end
      end

      def __check_that_directory_exists

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

        survey_path = @survey.survey_path_
        ::Dir.mkdir survey_path  # dry? atomic? errors? meh.

        _path = ::File.join survey_path, CONFIG_FILENAME_

        _bytes = cfg.write_to_path_by do |o|
          o.path = _path
          o.is_dry = @is_dry_run
          o.listener = @listener
        end  # number of bytes

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

            o.accept_initial_config_ cfg
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
