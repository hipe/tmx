module Skylab::TestSupport

  module FileCoverage

    class Models_::Filename

      def initialize s

        dn = ::File.dirname s

        @__dir_ent_a = if DOT_ == dn
          EMPTY_A_
        else
          dn.split( ::File::SEPARATOR ).map do |entry|
            entry.freeze  # #entry-model
          end.freeze
        end

        @file_entry = ::File.basename(s).freeze  # #entry-model

        freeze
      end

      def to_dir_entry_stream
        Common_::Stream.via_nonsparse_array @__dir_ent_a
      end

      attr_reader(
        :file_entry,
      )

      DOT_ = '.'
    end
  end
end
