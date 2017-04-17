module Skylab::TanMan

  module Models_::Graph

    class WriteGraph_to_Bytestore_via_Graph_and_Workspace___ < Common_::MagneticBySimpleModel

      # ~#[#049] algo family (1x)

      # this get thick (and boring) because we are adding an extension to
      # the file (conditionally) and adding content to the file
      # (conditionally) and when we add content we use the starters silo..

      attr_writer(
        :digraph_path,
        :filesystem,
        :listener,
        :mutable_workspace,
        :sub_invoker,
        :template_values_provider,
      )

      # -
        def execute
          @_downstream_reference = __downstream_reference
          _const = THESE___.fetch @_downstream_reference.shape_symbol
          extend This___.const_get( _const, false )
          execute  # eek
        end

        THESE___ = {
          IO: :IO_Methods___,
          path: :PathMethods___,
        }

      # -

      module IO_Methods___

        def execute
          if _resolve_digraph_line_upstream_
            _flush_digraph_line_upstream_to_fileish_ @digraph_path
          end
        end
      end

      module PathMethods___

        def execute
          ok = true
          ok &&= __check_that_path_is_absolute
          ok &&= __touch_file
          ok &&= __write_path_to_workspace
          ok
        end

        # --

        def __write_path_to_workspace

          # #history-A.3: abstracted most of this away into new workspace class
          # #history-A.2: changed this to assume we are inside of a session

          _path = _current_unsanitized_absolute_path

          _ok = @mutable_workspace.write_digraph_asset_path_ _path, :path, & @listener

          _ok  # hi. #todo
        end

        # -- d.

        def __touch_file

          if __path_has_extension

            _touch_file_via_path_with_extension

          elsif __path_existed
            _check_that_it_was_file
          else
            __add_extension_to_path
            _touch_file_via_path_with_extension
          end
        end

        def _touch_file_via_path_with_extension

          if __open_new_file_for_writing

            __write_upstream_content

          elsif remove_instance_variable :@_referent_existed

            # #cov1.2
            _init_stat  # (there is one of these #[#sy-004.9] dangerous gaps here
            _check_that_it_was_file
          else

            # maybe the dirname of the argument path didn't exist

            UNABLE_  # hi.
          end
        end

        def __open_new_file_for_writing

          existed = false
          _custom_listener = -> * chan, & ev_p do
            if :error == chan[0] && :resource_existed == chan[1]
              existed = true
            else
              @listener[ * chan, & ev_p ]
            end
          end

          o = ::File::Constants

          kn = _these::Downstream_IO.via(
            :qualified_knownness_of_path, @_current_unsanitized_absolute_path_qkn,
            :flags_for_open, o::CREAT | o::EXCL | o::WRONLY,
            :filesystem, @filesystem,
            & _custom_listener )

          if kn
            ::Kernel._OKAY

          elsif existed

            # this means that *some* referent (maybe a directory) is already
            # in the path. silently pass thru to #cov1.2..

            @_referent_existed = true ; UNABLE_
          else
            @_referent_existed = false ; UNABLE_  # #cov1.1
          end
        end

        # -- c. if the path had an existing referent, success or fail hinges
        #       on whether that referrent was a file. we won't be adding any
        #       content to this file here (even if it is empty) so we do not
        #       lock it.

        def _check_that_it_was_file

          _o = _these::Upstream_IO.with(
            :stat, remove_instance_variable( :@__stat ),
            :qualified_knownness_of_path, @_current_unsanitized_absolute_path_qkn,
            :must_be_ftype, :FILE_FTYPE,
            :filesystem, @filesystem,
            & @listener )

          _ok = _o.via_stat_execute
          _ok  # hi. #todo
        end

        def _these
          Home_.lib_.system_lib::Filesystem::Normalizations
        end

        def __write_upstream_content

          self._USE_OR_LOSE  # #todo
          ok = @parent.resolve_upstream_lines_
          ok &&= __resolve_downstream_file
          ok and @parent.flush_upstream_lines_to_file_ @f
        end

        def __path_existed  # all you know is path has no extension
          _init_stat
          ACHIEVED_
        rescue ::Errno::ENOENT => _e
          NOTHING_
        end

        def _init_stat
          @__stat = @filesystem.stat _current_unsanitized_absolute_path
          NIL
        end

        # -- B. digraph paths must either already exist or have an extension.
        #       if a path is provided that both has no extension and has no
        #       referent, we will add a default extension to it before proceding.

        def __add_extension_to_path  # assume path has no extension

          ext = Home_::Models_::DotFile::DEFAULT_EXTENSION
          path_before = _current_unsanitized_absolute_path

          _build_event = -> do

            _ev = Common_::Event.inline_neutral_with(

              :adding_extension,
              :extension, ext,
              :path, path_before,

            ) do |y, o|

              y << "adding #{ o.extension } extension to #{ pth o.path }"
            end
            _ev  # hi. #todo
          end

          qkn = remove_instance_variable :@_current_unsanitized_absolute_path_qkn
          qkn = qkn.new_with_value "#{ qkn.value_x }#{ ext }"  # `::Pathname#sub_ext`
          @_current_unsanitized_absolute_path_qkn = qkn

          @listener.call :info, :adding_extension do
            _build_event[]
          end
          NIL
        end

        def __path_has_extension
          ::File.extname( _current_unsanitized_absolute_path ).length.nonzero?
        end

        # -- A. at the level of magnetics we never expand relative paths.
        #       this must have already happened before we get to this point.
        #
        #       (also, any relative paths in the config are relative to
        #        the asset directory)

        def __check_that_path_is_absolute

          _qkn = Common_::QualifiedKnownness.via_value_and_symbol(
            @_downstream_reference.path, :digraph_path )

          _kn = Path_lib_[]::Normalization.via(
            :qualified_knownness, _qkn,
            :absolute,
            & @listener )

          if _kn
            @_current_unsanitized_absolute_path_qkn = _qkn ; true
          end
        end

        def _current_unsanitized_absolute_path
          @_current_unsanitized_absolute_path_qkn.value_x
        end
      end

      def flush_upstream_lines_to_file_ f  # assume @up_lines
        self._USE_OR_LOSE  # #todo

        # flush upstream lines into file

        bytes = 0
        begin
          line = @up_lines.gets
          line or break
          bytes += f.write line
          redo
        end while nil

        f.close

        maybe_send_event :info, :wrote_file do
          __build_wrote_file_event bytes, f
        end

        bytes
      end

      # -

        # -- A

        def _resolve_digraph_line_upstream_

          _ = DigraphLineUpstream_via_These___.call_by do |o|
            o.template_values_provider = @template_values_provider
            o.sub_invoker = @sub_invoker
          end
          _store :@__line_upstream, _
        end

      def __build_wrote_file_event bytes, f
        self._USE_OR_LOSE  # #todo

        build_OK_event_with :wrote_file,
            :is_dry, @is_dry_run,
            :path, f.path, :bytes, bytes do | y, o |

          o.is_dry and _dry = " dry"
          y << "wrote #{ pth o.path } (#{ o.bytes }#{ _dry } bytes)"
        end
      end

        def __downstream_reference

          x = remove_instance_variable :@digraph_path

          _m = if x.respond_to? :write  # allow the passing of an open IO
            :via_open_IO
          else
            :via_path
          end

          _hi = Byte_downstream_reference_[].send _m, x
          _hi  # hi. #todo
        end

        define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
      # -

      # ==

      class DigraphLineUpstream_via_These___ < Common_::MagneticBySimpleModel

        attr_writer(
          :sub_invoker,
          :template_values_provider,
        )

        def execute

          __init_value_fetcher_via_value_provider
          _x = __via_workspace_expect_lines
          _x || __any_lines
        end

        def __any_lines

          # if no starter is indicated in the workspace, use default

          Models_::Starter::Actions::Lines.session @kernel, @listener do | o |
            o.value_fetcher = @value_fetcher
          end.via_default
        end

        def __via_workspace_expect_lines
          self._USE_OR_LOSE

          # first, use any starter indicated in the workspace

          @kernel.silo( :starter ).lines_via__(
              @value_fetcher, @workspace ) do | * sym_a, & ev_p |

            if :component_not_found == sym_a.last
              @on_event_selectively.call :info, :component_not_found do
                wrap = ev_p[]
                wrap.new_with_event wrap.to_event.new_inline_with( :ok, nil )
              end
            else
              @on_event_selectively[ * sym_a, & ev_p ]
            end
          end
        end

        def __init_value_fetcher_via_value_provider
          _ = remove_instance_variable :@template_values_provider
          @_value_fetcher = Fetcher_via_TemplateValueProvider___.new _
          NIL
        end
      end

      # ==

      class Fetcher_via_TemplateValueProvider___ < ::BasicObject

        def initialize o
          @__provider = o
        end

        def fetch sym
          @__provider.template_value sym
        end
      end

      # ==
      # ==

      This___ = self

      # ==
    end
  end
end
# #history-A.3: (can be temporary)..
# #history-A.2: (can be temporary)..
# #history-A.1: begin rewriting most of it for ween off [br]
