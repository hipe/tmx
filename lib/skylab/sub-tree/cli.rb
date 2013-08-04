require_relative 'core'

module Skylab::SubTree

  class CLI # (fwd decl. of a class also used as a namespace [#sl-109])
  end

  module CLI::Styles
    include Headless::NLP::EN::Methods
    include Headless::CLI::Pen::Methods  # `stylize`

    def pre x
      stylize x.to_s, :green
    end
  end

  class CLI

  private

    include CLI::Styles

    define_method :escape_path, & Headless::CLI::PathTools::FUN.pretty_path # yay

    extend PubSub::Emitter  # do this before you extend legacy, it gives you
                            # a graph

    def mutex name_i, value_i
      @param_h[ name_i ] ||= [ ]
      @param_h[ name_i ] << value_i
      nil
    end

  public

    def pen
      Headless::CLI::Pen::MINIMAL
    end

    alias_method :expression_agent, :pen
    private :expression_agent

    # --*--                         DSL ZONE                              --*--

    extend Porcelain::Legacy::DSL

    desc "inspired by unix builtin `tree`"
    desc "but adds custom features geared towards development"

    option_parser do |o|
      my_tree_front.absorb( :expression_agent, expression_agent,
                            :param_h, @param_h ).write_option_parser_to o
    end
    argument_syntax '[<path> [..]]'

    def my_tree *path, _
      path.length.zero? and path << ::Dir.pwd
      @param_h[ :path_a ] = path
      i, o, e = @three_streams_p.call ; f = my_tree_front
      f.absorb :upstream, i, :paystream, o, :infostream, e, :program_name,
        @legacy_last_hot.normalized_invocation_string
      r = f.flush
      if false == r
        @legacy_last_hot.invite
        status_error
      else
        status_normal
      end
    end

    def my_tree_front
      @my_tree_front ||= SubTree::API::Actions::My_Tree.new
    end
    private :my_tree_front

    desc "(\"sub-tree\") from <in-dir> copy the files in <list> to <out-dir>. always safe."

    option_parser do |o|
      o.on '-F', '--force', 'to confirm clobbering existing files' do
        @param_h[:do_force] = true
      end
    end
    argument_syntax '<in-dir> <out-dir> <list>'

    def st in_dir, out_dir, list, param_h
      ensure_three_streams
      SubTree::API::Actions::Sub_Tree.new( :err, @infostream,
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
        old and emit( :error, "(clobbering \"#{ old.last }\")" )
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
      ensure_three_streams
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
        :sin, @instream, :sout, @paystream, :serr, @infostream,
        :program_name, @legacy_last_hot.send( :normalized_invocation_string ),
        * a
      ).execute
    end

    def bork msg
      emit :error, msg
      invite
      nil
    end

  public

    desc "see crude unit test coverage with a left-right-middle filetree diff"
    desc "  * test files with corresponding application files appear as green."
    desc "  * application files with no corresponding test files appear as red."

    argument_syntax '[<path>]'

    option_parser do |o|

      o.on '-l', '--list', "show a list of matched test files only." do
        mutex :list_as, :list
      end

      o.on '-s', '--shallow', "show a shallow tree of matched test #{
          }files only." do
        mutex :list_as, :test_tree_shallow
      end

      -> do
        h = { 'c' => :code, 't' => :test }.freeze
        o.on '-t', '--tree <c|t>', "show a debugging tree of the raw #{
            }[c]ode and/or [t]est only." do |tc|
          mutex :list_as, h.fetch( tc, & :intern )
        end
      end.call

      o.on '-v', '--verbose', 'verbose (debugging) output' do
        @param_h[:be_verbose] = true
      end
    end

    def cov path=nil, opts
      param_h = opts.merge path: path
      klass = CLI::Actions.const_fetch :cov  # grease the gears
      hot = klass.new self
      res = hot.invoke param_h
      if false == res
        invite
        res = status_error
      end
      res
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
      emit :info, "hello from sub tree."
      :hello_from_sub_tree
    end

    Client = self  # #tmx-compat
  end
end
