require File.expand_path('../get', __FILE__)

module Skylab
  module Dependency
    class TaskTypes::TarballTo < TaskTypes::Get
      attribute :tarball_to
      attribute :from, :required => false
      attribute :get
      attribute :stem, :required => false
      TarballExtension = /\.tar\.gz\z/
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
        def stem filename
          filename.sub(TarballExtension, '')
        end
      end
    end
  end
end
