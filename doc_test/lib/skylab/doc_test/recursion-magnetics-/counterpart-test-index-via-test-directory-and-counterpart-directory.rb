module Skylab::DocTest

  class RecursionMagnetics_::CounterpartTestIndex_via_TestDirectory_and_CounterpartDirectory < Common_::Actor::Dyadic  # :[#028].

    # exactly [#005]

    # non-declared parameters: name_conventions
    # currently hard-coded: the_find_service

    class << self

      def of rsx
        call(
          rsx.test_directory,
          rsx.counterpart_directory,
          rsx.name_conventions,
          rsx.system_conduit,
          & rsx.listener_
        )
      end

      def call *a, &p
        new( *a, &p ).execute
      end

      alias_method :[], :call
      private :new
    end  # >>

    def initialize td, cd, nc, sc, & oes_p
      @counterpart_directory = cd
      @name_conventions = nc
      @system_conduit = sc
      @test_directory = td
      @the_find_service = Home_.lib_.system.find  # module
      @_on_event_selectively = oes_p  # not guaranteed
    end

    def execute
      __init_path_stream
      __build_index_via_path_stream
    end

    def __build_index_via_path_stream

      # we won't know if the find command fails until we try to get the
      # first path BUT NOTE just because we find no paths doesn't mean we
      # failed. (finding no test files is OK, we just need the directory
      # to be there). so we have to kick into the first path:

      st = remove_instance_variable :@__path_stream
      path = st.gets
      if @_find.ok
        __build_index_via path, st
      else
        path
      end
    end

    def __build_index_via path, st  # if path is false-ish, stream is empty

      @_localize = Home_.lib_.basic::Pathname::Localizer[ @test_directory ]
      @_paths = []
      @_tree = {}

      begin
        path || break
        __process_test_path path
        path = st.gets
        redo
      end while above

      remove_instance_variable :@_localize

      Home_::RecursionModels_::CounterpartTestIndex.via__(
        remove_instance_variable( :@_tree ),
        remove_instance_variable( :@_paths ),
        @counterpart_directory,
        @test_directory,
        @name_conventions,
      )
    end

    def __process_test_path path

      # break every path up into a stream of entries. every entry but the
      # last entry will correspond to a directory. the last entry will
      # correspond to a file. for each of these entries, determine its
      # "stem" as appropriate according to the name conventions and whether
      # the entry is for file or directory.
      #
      # using each of the stems that is produced in this manner, recurse
      # into a tree (whose nodes are added as necessary), indexing the whole
      # path in this way. this way each node will "know about" the possibly
      # many paths passing through it.

      path_id = @_paths.length
      @_paths[ path_id ] = path

      tip = @_tree

      scn = RecursionModels_::EntryScanner.via_path_ @_localize[ path ]
      entry = scn.scan_entry
      entry_ = scn.scan_entry
      begin

        if entry_
          dir_stem = @name_conventions.stemify_test_directory_entry entry

          node = tip.fetch dir_stem do
            x = Node__.new
            tip[ dir_stem ] = x
            x
          end

          node.__add_directory path_id, entry
          tip = node.hash

          entry = entry_
          entry_ = scn.scan_entry
          redo
        end

        file_stem = @name_conventions.stemify_test_file_entry entry

        node = tip.fetch file_stem do
          x = Node__.new
          tip[ file_stem ] = x
          x
        end

        node.__add_test_file path_id, entry
        break
      end while above
      NIL
    end

    def __init_path_stream

      # find all paths in the test directory that look like test files.
      # it's OK if none are found (however the directory must exist).

      _patterns = @name_conventions.test_filename_patterns

      @_find = @the_find_service.statuser_by( & @_on_event_selectively )

      _command = @the_find_service.new_with(
        :path, @test_directory,
        :filenames, _patterns,
        :freeform_query_infix_words, TYPE_FILE___,
        :when_command, IDENTITY_,
        & @_find
      )

      _st = _command.path_stream_via @system_conduit
      _st || self._SANITY  # even when noent
      @__path_stream = _st
      NIL
    end

    # ==

    class Node__

      def initialize
        @dir_entries = nil
        @file_entries = nil
      end

      def __add_directory path_id, entry
        ( @dir_entries ||= [] ).push [ path_id, entry ] ; nil
      end

      def has_directory_entry
        ! @dir_entries.nil?
      end

      def first_directory_entry
        @dir_entries.fetch(0).fetch(1)  # #will-change
      end

      def __add_test_file path_id, entry
        ( @file_entries ||= [] ).push [ path_id, entry ] ; nil
      end

      def has_test_file
        ! @file_entries.nil?
      end

      def first_test_file_entry
        @file_entries.fetch(0).fetch(1)  # #will-change
      end

      def hash
        @hash ||= {}
      end

      attr_reader(
        :dir_entries,
        :file_entries,
      )
    end

    # ==

    TYPE_FILE___ = %w( -type f )
  end
end
