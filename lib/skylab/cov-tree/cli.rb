require File.expand_path('../api', __FILE__)
require 'skylab/porcelain/all'

module Skylab::CovTree
  class CLI
    module Actions
    end
  end
  module CLI::Styles
    include ::Skylab::Porcelain::En
    include ::Skylab::Porcelain::TiteColor::Methods
    def pre(s)  ; stylize(s, :green         )   end
  end
  class CLI
    extend ::Skylab::Porcelain
    extend ::Skylab::PubSub::Emitter
    include CLI::Styles

  inactionable

    emits :error, :info, :payload

  public

    desc "see crude unit test coverage with a left-right-middle filetree diff"
    desc "  * test files with corresponding application files appear as green."
    desc "  * application files with no corresponding test files appear as red."

    argument_syntax '[<path>]'

    option_syntax do |ctx|
      on('-l', '--list', "show a list of matched test files only.") { ctx[:list_as] = :list }
      on('-t', '--tree', "show a shallow tree of matched test files only.") { ctx[:list_as] = :tree }
    end

    def tree path=nil, opts
      ok = api.invoke_porcelain(:tree, opts.merge(emitter: self, path: path))
      ok == false ? invite_fuck_me(:tree) : ok
    end



    desc "see a left-middle-right filetree diff of rerun list vs. all tests."
    desc "  * tests that failed (that appeared in your rerun list) appear as red."
    desc "  * test that do not appear (that presumably passed *) appear as green."
    desc "  * note this does not take into account @wip tags etc"

    argument_syntax '<rerun-file>'

    desc " arguments: "

    desc "        <rerun-file>                a cucumber-like rerun.txt file"

    def rerun path
      ok = api.invoke_porcelain(:rerun, emitter: self, rerun: path)
      ok == false ? invite_fuck_me(:rerun) : ok
    end

  protected

    def api
      ::Skylab::CovTree.api
    end

    def invite_fuck_me token
      help_frame.invite(help_frame.action) # @todo fuck this shit
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
  class CLI::Action
    include CLI::Styles
    include ::Skylab::Autoloader::Inflection::Methods
    def controller_class # @todo use autoloader instead (requires rearch)
      const_stem = self.class.to_s.split('::').last
      require ROOT.join("api/#{pathify const_stem}").to_s
      API::Actions.const_get const_stem
    end
    def emit(*a)
      @emitter.emit(*a)
    end
    attr_writer :emitter
    def initialize params
      params.each do |k, v|
        send("#{k}=", v)
      end
      @emitter or fail('no emitter')
    end
  end
end
