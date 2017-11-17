module Skylab::DocTest::TestSupport

  module Recursion_Stubs

    class << self
      def [] tcc
        tcc.send(
          :define_singleton_method,
          :given_these_system_resources,
          Given_etc___,
        )
        tcc.include InstanceMethods___ ; nil
      end
    end  # >>

    # ==== Section 1. module & instance methods

    # -

      Given_etc___ = -> & dsl_p do

        yes = true ; x = nil

        define_method :_the_unit_of_work_tuples do
          if yes
            yes = false
            x = self.__build_unit_of_work_tuples_given dsl_p
          end
          x
        end
      end
    # -

    module InstanceMethods___

      def find_line_with_ needle, path

        io = open_possibly_mocked_file_readonly_ path

        begin
          line = io.gets
          line.include? needle and break
          redo
        end while above
        io.close
        line
      end

      def open_possibly_mocked_file_readonly_ path

        _fs = _the_unit_of_work_tuple.the_filesystem_post_execution[]
        _fs.open path, ::File::RDONLY
      end

      def the_emission_
        em_a = the_emissions_
        1 == em_a.length || fail
        em_a.fetch 0
      end

      def the_emissions_
        _the_unit_of_work_tuple.the_lazily_evaluated_emissions[]
      end

      def _the_unit_of_work_tuple
        _the_unit_of_work_tuples.fetch the_unit_of_work_index_
      end

      def __build_unit_of_work_tuples_given dsl_p

        rsx = __resources_via_DSL_proc dsl_p
        fs = rsx.filesystem
        _VCS_rdr = rsx.VCS_reader

        _asset_st = __asset_stream_via_filesystem fs

        event_log = Common_.test_support::Want_Emission::Log.for self

        _p = event_log.handle_event_selectively

        _mock_index = the_stub_index_

        _DO_NOT_LIST = false

        _st = against_ _mock_index, _asset_st, _DO_NOT_LIST, _VCS_rdr, fs, & _p

        __tuple_array_via_stream _st, event_log, fs
      end

      def __asset_stream_via_filesystem fs

        need = '/stub/assetz/'
        r = 0 ... need.length

        fs._read_only_filesystem.to_path_stream.reduce_by do |path|
          need == path[ r ]
        end
      end

      def __tuple_array_via_stream st, event_log, fs  # eek [#029] #note-3

        st.map_by do |uow|

          tuple = UnitOfWorkTuple___.new

          tuple.the_filesystem_post_execution = -> do
            tuple.the_lazily_evaluated_emissions[]
            fs
          end

          tuple.the_lazily_evaluated_emissions = Lazy_.call do

            d = event_log.current_emission_count

            execute_unit_of_work_ uow

            d_ = event_log.current_emission_count

            num = d_ - d
            num.zero? && fail

            event_log.shave num
          end

          tuple
        end.to_a
      end

      def __resources_via_DSL_proc dsl_p
        @these = Resources___.new
        instance_exec( & dsl_p )
        remove_instance_variable :@these
      end

      def filesystem_by & fs_p
        @these.filesystem = fs_p[]
        NIL
      end

      def _VCS_reader_by & rdr_p
        @these.VCS_reader = rdr_p[]
        NIL
      end
    end

    # ==

    Resources___ = ::Struct.new(
      :VCS_reader,
      :filesystem,
    )

    UnitOfWorkTuple___ = ::Struct.new(
      :the_filesystem_post_execution,
      :the_lazily_evaluated_emissions,
    )

    # ==== Section 2. this

    class StubIndex

      # the production node that this is stubbing (the "counterpart test
      # index") does some relatively heavy work to try and find corresponding
      # test files for asset files (involving name conventions, etc).
      #
      # here we do no such heavy lifting - it is simple key-value store (hash)
      # where for every asset path that will be queried there *must* be a
      # boolean on record indicating whether or not there is a corresponding
      # test file. when producing results when the test file supposedly
      # does exist, the path for the test is derived in the below simple,
      # hard-coded manner.

      def initialize
        @_test_file_exist_yes_no_hash = {}
      end

      def have_no_test_file_for stem
        @_test_file_exist_yes_no_hash[ stem ] = false
      end

      def have_test_file_for stem
        @_test_file_exist_yes_no_hash[ stem ] = true
      end

      def details_via_asset_path asset_path

        bn = ::File.basename asset_path
        en = ::File.extname bn
        stem = if en.length.zero?
          bn
        else
          bn[ 0 ... - en.length ]
        end

        _b = @_test_file_exist_yes_no_hash.fetch stem

        test_path = "/stub/testz/#{ stem }_speg#{ en }"

        LookupResult___.new _b, test_path
      end
    end

    LookupResult___ = ::Struct.new(
      :is_real,
      :to_path,
    ) do
      def localize_test_path x
        x
      end
    end

    # ==== Section 3. mock VCS reader controller

    class VCS_Reader

      def initialize
        @_h = {}
      end

      def status_via_path path
        @_h.fetch path
      end

      def this_is_a_file_that_is_versioned_but_has_changes path
        o = VersionedStatus__.new
        o.has_unversioned_changes = true
        @_h[ path ] = o
      end

      def this_is_a_file_that_is_versioned_and_has_no_changes path
        @_h[ path ] = VersionedStatus__.new ; nil
      end
    end

    class VersionedStatus__
      def is_versioned
        true
      end
      attr_accessor(
        :has_unversioned_changes,
      )
    end

    # ==== Section 4. mock filesystem (instances & support)

    This_one_read_only_filesystem = Lazy_.call do

      fs = ReadOnlyFilesystem.new

      # ~ "file 21"

      fs.add_file '/stub/assetz/file-21-participating-create.kerd' do

        <<-HERE.unindent
          some code

          # look:
          #     My_lib_[ 1 + 1 ]  # => 3
          #

          more code

          # last line.
        HERE
      end

      # ~ "file 22"

      fs.add_file '/stub/assetz/file-22-participating-but-changes.kerd' do

        <<-HERE.unindent
          # xx:
          #     1  # => 2
        HERE
      end

      fs.add_file '/stub/testz/file-22-participating-but-changes_speg.kerd' do

        <<-HERE.unindent
          this old test content might not be versioned..
        HERE
      end

      # ~ "file 23"

      fs.add_file '/stub/assetz/file-23-participating-clobberin-time.kerd' do

        <<-HERE.unindent
          # xx:
          #     3  # => 4
        HERE
      end

      fs.add_file '/stub/testz/file-23-participating-clobberin-time_speg.kerd' do

        <<-HERE.unindent
          this old test content *is* versioned
        HERE
      end

      fs
    end

    # ==

    class MockFilesystem  # there are others. this one is bespoke

      def initialize ro
        @_files_written = {}
        @_read_only_filesystem = ro
      end

      def touch_excl path
        did = nil
        @_files_written.fetch path do
          did = true
          @_files_written[ path ] = EMPTY_S_
        end
        did || fail
      end

      def open path, mode
        dup.extend( OpenSupport___ ).__execute_against path, mode
      end

      attr_reader(
        :_read_only_filesystem,
      )
    end

    module OpenSupport___

      def __execute_against path, mode
        @mode = mode
        @path = path

        @_is_wronly = ( ::File::WRONLY & mode ).nonzero?
        @_is_rdonly = ! @_is_wronly  # rdonly is 0 so you can't bitmask it
        @_do_append = ( ::File::APPEND & mode ).nonzero?  # 8
        @_do_create = ( ::File::CREAT & mode ).nonzero?  # 512
        @_do_truncate = ( ::File::TRUNC & mode ).nonzero?  # 1024
        @_is_exclusive = ( ::File::EXCL & mode ).nonzero?  # 2048

        written_s = @_files_written[ path ]

        if written_s
          __open_a_written_file written_s
        else
          __modeoriffic
        end
      end

      def __open_a_written_file big_s

        @mode.zero? || fail  # when we open a file rdonly, expect NO other flags

        MockReadOnlyFilehandle___.new big_s
      end

      def __modeoriffic

        if @_is_rdonly
          @mode.zero? || fail  # expect NO other flags
          _open_read_only
        else
          __want_some_sensical_kind_of_write
        end
      end

      def __want_some_sensical_kind_of_write

        @_do_append && fail  # we never append (these aren't logfiles)

        @_is_wronly || fail  # we never do RDWR, only one or the other

        if @_do_create

          @_is_exclusive || fail  # when creating, we always assert that file does not exist

          @_do_truncate && fail  # when creating, it makes no sense to truncate

        else

          # a write-only without the create flag means it is presupposing
          # the file exists. (hopefully with reason).

          @_is_exclusive && fail  # if you said "write only" and don't create,
            # that's saying you expect to open an existing file for writing.
            # putting this flag, then, wouldn't make sense.

          @_do_truncate || fail  # we should (gulp) always truncate files like these
        end

        mutable_string = ""
        @_files_written[ @path ] = mutable_string
        MockWriteOnlyFilehandle___.new mutable_string
      end

      def _open_read_only
        @_read_only_filesystem.open @path, @mode
      end
    end

    # ==

    class MockWriteOnlyFilehandle___

      def initialize str
        @_buffer = str
      end

      def write s
        len = s.length
        @_buffer << s
        len
      end

      def close
        remove_instance_variable :@_buffer
        NIL
      end
    end

    # ==

    class MockReadOnlyFilehandle___

      # (we would just use StringIO as-is but we want to assert read-only)

      def initialize big_s
        require 'stringio'
        @_io = ::StringIO.new big_s
      end

      def read
        @_io.read
      end

      def gets
        @_io.gets
      end

      def close
        @_io.close
      end
    end

    # ==

    class ReadOnlyFilesystem

      def initialize
        @_a = []
        @_h = {}
      end

      def add_file path, & y_p
        @_a.push path
        @_h[ path ] = y_p ; nil
      end

      def open path, mode
        ::File::RDONLY == mode || fail
        _p = @_h.fetch path
        _big_string = _p[]
        Line_stream_via_string_[ _big_string ]
      end

      def to_path_stream
        Stream_[ @_a ]
      end
    end
  end
end
