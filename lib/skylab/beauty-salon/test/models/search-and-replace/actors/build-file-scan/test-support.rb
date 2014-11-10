require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport::Models::S_and_R::Actors_BFS

  Parent_TS_ = ::Skylab::BeautySalon::TestSupport::Models::S_and_R

  Parent_TS_[ self ]

  include Constants

  extend TestSupport_::Quickie

  DELIMITER_ = BS_::NEWLINE_

  Subject_ = -> do

    Parent_TS_::Subject_[]::Actors_::Build_file_scan

  end
end
