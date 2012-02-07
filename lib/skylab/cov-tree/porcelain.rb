require File.expand_path('../api', __FILE__)
require 'skylab/porcelain/tite-color'

module Skylab::CovTree
  class Porcelain
    extend ::Skylab::Porcelain
    extend ::Skylab::Slake::Muxer

    emits :all,
      :info => :all,
      :error => :all,
      :payload => :all

    porcelain { blacklist /^on_.*/ } # hack so that our event knobs don't appear as actions


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
  end
end

