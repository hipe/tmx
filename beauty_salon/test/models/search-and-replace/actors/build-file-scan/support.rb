module Skylab::BeautySalon::TestSupport

  module Models::Search_And_Replace::Actors::Build_File_Scan::Support

    def self.[] tcc
      tcc.include self
    end

    def build_stream_for_single_path_to_file_with_three_lines_

      Callback_::Stream.via_item(
        TestSupport_::Data::Universal_Fixtures[ :three_lines ] )
    end

    def actors_
      Models::Search_And_Replace::Subject_module_[]::Actors_
    end

    define_method :unindent_, Models::Search_And_Replace::UNINDENT_

  end
end
