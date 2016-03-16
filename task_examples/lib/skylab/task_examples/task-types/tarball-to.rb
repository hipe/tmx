module Skylab::TaskExamples

  class TaskTypes::TarballTo < Common_task_[]

    # this is a mystery node now

    depends_on_parameters(
      build_dir: :_from_context,
      from: nil,
      get: :optional,
      tarball_to: nil,
    )

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
