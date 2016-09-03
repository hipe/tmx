module Skylab::DocTest::TestSupport

  module Recursion_Stubs

    class << self
      def [] tcc
        tcc.send(
          :define_singleton_method,
          :given_unit_of_work_stream_for_filesystem__,
          Given_etc___,
        )
        tcc.include InstanceMethods___ ; nil
      end
    end  # >>

    # -

      Given_etc___ = -> & fs_p do

        yes = true ; x = nil

        define_method :_the_unit_of_work_tuples do
          if yes
            yes = false
            x = self.__build_unit_of_work_tuples_given fs_p
          end
          x
        end
      end
    # -

    module InstanceMethods___

      def find_line_with_ needle, path

        _fs = _the_unit_of_work_tuple.the_filesystem_post_execution[]

        io = _fs.open path, ::File::RDONLY

        begin
          line = io.gets
          line.include? needle and break
          redo
        end while above
        io.close
        line
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

      def __build_unit_of_work_tuples_given fs_p

        fs = fs_p[]

        _asset_st = fs._read_only_filesystem_._to_path_stream_

        event_log = Common_.test_support::Expect_Event::EventLog.for self

        _oes_p = event_log.handle_event_selectively

        _DO_NOT_LIST = false

        _mock_index = _new_stub_index

        st = against_ _mock_index, _asset_st, _DO_NOT_LIST, fs,  & _oes_p

        # -- unwound:

        st.map_by do |uow|

          tuple = UnitOfWorkTuple___.new

          tuple.the_filesystem_post_execution = -> do
            tuple.the_lazily_evaluated_emissions[]
            fs
          end

          tuple.the_lazily_evaluated_emissions = Lazy_.call do  # eek [#029] #note-3

            d = event_log.current_emission_count

            _hi = uow.express_into_under :_not_used, :_expag_not_used
            _hi == :_not_used || fail

            d_ = event_log.current_emission_count

            num = d_ - d
            num.zero? && fail

            event_log.shave num
          end

          tuple
        end.to_a
      end
    end

    # ==

    UnitOfWorkTuple___ = ::Struct.new(
      :the_filesystem_post_execution,
      :the_lazily_evaluated_emissions,
    )

    # ==

    class StubIndex

      # stubs a `CounterpartTestIndex` which for each asset path it receives
      # requests for, results in a stubbed details structure that has a test
      # file path that is derived in the below simple, hard-coded manner.
      #
      # for *every other* request that is made of a subject instance, the
      # resulting details structure will report the test file as having
      # existed (the first one "no", the second one "yes" etc).
      #
      # this internal boolean state is memoized into the subject so you must
      # contstruct a new subject instance for each test so that the results
      # are consistent per test.

      def initialize
        @_is_real = false
      end

      def details_via_asset_path ast
        b = @_is_real
        @_is_real = ! b
        _path = "/stub/testdir/#{ ::File.basename( ast ) }_speg.kode"
        LookupResult___.new b, _path
      end
    end

    LookupResult___ = ::Struct.new(
      :is_real,
      :to_path,
    )

    class MockFilesystem  # there are others. this one is bespoke

      def initialize ro
        @_files_written = {}
        @_read_only_filesystem_ = ro
      end

      def open path, mode

        written_s = @_files_written[ path ]

        if written_s

          __open_a_written_file written_s, mode

        elsif ::File::RDONLY == mode

          @_read_only_filesystem_.open path, mode

        else
          __expect_open_for_write_only_etc path, mode
        end
      end

      def __open_a_written_file big_s, mode

        ::File::RDONLY == mode || fail

        MockReadOnlyFilehandle___.new big_s
      end

      def __expect_open_for_write_only_etc path, mode

        # (more unwound than it needs to be for now, and that's OK.)

        _do_creat = ( ::File::CREAT & mode ).nonzero?
        _is_excl = ( ::File::EXCL & mode ).nonzero?
        _is_wronly = ( ::File::WRONLY & mode ).nonzero?

        ( _do_creat && _is_excl && _is_wronly ) || fail

        mutable_string = ""
        @_files_written[ path ] = mutable_string
        MockWriteOnlyFilehandle___.new mutable_string
      end

      attr_reader(
        :_read_only_filesystem_,
      )
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

    This_one_read_only_filesystem = Lazy_.call do

      fs = StubbedFilesystem___.new

      fs._add_file '/stub/asset/file-21-participating-create' do

        <<-HERE.unindent
          some code

          # look:
          #     My_lib_[ 1 + 1 ]  # => 3
          #

          more code

          # last line.
        HERE
      end

      fs._add_file '/stub/asset-file/file-22-' do
        <<-HERE.unindent
          xx yy
        HERE
      end

      fs
    end

    class StubbedFilesystem___

      def initialize
        @_a = []
        @_h = {}
      end

      def _add_file path, & y_p
        @_a.push path
        @_h[ path ] = y_p ; nil
      end

      def open path, mode
        ::File::RDONLY == mode || fail
        _p = @_h.fetch path
        _big_string = _p[]
        _st = Home_.lib_.basic::String.line_stream _big_string
        _st
      end

      def __has path
        @_h.key? path
      end

      def _to_path_stream_
        Common_::Stream.via_nonsparse_array @_a
      end
    end
  end
end
