require File.expand_path('../tree', __FILE__)

module Skylab::CovTree
  class CLI::Actions::Rerun < CLI::Actions::Tree

    @sides = [:all, :rerun] # left one gets the "plus"

    @colors = {
      [:all].to_set         => :green,
      [:all, :rerun].to_set => :red,
      [:rerun].to_set       => :cyan
    }

    def controller_class
      require ROOT.join('plumbing/rerun').to_s
      Plumbing::Rerun
    end
  end
end

