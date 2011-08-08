o = File.dirname(__FILE__)
require o + '/face/cli.rb'

module Skylab; end
module Skylab::Tmx; end
module Skylab::Tmx::Modules; end

class Skylab::Tmx::Cli < Skylab::Face::Cli
  Face = Skylab::Face
  Dir["#{File.dirname(__FILE__)}/modules/*/cli.rb"].each do |cli_path|
    len = Face::Command::Namespace.namespaces.length
    require cli_path
    namespace Face::Command::Namespace.namespaces[len]
  end
end