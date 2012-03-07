require File.expand_path('../api', __FILE__)
# (requires at bottom!)

module Skylab::GitViz
  class Cli
    include Api::InstanceMethods

    ROOT = Pathname.new('..').expand_path(__FILE__)
    extend ::Skylab::Porcelain

    porcelain do
      desc 'fun data viz reports on a git project.'
      emits :payload => :all
      aliases 'gv'
    end

    action do
      desc "do the foo."
      aliases 'ht'
    end

    argument_syntax '[<path>]'

    def hist_tree path=nil
      porcelain_dispatch(:path => path)
    end

  private

    def porcelain_dispatch *a
      meth = runtime.stack.top.action.name
      require self.class::ROOT.join("cli/actions/#{meth}").to_s
      Cli::Actions::const_get(camelize meth).new(runtime).invoke(*a)
    end
  end

  module Cli::Actions
  end
end

require File.expand_path('../cli/action', __FILE__)

