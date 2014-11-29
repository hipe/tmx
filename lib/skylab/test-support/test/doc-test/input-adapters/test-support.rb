require_relative '../test-support'

module Skylab::TestSupport::TestSupport::DocTest::Input

  ::Skylab::TestSupport::TestSupport::DocTest[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  module InstanceMethods

    def with_file fake_file_name_symbol
      _fake_file = fake_file_structure_for_path( big_file_path ).
        fake_files_demarcated_by_regex( magic_line_regexp )[
          fake_file_name_symbol ]
      @cb_stream = cb_stream_via_fake_file _fake_file
      nil
    end
  end
end
