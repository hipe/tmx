module Skylab::System

  module Doubles::Stubbed_System  # see [#028]

    class << self
      def readable_writable_via_OGDL_path path
        # #todo not covered AT ALL - used in [gi] task
        Here_::Readable_Writable_Based_.new path
      end
    end  # >>

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
            # all four components in a definition (because #note-1) then
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
          Home_.lib_.basic::String.line_stream x
        else
          Common_::Stream.the_empty_stream
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
        @value = Stubbed_Thread_Value___.new es
      end

      attr_reader(
        :value
      )

      def exit
        self
      end
    end

    # ==

    Stubbed_Thread_Value___ = ::Struct.new :exitstatus

    # ==

    Here_ = self
  end
end
# #history: nabbed simplified rewrite from [gv]
