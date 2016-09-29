module Skylab::Common::TestSupport::FixtureTree

  module One_Skorlab

    path = ::File.join FixtureTree_.dir_path, 'one-skorlab'
    path.freeze

    define_singleton_method :dir_path do
      path
    end

    dpn = nil
    define_singleton_method :dir_pathname do
      # self._REFACTOR_ME  # #open [#050]
      dpn ||= ::Pathname.new( path )
    end
  end
end
