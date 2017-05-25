module Skylab::Cull

  class Models_::Survey

    class Magnetics_::Survey_via_SurveyPath < Common_::MagneticBySimpleModel  # 1x, stowaway

      #   - this is a stowaway in the host file for reasons. (it was
      #     initially quite small #history-A.1). we anticipate that as needed,
      #     this and maybe the other performer in this file will abstract out
      #     to a dedicated entity toolkit.
      #
      #   - the bulk of this performer is written almost blindly pursuant
      #     to the flowchart as referenced inline..
      #
      #   - for now this is specific to unmarshaling "surveys" but this
      #     magnetic could be abstracted to work for any "git-config"
      #     based entity..

      def initialize
        super
        @associations_module = Here_::Associations_  # ..
        @models_module = Home_::Models_  # ..
      end

      attr_writer(
        :filesystem,
        :listener,
        :survey_path,
      )

      def execute
        if __parse_config
          __via_config
        end
      end

      def __via_config
        ok = nil
        svy = Here_.define_survey_ do |o|
          @_mutable_survey = o
          ok = __via_mutable_survey
          if ok  # (it shouldn't kill things to do the below. also, :#spot1.4)
            o.accept_initial_config_ @_readable_config
            o.survey_path = @survey_path
          end
        end
        ok && svy
      end

      def __via_mutable_survey
        # (exactly the flowchart of [#010] fig. 1)
        while __next_section
          if __find_association_for_this_section_name
            if __parse_the_entity_via_the_section
              if __the_association_is_a_singleton_association
                if __the_ivar_is_already_set
                  __whine_about_multiple_entities_for_a_single_association ; break
                else
                  __store_the_entity_under_the_ivar
                end
              else
                __autovivify_the_array_and_push_the_entity_to_it
              end
            else
              break  # should have whined natively
            end
          else
            __whine_about_unrecognized_section_name ; break
          end
        end
        __OK_or_not_OK
      end

      # --

      def __OK_or_not_OK
        remove_instance_variable :@_OK_or_not_OK
      end

      def _failed
        @_OK_or_not_OK = false ; UNABLE_
      end

      # --

      def __the_association_is_a_singleton_association
        # #cov1.3
        @_current_association_module::IS_SINGLETON_ASSOCIATION
      end

      def __the_ivar_is_already_set
        @_mutable_survey._knows_value_for_association_ @_current_association_name
      end

      def __whine_about_multiple_entities_for_a_single_association

        # (this is the new :#cov1.6, moved here from elsewhere.)

        # (we used to be able to indicate the erroneous number of sections,
        # but now we short circuit on the first extra one, which is fine.)

        nm = @_current_association_name

        @listener.call :error, :expression, :multiple_sections_for_singleton do |y|

          y << "the document has more than one existing \"#{ nm.as_human }\" section."
          y << "must have at most one."
        end

        _fail
      end

      def __store_the_entity_under_the_ivar
        _ent = remove_instance_variable :@_current_entity
        @_mutable_survey._write_via_association_ _ent, @_current_association_name
      end

      def __autovivify_the_array_and_push_the_entity_to_it
        ::Kernel._COVER_ME__ohai__
        # (we expect this to happen sometime soon, for example with functions)
      end

      # --

      def __parse_the_entity_via_the_section

        _c = @_current_association_module::MODEL_CONST
        _model_module = @models_module.const_get _c, false

        _nv_st = __flush_primitive_name_value_stream_via_section

        ent = _model_module.via_persistable_primitive_name_value_pair_stream_ do |o|
          o.name_value_pair_stream = _nv_st
          o.survey_path = @survey_path
          o.filesystem = @filesystem
          o.listener = @listener
        end

        if ent
          @_current_entity = ent ; true
        else
          _fail
        end
      end

      def __flush_primitive_name_value_stream_via_section

        sect = remove_instance_variable :@_current_section
        ary = sect.assignments.ARRAY_READ_ONLY

        s = sect.subsection_string
        if s
          use_ary = []
          use_ary.push SurrogateAssignment___.new s, @_current_association_symbol  # #emergent-mechanic-1
          use_ary.concat ary
        else
          use_ary = ary
        end

        Stream_.call use_ary do |asmt|

          Common_::QualifiedKnownKnown.via_value_and_symbol(
            asmt.value,
            asmt.external_normal_name_symbol,
          )
        end
      end

      SurrogateAssignment___ = ::Struct.new :value, :external_normal_name_symbol

      # --

      def __find_association_for_this_section_name

        @_current_association_symbol = @_current_section.external_normal_name_symbol
        _ob = _associations_operator_branch
        item = _ob.lookup_softly @_current_association_symbol
        if item
          # (shed the intricacies of the remote library now by exploding the item)
          @_current_association_module = item.value
          @_current_association_name = item.name
          ACHIEVED_
        end
      end

      def __whine_about_unrecognized_section_name

        sect = @_current_section
        @listener.call :error, :expression, :unrecognized_section_name do |y|
          _hum = humanize sect.external_normal_name_symbol
          y << "the section \"#{ _hum }\" does not correspond to any known association."
        end
        _fail
      end

      def _associations_operator_branch
        @associations_module.boxxy_module_as_operator_branch
      end

      # --

      def __next_section
        send( @_next_section ||= :__next_section_initially )
      end

      def __next_section_normally
        sect = @__section_stream.gets
        if sect
          @_current_section = sect ; true
        else
          @_OK_or_not_OK = true
          @_next_section = nil
          remove_instance_variable :@__section_stream ; false
        end
      end

      def __next_section_initially
        @_next_section = :__next_section_normally
        @__section_stream = @_readable_config.to_section_stream
        @_next_section = :__next_section_normally
        send @_next_section
      end

      # --

      def __parse_config

        _config_path = ::File.join @survey_path, CONFIG_FILENAME_

        _cfg = Git_config_[].parse_document_by do |o|
          o.upstream_path = _config_path
          o.listener = @listener
        end

        _store :@_readable_config, _cfg
      end

      def _fail
        @_OK_or_not_OK = false ; false
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end

    # ~

    class Magnetics_::PersistSurvey_via_Survey < Common_::MagneticBySimpleModel

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
        # (this :#spot1.3 may be redundant with other places that unset sections)
        qk = @_current_qualified_component
          # (cleanup assets..)
          $stderr.puts "IGNORING CLEAN UP ASSETS FOR NOW in [cu] (for #{ qk.name.as_const })"
          ACHIEVED_
      end

      def __write_component
        qc = @_current_qualified_component
        _asc = qc.association
        _asc_mod = _asc.module
        _ok = _asc_mod::WriteComponent_via_Component_and_Entity.call(
          qc, @survey, & @listener )
        _ok  # hi. #todo
      end

      # -- C

      def __write_the_config_file

        cfg = @survey.config_for_write_  # ..

        if cfg.DOCUMENT_IS_EMPTY
          cfg.add_comment "ohai"
        end

        su_path = @survey.survey_path_

        config_path = ::File.join su_path, CONFIG_FILENAME_

        if ! @is_re_persist
          ::Dir.mkdir su_path  # dry? atomic? failure? meh
        end

        @survey.flush_persistence_script_  # goes away momentarily

        _bytes = cfg.write_to_path_by do |o|
          o.path = config_path
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

        _config_path = ::File.join survey_path, CONFIG_FILENAME_

        _bytes = cfg.write_to_path_by do |o|
          o.path = _path
          o.is_dry = @is_dry_run
          o.listener = @listener
        end  # number of bytes

        _bytes  # hi. #todo
      end
    end

    # ~
    # ~
  end
end
# :#history-A.1: big spike of unmarshaling performer
