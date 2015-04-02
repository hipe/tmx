module Skylab::SubTree

  class Models_::File_Coverage

    class Models_::Name_Conventions

      # a placeholder for the idea of it

      def initialize test_file_name_pattern_a

        @f = For_now___
        @N = 1

        @test_file_patterns = SubTree_.lib_.basic::Pathname::Patterns[
          test_file_name_pattern_a ]
      end

      def normal_string_for_asset_dir_entry entry

        @f::String_without_trailing_dashes[ entry.to_s ]
      end

      def normal_string_for_asset_file_entry entry

        @f::Base_string_without_trailing_dashes[ entry.to_s ]
      end

      def normal_string_for_test_dir_entry entry

        entry.to_s  # :+[#001] test sub-directory names are already normal
      end

      def normal_string_for_test_file_entry entry

        s = entry.to_s

        _is = @test_file_patterns.match s

        if _is

          @f::Base_string_without_N_suffix_parts[ s, @N ]
        end
      end

      module For_now___

        Base_string_without_N_suffix_parts = -> s, d do

          s = Base_string_of__[ s ]
          a = s.split UNDERSCORE_
          a[ 0 .. - ( 1 + d ) ].join UNDERSCORE_
        end

        Base_string_without_trailing_dashes = -> s do

          s = Base_string_of__[ s ]
          Mutate_string_by_removing_trailing_dashes__[ s ]
          s
        end

        Base_string_of__ = -> s do

          ext = ::File.extname s
          s[ 0 .. - ( 1 + ext.length ) ]
        end

        Mutate_string_by_removing_trailing_dashes__ = -> s do

          s.gsub! Callback_::Name::TRAILING_DASHES_RX, EMPTY_S_
          NIL_
        end

        String_without_trailing_dashes = -> s do

          s = s.dup
          Mutate_string_by_removing_trailing_dashes__[ s ]
          s
        end
      end
    end
  end
end
