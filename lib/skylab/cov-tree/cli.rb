require_relative 'core'

module Skylab::CovTree

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

  protected

    include CLI::Styles

    define_method :escape_path, & Headless::CLI::PathTools::FUN.pretty_path # yay

    extend PubSub::Emitter  # do this before you extend legacy, it gives you
                            # a graph
  public

    # --*--                         DSL ZONE                              --*--

    extend Porcelain::Legacy::DSL

    desc "performs a ping."

    def ping
      @infostream.puts "hello from cov tree."
      :hello_from_cov_tree
    end

    desc "(\"sub-tree\") from <in-dir> copy the files in <list> to <out-dir>. always safe."

    option_parser do |o|
      o.on '-F', '--force', 'to confirm clobbering existing files' do
        @param_h[:do_force] = true
      end
    end
    argument_syntax '<in-dir> <out-dir> <list>'

    def st in_dir, out_dir, list, param_h
      CovTree::API::Actions::Sub_Tree.new( :err, @infostream,
        :is_dry_run, false, :do_force, param_h[:do_force],
        :in_dir, in_dir, :out_dir, out_dir, :list, list ).execute
    end

    p = -> do
      CovTree::API::Actions::Dirstat.get_desc
    end

    p.singleton_class.send :alias_method, :to_s, :call

    desc p

    argument_syntax '<prefix> [<file>]'

    def dirstat prefix, file=nil
      argv = [ prefix ]
      file and argv.push file
      CovTree::API::Actions::Dirstat.new(
        :sin, @instream, :sout, @paystream, :serr, @infostream, :argv, argv,
        :program_name, @legacy_last_hot.send( :normalized_invocation_string ) ).
          execute
    end

    desc "see crude unit test coverage with a left-right-middle filetree diff"
    desc "  * test files with corresponding application files appear as green."
    desc "  * application files with no corresponding test files appear as red."

    argument_syntax '[<path>]'

    option_parser do |o|
      param_h = @param_h
      o.on '-l', '--list', "show a list of matched test files only." do
        param_h[:list_as] = :list
      end
      o.on '-t', '--tree', "show a shallow tree of matched test files only." do
        param_h[:list_as] = :tree
      end
      o.on '-v', '--verbose', 'verbose (debugging) output' do
        param_h[:verbose] = true
      end
    end

    def tree path=nil, opts
      param_h = opts.merge path: path
      klass = CLI::Actions.const_fetch :tree  # grease the gears
      live_action = klass.new self  # BOOM
      res = live_action.subinvoke param_h
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
  end
end
