module Skylab::System

  module Doubles::Stubbed_System  # see [#028]

    class << self
      def readable_writable_via_OGDL_path path
        # #todo not covered AT ALL - used in [gi] task
        Here_::Readable_Writable_Based_.new path
      end
    end  # >>

    class MockedThree  # :[#041.4]

      # (yes this is the seventh.)

      # we must keep up with the times - now we don't like usen popen3

      class << self
        def hash_via_definition ** hh
          new( ** hh ).execute
        end
        private :new
      end  # >>

      def initialize(
        given_command: nil,
        do_this: nil
      )
        @__given_command = given_command
        @__do_this = do_this
      end

      def execute

        _mocked_piper = MockedPiper___.new self
        _mocked_spawner = MockedSpawner___.new self
        _mocked_waiter = MockedWaiter___.new self

        o = BuildExpectationScanner___.new

        # ~( NOTE we must track closely with assumption [#041.D.2]

        o.then :_pipe_, :__pipe_for_stdout
        o.then :_pipe_, :__pipe_for_stderr
        o.then :_spawn_, :__spawn

        # (reads from the stdout and stderr pipe happen off script #here2)

        o.then :_close_write_stdout_
        o.then :_close_write_stderr_

        o.then :_wait_, :__wait

        # ~)

        @_expectation_scanner = o.__flush_to_scanner

        {
          piper: _mocked_piper,
          spawner: _mocked_spawner,
          waiter: _mocked_waiter,
        }
      end  # >>

      # -
        #
        # these correspond to real methods that get called
        #

        def __pipe_
          _step :_pipe_
        end

        def __spawn_ args, opts
          _step :_spawn_, args, opts
        end

        def __wait_ d
          _step :_wait_, d
        end

        #
        #
        #

        def __pipe_for_stdout

          _reader = MockedReader__.new :__gets_stdout, :__close_stdout, self
          _writer = MockedWriter__.new :__close_write_stdout, self

          [ _reader, _writer ]
        end

        def __pipe_for_stderr

          _reader = MockedReader__.new :__gets_stderr, :__close_stderr, self
          _writer = MockedWriter__.new :__close_write_stderr, self

          [ _reader, _writer ]
        end

        def __spawn cmd_s_a, opt_h

          # our job is to parse the incoming actual command for whatever
          # it is the expectation is trying to parse out from it

          h = __parse_cha_cha cmd_s_a
          def h.[] k  # #experiment
            fetch k  # hi.
          end

          sout_s_a = []
          serr_s_a = []
          _es = remove_instance_variable( :@__do_this )[ sout_s_a, serr_s_a, h ]

          @_sout_and_serr = SoutAndSerr___.new(
            Stream_[ sout_s_a ],
            Stream_[ serr_s_a ],
          )

          @__mocked_exitstatus = _es

          :fake_PID_SY
        end

        def __parse_cha_cha cmd_s_a

          md_box = Common_::Box.new

          exp_scn = Scanner_[ remove_instance_variable( :@__given_command ) ]
          act_scn = Scanner_[ cmd_s_a ]

          offset = 0
          begin
            exp_x = exp_scn.gets_one
            act_x = act_scn.gets_one

            if exp_x.respond_to? :ascii_only?
              if exp_x != act_x
                fail %[needed "#{ exp_x }", had "#{ act_x }" (at offset #{ offset })]  # #cover-me
              end
            else
              md = exp_x.match act_x
              if ! md
                fail %[needed to match #{ exp_x.inspect }, had "#{ act_x }" (at offset #{ offset })]  # #cover-me
              end
              md.named_captures.each_pair do |key_s, s|
                md_box.add key_s.intern, s
              end
            end

            if exp_scn.no_unparsed_exists
              if act_scn.no_unparsed_exists
                break
              end
              fail %[unexpected extra actual doo-hah "#{ act_scn.head_as_is.inspect }"]  # #cover-me
            elsif act_scn.no_unparsed_exists
              fail %[command ended early. expected #{ exp_scn.head_as_is }]  # #cover-me
            end
            offset += 1
            redo
          end while above

          md_box.h_
        end

        def __close_write_stdout
          _step :_close_write_stdout_
        end

        def __close_write_stderr
          _step :_close_write_stderr_
        end

        def __gets_stdout
          _gets :_stdout_
        end

        def __gets_stderr
          _gets :_stderr_
        end

        def __close_stdout
          _close :_stdout_
        end

        def __close_stderr
          _close :_stderr_
        end

        def _gets sym

          # (:#here2: reads to stdout and stderr pipe happen off-script)

          s = @_sout_and_serr[ sym ].gets
          # above fails per #here2
          if s
            s
          else
            @_sout_and_serr[ sym ] = CLOSED_NATURALLY___ ; nil
          end
        end

        def _close sym

          # (these happen off-script. we somewhat ensure state transitions)

          @_sout_and_serr[ sym ]._hello_active
          @_sout_and_serr[ sym ] = CLOSED_MANALLY___ ; nil
        end

        def __wait pid

          # because ultimately we're reading a global variable (per platform)
          # and A) we cannot just write to it and B) if we could it would
          # be super scary, we set up some ridiculous wrapping in our lib
          # code so that we can hack things here without the lib code needing
          # to have excessive knowledge of our mocking.

          :fake_PID_SY == pid || oops
          _es = remove_instance_variable :@__mocked_exitstatus

          yikes = Home_::Command::LAST_PROCESS_STATUS

          stv = StubbedThreadValue__.new _es
          once = -> do
            once = nil ; stv
          end

          restore_me_YIKES = yikes.read
          yikes.read = -> do
            yikes.read = restore_me_YIKES
            once[]
          end

          NIL
        end

        #
        # we corral all actual calls through here
        #

        def _step m_ref, * args
          if @_expectation_scanner.no_unparsed_exists
            # #cover-me
            fail "had no more expected method calls, encountered: `#{ m_ref }`"
          else
            exp = @_expectation_scanner.gets_one
            if exp.method_reference == m_ref
              m = exp.my_method_name
              if m
                send m, * args
              end
            else
              fail "expected `#{ exp.method_reference }` had `#{ m_ref }`"
            end
          end
        end
      # -

      # ===

      class MockedPiper___
        def initialize _
          @_ = _
        end
        def pipe
          @_.__pipe_
        end
      end

      class MockedSpawner___
        def initialize _
          @_ = _
        end
        def spawn * args, opts
          @_.__spawn_ args, opts
        end
      end

      class MockedReader__

        def initialize m, m2, _
          @__gets_method = m
          @__close_method = m2
          @_ = _
        end

        def gets
          @_.send @__gets_method
        end

        def close
          @_.send @__close_method
        end

        def _hello_active
          NOTHING_
        end
      end

      class MockedWriter__
        def initialize close_m, _
          @__close_method = close_m
          @_ = _
        end
        def close
          @_.send remove_instance_variable :@__close_method
        end
      end

      class MockedWaiter___
        def initialize _
          @_ = _
        end
        def wait d
          @_.__wait_ d
        end
      end

      class BuildExpectationScanner___
        def initialize
          @_a = []
        end
        def then m, m_=nil
          @_a.push ExpectedCall___.new( m, m_ ) ; nil
        end
        def __flush_to_scanner
          Scanner_[ remove_instance_variable :@_a ]
        end
      end

      # ===

      class ExpectedCall___
        def initialize m_sym, m
          @method_reference = m_sym
          @my_method_name = m
          freeze
        end
        attr_reader(
          :method_reference,
          :my_method_name,
        )
      end

      module CLOSED_NATURALLY___ ; class << self
        def gets
          fail  # ..
        end
        def _hello_active
          NOTHING_
        end
      end ; end
      module CLOSED_MANALLY___ ; class << self
        def gets
          fail
        end
      end ; end

      SoutAndSerr___ = ::Struct.new(
        :_stdout_,
        :_stderr_,
      )
    end

    class MockSystem  # the sixth system double - fully documented at [#035].

      class << self

        def begin
          DSL___.new
        end

        alias_method :__new, :new
        undef_method :new
      end  # >>

      # ---- Section 1. Definition

      class DSL___

        def initialize
          @_current_category = nil
        end

        def command_category & p
          x = @_current_category
          if x
            @_categories.push x.finish
          else
            @_categories = []
          end
          @_current_category = Category___.new p ; nil
        end

        def times d, & p
          @_current_category.receive_times d, p ; nil
        end

        def command_key & p
          @_current_category.receive_command_key p ; nil
        end

        def on x, & p
          @_current_category.receive_case x, p
        end

        def finish
          @_categories.push remove_instance_variable( :@_current_category ).finish
          Here_.__new remove_instance_variable( :@_categories ).freeze
        end
      end

      # ==

      class Category___

        def initialize p
          @_is_times = false
          @_match_proc = p
          @_receive_case = :__CANNOT_receive_case_before_command_key
          @_receive_command_key = :__receive_first_commnd_key
          @_receive_times =  :__receive_first_times
        end

        def receive_times d, p
          send @_receive_times, d, p
        end

        def __receive_first_times d, p
          @_is_times = true
          @_receive_case = :__CANNOT_receive_case_after_times
          @_receive_command_key = :__CANNOT_receive_command_after_times
          @_receive_times = :__CANNOT_receive_times_after_times
          @__times = d
          @__times_proc = p
          NIL
        end

        def receive_command_key p
          send @_receive_command_key, p
        end

        def __receive_first_commnd_key p
          @_case_hash = {}
          @__command_key_proc = p
          @_receive_case = :__do_receive_case
          @_receive_command_key = :__CANNOT_have_multiple_command_keys
          @_receive_times = :__CANNOT_receive_times_after_etc
          NIL
        end

        def receive_case x, p
          send @_receive_case, Case___.new( x, p )
        end

        def __do_receive_case kase
          h = @_case_hash ; had = true ; k = kase.key
          h.fetch k do
            had = false
            h[ k ] = kase ; nil
          end
          had and self._COLLISION
        end

        def finish
          remove_instance_variable :@_receive_case
          remove_instance_variable :@_receive_command_key
          freeze
        end

        def match_argv argv
          @_match_proc[ argv ]
        end
      end

      # ==

      class Case___

        def initialize key_x, p
          @key = key_x
          @proc = p
        end

        attr_reader(
          :key,
          :proc,
        )
      end

      # ---- Section 2. Lookup

      # ==

      def initialize frozen_category_array
        @_lookup_prototype = Lookup___.new frozen_category_array
      end

      def popen3 * args
        @_lookup_prototype.__lookup args
      end

      # ==

      class Lookup___

        def initialize frozen_category_array
          @_active_pools = []
          @_frozen_category_array = frozen_category_array
          @_not_yet_active_category_indexes = frozen_category_array.length.times.to_a
          @_spent_pools = []
        end

        def __lookup args
          dup.___do_lookup args
        end

        def ___do_lookup args
          @argv = args
          if __find_an_active_pool
            _use_active_pool
          elsif __find_unused_category
            __use_unused_category
          else
            __when_not_found
          end
        end

        def __find_unused_category

          cat_a = @_frozen_category_array
          d_a = @_not_yet_active_category_indexes
          dd = nil

          cat_st = Common_::Stream.via_times d_a.length do |dd_|
            dd = dd_
            d_a.fetch dd_
          end.map_by do |d_|
            cat_a.fetch d_
          end

          begin
            cat = cat_st.gets
            cat || break
            cat.match_argv @argv and break
            redo
          end while above

          if cat
            @__index_index = dd
            @__unused_category = cat
            ACHIEVED_
          else
            a = @argv[ 0, 3 ]
            a.push '[..]'
            fail "no category found to match #{ a.inspect }"
          end
        end

        def __find_an_active_pool

          d = @_active_pools.index do |ap_|
            ap_.match_lookup self
          end
          if d
            @_active_pool = @_active_pools.fetch d
            @_active_pool_index = d
            ACHIEVED_
          else
            UNABLE_
          end
        end

        def __use_unused_category

          cat = remove_instance_variable :@__unused_category
          _dd = remove_instance_variable :@__index_index

          @_not_yet_active_category_indexes[ _dd, 1 ] = EMPTY_A_
          pool = cat.create_new_pool
          if pool.is_empty
            fail pool.say_is_empty_during self
          else
            d = @_active_pools.length
            @_active_pools[ d ] = pool
            @_active_pool = pool
            @_active_pool_index = d
            _use_active_pool
          end
        end

        def _use_active_pool

          raw_tuple = @_active_pool.destructive_lookup self

          if @_active_pool.is_empty
            @_active_pools[ @_active_pool_index, 1 ] = EMPTY_A_
            @_spent_pools.push @_active_pool
          end

          __final_tuple_via_raw_tuple raw_tuple
        end

        def __final_tuple_via_raw_tuple a

          case a.length

          when 1 .. 3
            exitstatus, sout_x, serr_x = a
            exitstatus.zero?  # catch definition errors early

            _wait = Stubbed_Thread.new exitstatus
            [ :_never_use_stdin_, Stream__[ sout_x ], Stream__[ serr_x ], _wait ]

          when 4
            # cheating a bit here - since we ourselves never need to specify
            # all four components in a definition (because [#here.B]) then
            # assume that when there *are* four components, it's #pass-thru
            a

          else
            self._RAW_TUPLE_IS_OF_INVALID_LENGTH
          end
        end

        attr_reader(
          :argv,
        )
      end

      # ==

      class Category___  # #re-open

        def create_new_pool
          if @_is_times
            TimesBasedPool___.new @__times, @__times_proc, @_match_proc
          else
            DiminishingPool___.new @_case_hash, @__command_key_proc, @_match_proc
          end
        end
      end

      class TimesBasedPool___

        def initialize d, tp, mp
          case d <=> 0
          when 1
            # normal -
            @is_empty = false
            @__match_proc = mp
            @_times_allowed = d
            @_times_proc = tp
            @_times_remaining = d
          when 0  # kind of weird -
            @is_empty = true
          else
            self._NOT_IMPLEMENTED_infinite_times_could_be_done
          end
        end

        def match_lookup lookup
          @__match_proc[ lookup.argv ]
        end

        def destructive_lookup lookup
          @_times_remaining -= 1
          if @_times_remaining.zero?
            @is_empty = true
            p = remove_instance_variable :@_times_proc
          else
            p = @_times_proc
          end
          p[ lookup.argv ]
        end

        attr_reader(
          :is_empty,
        )
      end

      class DiminishingPool___

        def initialize h, ckp, mp
          if h.length.zero?
            @is_empty = true
          else
            @_command_key_proc = ckp
            @_diminishing_hash = h.dup
            @is_empty = false
            @__match_proc = mp
          end
        end

        def match_lookup lookup
          @__match_proc[ lookup.argv ]
        end

        def destructive_lookup lookup
          _k = @_command_key_proc[ lookup.argv ]
          kase = @_diminishing_hash.delete _k
          if kase
            if @_diminishing_hash.length.zero?
              @is_empty = true
            end
            _ = kase.proc.call
          else
            ::Kernel._B
          end
        end

        attr_reader(
          :is_empty,
        )
      end

      # ==

      Stream__ = -> x do
        if x
          Basic_[]::String::LineStream_via_String[ x ]
        else
          Common_::THE_EMPTY_STREAM
        end
      end

      Here_ = self
    end

    class << self

      def enhance_client_class tcc

        if tcc.method_defined? :stubbed_system_conduit
          self._WHERE
        end

        tcc.send :define_method, :stubbed_system_conduit do

          cache = cache_hash_for_stubbed_system

          cache.fetch manifest_path_for_stubbed_system do |path|
            x = Here_::Readable_Writable_Based_.new path
            cache[ path ] = x
            x
          end
        end ;
      end  # >>

      def recording_session byte_downstream, & edit_p
        Here_::Recording_Session__.new( byte_downstream, & edit_p ).execute
      end
    end  # >>

    # ==

    class Popen3_Result_via_Proc_

      def initialize & three_p
        @__three_p = three_p
      end

      def produce

        sout_a = [] ; serr_a = []

        d = @__three_p[ :_nothing_, sout_a, serr_a ]

        _sout_st = Stubbed_IO_for_Read_.via_nonsparse_array sout_a
        _serr_st = Stubbed_IO_for_Read_.via_nonsparse_array serr_a
        _thread = Stubbed_Thread.new d

        [ :_dont_, _sout_st, _serr_st, _thread ]
      end
    end

    class Stubbed_IO_for_Read_ < Common_::Stream

      class << self
        def the_empty_stream_
          @___the_empty_stream ||= by() { NOTHING_ }
        end
      end  # >>

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

    # ==

    class Stubbed_Thread

      def initialize es
        @value = StubbedThreadValue__.new es
      end

      attr_reader(
        :value
      )

      def exit
        self
      end
    end

    # ==

    StubbedThreadValue__ = ::Struct.new(
      :exitstatus,
    )

    # ==

    Here_ = self
    Home_::Doubles::StubbedSystem = self  # ..

  end
end
# #history-A.2: spike the seventh thing
# #history: nabbed simplified rewrite from [gv]
