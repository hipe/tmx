class Skylab::TMX::CLI

  namespace :'beauty-salon', -> do

    require 'skylab/beauty-salon/core'

    ::Skylab::BeautySalon::CLI::Client

  end, aliases: %i| bs |

end
