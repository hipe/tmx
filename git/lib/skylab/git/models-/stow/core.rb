module Skylab::Git

  class Models_::Stow  # see [#010]

    Actions = ::Module.new

    class Actions::Ping

      def initialize
        @channel = nil
        extend CommonActionMethods__
        init_action_ yield
      end

      def definition ; [
        :property, :channel,
        :property, :zerp,
      ]
      end

      def execute

        ch = @channel
        oes_p = _listener_
        x = @zerp
        # --
        if ch
          case ch
          when 'ero'

            oes_p.call :error, :expression, :fake_error do | y |

              y << "(pretending this was wrong: #{ ick x })"
            end
            UNABLE_

          when 'inf'

            oes_p.call :info, :expression, :for_ping do | y |
              y << "(inf: #{ x })"
            end
            ACHIEVED_
          end
        else

          if x
            oes_p.call :payload, :expression, :ping do | y |

              y << "(out: #{ x })"
            end
            :pingback_from_API
          else
            oes_p.call :info, :expression, :ping do | y |
              y << "hello from git."
            end
            :hello_from_git
          end
        end
      end
      Actions = nil
    end

    class Actions::Save

      def initialize
        extend CommonActionMethods__
        init_action_ yield
      end

      def definition ; [

        :description, -> y do
          "move all untracked files in the current path to #{
            }a \"stow\" directory"
        end,

        :required, :property, :stows_path,
        :required, :property, :project_path,
        :required, :property, :current_relpath,
        :required, :property, :stow_name,
      ] ; end

      def execute

        _init_stows_collection
        _ok = _resolve_versioned_directory
        _ok && __money
      end

      def __money

        _sn = remove_instance_variable :@stow_name

        Stow_::Magnetics_::WriteStow_via_StowName_and_StowsCollection_and_VersionedDirectory.call_by do |o|
          o.versioned_directory = @_versioned_directory
          o.stow_name = _sn
          o.stows_collection = @_stows_collection
          o.system_conduit = _system_conduit_
          o.filesystem = _filesystem_
          o.listener = _listener_
        end
      end
      Actions = nil
    end

    class Actions::Pop

      def initialize
        @channel = nil
        extend CommonActionMethods__
        init_action_ yield
      end

      def definition ; [

        :description, -> y do
          y << "attempts to put the files back if there are no collisions."
        end,

        # :inflect, :noun, :lemma_string,  # say "couldn't pop stow", not "couldn't pop a stow"

        :required, :property, :stows_path,
        :required, :property, :project_path,
        :required, :property, :current_relpath,
        :required, :property, :stow_name,
      ] end

      def execute

        ok = __resolve_expressive_stow :no_color
        ok &&= _resolve_versioned_directory
        ok && __money
      end

      def __money

        Stow_::Magnetics_::PopStow_via_Stow_and_ProjectPath.call_by do |o|
          o.expressive_stow = @_expressive_stow
          o.project_path = @_versioned_directory.project_path
          o.filesystem = _filesystem_
          o.listener = _listener_
        end
      end
      Actions = nil
    end

    class Actions::Show

      def initialize
        extend CommonActionMethods__
        init_action_ yield
      end

      def definition ; [

        :description, -> y do
          y << "in the spirit of `git stash show`, show contents of stash"
        end,

        :required, :property, :stows_path,
        :required, :property, :stow_name,
      ] ; end

      def execute

        _build_expressive_stow :yes_colo
      end
      Actions = nil
    end

    class Actions::Status

      def initialize
        extend CommonActionMethods__
        init_action_ yield
      end

      def definition ; [

        :description, -> y do
          y << "shows the files that would be stashed."
        end,

        :required, :property, :project_path,
        :required, :property, :current_relpath,
      ] ; end

      def execute
        ok = _resolve_versioned_directory
        ok && @_versioned_directory.to_entity_stream
      end
      Actions = nil
    end

    class Actions::List

      def initialize
        extend CommonActionMethods__
        init_action_ yield
      end

      def definition ; [

        :description, -> y do
          y << "list the stows"
        end,

        :required, :property, :stows_path,
      ] end

      def execute

        _new_stows_collection.to_entity_stream
      end
      Actions = nil
    end

    module CommonActionMethods__

      def init_action_ invo
        invo.HELLO_INVOCATION  # #todo
        @_microservice_invocation_ = invo ; nil
      end

      def __resolve_expressive_stow style_x

        es = _build_expressive_stow style_x
        if es
          @_expressive_stow = es
          ACHIEVED_
        else
          es
        end
      end

      def _build_expressive_stow style_x

        _ok = _resolve_stow
        _ok and __via_etc_build_ES style_x
      end

      def __via_etc_build_ES yes_or_no_color

        _rsc = _invocation_resources_

        Here_::Models_::ExpressiveStow.new(
          :yes_or_no_color,
          @_stow,
          _rsc,
          & _listener_ )
      end

      Resources___ = ::Struct.new :system_conduit, :filesystem

      def _resolve_stow

        stow = _produce_stow
        if stow
          @_stow = stow
          ACHIEVED_
        else
          stow
        end
      end

      def _produce_stow

        @_stows_collection ||= _new_stows_collection

        _sn = remove_instance_variable :@stow_name

        @_stows_collection.entity_via_intrinsic_key(
          _sn )
      end

      def _init_stows_collection & oes_p

        @_stows_collection = _new_stows_collection( & oes_p )
        NIL_
      end

      def _new_stows_collection

        Here_::Models_::StowsOperatorBranchFacade.new(
          @stows_path,
          _filesystem_,
          @_microservice_invocation_,
          & _listener_ )
      end

      def _resolve_versioned_directory

        _crp = remove_instance_variable :@current_relpath
        _pp = remove_instance_variable :@project_path

        @_versioned_directory = Here_::Models_::VersionedDirectory.new(
          _crp,
          _pp,
          _system_conduit_,
          & _listener_
        )

        ACHIEVED_
      end

      def _simplified_write_ x, k
        instance_variable_set :"@#{ k }", x ; nil
      end

      def _simplified_read_ k
        ivar = :"@#{ k }"
        if instance_variable_defined? ivar
          instance_variable_get ivar
        end
      end

      def _listener_
        _argument_scanner_narrator_.listener
      end

      def _argument_scanner_narrator_
        _invocation_resources_.argument_scanner_narrator
      end

      def _filesystem_
        _invocation_resources_.filesystem
      end

      def _system_conduit_
        _invocation_resources_.system_conduit
      end

      def _invocation_resources_
        @_microservice_invocation_.invocation_resources
      end
    end

    Stow_ = self
    class Stow_

      attr_reader(
        :path,
      )

      class << self

        def new_flyweight k, & oes_p
          new( k, & oes_p ).__init_as_flyweight
        end

        def via_path path
          o = new :_no_kernel_
          o.reinitialize_as_flyweight_ path
          o
        end
      end  # >>

      def initialize k, & oes_p

        # NOTE might be an entity, might be a UI node!
        @kernel = k
        @on_event_selectively = oes_p
      end

      def __init_as_flyweight
        self
      end

      def reinitialize_as_flyweight_ path
        @path = path ; self
      end

      def express_of_via_into_under y, expag
        -> me do
          expag.calculate do
            y << me._item_name
          end
        end
      end

      def description_under expag
        s = _item_name
        expag.calculate do
          val s
        end
      end

      def normal_symbol
        _item_name.gsub( DASH_, UNDERSCORE_ ).intern
      end

      def get_stow_name
        _item_name
      end

      def _item_name
        ::File.basename @path
      end
    end

    Here_ = self

    # ==
    # ==
  end
end
# [#bs-001] 'reaction-to-assembly-language-phase' phase :+#tombstone:
# :+#tombstone: #storypoint-3
