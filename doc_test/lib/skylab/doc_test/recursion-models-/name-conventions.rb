module Skylab::DocTest

  class RecursionModels_::NameConventions  # exactly #note-2 in [#005] (see)

    class << self

      define_method :default_instance__, ( Lazy_.call do  # #testpoint
        Here___.__new(
          %w( *_spec.rb ),
          Autoloader_::EXTNAME,
        )
      end )

      alias_method :__new, :new
      undef_method :new
    end  # >>

    Here___ = self

    def initialize tfnpz, ae
      @test_directory_entry_name = DEFAULT_TEST_DIRECTORY_ENTRY_
      self.asset_extname = ae
      self.test_filename_patterns = tfnpz
      finish
    end

    def initialize_copy _
      NOTHING_  # (hi.)
    end

    def asset_extname= s
      s || fail
      pat = "*#{ s }"
      _o = Build_procer__[ nil, ANY_TRAILING_DASHES_RXS___, pat ]
      @__stem_via_asset_entry = _o.to_stemmer_proc
      @asset_filename_pattern__ = pat
      @asset_extname = s
    end

    ANY_TRAILING_DASHES_RXS___ = '-*'

    def test_filename_patterns= a
      o = Build_procer__[ "#{ LEADING_DIGIT_RXS__ }?", nil, a.fetch( 0 ) ]
      @__stem_via_test_entry = o.to_stemmer_proc
      @__test_entry_via_stem = o.__to_unstemmer_proc
      @test_filename_patterns = a
    end

    LEADING_DIGIT_RXS__ = '(?:\d+(?:\.\d+)*-)'

    def finish
      freeze  # (hi.)
    end

    # -- (write above; read below)

    # ~ stemify test directory

    def stemify_test_directory_entry entry

      entry.gsub LEADING_DIGIT_RX___, EMPTY_S_  # #hardcoded-for-now
    end

    LEADING_DIGIT_RX___ = ::Regexp.new "\\A#{ LEADING_DIGIT_RXS__ }"

    # ~ stemify test file

    def stemify_test_file_entry entry
      @__stem_via_test_entry[ entry ]
    end

    # ~ unstemify for test

    def test_directory_entry_for_stem stem

      # we like these to have leading numbers but here is not the place to
      # infer those. as a last resort, when we're inferring the directory,
      # there's no inflection

      stem
    end

    def test_file_entry_for_stem stem
      @__test_entry_via_stem[ stem ]
    end

    # ~ stemify asset directory

    def stemify_asset_directory_entry entry

      entry.gsub TRAILING_DASHES_RX___, EMPTY_S_  # #hardcoded-for-now
    end

    TRAILING_DASHES_RX___ = ::Regexp.new "-+\\z"

    # ~ stemify asset file entry

    def stemify_asset_file_entry entry
      @__stem_via_asset_entry[ entry ]
    end

    attr_reader(
      :asset_extname,
      :asset_filename_pattern__,
      :test_directory_entry_name,
      :test_filename_patterns,
    )

    # ==

    Build_procer__ = -> lead_rxs, trail_rxs, filename_pattern do

      o = Procer___.new
      o.extend ProcerBuildingMethods___
      o.__build_via lead_rxs, trail_rxs, filename_pattern
    end

    module ProcerBuildingMethods___

      def __build_via lead_rxs, trail_rxs, filename_pattern

        md = FANTASTIC_HACK_RX___.match filename_pattern
        md or raise __say_fantastic_hack_failed filename_pattern
        @before = md[ :before ]
        @after = md[ :after ]
        __init_regexp_and_prototype_array_via lead_rxs, trail_rxs
        dup.freeze  # NOTE - a copy *WITHOUT* the singleton ancestor chain
      end

      FANTASTIC_HACK_RX___ = /\A(?<before>[^*]+)?\*(?<after>[^*]+)?\z/

      def __say_fantastic_hack_failed pat
        "for now, must be an ordinary looking glob expression, #{
          }like \"*_test.ext\": #{ pat.inspect }"
      end

      def __init_regexp_and_prototype_array_via lead_rxs, trail_rxs

        # when going in the one direction we use a regex to derive a stem from
        # an entry. for the other direction, given a stem we infer an entry
        # using a "prototype array". as long as it is useful to, we build these
        # two somewhat in parallel (because they are both derived from
        # derivatives of the argument filename patterns).

        rxs = '\A'

        if @before

          prototype = [ @before, nil ]
          insert_at = 1
          rxs.concat ::Regexp.escape @before

        else
          prototype = [ nil ]
          insert_at = 0
        end

        if lead_rxs
          rxs.concat lead_rxs
        end

        rxs.concat '(?<stem>[a-z]+(?:-[a-z]+)*(?:-[0-9])?)'

        if trail_rxs
          rxs.concat trail_rxs
        end

        if @after
          rxs.concat ::Regexp.escape @after
          prototype.push @after
        end

        rxs.concat '\z'

        @insert_at = insert_at
        @prototype_array = prototype.freeze
        @stemmer_regex = ::Regexp.new rxs, ::Regexp::IGNORECASE  # see #here

        NIL
      end
    end

    # ==

    class Procer___

      def to_stemmer_proc
        rx = @stemmer_regex
        -> entry do
          md = rx.match entry
          if ! md
            self._DID_NOT_MATCH_REGEX  # #todo
          end
          md[ :stem ].downcase  # :#here - uppercase OK in test not asset files
        end
      end

      def __to_unstemmer_proc

        before = @before
        after = @after

        if before
          if after
            -> stem do
              "#{ before }#{ stem }#{ after }"
            end
          else
            -> stem do
              "#{ before }#{ stem }"
            end
          end
        elsif after
          -> stem do
            "#{ stem }#{ after }"
          end
        else
          IDENTITY_
        end
      end
    end

    # ==
  end
end
