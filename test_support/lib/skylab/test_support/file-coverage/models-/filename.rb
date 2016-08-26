module Skylab::TestSupport

  module FileCoverage

    class Models_::Filename

      def initialize s

        @file_entry = ::File.basename(s).freeze  # #entry-model

        dn = ::File.dirname s

        @directory_entry_string_array = if DOT_ == dn
          EMPTY_A_
        else
          dn.split( ::File::SEPARATOR ).map do |entry|
            entry.freeze  # #entry-model
          end.freeze
        end

        freeze
      end

      def to_dir_entry_stream
        Common_::Stream.via_nonsparse_array @directory_entry_string_array
      end

      attr_reader(
        :directory_entry_string_array,
        :file_entry,
      )

      DOT_ = '.'
    end
  end
end
