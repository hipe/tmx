require_relative 'core'

module Skylab::SubTree

  class CLI

    Callback_[ self, :employ_DSL_for_digraph_emitter ]  # do this before you extend
      # legacy, it gives you a graph

    listeners_digraph event: :all

    def initialize( * )
      @local_iambic = []
      super
    end

  private

    def get_services
      Client_Services_.new self
    end

    Client_Services_ = SubTree::Lib_::Iambic[
          :emit_proc, -> { method :call_digraph_listeners },
          :instream, -> { some_upstream },
          :errstream, -> { some_infostream },
          :outstream, -> { some_paystream } ]

  public

    def pen
      SubTree::Lib_::CLI_pen[]
    end

  private

    def expression_agent
      self.class.expression_agent
    end

    -> do
      p = -> do
        class Expression_Agent__
          def initialize _ ; end
          alias_method :calculate, :instance_exec
        private
          SubTree::Lib_::EN_add_methods[ self, :private, %i( s ) ]
          o = Lib_::CLI_lib[].pen.stylify.curry
          define_method :em, o[ %i( green ) ]
          define_method :escape_path, Lib_::Pretty_path_proc[]
          define_method :ick, Lib_::Strange_proc[].curry[ 60 ]
        public
          def stylize * a
            SubTree_::Lib_::CLI_lib[].pen.stylify a, a.pop
          end
        end
        r = Expression_Agent__.method :new ; p = -> { r } ; r
      end
      define_singleton_method :expression_agent,
        Lib_::Touch_const_reader[
          true, p[], :EXPRESSION_AGENT__, self, :_no_arg_ ]
    end.call

  public

    # --*--                         DSL ZONE                              --*--


    Lib_::CLI_DSL[ self ]

    desc "inspired by unix builtin `tree`"
    desc "but adds custom features geared towards development"

    option_parser do |o|
      front = my_tree_front
      front.with_properties( :param_h, @param_h, :expression_agent,
        SubTree::Lib_::Field_front_expression_agent[
          front.field_box, Lib_::Stock_API_expression_agent[] ]
      )
      front.write_option_parser_to o ; nil
    end

    argument_syntax '[<path> [..]]'

    def my_tree *path, _
      i, o, e = @three_streams_p[]
      f = my_tree_front
      if path.length.zero?
        path << ( ::Dir.pwd if i.tty? && ! @param_h[ :file ] )  # yes nil
      end
      @param_h[ :path_a ] = path
      f.with_properties :upstream, i, :paystream, o, :infostream, e,
        :program_name, @legacy_last_hot.normalized_invocation_string
      r = f.flush
      if false == r
        @legacy_last_hot.invite
        exitstatus_for_error
      else
        exitstatus_for_normal
      end
    end

  private

    def my_tree_front
      @my_tree_front ||= SubTree::API::Actions::My_Tree.new
    end

  public

    desc "(\"sub-tree\") from <in-dir> copy the files in <list> to <out-dir>. always safe."

    option_parser do |o|
      o.on '-F', '--force', 'to confirm clobbering existing files' do
        @param_h[:do_force] = true
      end
    end
    argument_syntax '<in-dir> <out-dir> <list>'

    def st in_dir, out_dir, list, param_h
      SubTree::API::Actions::Sub_Tree.new( :err, some_infostream,
        :is_dry_run, false, :do_force, param_h[:do_force],
        :in_dir, in_dir, :out_dir, out_dir, :list, list ).execute
    end

    option_parser do |o|
      pn = -> { @program_name }
      clr = -> x { hdr x }

      o.separator "#{ hdr 'stdin usage:' }"
      o.separator "   or: <git-command> | #{ pn[] } <prefix>"
      o.separator ''
      o.separator "#{ hdr 'typical usage:' }"
      o.separator "    #{ clr[ "git diff --numstat HEAD~1 | #{ pn[] } lib/skylab" ] }"
      o.separator ''
      o.separator "#{ hdr 'options:' }"

      o.on '-- HEAD[~N]', 'will become `git diff HEAD~<n> --numstat' do |x|
        old = @param_h[ :mode_a ]
        @param_h[ :mode_a ] = [ :git_diff, x ]
        if old
          call_digraph_listeners :error_string, "(clobbering \"#{ old.last }\")"
        end
      end

    end

    desc( -> do
      p = -> do
        SubTree::API::Actions::Dirstat.get_desc
      end
      p.singleton_class.send :alias_method, :to_s, :call
      p
    end.call )

    argument_syntax '<prefix> [<file>]'

    def dirstat prefix, file=nil, _par_h
      a = parse_dirstat( prefix, file ) and execute_dirstat a
    end

  private

    def parse_dirstat prefix, file
      @param_h[ :prefix ] = prefix
      if file && (( x = @param_h[ :mode_a ] ))
        bork "can't have both <file> and \"#{ x.last }\""
      else
        file and @param_h[ :mode_a ] = [ :file, file ]
        @param_h.reduce( [] ) { |m, (k, v)| m << k << v }
      end
    end

    def execute_dirstat a
      SubTree::API::Actions::Dirstat.new(
        :sin, @instream, :sout, @paystream, :serr, @errstream,
        :program_name, @legacy_last_hot.send( :normalized_invocation_string ),
        * a
      ).execute
    end

    def bork msg
      call_digraph_listeners :error_string, msg
      invite
      nil
    end

  public

    desc "see crude unit test coverage with a left-right-middle filetree diff"
    desc "  * test files with corresponding application files appear as green."
    desc "  * application files with no corresponding test files appear as red."

    argument_syntax '<path>'

    option_parser do |o|

      o.on '-l', '--list', "show a list of matched test files only." do
        @local_iambic.push :list_as, :list
      end

      o.on '-s', '--shallow', "show a shallow tree of matched test #{
          }files only." do
        @local_iambic.push :list_as, :test_tree_shallow
      end

      -> do

        h = { 'c' => :code, 't' => :test }.freeze

        o.on '-t', '--tree <c|t>', "show a debugging tree of the raw #{
            }[c]ode and/or [t]est only." do |tc|

          _x = h.fetch( tc, & :intern )
          @local_iambic.push :list_as, _x
        end
      end.call

      o.on '-v', '--verbose', 'verbose (debugging) output' do
        @local_iambic.push :verbose
      end
    end

    def cov path, _opts
      @local_iambic.push :path, path
      _const = Name_.via_variegated_symbol( :cov ).as_const
      _cls = CLI::Actions.const_get _const, false
      _act = _cls.new
      hot = _act.init_for_invocation_via_services get_services
      x = hot.invoke_via_iambic @local_iambic
      if false == x
        invite
        x = exitstatus_for_error
      end
      x
    end

    # --*--

    desc "see a left-middle-right filetree diff of rerun list vs. all tests."
    desc "  * tests that failed (that appeared in your rerun list) appear as red."
    desc "  * test that do not appear (that presumably passed *) appear as green."
    desc "  * note this does not take into account @wip tags etc"

    argument_syntax '<rerun-file>'

    desc " arguments: "

    desc "        <rerun-file>                a cucumber-like rerun.txt file"

    def rerun path
      param_h = { emitter: self, rerun: path }
      res = cli_invoke :rerun, param_h
      if false == ok
        res = invite_fuck_me :rerun
      end
      res
    end

    desc "performs a ping."

    def ping
      call_digraph_listeners :info, "hello from sub tree."
      :hello_from_sub_tree
    end

    dsl_off

    module Actions
      Autoloader_[ self ]
    end

    Client = self  # #comport:tmx
  end
end
