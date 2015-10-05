module Skylab::Git

  class Models_::Stow

    module Modalities::CLI

      Stow_Action_Adapter__ = ::Class.new Home_::CLI::Action_Adapter

      module Actions

        Status = ::Class.new Stow_Action_Adapter__
        List = ::Class.new Stow_Action_Adapter__
        Show = ::Class.new Stow_Action_Adapter__
        Save = ::Class.new Stow_Action_Adapter__
        Pop = ::Class.new Stow_Action_Adapter__

      end

      class Stow_Action_Adapter__  # (re-open)

        # this mode client adaptation is an interesting case - *all* props
        # of all model actions are required. as well, almost all of them
        # go through special transformation before they express (or don't
        # express) in the front. a such, we write the below so that mutating
        # each formal property is the rule rather than the exception:

        def mutate_properties

          mutate_these_properties @back_properties.a_
        end

        def mutate__channel__properties
          NIL_
        end

        def mutate__current_relpath__properties

          substitute_knownness_for_argument :current_relpath do

            _orientation_knownness.knownness_for :current_relpath
          end
        end

        def mutate__filesystem__properties

          substitute_knownness_for_argument :filesystem do

            _filesystem_knownness
          end
        end

        def mutate__project_path__properties

          substitute_knownness_for_argument :project_path do

            _orientation_knownness.knownness_for :project_path
          end
        end

        def mutate__stow_name__properties
          NIL_  # an exception to the rule
        end

        def mutate__stows_path__properties

          substitute_knownness_for_argument :stows_path do

            _orientation_knownness.knownness_for :stows_path
          end
        end

        def mutate__system_conduit__properties

          substitute_knownness_for_argument :system_conduit do

            _system_conduit_knownness
          end
        end

        def mutate__zerp__properties
          NIL_
        end

        # a policy decision that is made by the front (not the back),
        # derive all of "stows path", "project path" and "current relpath"
        # from the same one operation:
        #
        #   1) find any project path by looking upwards from the
        #      current working directory for this process.
        #      (if not found, unable.)
        #
        #   2) if above was found, the "stows path" (whether existent
        #      or not) is [ some const entry ] *sibling to* the project
        #      path.
        #
        #   3) likewise the current relpath is the difference between
        #      the project path and the CWD from (1).

        def _orientation_knownness
          @___orientation_knownness ||= __build_orientation_knownness
        end

        def __build_orientation_knownness

          rsx = @resources

          repo = Home_.lib_.git_viz.repository.new_via(
            ::Dir.pwd,
            rsx.bridge_for( :system_conduit ),
            rsx.bridge_for( :filesystem ),
            & handle_event_selectively )

          if repo

            Orientation_Knownness___.new(
              repo.relative_path_of_interest,
              repo.path,
            )
          else
            UNKNOWN_ORIENTATION___
          end
        end

        def _system_conduit_knownness

          @resources.knownness_for :system_conduit
        end

        def _filesystem_knownness

          @resources.knownness_for :filesystem
        end
      end

      module UNKNOWN_ORIENTATION___ ; class << self

        def knownness_for _

          # giving just unable here as opposed the below singleton
          # short-circuits further normalization appropriately early

          # Callback_::Known::UNKNOWN

          UNABLE_
        end
      end ; end

      class Orientation_Knownness___

        def initialize curr_relpath, proj_path

          @__current_relpath__ = curr_relpath
          @__project_path__ = proj_path
          @__stows_path__ = ::File.expand_path '../Stows', proj_path  # etc
        end

        def knownness_for sym

          Callback_::Known.new_known instance_variable_get :"@__#{ sym }__"
        end
      end
    end
  end
end
