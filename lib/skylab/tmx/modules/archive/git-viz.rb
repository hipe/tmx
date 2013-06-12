module Skylab::TMX

  # this file being here and not in strange.rb is just grease.

  class Modules::Arch::NS  # #re-open!

    namespace :'git-viz', -> do

      require 'skylab/git-viz/core'

      ::Skylab::GitViz::CLI::Client

    end
  end
end
