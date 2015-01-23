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
          :persist_via_args, :unparse_entire_document ]
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

      def unparse_entire_document
        @graph_sexp.unparse
      end

      def insert_stmt_before_stmt new, least_greater_neighbor
        insert_stmt new, least_greater_neighbor
      end

      def insert_stmt new, new_before_this=nil  # #note-20
        g = @graph_sexp
        prototype = -> do
          p = -> do
            x = g.class.parse :stmt_list, "xyzzy_1\nxyzzy_2"
            p = -> { x } ; x
          end
          -> { p[] }
        end.call
        empty_stmt_list = -> do
          prototype[].__dupe except: [ :stmt, :tail ]
        end
        if ! g.stmt_list
          g.stmt_list = empty_stmt_list[]
        end
        if ! g.stmt_list._prototype && ! g.stmt_list._items_count_exceeds( 1 )
          g.stmt_list._prototype = prototype[]
        end
        g.stmt_list._insert_item_before_item new, new_before_this
      end

      def destroy_stmt stmt
        if @graph_sexp.stmt_list
          _x = @graph_sexp.stmt_list._remove_item stmt
          _x ? ACHIEVED_ : UNABLE_  # we mean to destroy
        else
          UNABLE_
        end
      end

      def provide_action_precondition _id, _g
        self
      end

    if false
    include Core::SubClient::InstanceMethods
    include Models::DotFile::Parser::InstanceMethods

    def add_association *a
      if associations
        associations.add_association(* a)
      end
    end

    def apply_meaning node_ref, meaning, dry_run, verbose, error, success, info
      res = nil
      begin
        nodes or break
        node = nodes.fetch node_ref, error
        break( res = node ) if ! node
        res = meanings.apply(
          node, meaning, dry_run, verbose, error, success, info )
      end while nil
      res
    end

    def check verbose
      res = true # always succeeds
      begin
        sexp = self.sexp or break # emitted
        if verbose

          TanMan_.lib_.pretty_print.pp(
            sexp,
            TanMan_::System[].IO.some_stderr_IO )

          s = ::Pathname.new( __FILE__ ).relative_path_from TanMan.dir_pathname
          send_info_string "(from #{ s })"
        else
          send_info_string "#{ escape_path pathname } looks good : #{ sexp.class }"
        end
      end while nil
      res
    end

    def graph_noun
      "#{ escape_path pathname }"
    end

    def meanings
      @meanings ||= Models::Meaning::Collection.new self
    end

    attr_reader :pathname

    def set_dependency source_ref, target_ref, do_create,
      do_fuzz, error, success, info

      associations.set_dependency source_ref, target_ref, do_create,
        do_fuzz, error, success, info
    end

    def set_meaning agent_ref, target_ref, create, dry_run, verbose,
                      error, success, info
      meanings.set agent_ref, target_ref, create, dry_run, verbose,
        error, success, info
    end

    def tell statement_sexp, dry_run, force, verbose
      rule = statement_sexp.class.rule.to_s
      rule_stem = rule.match( /_statement\z/ ).pre_match
      action_class = Models::DotFile::Actions.const_fetch rule_stem # BOXXY
      o = action_class.new self
      res = o.invoke dotfile_controller: self,
                                dry_run: dry_run,
                                  force: force,
                              statement: statement_sexp,
                                verbose: verbose
      res
    end

    def unset_dependency *a
      associations.unset_dependency(* a)
    end

    def unset_meaning *a
      meanings.unset(* a)
    end
    end

      attr_accessor :caddied_output_args  # topic doesn't do anything with this, just carries it

      def persist_via_args is_dry, arg
        adapter = Persist_Adapters__.produce_via_argument arg
        adapter.init @kernel, & @on_event_selectively
        adapter.receive_rewritten_datastore_controller is_dry, self
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

        class Output_String

          class << self
            def build x
              new x
            end
          end

          def initialize output_string
            @output_string = output_string
          end

          def init k, & oes_p
            @on_event_selectively = oes_p
            @kernel = k
            nil
          end

          def receive_rewritten_datastore_controller is_dry, o  # #hook-out (local)
            @output_string.replace o.graph_sexp.unparse
            ACHIEVED_
          end
        end

        class Output_Path

          class << self
            def build x
              new x
            end
          end

          def initialize path
            @output_path = path
          end

          def init k, & oes_p
            @on_event_selectively = oes_p
            @kernel = k
            nil
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

    if false


    def associations
      @associations ||= begin                  # #sexp-release
        if sexp = self.sexp
          Models::Association::Collection.new self, sexp
        end
      end
    end
    end

    end
  end
end
