module Skylab::DocTest

  class RecursionModels_::NameConventions

    class << self

      def instance_
        @___ ||= new.__init_with_defaults.freeze
      end
    end  # >>

    def initialize
    end

    def __init_with_defaults

      @__stemify_asset_directory_entry = :__stemify_asset_directory_entry_normally
      @__stemify_asset_file_entry = :__stemify_asset_file_entry_normally

      @__stemify_test_directory_entry = :__stemify_test_directory_entry_normally
      @__stemify_test_file_entry = :__stemify_test_file_entry_normally

      @test_directory_entry_name = 'test'
      @test_filename_patterns__ = %w( *_spec.rb )
      self
    end

    def test_directory_entry_for_stem stem
      # we like these to have but here is not the place to infer those. as a
      # last resort, when we're inferring the directory, there's no inflection
      stem
    end

    def test_file_entry_for_stem stem
      "#{ stem }_spec.rb"  # etc
    end

    def stemify_test_directory_entry entry
      send @__stemify_test_directory_entry, entry
    end

    def __stemify_test_directory_entry_normally entry
      entry.gsub LEADING_NUMBER_SERIES_RX__, EMPTY_S_
    end

    def stemify_test_file_entry entry
      send @__stemify_test_file_entry, entry
    end

    def __stemify_test_file_entry_normally entry
      s = entry.gsub LEADING_NUMBER_SERIES_RX__, EMPTY_S_
      s.gsub! TRAILING_SPEC_ETC_RX__, EMPTY_S_
      s
    end

    def stemify_asset_directory_entry entry
      send @__stemify_asset_directory_entry, entry
    end

    def __stemify_asset_directory_entry_normally entry
      entry.gsub TRAILING_DASHES_RX__, EMPTY_S_
    end

    def stemify_asset_file_entry entry
      send @__stemify_asset_file_entry, entry
    end

    def __stemify_asset_file_entry_normally entry
      en = ::File.extname entry
      buffer = entry[ 0 ... - en.length ]
      buffer.gsub! TRAILING_DASHES_RX__, EMPTY_S_
      buffer
    end

    attr_reader(
      :test_directory_entry_name,
      :test_filename_patterns__,
    )

    # ==

    LEADING_NUMBER_SERIES_RX__ = /\A
      \d+
      (?: \. \d+ )*
      -
    /x

    TRAILING_DASHES_RX__ = /-+\z/

    # (there's a thing for converting filename patterns to regexes #todo)
    TRAILING_SPEC_ETC_RX__ = /
      _spec\.rb
    \z/x
  end
end
