require File.expand_path('../api', __FILE__)
require 'skylab/porcelain/all'

module Skylab::CovTree
  class CLI
    extend ::Skylab::Porcelain
    extend ::Skylab::PubSub::Emitter
    module Actions
    end

  inactionable

    emits :all,
      :info => :all,
      :error => :all,
      :payload => :all

  public

    desc "see crude unit test coverage with a left-right-middle filetree diff"
    desc "  * test files with corresponding application files appear as green."
    desc "  * application files with no corresponding test files appear as red."

    argument_syntax '[<path>]'

    option_syntax do |ctx|
      on('-l', '--list', "shows a list of matched test files and returns.") { ctx[:list] = true }
    end

    def tree path=nil, ctx
      api.invoke_porcelain(:tree, ctx.merge(
        :emitter => self,
        :path => path
      ))
    end



    desc "see a left-middle-right filetree diff of rerun list vs. all tests."
    desc "  * tests that failed (that appeared in your rerun list) appear as red."
    desc "  * test that do not appear (that presumably passed *) appear as green."
    desc "  * note this does not take into account @wip tags etc"

    argument_syntax '<rerun-file>'

    desc " arguments: "

    desc "        <rerun-file>                a cucumber-like rerun.txt file"

    def rerun path
      api.invoke_porcelain(:rerun, :emitter => self, :rerun => path)
    end

  protected

    def api
      ::Skylab::CovTree.api
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

