module Skylab::TanMan

  class Models_::Graph

    class Actors__::Touch  # ~:+[#049] algo family

      Actor_.call( self,
        :is_dry_run,
        :entity,
        :template_values_provider,
        :workspace,
        :kernel,
      )

      def initialize & p
        @on_event_selectively = p
      end

      def execute
        __init_downstream_reference
        send :"__execute_for__#{ @down_ID.shape_symbol }__"
      end

      def __init_downstream_reference

        @_qkn = @entity.qualified_knownness :digraph_path
        x = @_qkn.value_x

        if x.respond_to? :write
          @down_ID = Byte_downstream_reference_[].via_stream x
        else
          @down_ID = Byte_downstream_reference_[].via_path x
        end
        nil
      end

      def __execute_for__path__
        Touch_path___.new( @_qkn, self, & @on_event_selectively ).execute
      end

      def __execute_for__IO__
        _ok = resolve_upstream_lines_
        _ok and flush_upstream_lines_to_file_ @_qkn.value_x
      end

      class Touch_path___

        def initialize arg, parent, & oes_p
          @_qkn = arg
          @parent = parent
          @on_event_selectively = oes_p
        end

        def execute
          if __path_is_absolute
            __via_absolute_path_touch_path
          else
            UNABLE_
          end
        end

        def __path_is_absolute

          _n11n = Path_lib_[].normalization.with :absolute

          _ok_arg = _n11n.normalize_qualified_knownness(
            @_qkn, & @on_event_selectively )

          _store :@_qkn, _ok_arg
        end

        def __via_absolute_path_touch_path

          begin

            if __path_exists
              ok = __path_is_file
              ok &&= _write_path_to_entity
              break
            end

            if __path_has_extension
              ok = __write_upstream_content
              ok &&= _write_path_to_entity
              break
            end

            __add_extension_to_path
            redo
          end while nil
          ok
        end

        def __path_exists
          e, @stat = __noent_exception_and_stat_via_path @_qkn.value_x
          e ? false : true
        end

        def __noent_exception_and_stat_via_path path
          [ nil, ::File.stat( path ) ]
        rescue ::Errno::ENOENT => e
          [ e, false ]
        end

        def __path_is_file

          _o = _sys.filesystem.normalization( :Upstream_IO ).edit_with(
            :stat, @stat,
            :qualified_knownness_of_path, @_qkn,
            :must_be_ftype, :FILE_FTYPE,
            & @on_event_selectively )

          _o.via_stat_execute
        end

        def __path_has_extension
          ::File.extname( @_qkn.value_x ).length.nonzero?
        end

        def __add_extension_to_path

          @ext = Home_::Models_::DotFile::DEFAULT_EXTENSION

          path = @_qkn.value_x

          maybe_send_event :info, :adding_extension do
            __build_adding_extension_event path
          end

          d = ::File.extname( path ).length
          _head = d.zero? ? path : path[ 0 ... - d ]
          @_qkn = @_qkn.new_with_value "#{ _head }#{ @ext }"
          NIL
        end

        def __build_adding_extension_event path_before

          Common_::Event.inline_neutral_with(

            :adding_extension,
            :extension, @ext,
            :path, path_before,

          ) do | y, o |

            y << "adding #{ o.extension } extension to #{ pth o.path }"
          end
        end

        def _write_path_to_entity
          @parent.into_entity_write_digraph_path__ @_qkn.value_x
        end

        def __write_upstream_content

          ok = @parent.resolve_upstream_lines_
          ok &&= __resolve_downstream_file
          ok and @parent.flush_upstream_lines_to_file_ @f
        end

        def __resolve_downstream_file

          kn = _sys.filesystem( :Downstream_IO ).call_via(
            :qualified_knownness_of_path, @_qkn,
            & @on_event_selectively )

          if kn
            @f = kn.value_x
            ACHIEVED_
          else
            kn
          end
        end

        def _sys
          @__sys ||= Home_.lib_.system
        end

        define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

        include Common_::Event::Selective_Builder_Receiver_Sender_Methods
      end

      def into_entity_write_digraph_path__ path

        # the path is not relativized here. the path might not have changed.

        @entity.properties.replace :digraph_path, path

        ACHIEVED_
      end

      def resolve_upstream_lines_
        otr = dup
        otr.extend Produce_upstream_lines___  # :+[#sl-106]
        _store :@up_lines, otr.execute
      end

      def flush_upstream_lines_to_file_ f  # assume @up_lines

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

      def __build_wrote_file_event bytes, f

        build_OK_event_with :wrote_file,
            :is_dry, @is_dry_run,
            :path, f.path, :bytes, bytes do | y, o |

          o.is_dry and _dry = " dry"
          y << "wrote #{ pth o.path } (#{ o.bytes }#{ _dry } bytes)"
        end
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      module Produce_upstream_lines___

        def execute

          @value_fetcher = Template_Value_Provider_as_Fetcher___.
            new( @template_values_provider )

          _x = __via_workspace_expect_lines
          _x || __any_lines
        end

        def __via_workspace_expect_lines

          # first, use any starter indicated in the workspace

          @kernel.silo( :starter ).lines_via__(
              @value_fetcher, @workspace ) do | * i_a, & ev_p |

            if :component_not_found == i_a.last
              @on_event_selectively.call :info, :component_not_found do
                wrap = ev_p[]
                wrap.new_with_event wrap.to_event.new_inline_with( :ok, nil )
              end
            else
              @on_event_selectively[ * i_a, & ev_p ]
            end
          end
        end

        def __any_lines

          # if no starter is indicated in the workspace, use default

          Models_::Starter::Actions::Lines.session @kernel, @on_event_selectively do | o |
            o.value_fetcher = @value_fetcher
          end.via_default
        end
      end

      class Template_Value_Provider_as_Fetcher___ < ::BasicObject

        def initialize o
          @provider = o
        end

        def fetch sym
          @provider.template_value sym
        end
      end

      include Common_::Event::Selective_Builder_Receiver_Sender_Methods
    end
  end
end
