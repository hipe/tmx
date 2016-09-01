module Skylab::DocTest

  class RecursionModels_::CounterpartTestIndex

    class << self
      alias_method :begin_via__, :new
      undef_method :new
    end  # >>

    def initialize tr, pa, cd, td, nc
      @__counterpart_directory = cd
      @__name_conventions = nc
      @__paths = pa
      @__test_directory = td
      @__trees = tr
    end

    def finish__

      cd = remove_instance_variable :@__counterpart_directory
      len = cd.length
      @_localize_r = len .. -1
      @_sanity_r = 0 ... len
      @_sanity_s = cd

      @_lookup_prototype = Lookup___.new(
        remove_instance_variable( :@__trees ),
        remove_instance_variable( :@__paths ),
        remove_instance_variable( :@__test_directory ),
        remove_instance_variable( :@__name_conventions ),
      )
      self
    end

    def details_via_asset_path path
      _check = path[ @_sanity_r ]
      @_sanity_s == _check || self._SANITY
      _local_path = path[ @_localize_r ]
      @_lookup_prototype.__details_via_local_asset_path _local_path
    end

    # ==

    class Lookup___

      def initialize tr, pa, td, nc
        @name_conventions = nc
        @_paths = p
        @_trees = tr
        @__test_directory = td
        freeze
      end

      def __details_via_local_asset_path local_path
        otr = dup
        otr.local_path = local_path
        otr.execute
      end

    protected

      attr_writer(
        :local_path,
      )

      def execute

        is_real = true ; these = []

        tip = @_trees

        scn  = RecursionModels_::EntryScanner.via_path_ @local_path
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
