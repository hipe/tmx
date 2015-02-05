module Skylab::TanMan

  module Models_::DotFile

    class Controller__  # see [#009]

      def initialize gsp, input_arg, k, & oes_p
        @graph_sexp = gsp
        @input_arg = input_arg
        @on_event_selectively = oes_p
        @kernel = k
      end

      def members
        [ :caddied_output_args, :graph_sexp,
          :persist_via_args, :unparse_into ]
      end

      attr_reader :graph_sexp

      def description_under expag
        send :"description_under_expag_when_#{ @input_arg.name_symbol }", expag
      end
    private
      def description_under_expag_when_input_string expag
        s = TanMan_.lib_.ellipsify[ @input_arg.value_x ]
        expag.calculate do
          val s
        end
      end

      def description_under_expag_when_input_pathname expag
        pn = @input_arg.value_x
        expag.calculate do
          pth pn
        end
      end
    public

      def at_graph_sexp i
        @graph_sexp.send i
      end

      def unparse_into y
        @graph_sexp.unparse_into y
      end

      def insert_stmt_before_stmt new, least_greater_neighbor
        insert_stmt new, least_greater_neighbor
      end

      def insert_stmt new, new_before_this=nil  # #note-20

        g = @graph_sexp

        if ! g.stmt_list
          g.stmt_list = __empty_stmt_list
        end

        if ! g.stmt_list.prototype_ && ! g.stmt_list.to_node_stream_.length_exceeds( 1 )
          g.stmt_list.prototype_ = _sl_proto
        end

        if new_before_this
          g.stmt_list.insert_item_before_item_ new, new_before_this
        else
          g.stmt_list.append_item_ new
        end
      end

      def __empty_stmt_list
        _sl_proto.__dupe except: [ :stmt, :tail ]
      end

      def _sl_proto  # assumes static grammar
        Memoized_SL_proto___[] || Memoize_SL_proto___[ @graph_sexp.class ]
      end

      -> do
        x = nil
        Memoized_SL_proto___ = -> do
          x
        end
        Memoize_SL_proto___ = -> parser do
          x = parser.parse :stmt_list, "xyzzy_1\nxyzzy_2"
          x.freeze
          x
        end
      end.call

      def destroy_stmt stmt
        if @graph_sexp.stmt_list
          _x = @graph_sexp.stmt_list.remove_item_ stmt
          _x ? ACHIEVED_ : UNABLE_  # we mean to destroy
        else
          UNABLE_
        end
      end

      def provide_action_precondition _id, _g
        self
      end

      attr_accessor :caddied_output_args  # topic doesn't do anything with this, just carries it

      def persist_via_args is_dry, arg, *_
        adapter = Persist_Adapters__.produce_via_argument arg
        adapter.init @kernel, & @on_event_selectively
        adapter.receive_rewritten_datastore_controller is_dry, self
      end

      class Common_Persist_Adapter__
        class << self
          alias_method :build, :new
        end

        def init k, & oes_p
          @on_event_selectively = oes_p
          @kernel = k
          nil
        end
      end

      module Persist_Adapters__

        class << self

          def produce_via_argument arg
            ftch_class_via_argument_name( arg.name_symbol ).build arg.value_x
          end

          define_method :ftch_class_via_argument_name, ( -> do
            p = -> name_symbol do
              mod = Persist_Adapters__
              h = {}
              mod.constants.each do |i|
                h[ i.downcase ] = mod.const_get i, false
              end
              ( p = h.method :fetch )[ name_symbol ]
            end
            -> i { p[ i ] }
          end ).call
        end

        class Output_String < Common_Persist_Adapter__

          def initialize output_string
            @output_string = output_string
          end

          def receive_rewritten_datastore_controller _is_dry, o  # #hook-out (local)
            @output_string.replace o.graph_sexp.unparse
            ACHIEVED_
          end
        end

        class Output_Stream < Common_Persist_Adapter__

          def initialize io
            @io = io
          end

          def receive_rewritten_datastore_controller _is_dry, o
            o.graph_sexp.unparse_into @io
            ACHIEVED_
          end
        end

        class Output_Path < Common_Persist_Adapter__

          def initialize path
            @output_path = path
          end

          def receive_rewritten_datastore_controller is_dry, x

            if is_dry
              bytes = x.graph_sexp.unparse.length
            else
              bytes =
              ::File.open @output_path, WRITE_MODE_ do | fh |
                fh.write x.graph_sexp.unparse
              end
            end
            @on_event_selectively.call :info, :wrote_resource do
              Callback_::Event.inline_OK_with :wrote_resource,
                  :path, @output_path,
                  :bytes, bytes,
                  :is_dry, is_dry,
                  :is_completion, true do  |y, o|

                y << "wrote #{ pth o.path } #{
                  }(#{ o.bytes }#{ ' dry' if o.is_dry } bytes)"
              end
            end
            ACHIEVED_  # not bytes, it's confusing to the API
          end

          WRITE_MODE_ = 'w'
        end
      end
    end
  end
end
