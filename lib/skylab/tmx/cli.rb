mylib = File.expand_path('../../..', __FILE__)

$:.include?(mylib) or $:.unshift(mylib) # etc

require 'skylab/face/cli'

module Skylab; end

module Skylab::Tmx

  module Modules; end

  Face = Skylab::Face

  class Cli < Face::Cli

    version { File.read(File.expand_path('../../../../VERSION', __FILE__)) }

    Dir["#{File.dirname(__FILE__)}/modules/*/cli.rb"].each do |cli_path|
      len = Face::Command::Namespace.namespaces.length
      require cli_path
      namespace Face::Command::Namespace.namespaces[len]
    end
  end
end
