require 'skylab/face/cli'

module Skylab::TMX
  module Modules::Jshint
    class CLI < Skylab::Face::CLI

      set :desc, -> y do
        y << '(woah - heh this tiny thing "works")'
      end

      def install *a
        Plumbing.new.run
      end
    end
  end
end

module ::Skylab::TMX::Modules::Jshint
  class Plumbing
    def run
      require 'json'
      json = JSON.parse(File.read(File.expand_path('../data/deps.json', __FILE__)))
      @git_url = json['external dependencies'].first['jshint']['with git clone']
      puts "Here's the url fyi, but actually just use node and npm to install this."
      puts @git_url
    end
  end
end

