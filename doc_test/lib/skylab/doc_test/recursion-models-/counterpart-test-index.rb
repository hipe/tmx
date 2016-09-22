module Skylab::DocTest

  class RecursionModels_::CounterpartTestIndex

    class << self
      alias_method :via__, :new
      undef_method :new
    end  # >>

    def initialize tr, pa, cd, td, nc
      @_lookup_prototype = Lookup___.new cd, tr, pa, td, nc
    end

    def details_via_asset_path path
      @_lookup_prototype.__details_via_asset_path path
    end

    # ==

    class Lookup___

      def initialize cd, tr, pa, td, nc

        __init_crazy_regex cd
        @name_conventions = nc
        @_paths = p
        @_trees = tr
        @__test_directory = td
        freeze
      end

      def __init_crazy_regex cd
        # parsing the asset paths would be simple were it not for one
        # edge case we want to support..

        dn = ::File.dirname cd
        bn = ::File.basename cd
        esc = ::Regexp.method :escape
        sep = esc[ ::File::SEPARATOR ]

        # all asset paths must be under the *parent* directory of the
        # "counterpart directory" (undefined if not). BUT we are making
        # an allowance of one special file that can exist outside of it
        # for now (and this all may broaden or tighten later..)

        @_rx = /\A
          #{ esc[ dn ] } #{ sep }  # all asset paths must be in this
          (?:                      # directory, and then EITHER:

           #{ esc[ bn ] } #{ sep } (?<typical_path> .+ )
           |
           (?<atypical_path> .* )  # anything else (for now)
          )
        \z/x

        @__counterpart_directory_basename = bn
      end

      def __details_via_asset_path asset_path
        otr = dup
        otr.asset_path = asset_path
        otr.execute
      end

    protected

      attr_writer(
        :asset_path,
      )

      def execute
        md = @_rx.match @asset_path
        # ..
        s = md[ :typical_path ]
        if s
          _for_localized_asset_path s
        else
          __when_atypical_path md[ :atypical_path ]
        end
      end

      def __when_atypical_path s

        # the operation is based around straightforward isomorphisms between
        # asset and test files. here we deal with those parts that are not
        # straightforward.

        exp = "#{ @__counterpart_directory_basename }#{ @name_conventions.asset_extname }"
        if exp == s
          _pretend = "core#{ @name_conventions.asset_extname }"
          _for_localized_asset_path _pretend
        else
          self._COVER_ME_not_corefile
        end
      end

      def _for_localized_asset_path local_path

        is_real = true ; these = []

        tip = @_trees

        scn  = RecursionModels_::EntryScanner.via_path_ local_path
        entry = scn.scan_entry
        entry_ = scn.scan_entry
        begin

          if entry_  # then `entry` is a directory

            dir_stem = @name_conventions.stemify_asset_directory_entry entry
            node = tip && tip[ dir_stem ]

            if node
              if node.has_directory_entry
                these.push _real( node.first_directory_entry )
                tip = node.hash
              else
                _entry = node._TODO_infer_test_directory_entry_for_stem  # #todo
                these.push _imagined _entry
                tip = nil ; is_real = false
              end
            else
              _entry = @name_conventions.test_directory_entry_for_stem dir_stem
              these.push _imagined _entry
              tip = nil ; is_real = false
            end

            # --

            entry = entry_
            entry_ = scn.scan_entry
            redo
          end

          # then `entry` is a file

          file_stem = @name_conventions.stemify_asset_file_entry entry
          node = tip && tip[ file_stem ]
          if node
            if node.has_test_file
              these.push _real node.first_test_file_entry
            else
              ::Kernel._K_should_be_easy_but_lets_find_it
              is_real = false
            end
          else
            _entry = @name_conventions.test_file_entry_for_stem file_stem
            these.push _imagined _entry
            is_real = false
          end
          break
        end while above

        LookupResults___.new is_real, these, @__test_directory
      end

      def _imagined entry
        QualifiedEntry__.new :imagined, entry
      end

      def _real entry
        QualifiedEntry__.new :real, entry
      end

      # ==

      class LookupResults___

        def initialize is_real, x, td
          @is_real = is_real
          @qualified_entries = x
          @test_directory = td
        end

        def to_path
          _s_a = @qualified_entries.map( & :entry )
          ::File.join @test_directory, * _s_a
        end

        def localize_test_path path
          ( @___p ||= ___etc ).call path
        end

        def ___etc
          Home_.lib_.basic::Pathname::Localizer[ ::File.dirname( @test_directory ) ]
        end

        attr_reader(
          :is_real,
          :qualified_entries,
          :test_directory,
        )
      end

      class QualifiedEntry__

        def initialize sym, entry
          @category_symbol = sym
          @entry = entry
        end

        attr_reader(
          :category_symbol,
          :entry,
        )
      end
    end
  end
end
