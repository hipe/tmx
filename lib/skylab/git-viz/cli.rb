# (requires at bottom!)

module Skylab::GitViz
  class Cli
    ROOT = Pathname.new('..').expand_path(__FILE__)
    extend ::Skylab::Porcelain

    porcelain do
      desc 'fun data viz reports on a git project.'
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
      require self.class::ROOT.join("cli/#{meth}").to_s
      self.class.const_get(meth.to_s.gsub(/(?:^|-)([a-z])/) { $1.upcase }).new(runtime).invoke(*a)
    end
  end
end

require File.expand_path('../cli/action', __FILE__)

