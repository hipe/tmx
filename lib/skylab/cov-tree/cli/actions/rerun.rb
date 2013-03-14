module Skylab::CovTree

  class CLI::Actions::Rerun < CLI::Actions::Tree

    @sides = [:all, :rerun] # left one gets the "plus"

    @colors = {
      [:all].to_set         => :green,
      [:all, :rerun].to_set => :red,
      [:rerun].to_set       => :cyan
    }

    # HA YOU LOVE IT

  end
end
