module Skylab::Git

  class CLI < Home_.lib_.brazen::CLI

    Brazen_ = ::Skylab::Brazen

    def self.new * a
      new_top_invocation a, Home_::API.application_kernel_
    end

    def expression_agent_class
      Brazen_::CLI.expression_agent_class
    end

    def initialize a, ak

      @resources = Resources___.new a, ak.module
      super
    end

    class Resources___ < Resources

      # (this subclassing is questionable - would be better if ..)

      def initialize( * )
        @_cache = {}
        super
      end

      def knownness_for sym

        Callback_::Known.new_known send :"__#{ sym }__"
      end

      def __filesystem__

        @_cache[ :fs ] ||= Home_.lib_.system.filesystem
        # (directory? exist? mkdir mv open rmdir)
      end

      def __system_conduit__

        @_cache[ :sc ] ||= Home_.lib_.open_3
      end

      alias_method :_system_conduit, :__system_conduit__
    end

    class Action_Adapter < Action_Adapter

      # this mode client adaptation is an interesting case - *all* props
      # of all model actions are required. as well, almost all of them
      # go through special transformation before they express (or don't
      # express) in the front. a such, mutating a formal property is rule
      # rather than the exception:

      def mutate_properties

        mutate_these_properties @back_properties.a_
      end

      def mutate__channel__properties
        NIL_
      end

      def mutate__current_relpath__properties

        _substitute_knownness_for_argument :current_relpath do

          _orientation_knownness.knownness_for :current_relpath
        end
      end

      def mutate__filesystem__properties

        _substitute_knownness_for_argument :filesystem do

          _filesystem_knownness
        end
      end

      def mutate__project_path__properties

        _substitute_knownness_for_argument :project_path do

          _orientation_knownness.knownness_for :project_path
        end
      end

      def mutate__stow_name__properties
        NIL_  # an exception to the rule
      end

      def mutate__stows_path__properties

        _substitute_knownness_for_argument :stows_path do

          _orientation_knownness.knownness_for :stows_path
        end
      end

      def mutate__system_conduit__properties

        _substitute_knownness_for_argument :system_conduit do

          _system_conduit_knownness
        end
      end

      def mutate__zerp__properties
        NIL_
      end

      def _substitute_knownness_for_argument sym, & arg_p

        mutable_front_properties.remove sym

        mutable_back_properties.replace_by sym do | prp |

          otr = prp.dup
          otr.append_ad_hoc_normalizer( & arg_p )
          otr
        end
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

        oes_p = handle_event_selectively
        sc = @resources._system_conduit

        repo = Home_.lib_.git_viz.repository.new_via_path(
          ::Dir.pwd,
          sc,
          & oes_p )

        if repo

          Orientation_Knownness___.new(
            repo.relative_path_of_interest,
            repo.path,
            sc,
            & oes_p
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

      def initialize curr_relpath, proj_path, sc, & oes_p

        @__current_relpath__ = curr_relpath
        @__project_path__ = proj_path
        @__stows_path__ = ::File.expand_path '../Stows', proj_path  # etc
      end

      def knownness_for sym

        Callback_::Known.new_known instance_variable_get :"@__#{ sym }__"
      end
    end

    Actions = ::Module.new
    class Actions::Stow < self::Branch_Adapter

      module Actions
        class Save < Action_Adapter

          def __bound_call_via_bound_action_and_mutated_backbound_iambic
            # hi
            super
          end
        end
      end
    end

    # (( BEGIN
    Client = self
    module Adapter
      module For
        module Face
          module Of
            Hot = -> ns_sheet, my_client_class do

              -> mechanics, slug do

                annoy = mechanics.instance_variable_get( :@surface )[]
                Tmp___.new annoy, [ slug ]  # wrong, meht
              end
            end
          end
        end
      end
    end

    class Tmp___

      def initialize annoy, s_a

        _sin = annoy.instance_variable_get :@sin
        _sout = annoy.instance_variable_get :@out
        _serr = annoy.instance_variable_get :@err

        @_bridge = CLI.new _sin, _sout, _serr, s_a
      end

      def pre_execute
        ACHIEVED_
      end

      def invokee
        @_bridge
      end
    end
    # END ))
  end
end
