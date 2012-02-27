mylib = File.expand_path('../../..', __FILE__)

$:.include?(mylib) or $:.unshift(mylib) # etc

require 'skylab/face/cli'
require 'skylab/porcelain/all'

module Skylab; end

module Skylab::Tmx

  module Modules; end

  class Cli < ::Skylab::Face::Cli

    version { File.read(File.expand_path('../../../../VERSION', __FILE__)) }

    face_namespaces = ::Skylab::Face::Command::Namespace.namespaces
    porc_namespaces = ::Skylab::Porcelain.namespaces
    both = [face_namespaces, porc_namespaces]

    Dir["#{File.dirname(__FILE__)}/modules/*/cli.rb"].each do |cli_path|
      f1, p1 = both.map(&:length)
      require cli_path
      f2, p2 = both.map(&:length)
      _last_added_namespace = if p2 > p1
        porc_namespaces[p1]
      elsif f2 > f1
        face_namespaces[f1]
      else
        fail("Must add a namespace, did not: #{cli_path}")
      end
      namespace _last_added_namespace
    end
  end
end

