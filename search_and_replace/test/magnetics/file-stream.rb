module Skylab::SearchAndReplace::TestSupport

  module Magnetics::File_Stream

    def self.[] tcc
      tcc.include self
    end

    def build_stream_for_single_path_to_file_with_three_lines_

      Callback_::Stream.via_item(
        TestSupport_::Fixtures.file( :three_lines ) )
    end

    def actors_
      Subject_module_[]::Actors_
    end
  end
end
