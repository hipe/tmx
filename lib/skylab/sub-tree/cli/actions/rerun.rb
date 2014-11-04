module Skylab::SubTree

  SubTree_::Library_.touch :Set

  class CLI::Actions::Rerun < CLI::Actions::Cov

    @sides = [:all, :rerun] # left one gets the "plus"

    @colors = {
      [:all].to_set         => :green,
      [:all, :rerun].to_set => :red,
      [:rerun].to_set       => :cyan
    }

    # HA YOU LOVE IT

  end
end
