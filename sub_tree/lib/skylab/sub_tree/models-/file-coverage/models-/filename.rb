module Skylab::SubTree

  class Models_::File_Coverage

    class Models_::Filename

      def initialize s

        dn = ::File.dirname s
        @__dir_ent_a = if DOT_ == dn
          EMPTY_A_
        else
          dn.split( ::File::SEPARATOR ).map do | entry_s |

            Models_::Entry[ entry_s.freeze ]

          end.freeze
        end

        @file_entry = Models_::Entry[ ::File.basename( s ).freeze ]

        freeze
      end

      attr_reader :file_entry

      def to_dir_entry_stream

        Common_::Stream.via_nonsparse_array @__dir_ent_a
      end
    end
  end
end
