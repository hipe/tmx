require File.expand_path('../get', __FILE__)

module Skylab
  module Dependency
    class TaskTypes::TarballTo < TaskTypes::Get
      attribute :tarball_to
      attribute :from, :required => false
      attribute :get
      attribute :stem, :required => false
      module Constants
        TARBALL_EXTENSION = /(?:\.tar\.(?:gz|bz2)|\.tgz)\z/
      end
      def interpolate_basename
        File.basename(@get)
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
end
