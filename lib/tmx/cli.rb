o = File.dirname(__FILE__)
require o + '/face/cli.rb'

module Skylab; end

module Skylab::Tmx

  module Modules; end

  Face = Skylab::Face

  class Cli < Face::Cli

    version { require "#{File.dirname(__FILE__)}/version"; VERSION }

    Dir["#{File.dirname(__FILE__)}/modules/*/cli.rb"].each do |cli_path|
      len = Face::Command::Namespace.namespaces.length
      require cli_path
      namespace Face::Command::Namespace.namespaces[len]
    end
  end
end
