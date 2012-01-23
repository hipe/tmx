require File.expand_path('../get', __FILE__)

module Skylab::Dependency
  class TaskTypes::TarballTo < TaskTypes::Get
    attribute :tarball_to
    attribute :from, :required => false
    attribute :stem, :required => false
    attribute :basename, :required => false
    module Constants
      TARBALL_EXT = /\.tar\.(?:gz|bz2)|\.tgz/
      TARBALL_EXTENSION = /(?:#{TARBALL_EXT.source})\z/
    end
    def interpolate_stem
      @stem || self.class.stem(@get)
    end
  protected
    def pairs
      [[File.join(@from, @get), File.join(build_dir, @get)]]
    end
    class << self
      include Constants
      def stem filename
        filename.sub(TARBALL_EXTENSION, '')
      end
    end
  end
end

