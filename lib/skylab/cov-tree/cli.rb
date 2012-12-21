require_relative 'core'

module Skylab::CovTree

  class CLI # (fwd decl. of a class also used as a namespace [#sl-109])
    extend MetaHell::Autoloader::Autovivifying::Recursive
      # (the above is necessary to state explicitly for this class
      # only because this file gets loaded directly and not by
      # a recursive autoloader.  But this is an exception to a rule
      # that covers just about every other module/file in this subproduct.)
  end


  module CLI::Styles
    include Headless::NLP::EN::Methods
    include Headless::CLI::Stylize::Methods # `stylize`

    def pre x
      stylize x.to_s, :green
    end
  end


  class CLI
    extend Porcelain
    extend PubSub::Emitter
    include CLI::Styles

  inactionable

    emits :error, :info, :payload

  public

    desc "see crude unit test coverage with a left-right-middle filetree diff"
    desc "  * test files with corresponding application files appear as green."
    desc "  * application files with no corresponding test files appear as red."

    argument_syntax '[<path>]'

    option_syntax do |param_h|
      on '-l', '--list', "show a list of matched test files only." do
        param_h[:list_as] = :list
      end
      on '-t', '--tree', "show a shallow tree of matched test files only." do
        param_h[:list_as] = :tree
      end
      on '-v', '--verbose', 'verbose (debugging) output' do
        param_h[:verbose] = true
      end
    end

    def tree path=nil, opts
      param_h = opts.merge path: path
      res = cli_invoke :tree, param_h
      if false == res
        res = invite_fuck_me :tree
      end
      res
    end


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

  protected

    def cli_invoke norm_name, param_h
      k = CLI::Actions.const_fetch norm_name
      o = k.new self
      r = o.invoke param_h
      r
    end


    define_method :escape_path, & Headless::CLI::PathTools::FUN.pretty_path # yay


    def invite_fuck_me token
      help_frame.invite help_frame.action  # #todo fuck this shit
      nil
    end


    # the gui client runtime that you have, map your events to the parent events.
    def wire! my_runtime, parent
      my_runtime.tap do |o|
        o.on_payload { |e| parent.emit(:payload, e.touch!) }
        o.on_error   { |e| parent.emit(:error,   e.touch!) }
        o.on_all     { |e| parent.emit(:info,    e) unless e.touched? }
      end
    end
  end
end
