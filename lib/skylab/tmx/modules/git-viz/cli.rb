require File.expand_path('../../../../git-viz/cli', __FILE__)

module Skylab
  module Tmx
    module CovTree
      extend ::Skylab::Porcelain
      namespace :'git-viz', ::Skylab::GitViz::Cli
    end
  end
end

