require File.expand_path('../../../git-viz/cli', __FILE__)

class Skylab::TMX::CLI

  namespace :'git-viz', -> { ::Skylab::GitViz::CLI }

end
