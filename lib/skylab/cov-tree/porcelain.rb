require File.expand_path('../api', __FILE__)
require 'skylab/porcelain/tite-color'

module Skylab::CovTree
  class Porcelain
    extend ::Skylab::Porcelain
    extend ::Skylab::Slake::Muxer
    emits :all, :info => :all, :error => :all, :payload => :all
    porcelain { blacklist /^on_.*/ } # hack so that our event knobs don't appear as actions
    argument_syntax '[<path>]'
    option_syntax do |ctx|
      on('-l', '--list', "shows a list of matched test files and returns.") { ctx[:list] = true }
      on('--rerun <file>', "use a cucumber-like rerun.txt file, show inferred tree") do |s|
        ctx[:rerun] = s
      end
    end
    def tree path=nil, ctx
      ::Skylab::CovTree.api.invoke_porcelain(:tree, ctx.merge(
        :emitter => self,
        :path => path
      ))
    end
  end
end

