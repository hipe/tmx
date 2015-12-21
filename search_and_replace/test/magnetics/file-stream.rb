module Skylab::SearchAndReplace::TestSupport

  module Magnetics::File_Stream

    def self.[] tcc
      tcc.include self
    end

    def build_stream_for_single_path_to_file_with_three_lines_

      _path = TestSupport_::Fixtures.file :three_lines

      Callback_::Stream.via_item _path
    end

    def magnetics_
      Subject_module_[]::Magnetics_
    end
  end

  DELIMITER_ = NEWLINE_  # technically bad and wrong to assign this here
end
