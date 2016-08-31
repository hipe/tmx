module Skylab::TestSupport

  module FileCoverage

    class Models_::NameConventions

      # a placeholder for the idea of it

      def initialize test_file_name_pattern_a

        __init_big_tree_filename_patterns_via test_file_name_pattern_a

        @test_file_patterns = Home_.lib_.basic::Pathname::Patterns.call(
          test_file_name_pattern_a )

        @N = 1  # how many parts to omit from the tail of the stem, eg.
        #  if you have `foo_bar_baz_qux.kode` and N=2, you are left with
        #  `foo`, `bar`. typically just omit the `_spec` or _test`.
      end

      def __init_big_tree_filename_patterns_via test_file_name_pattern_a

        # explained fully at [#013]:#note-1

        a = [] ; seen = {}
        test_file_name_pattern_a.each do |pat|
          s = ::File.extname pat
          s.length.zero? && next
          seen.fetch s do
            seen[ s ] = true
            CRUDE_RX___ =~ s || next
            a.push s
          end
        end

        @big_tree_filename_extensions = if a.length.nonzero?
          a.freeze
        end
        NIL
      end

      CRUDE_RX___ = /\A\.[[:alnum:]]+\z/

      def normal_string_for_asset_dir_entry entry

        _without_trailing_dashes entry  # #entry-model
      end

      def normal_string_for_asset_file_entry entry

        s = _without_extension entry  # #entry-model
        _mutate_by_removing_trailing_dashes s
        s
      end

      def normal_string_for_test_dir_entry entry
        _without_number_prefix entry  # #entry-model
      end

      def normal_string_for_test_file_entry entry

        s = entry.dup  # #entry-model

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

      NUMBER_PREFIX_RX__ = /\A\d+(?:\.\d+)*-/

      def _mutate_by_removing_trailing_dashes s

        s.gsub! Common_::Name::TRAILING_DASHES_RX, EMPTY_S_
        NIL_
      end

      def big_tree_filename_patterns__
        ( @___btfp  ||= ___build_etc ).value_x
      end

      def ___build_etc
        s_a = @big_tree_filename_extensions
        if s_a
          x = s_a.map { |s| "#{ ASTERISK_ }#{ s }" }
        end
        Common_::Known_Known[ x ]
      end

      def to_big_tree_filename_patterns__
        s_a = @big_tree_filename_extensions
        if s_a
          Common_::Stream.via_nonsparse_array s_a
        end
      end

      attr_reader(
        :big_tree_filename_extensions,
      )
    end
  end
end
