module Skylab::System

  module Doubles::Stubbed_System  # see [#028]

    # ->
      class << self

        def enhance_client_class test_context
          test_context.include Instance_Methods___
          NIL_
        end

        def recording_session byte_downstream, & edit_p
          Here_::Recording_Session__.new( byte_downstream, & edit_p ).execute
        end
      end  # >>
      # <-

    # -- this section is a simplified rewrite

    class Inline_Pool

      def initialize
        @_pool = []
      end

      def _add_entry_by_ & matcher_p
        @_pool.push matcher_p ; nil
      end

      def popen3 * cmd_s_a

        d = nil ; p = nil

        @_pool.length.times do |d_|
          p = @_pool.fetch( d_ ).call cmd_s_a
          if p
            d = d_
            break
          end
        end

        if d
          @_pool[ d, 1 ] = EMPTY_A_

          if @_pool.length.zero?
            remove_instance_variable :@_pool  # for sanity
          end

          Stub_Sys_Result__.new( & p ).produce
        else
          fail ___say_not_found cmd_s_a
        end
      end

      def ___say_not_found cmd_s_a
        "not found - #{ cmd_s_a.inspect }"
      end
    end

    class Inline_Static

      def initialize
        @_h = {}
      end

      def _add_entry_ chdir=nil, cmd_s_a, & three_p

        _bx = @_h.fetch chdir do
          @_h[ chdir ] = Callback_::Box.new
        end

        _bx.add cmd_s_a, Stub_Sys_Result__.new( & three_p )

        NIL_
      end

      def popen3 * cmd_s_a

        block_given? and raise ::ArgumentError  # no

        if cmd_s_a.last.respond_to? :each_pair
          _key = cmd_s_a.pop.fetch :chdir
        end

        _bx = @_h.fetch _key

        _rslt = _bx.fetch cmd_s_a

        _rslt.produce
      end
    end

    class Stub_Sys_Result__

      def initialize & three_p
        @__three_p = three_p
      end

      def produce

        sout_a = [] ; serr_a = []

        d = @__three_p[ :_nothing_, sout_a, serr_a ]

        _sout_st = Stubbed_IO_for_Read__.via_nonsparse_array sout_a
        _serr_st = Stubbed_IO_for_Read__.via_nonsparse_array serr_a
        _thread = Stubbed_Thread.new d

        [ :_dont_, _sout_st, _serr_st, _thread ]
      end
    end

    class Stubbed_IO_for_Read__ < Callback_::Stream

      def read
        s = gets
        if s
          buffer = s.dup
          begin
            s = gets
            s or break
            buffer << s
            redo
          end while nil
          buffer
        end
      end
    end

    # --
      # ->

      module Instance_Methods___

        def stubbed_system_conduit

          h = cache_hash_for_stubbed_system
          h.fetch manifest_path_for_stubbed_system do | path |
            h[ path ] = Conduit.new path
          end
        end
      end

      class Conduit

        def initialize path
          @is_opened = false
          @is_fully_loaded = false
          @lookup = method :__first_lookup
          @path = path
          @st = nil
        end

        def popen3 * args
          block_given? and raise ::ArgumentError
          cmd = @lookup[ args ]
          if cmd
            cmd.to_four
          else
            raise ::KeyError, "no such mock command #{ args.inspect } in #{ @path.inspect }"
          end
        end

        def __first_lookup args

          @st = to_command_stream
          @cache = {}
          @lookup = method :__lookup_while_reading
          @lookup[ args ]
        end

        def to_command_stream
          _lines = ::File.open @path, ::File::RDONLY
          Models_::Command.unmarshalling_stream _lines, :OGDL  # etc
        end

        def __lookup_while_reading args

          begin
            cmd = @st.gets
            if cmd

              @cache[ cmd.args_ ] = cmd

              if cmd.args_ == args
                x = cmd
                break
              else
                redo
              end
            else
              @lookup = method :__lookup_when_fully_loaded
              x = @lookup[ args ]  # meh
              break
            end
          end while nil
          x
        end

        def __lookup_when_fully_loaded args

          @cache[ args ]
        end
      end

      Models_ = ::Module.new

      class Models_::Command

        class << self

          def unmarshalling_stream x, sym

            Build_unmarshalling_stream___[ x, sym, self ]
          end
        end  # >>

        def initialize
          @chdir = nil
          @exitstatus = nil
          @stdout_string = nil
          @stderr_string = nil
          @argv = nil
        end

        attr_accessor :exitstatus, :stdout_string, :stderr_string

        attr_reader :argv, :chdir

        def args_
          @__args__ ||= if @chdir
            [ * @argv, chdir: @chdir ]
          else
            @argv
          end
        end

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

        # ~ end
      end

      Build_unmarshalling_stream___ = -> x, sym, model_class do

        st = Here_::Input_Adapters_.const_get( sym ).tree_stream_from_lines( x )

        Callback_.stream do

          tree = st.gets
          tree and begin

            model_class.new.read_from_tree tree
          end
        end
      end

      # ~ begin re-open for subject

      class Models_::Command

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
      end

      class Stubbed_Thread

        def initialize es
          @value = Stubbed_Thread_Value___.new es
        end

        attr_reader(
          :value
        )

        def exit
          self
        end
      end

      Stubbed_Thread_Value___ = ::Struct.new :exitstatus

      # ~ end

      Here_ = self
    # -
  end
end
# #history: nabbed simplified rewrite from [gv]
