require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport::Models::S_and_R::Actors_BFS

  Parent_TS_ = ::Skylab::BeautySalon::TestSupport::Models::S_and_R

  Parent_TS_[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  Callback_ = Callback_

  DELIMITER_ = Home_::NEWLINE_

  TestSupport_ = TestSupport_

  module InstanceMethods

    def build_stream_for_single_path_to_file_with_three_lines

      Callback_::Stream.via_item( TestSupport_::Data::Universal_Fixtures.
        dir_pathname.join( 'three-lines.txt' ).to_path )

    end
  end

  Actors_ = -> do

    Parent_TS_::Subject_[]::Actors_

  end
end
