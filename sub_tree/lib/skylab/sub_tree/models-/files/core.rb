module Skylab::SubTree

  module API

    module Home_::Models_::Files

      Actions = ::Module.new

      class Actions::Files < API.action_class_

        @is_promoted = true

        Home_.lib_.brazen::Modelesque.entity self,

          :branch_description, -> y do
            y << "inspired by unix builtin `tree`"
            y << "but adds custom features geared towards development"
          end,


          :meta_property, :is_extension,


          :flag, :property, :show_find_command,

          :flag, :property, :show_lines,


          :is_extension, true,

          :description, -> y do
            y << "as reported by wc, affixed as metadata"
          end,
          :flag, :property, :line_count,


          :is_extension, true,

          :description, -> y do
            y << "if ordinary file, display humanized mtime"
          end,

          :flag, :property, :mtime,


          :required, :property, :output_stream,  # etc


          :description, -> y do
            y << "reduce the search with this pattern (passsed to `find -name`)"
          end,
          # (used to be :single_letter 'P'
          :property, :pattern,


          :property, :input_stream,


          :description, -> y do
            y << "instead of #{ par_via_sym :path }s, get tree paths from #{
              }file, one per line"
          end,
          :property, :file_of_input_paths,


          :argument_arity, :one_or_more,
          :property, :path


        def produce_result

          ok = __reconcile_upstream_arg
          ok &&= __resolve_extensions
          ok &&= __normalize_upstream
          ok && __traverse
        end

        # ~

        def __reconcile_upstream_arg

          a = []

          qkn_bx = to_qualified_knownness_box_proxy

          x = qkn_bx.any_trueish :file_of_input_paths
          x and x.value.length.nonzero? and a.push x

          x = qkn_bx.any_trueish :path
          x and a.push x

          x = qkn_bx.any_trueish :input_stream
          x and ! x.value.tty? and a.push x

          case 1 <=> a.length
          when  0
            @upstream_arg = a.fetch( 0 )
            ACHIEVED_
          when  1
            __when_no_upstream
          when -1
            __when_many_upstreams a
          end
        end

        def __when_no_upstream
          self._ETC
          maybe_send_event :error, :etc do

            build_not_OK_event_with :etc

          end
          UNABLE_
        end

        def __when_many_upstreams a

          maybe_send_event :error, :irreconcilable_upstream do

            Common_::Event.inline_not_OK_with(

              :irreconcilable_upstream,
              :a, a,

            ) do | y, o |

              _s_a = o.a.map do | qualified_knownness |
                par qualified_knownness.association
              end

              y << "can't read input from #{ both _s_a }#{ and_ _s_a } at the same time"
            end
          end
          UNABLE_
        end

        # ~

        def __resolve_extensions
          ok = true

          @extensions = nil

          @argument_box.each_pair do | k, x |
            x or next
            prp = @formal_properties[ k ]
            prp.is_extension or next
            ok = __load_extension Common_::QualifiedKnownKnown.via_value_and_association( x, prp )
            ok or break
          end

          ok
        end

        def __load_extension arg

          @extensions ||= Files_::Extensions_.new( & handle_event_selectively )

          @extensions.load_extension arg
        end

        # ~

        def __normalize_upstream

          @pattern = @argument_box[ :pattern ]

          send :"__normalize__#{ @upstream_arg.name_symbol }__upstream"
        end

        def __normalize__path__upstream

          _listener = -> * i_a, & ev_p do

            if :find_command_args == i_a.last
              if @argument_box[ :show_find_command ]
                yes = true
              end
            else
              yes = true
            end
            if yes
              maybe_send_event( * i_a, & ev_p )
              NIL
            end
          end

          _ = Files_::Magnetics_::Find_via_Paths_and_Pattern.via(
            :paths, @upstream_arg.value,
            :pattern, @pattern,
            & _listener )

          _store :@upstream_IO, _
        end

        def __emit_find_command & x_p

          maybe_send_event :info, :find_command do

            Common_::Event.inline_neutral_with(
              :find_command,
              :args, x_p[].args

            ) do | y, o |

              _p = Home_::Library_::Shellwords.method :shellescape

              _s_a = x_p[].args.map( & _p )

              y << "find command: #{ _s_a * SPACE_ }"

            end
          end
        end

        def __normalize__file_of_input_paths__upstream

          if @pattern
            _when_pattern
          else

            kn = Home_.lib_.system_lib::Filesystem::Normalizations::Upstream_IO.via(
              :qualified_knownness_of_path, @upstream_arg,
              :filesystem, Home_.lib_.system.filesystem,
              & handle_event_selectively )

            if kn

              @upstream_IO = kn.value
              ACHIEVED_
            else
              kn
            end
          end
        end

        def __normalize__input_stream__upstream

          if @pattern
            _when_pattern
          else
            @upstream_IO = @upstream_arg.value
            ACHIEVED_
          end
        end

        def _when_pattern
          self._LOOK_OVER_THERE
        end

        # ~

        def __traverse
          if @extensions
            if @extensions.has_collection_operations
              __via_triple_buffer_traverse
            else
              __traverse_with_notifications
            end
          else
            __traverse_direct
          end
        end

        def __via_triple_buffer_traverse  # for #collection-operations

          node_a = []
          @downstream_p = -> glyphs, slug, any_leaf do
            node_a.push Line_Item___.new( glyphs, slug, any_leaf )
            nil
          end

          _init_traversal

          exts = @extensions ; tr = @tr ; ups = @upstream_IO

          begin
            line = ups.gets
            line or break
            line.chomp!
            lf = Mutable_Leaf_Item_.new line
            exts.receive_mutable_leaf lf
            tr.puts_with_free_cel lf.input_line, lf
            redo
          end while nil

          _close_upstream_and_flush_traversal
          _ok = exts.receive_the_collection_of_mutable_items node_a  # we ignore any failure
          _ok && Result_Table___.new( node_a )
        end

        define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

        Line_Item___ = ::Struct.new :glyphs, :slug, :any_leaf

        class Result_Table___

          def initialize node_a

            @node_array = node_a
          end

          def describe_into_under y, _expag=nil

            _my_CLI::Render_table[ y, @node_array ]
          end

          def to_line_stream

            _delimited_lines = _my_CLI::Render_table[ [], @node_array ]

            Stream_[ _delimited_lines ]
          end

          def _my_CLI
            Home_::Models_::Files::Modalities::CLI
          end

          attr_reader(
            :node_array,
          )
        end

        def __traverse_with_notifications  # assume extensions

          _init_downstream_proc_as_normal
          _init_traversal

          exts = @extensions ; tr = @tr ; ups = @upstream_IO

          begin
            line = ups.gets
            line or break
            line.chomp!
            lf = Mutable_Leaf_Item_.new line
            exts.receive_mutable_leaf lf
            tr.puts_with_free_cel lf.input_line, lf.any_free_cel
            redo
          end while nil

          _close_upstream_and_flush_traversal
        end

        def __traverse_direct

          _init_downstream_proc_as_normal
          _init_traversal

          tr = @tr ; ups = @upstream_IO

          begin
            line = ups.gets
            line or break
            tr.puts line
            redo
          end while nil

          _close_upstream_and_flush_traversal
        end

        def _init_downstream_proc_as_normal
          @downstream_p = @argument_box.fetch( :output_stream ).method :puts
          nil
        end

        def _init_traversal

          @tr = Home_::OutputAdapters_::Continuous::Traversal.with(

            :output_proc, @downstream_p,
            :do_verbose_lines, @argument_box[ :show_lines ],
            & handle_event_selectively )

          NIL_
        end

        def _close_upstream_and_flush_traversal
          ups = @upstream_IO

          if ! ups.tty?
            ups.close
          end

          @tr.flush  # result
        end
      end


      Files_ = self
    end
  end
end
