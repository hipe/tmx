module Skylab::TanMan

  module Models_::DotFile

    class Controller__  # see [#009]

      def initialize gsp, input_arg, er, k
        @graph_sexp = gsp ; @event_receiver = er
        @input_arg = input_arg ; @kernel = k
      end

      attr_reader :graph_sexp

      def description_under expag
        send :"description_under_expag_when_#{ @input_arg.name_i }", expag
      end
    private
      def description_under_expag_when_input_string expag
        s = TanMan_::Lib_::Ellipsify[][ @input_arg.value_x ]
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

      def provide_action_precondition _id, _g
        self
      end

      def event_receiver
        @event_receiver
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

          TanMan_::Lib_::Pretty_print[].pp(
            sexp,
            TanMan_::System[].IO.some_stderr_IO )

          s = ::Pathname.new( __FILE__ ).relative_path_from TanMan.dir_pathname
          info "(from #{ s })"
        else
          info "#{ escape_path pathname } looks good : #{ sexp.class }"
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

    def rm_node *a
      if nodes
        nodes.rm(* a)
      end
    end

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

    def sexp
      res = nil
      begin
        res = services.tree.fetch pathname do |k, svc|
          tree = parse_file pathname
          if tree
            svc.set! k, tree
          end
          tree
        end
        if ! res
          emit :help, "perhaps try fixing above syntax errors and try again"
          res = nil
        end
      end while nil
      res
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

    attr_reader :verbose_dotfile_parsing # compat

    def add_remote_notify * x_a
      remotes.add_notify x_a
    end

    def get_remote_scanner
      remotes.get_remote_scanner_notify
    end

    def remove_remote_with_dry_run_and_locator dry_run, locator
      remotes.remove_with_dry_run_and_locator_notify dry_run, locator
    end

  private
    def remotes
      @remotes ||= Models::DotFile::Remotes__.new client_services
    end ; private :remotes
    #
    TanMan::Sub_Client[ self, :client_services ]
    #
    Client_Services_Proc = -> do
      delegate :controllers
      delegating :with_suffix, :_for_subclient,
        %i( emit expression_agent full_dotfile_pathname )
    end
    def emit_for_subclient i, x
      emit i, x
    end
    def expression_agent_for_subclient
      @request_client.expression_agent_for_subclient
    end
    def full_dotfile_pathname_for_subclient
      @pathname
    end
    end

      def persist_via_args arg
        adapter = Persist_Adapters__.produce_via_argument arg
        adapter.init @event_receiver, @kernel
        adapter.receive_rewritten_datastore_controller self
      end

      module Persist_Adapters__

        class << self

          def produce_via_argument arg
            ftch_class_via_argument_name( arg.name_i ).build arg.value_x
          end

          define_method :ftch_class_via_argument_name, ( -> do
            p = -> name_i do
              mod = Persist_Adapters__
              h = {}
              mod.constants.each do |i|
                h[ i.downcase ] = mod.const_get i, false
              end
              ( p = h.method :fetch )[ name_i ]
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

          def init event_receiver, kernel
            @event_receiver = event_receiver
            @kernel = kernel ; nil
          end

          def receive_rewritten_datastore_controller o
            @output_string.replace o.graph_sexp.unparse
            ACHIEVED_
          end
        end

        class Ouput_Pathname

          class << self
            def build x
              new x
            end
          end

          def initialize output_pathname
            self._IT_WILL_BE_EASY
          end
        end
      end

    if false
    public


    nl_rx = /\n/ # meh
    num_lines = -> str do
      scn = TanMan::Services::StringScanner.new str
      num = 0
      num += 1 while scn.skip_until( nl_rx )
      num += 1 unless scn.eos?
      num
    end

    define_method :write do |dry_run, force, verbose|
      bytes = nil
      begin
        next_string = sexp.unparse
        if ! pathname.exist?
          error "strange - #{graph_noun} didn't previously exist - won't write"
          break # or just raise
        end
        pathname.exist? or fail 'sanity'
        prev_string = pathname.read
        if prev_string == next_string
          info "(no changes in #{ graph_noun } - nothing to save.)"
          break
        end
        num_a = num_lines[ prev_string ]
        num_b = num_lines[ next_string ]
        if num_b < num_a && ! force
          error "ok to reduce number of lines in #{
            }#{ escape_path pathname } from #{ num_a } to #{ num_b }? #{
            }If so, use #{ par :force }."
          break # IMPORTANT!
        end
        bytes = write_commit next_string, dry_run, verbose
        break if ! bytes
        info "wrote #{ escape_path pathname } (#{ bytes } bytes)"
      end while nil
      bytes
    end

  private

    def associations
      @associations ||= begin                  # #sexp-release
        if sexp = self.sexp
          Models::Association::Collection.new self, sexp
        end
      end
    end

    def write_commit string, dry_run, verbose
      res = nil
      begin
        temp = services.tmpdir.tmpdir.join 'next.dot'
        bytes = nil
        temp.open( 'w' ) { |fh| bytes = fh.write string }
        diff = services.diff.diff pathname, temp, nil,
          -> e do
            error e
          end,
          -> i do
            if verbose
              info( gsub_path_hack i ) # e.g. `diff --normal `...
            end
          end
        break( res = diff ) if ! diff
        a = []
        nerk = -> x, verb do
          break if x == 0
          a.push "#{ verb } #{ x } line#{ s x }"
        end
        nerk[ diff.num_lines_removed, 'removed' ]
        nerk[ diff.num_lines_added,   'added'   ]
        no_change = ( 0 == diff.num_lines_added && 0 == diff.num_lines_removed )
        if no_change
          a.push "no lines added or removed!"
        end
        if verbose
          info( a.join ', ' )
        end
        break if no_change
        fu = Lib_::FU_lib[].new -> msg do
          if verbose
            info( gsub_path_hack msg )
          end
        end
        fu.mv temp, pathname, noop: dry_run
        bytes
      end while nil
      res
    end
    end

    end
  end
end
