module Skylab::Dependency
  class TaskTypes::TarballTo < TaskTypes::Get
    attribute :build_dir, :required => true, :pathname => true, :from_context => true
    attribute :from, :required => true # override parent
    attribute :tarball_to, :required => true

    attribute :get, :required => false # actually see if we can ..
    listeners_digraph  :all, :shell => :all, :info => :all, :error => :all

    module Constants
      TARBALL_EXT = /\.tar\.(?:gz|bz2)|\.tgz/ # #bound
      TARBALL_EXTENSION = /(?:#{TARBALL_EXT.source})\z/ # #bound
    end
  private
    def pairs
      md = %r{(^[^/]+:/{2,3}[^/]+)/(.+)$}.match(@from) or
        raise("Failed to hack-parse as url: #{@from}")
      [[@from, build_dir.join(::Pathname.new(md[2]))]]
    end
  end
end
