module Skylab::System

  module Doubles::Stubbed_System

    class Readable_Writable_Based_  # :[#038].

      def initialize path

        @_lookup = :__first_lookup
        @path = path
      end

      def popen3 * args

        block_given? and self._NOT_SUPPORTED
        cmd = send @_lookup, args
        if cmd
          cmd.to_four
        else
          raise ::KeyError, "no such mock command #{ args.inspect } in #{ @path.inspect }"
        end
      end

      def __first_lookup args

        @_st = to_command_stream
        @_cache = {}
        @_lookup = :_lookup_while_reading
        _lookup_while_reading args
      end

      def to_command_stream

        _lines = ::File.open @path, ::File::RDONLY
        Popen3_Result.unmarshalling_stream _lines, :OGDL  # etc
      end

      def _lookup_while_reading args

        begin
          cmd = @_st.gets
          if cmd

            @_cache[ cmd.args_ ] = cmd

            if cmd.args_ == args
              x = cmd
              break
            else
              redo
            end
          else
            @lookup = method :___lookup_when_fully_loaded
            x = @lookup[ args ]  # meh
            break
          end
        end while nil
        x
      end

      def ___lookup_when_fully_loaded args

        @_cache[ args ]
      end

      # ==

      class Popen3_Result

        class << self

          def unmarshalling_stream x, sym

            Build_unmarshalling_stream___[ x, sym, self ]
          end
        end  # >>

        def initialize
          @argv = nil
          @chdir = nil
          @exitstatus = nil
          @stdout_string = nil
          @stderr_string = nil
        end

        # -- write to instance

        def receive_args a
          @args = a
          h = ::Hash.try_convert a.last
          if h
            KEYS___ == h.keys or raise ::ArgumentError
            @chdir = h.fetch :chdir
            @argv = a[ 0 .. -2 ]
          else
            @argv = a
          end
          a
        end

        KEYS___ = [ :chdir ]

        attr_writer(
          :exitstatus,
          :stdout_string,
          :stderr_string,
        )

        # -- read

        def to_four
          [ nil, __to_mock_stdout, __to_mock_stderr, __to_mock_thread ]
        end

        def __to_mock_stdout
          if @stdout_string
            Home_.lib_.basic::String.line_stream @stdout_string
          end
        end

        def __to_mock_stderr
          if @stderr_string
            Home_.lib_.basic::String.line_stream @stderr_string
          end
        end

        def __to_mock_thread
          if @exitstatus
            Stubbed_Thread.new @exitstatus
          end
        end

        def args_
          @__args__ ||= if @chdir
            [ * @argv, chdir: @chdir ]
          else
            @argv
          end
        end

        def write_to io

          oa = Here_::Output_Adapters_::OGDL_esque.new io, :command

          if @argv
            oa.write @argv, :argv, :string_array
          end

          if @chdir
            oa.write @chdir, :chdir, :string
          end

          if @stdout_string
            oa.write @stdout_string, :stdout_string, :string
          end

          if @stderr_string
            oa.write @stderr_string, :stderr_string, :string
          end

          if @exitstatus
            oa.write @exitstatus, :exitstatus, :number
          end

          oa.flush
          NIL_
        end

        # ~ begin

        def read_from_tree tree  # result must be self on success

          ok = true
          tree.children.each do | node |
            ok = send :"__unmarshal__#{ node.string }__from_node", node
            ok or break
          end
          ok and self
        end

        def __unmarshal__argv__from_node node

          @argv = node.children.map do | nd |
            nd.string
          end
          ACHIEVED_
        end

        def __unmarshal__chdir__from_node nd

          @chdir = _insist_on_one_string nd
        end

        def __unmarshal__exitstatus__from_node nd

          s = _insist_on_one_string nd
          s and begin
            if D_RX___ =~ s
              @exitstatus = s.to_i
              ACHIEVED_
            else
              fail "is not an exitstatus: #{ s.inspect }"
            end
          end
        end
        D_RX___ = /\A[0-9]+\z/

        def __unmarshal__stdout_string__from_node nd

          @stdout_string = _insist_on_one_string nd
        end

        def __unmarshal__stderr_string__from_node nd

          @stderr_string = _insist_on_one_string nd
        end

        def _insist_on_one_string nd

          a = nd.children
          a.fetch( a.length - 1 << 1 ).string
        end

        attr_reader(
          :argv,
          :chdir,
          :exitstatus,
          :stdout_string,
          :stderr_string,
        )
      end

      Build_unmarshalling_stream___ = -> x, sym, model_class do

        st = Here_::Input_Adapters_.const_get( sym ).tree_stream_from_lines( x )

        Common_.stream do

          tree = st.gets
          tree and begin

            model_class.new.read_from_tree tree
          end
        end
      end

      # ==
    end
  end
end
