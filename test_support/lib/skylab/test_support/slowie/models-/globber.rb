module Skylab::TestSupport

  class Slowie

    class Models_::Globber

      # the term "glob" as a noun must only ever refer to the string with a
      # '*' in it. it must not be used to refer to any other related
      # noun-ish (like the resultant list of files, or like a performer that
      # produces such a list). the term "glob" *may* be used as a verb if
      # it's unambiguously referring to the act of producing a list/stream
      # of files from such a glob string.
      #
      # a "globber", then, is a performer that performs such a "glob"
      # operation. an intrinsic part of its (ostensibly immutable) identity
      # is the "glob" string. this "globber" then acts like a proc that
      # takes no arguments - its main method results in a stream of path
      # strings.
      #
      # it can be called multiple times; each time producing such a stream
      # that reflects the the state of the filesystem at that time of the
      # call.
      #
      # :#slowie-spot-1

      class << self
        alias_method :prototype_by, :new
        undef_method :new
      end  # >>

      def initialize

        yield self

        # (the below was `__build_find_test_files_prototype`)

        @__prototype_for_the_find_command = Home_.lib_.system.find.new_with(
          :freeform_query_infix_words, FIND_FILES_ONLY___,
          :filename, @test_file_name_pattern,
          & @listener
        )

        freeze
      end

      attr_writer(
        :listener,
        :test_file_name_pattern,
        :system_conduit,
        :xx_example_globber_option_xx,
      )

      # -- as prototype that produces an instance:

      def globber_via_directory dir
        __dup.__init dir
      end

      alias_method :__dup, :dup
      undef_method :dup

      def __init dir

        _find_proto = remove_instance_variable :@__prototype_for_the_find_command

        @_find_command = _find_proto.new_with :path, dir

        freeze
      end

      def to_count

        # (TL;DR: early optimization used system IPC instead of one ruby line)
        #
        # for thousands of test files, we consider it needlessly wasteful
        # to ask ruby to allocate memory for one string for each test file
        # path when all we are doing is aggregating a count of the items
        # in the stream (without needing ever to know the actual path of
        # each test file).
        #
        # since `find` (resonably) doesn't have any such counting aggretation
        # function of its own, what we would do is pipe the output of the
        # `find` command into `wc -l` (wordcount, lines). in this process
        # chain, the same sort of "waste" that is described above still
        # occurs, but is handled more efficiently by the operating system's
        # inter-process communication facility.
        #
        # to be sure, to get this "weedy" is an early optimization and
        # certainly hinders the portability/robustity of this, but it is
        # an excercize so we are comfortable with our answer to this
        # "what if" scenario if not for this than for other use cases
        # where scaling is an issue. if needed we could fall back on our
        # single line in-ruby solution (`stream.flush_to_count`).

        read_find_err, write_find_err = ::IO.pipe  # we wanted string IO but not allowed.

        write_wc, read_wc_out, read_wc_err, wc_wait = ::Open3.popen3(  * WORDCOUNT_COMMAND___ )
          # ::Open3 is @system_conduit, but we are being clear we cannot mock this

        _command = @_find_command.args

        _pid = ::Kernel.spawn( * _command, out: write_wc, err: write_find_err )

        # -- find stuff

        ::Process.wait _pid
        _find_wait_value = $?  # eew
        _find_wait_value.exitstatus.zero? || fail

        write_find_err.close
        read_find_err.gets && fail

        # -- wc stuff

        write_wc.close
        read_wc_err.gets && fail

        payload_line = read_wc_out.gets
        payload_line.chop!
        read_wc_out.gets && fail

        wc_wait.value.exitstatus.zero? || fail

        md = WORDCOUNT_LINE_RX___.match payload_line
        md || fail
        md[ :count_number ].to_i
      end

      def to_path_stream
        @_find_command.path_stream_via @system_conduit
      end

      def directory
        a = @_find_command.path_array
        a.fetch a.length - 1 << 1  # (assert that the array length is exactly 1)
      end
    end

    # ==

    FIND_FILES_ONLY___ = %w(-type f).freeze
    WORDCOUNT_COMMAND___ = %w( wc -l )
    WORDCOUNT_LINE_RX___ = /\A[ ]*(?<count_number>\d+)\z/

    # ==
  end
end
# #history: abstracted from what is at the time the "magnetics" node
