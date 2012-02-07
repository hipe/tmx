module Skylab::CovTree
  class Porcelain::Rerun < Porcelain::Tree
    SIDES = [:all, :rerun]
    def controller_class
      require ROOT.join('plumbing/rerun').to_s
      Plumbing::Rerun
    end
    def initialize params
      super
    end
  end
end

