module Skylab::SubTree

  class Models_::File_Coverage

    class Models_::Name_Conventions

      # a placeholder for the idea of it

      def initialize test_file_name_pattern_a

        @N = 1

        @test_file_patterns = Home_.lib_.basic::Pathname::Patterns[
          test_file_name_pattern_a ]
      end

      def normal_string_for_asset_dir_entry entry

        _without_trailing_dashes entry.to_s
      end

      def normal_string_for_asset_file_entry entry

        s = _without_extension entry.to_s
        _mutate_by_removing_trailing_dashes s
        s
      end

      def normal_string_for_test_dir_entry entry

        _without_number_prefix entry.to_s
      end

      def normal_string_for_test_file_entry entry

        s = entry.to_s

        _yes = @test_file_patterns.match s

        if _yes

          s = _without_extension s
          _mutate_by_removing_number_prefix s
          _without_N_suffix_parts s, @N
        end
      end

      # ~ the would-be support

      def _without_trailing_dashes s

        s.gsub Common_::Name::TRAILING_DASHES_RX, EMPTY_S_
      end

      def _without_extension s

        ext = ::File.extname s
        s[ 0 .. - ( 1 + ext.length ) ]
      end

      def _without_N_suffix_parts s, d

        a = s.split UNDERSCORE_
        a[ 0 .. - ( 1 + d ) ].join UNDERSCORE_
      end

      def _without_number_prefix s

        s.gsub NUMBER_PREFIX_RX__, EMPTY_S_
      end

      # ~

      def _mutate_by_removing_number_prefix s

        s.gsub! NUMBER_PREFIX_RX__, EMPTY_S_
        NIL_
      end

      NUMBER_PREFIX_RX__ = /\A\d+-/

      def _mutate_by_removing_trailing_dashes s

        s.gsub! Common_::Name::TRAILING_DASHES_RX, EMPTY_S_
        NIL_
      end
    end
  end
end
