module Skylab::TanMan

  module Models_::Graph

    class Actions::Use::WriteGraph_to_Bytestore_via_Graph_and_Workspace___ < Common_::MagneticBySimpleModel

      # ~#[#049] algo family (1x)

      # this get thick (and boring) because we are adding an extension to
      # the file (conditionally) and adding content to the file
      # (conditionally) and when we add content we use the starters silo..

      attr_writer(
        :digraph_path,
        :filesystem,
        :is_dry_run,
        :listener,
        :microservice_invocation,
        :mutable_workspace,
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
            @_locked_writable_open_IO = kn.value ; ACHIEVED_

          elsif existed

            # this means that *some* referent (maybe a directory) is already
            # in the path. silently pass thru to #cov1.2..

            @_referent_existed = true ; UNABLE_
          else
            @_referent_existed = false ; UNABLE_  # #cov1.1
          end
        end

        # -- C. if the path had an existing referent, success or fail hinges
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

          if _resolve_digraph_line_upstream_
            __write_upstream_lines_to_downstream
          else
            __woops_clean_up_opened_file
          end
        end

        def __woops_clean_up_opened_file

          # (probably not covered, but used during development)

          io = remove_instance_variable :@_locked_writable_open_IO
          d = io.stat.size
          io.close
          if d.zero?  # likely
            @filesystem.unlink io.path
          end
          UNABLE_
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
          qkn = qkn.new_with_value "#{ qkn.value }#{ ext }"  # `::Pathname#sub_ext`
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

          _qkn = Common_::QualifiedKnownKnown.via_value_and_symbol(
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
          @_current_unsanitized_absolute_path_qkn.value
        end
      end

      def __write_upstream_lines_to_downstream

        up_io = remove_instance_variable :@__line_upstream
        down_io = remove_instance_variable :@_locked_writable_open_IO

        # flush upstream lines into file

        bytes = 0
        begin
          line = up_io.gets
          line or break
          bytes += down_io.write line
          redo
        end while nil

        down_io.close  # was locked, too

        @listener.call :info, :wrote_file do
          __build_wrote_file_event bytes, down_io
        end

        bytes
      end

      # -

        # -- A


        def _resolve_digraph_line_upstream_

          _tvp = remove_instance_variable :@template_values_provider

          _vp = Fetcher_via_TemplateValueProvider___.new _tvp

          _ = Models_::Starter::Actions::Lines.call_directly__ @microservice_invocation do |o|
            o.value_provider = _vp
            o.mutable_workspace = @mutable_workspace
          end

          _store :@__line_upstream, _
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

        def __build_wrote_file_event bytes, io

          _ev = Common_::Event.inline_OK_with(
            :wrote_file,
            :bytes, bytes,
            :is_dry, @is_dry_run,
            :path, io.path,
          ) do |y, o|

            o.is_dry and _dry = " dry"
            y << "wrote #{ pth o.path } (#{ o.bytes }#{ _dry } bytes)"
          end
          _ev  # hi. #todo
        end

      # -

      # ==

      # ==

      class Fetcher_via_TemplateValueProvider___ < ::BasicObject

        # in the template's eyes, we've got to look like a hash. but
        # we would rather our internal API use more clear names

        def initialize o
          @__provider = o
        end

        def fetch sym
          @__provider.dereference_template_variable__ sym
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
