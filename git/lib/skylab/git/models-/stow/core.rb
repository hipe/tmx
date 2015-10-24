module Skylab::Git

  class Models_::Stow  # see [#010]

    Bz__ = Home_.lib_.brazen

    class Action_ < Bz__::Action

      Bz__::Modelesque.entity self

      # will re-open!
    end

    Actions = ::Module.new

    class Actions::Ping < Action_

      @is_promoted = true

      edit_entity_class(
        :property, :channel,
        :property, :zerp,
      )

      def produce_result

        h = @argument_box.h_

        ch = h[ :channel ]
        oes_p = @on_event_selectively

        if ch
          case ch
          when 'ero'

            oes_p.call :error, :expression, :fake_error do | y |

              y << "(pretending this was wrong: #{ ick h[ :zerp ] })"
            end
            UNABLE_

          when 'inf'

            oes_p.call :info, :expression, :for_ping do | y |
              y << "(inf: #{ h[ :zerp ] })"
            end
            ACHIEVED_
          end
        else

          s = h[ :zerp ]

          if s
            oes_p.call :payload, :expression, :ping do | y |

              y << "(out: #{ h[ :zerp ] })"
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
    end

    class Actions::Save < Action_

      edit_entity_class(
        :desc, -> y do
          "move all untracked files in the current path to #{
            }a \"stow\" directory"
        end,
        :required, :property, :filesystem,
        :required, :property, :system_conduit,
        :required, :property, :stows_path,
        :required, :property, :project_path,
        :required, :property, :current_relpath,
        :required, :property, :stow_name,
      )

      def produce_result

        _init_stows_collection
        _ok = _resolve_versioned_directory
        _ok && __money
      end

      def __money

        h = @argument_box.h_

        o = Stow_::Sessions_::Save.new( & @on_event_selectively )
        o.versioned_directory = @_versioned_directory
        o.stow_name = h.fetch :stow_name
        o.stows_collection = @_stows_collection
        o.system_conduit = h.fetch :system_conduit
        o.filesystem = h.fetch :filesystem
        o.execute
      end
    end

    class Actions::Pop < Action_

      edit_entity_class(
        :desc, -> y do
          y << "attempts to put the files back if there are no collisions."
        end,
        :required, :property, :filesystem,
        :required, :property, :system_conduit,
        :required, :property, :stows_path,
        :required, :property, :project_path,
        :required, :property, :current_relpath,
        :required, :property, :stow_name,
      )

      def produce_result

        ok = __resolve_expressive_stow :no_color
        ok &&= _resolve_versioned_directory
        ok && __money
      end

      def __money

        o = Stow_::Sessions_::Pop.new( & @on_event_selectively )
        o.expressive_stow = @_expressive_stow
        o.filesystem = @argument_box.h_.fetch :filesystem
        o.project_path = @_versioned_directory.project_path
        o.execute
      end
    end

    class Actions::Show < Action_

      edit_entity_class(
        :desc, -> y do
          y << "in the spirit of `git stash show`, show contents of stash"
        end,
        :required, :property, :filesystem,
        :required, :property, :system_conduit,
        :required, :property, :stows_path,
        :required, :property, :stow_name,
      )

      def produce_result

        _build_expressive_stow :yes_colo
      end
    end

    class Actions::Status < Action_

      edit_entity_class(
        :desc, -> y do
          y << "shows the files that would be stashed."
        end,
        :required, :property, :system_conduit,
        :required, :property, :project_path,
        :required, :property, :current_relpath,
      )

      def produce_result

        ok = _resolve_versioned_directory
        ok && @_versioned_directory.to_entity_stream
      end
    end

    class Actions::List < Action_

      edit_entity_class(
        :desc, -> y do
          y << "list the stows"
        end,
        :required, :property, :filesystem,
        :required, :property, :stows_path,
      )

      def produce_result

        _new_stows_collection.to_entity_stream
      end
    end

    class Action_  # re-open

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

        h = @argument_box.h_

        _rsc = Resources___.new(
          h.fetch( :system_conduit ),
          h.fetch( :filesystem ),
        )

        Stow_::Models_::Expressive_Stow.new(
          :yes_or_no_color,
          @_stow,
          _rsc,
          & @on_event_selectively )
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

        @_stows_collection.entity_via_intrinsic_key(
          @argument_box.h_.fetch :stow_name )
      end

      def _init_stows_collection & oes_p

        @_stows_collection = _new_stows_collection( & oes_p )
        NIL_
      end

      def _new_stows_collection & oes_p

        oes_p ||= @on_event_selectively

        h = @argument_box.h_
        @kernel.silo( :stow ).stows_collection_via(
          h.fetch( :stows_path ),
          h.fetch( :filesystem ),
          & oes_p )
      end

      def _resolve_versioned_directory

        h = @argument_box.h_

        @_versioned_directory = Stow_::Models_::Versioned_Directory.new(

          h.fetch( :current_relpath ),
          h.fetch( :project_path ),
          h.fetch( :system_conduit ),
          & @on_event_selectively
        )

        ACHIEVED_
      end
    end

    class Silo_Daemon

      def initialize k, _model_class
        @kernel = k
      end

      def stows_collection_via path, fs, & oes_p  # like `entity_via_intrinsic_key`

        # (we could cache each collection per path, but instead we bind the
        # collection to the event handler, making it a "collection controller")

        Stow_::Models_::Collection.new path, fs, @kernel, & oes_p
      end
    end

    Autoloader_[ ( Models_ = ::Module.new ), :boxxy ]
    Autoloader_[ ( Sessions_ = ::Module.new ), :boxxy ]

    Stow_ = self

    class Stow_

      attr_reader(
        :path,
      )

      class << self

        def new_flyweight k, & oes_p
          o = new k, & oes_p
          o.__init_as_flyweight
          o
        end

        def new_via_path path
          o = new :_no_kernel_
          o.reinitialize_via_path_for_directory_as_collection path
          o
        end
      end

      def initialize k, & oes_p

        # NOTE might be an entity, might be a UI node!
        @kernel = k
        @on_event_selectively = oes_p
      end

      def __init_as_flyweight
        NIL_
      end

      def reinitialize_via_path_for_directory_as_collection path
        @path = path
        NIL_
      end

      def express_into_under y, expag
        self._NOT_USED  # but it is necessary that we define the method
      end

      def express_of_via_into_under y, expag
        -> me do
          expag.calculate do
            y << me._item_name
          end
        end
      end

      def description_under expag

        me = self
        expag.calculate do
          "stow #{ val me._item_name }"
        end
      end

      def _item_name

        ::File.basename @path
      end

      def get_stow_name
        ::File.basename @path
      end
    end
  end
end

# [#bs-001] 'reaction-to-assembly-language-phase' phase :+#tombstone:
# :+#tombstone: #storypoint-3
