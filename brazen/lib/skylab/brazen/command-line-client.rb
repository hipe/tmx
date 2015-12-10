module Skylab::Brazen

  class Command_Line_Client < Home_::CLI

    # this is a now quite old (indeed the first) [br] CLI, that in part
    # stands to demonstrate and exercise the various ways we can effect
    # modality-specific formal property mutation.

    # normally you would call your subclass `CLI`, but we can't here.

    # the code here is much older than may appear -  it was broken out
    # from the "CLI" node at this writing.

    # all further notes are still in [#002] the documentation for CLI.

    def back_kernel

      # normally this can be inferred from the constantspace, but not here.

      Home_.application_kernel_
    end

    class Action_Adapter < Action_Adapter  # [#062]codepoint-A

      MUTATE_THESE_PROPERTIES = [  # [#062]codepoint-B
        :config_filename,
        :config_path,
        :max_num_dirs,
        :path,
        :workspace_path ]

      def mutate__config_filename__properties

        # exclude this formal property from the front. leave back as-is.

        mutable_front_properties.remove :config_filename
        NIL_
      end

      def mutate__max_num_dirs__properties  # ALSO handwritten below!

        # in the front, tag this property as mutable by the environment

        @_settable_by_environment_h ||= {}
        @_settable_by_environment_h[ :max_num_dirs ] = true

        mutable_back_properties.replace_by :max_num_dirs do | prp |

          # tricky - the back is written around having a default so it
          # expects the element to be set always in its box hence we change
          # the default to be nil rather than removing the default
          # entirely (covered)

          prp.new_with_default do
            NIL_
          end
        end

        NIL_
      end

      def mutate__path__properties

        edit_path_properties :path, :default_to_PWD
      end

      def mutate__workspace_path__properties

        # exclude this formal property from the front. default the back to CWD

        substitute_value_for_argument :workspace_path do
          present_working_directory
        end
        NIL_
      end
    end

    Actions = ::Module.new  # modality-specific customizations [#062]

    class Actions::Init < Action_Adapter

      def mutate__path__properties

        # override parent to do nothing. we want the `path` property to
        # stay required. we do not do any defaulting for this field for
        # this action. the user must indicate the path explicitly here.
      end
    end
  end
end
