module Skylab::TestSupport

  class Canon  # SimpleModel_

    # (experiment happening in [cm])

    # meet these requirements:
    #
    #   - provide the modeling of tests in a manner that can share those
    #     tests across a variety of clients with distinct setup.
    #
    #   - bundle these into a context-like tree structure that can recurse
    #     infinitely.
    #
    #   - ensure programmatically that every test in the suite is covered
    #     by every client (even into the future).
    #
    #   - expose the tests in such a way that each test has an "on screen"
    #     representation in individual test files as normal tests to (so
    #     tests can be wip'ed individualy, per client, in the obvious way).
    #
    # #open [#034] in the loopback we'll assess how r.s meets the above.

    class << self
      alias_method :define, :new
      undef_method :new
    end  # >>

    # -
      def initialize & p
        @_context_definition = RootContextDefinition___.define( & p )
        NIL
      end

      def begin_canon_pool
        @_context_definition.__to_two
      end
    # -

    # ==

    ControllerMan__ = ::Class.new

    class RootControllerMan___ < ControllerMan__

      def initialize defn

        recurse = -> bx do
          term_h = {} ; sub_h = nil
          bx.each_pair do |sym, node|
            if node.is_branch
              sub_h ||= {}
              _pool = recurse[ node.children_box ]
              sub_h[ sym ] = NonRootControllerMan__.new _pool, node
            else
              term_h[ sym ] = true
            end
          end
          Pool___.new term_h, sub_h
        end
        @pool = recurse[ defn.children_box ]
        super defn
      end

      def subcanon sym  # like #here-1

        cnt = @pool.sub_hash.fetch( sym )
        _cls = cnt.definition.description_pool_class
        _desc = _cls.new cnt
        [ _desc, cnt ]
      end

      def finish_canon

        missing = nil

        recurse = -> pool, context do
          if pool.term_hash.length.nonzero?
            pool.term_hash.keys.each do |k|
              ( missing ||= [] ).push [ * context, k ]
            end
          end
          h = pool.sub_hash
          if h
            h.each_pair do |k, cnt|
              recurse[ cnt.pool, [ * context, k ] ]
            end
          end
          NIL
        end

        recurse[ @pool, EMPTY_A_ ]
        if missing
          raise __say_missing missing
        end
      end

      def __say_missing missing_matrix
        a = []
        missing_matrix.each do |row|
          a.push row.inspect
        end
        "missing test(s): (#{ a.join ', ' })"
      end
    end

    # ==

    Pool___ = ::Struct.new :term_hash, :sub_hash

    # ==

    class NonRootControllerMan__ < ControllerMan__

      def initialize pool, defn
        @pool = pool
        super defn
      end

      attr_reader(
        :pool,
      )
    end

    # ==

    class ControllerMan__

      def initialize defn
        @definition = defn
      end

      def write_definitions_into tcc
        @definition.__write_definitions_into tcc
        NIL
      end

      def __tick_off_a_description_string_for k
        if ! @pool.term_hash.delete k
          raise __say k
        end
      end

      def __say k
        "no such item - '#{ k }'"
      end

      attr_reader(
        :definition,
      )
    end

    # ==

    ContextDefinition__ = ::Class.new

    class RootContextDefinition___ < ContextDefinition__

      def __to_two  # like #here-1

        cnt = RootControllerMan___.new self

        _desc = description_pool_class.new cnt

        [ _desc, cnt ]
      end
    end

    class NonRootContextDefinition___ < ContextDefinition__

      def is_branch
        true
      end
    end

    class ContextDefinition__  # SimpleModel_

      class << self
        alias_method :define, :new
        undef_method :new
      end  # >>

      def initialize
        @children_box = Common_::Box.new
        @_has_memoizations = false
        @pool_prototype_data = []
        @_receive_sequential_memoization = :__receive_first_sequential_memo
        @_writable_description_pool_class = :__WDPC_initially
        yield self
        @children_box.freeze
        @pool_prototype_data.freeze
      end

      # ~

      def add_context sym, & defn

        node = NonRootContextDefinition___.define do |o|
          o.__init_via_these_two @_my_writable_module, sym
          defn[ o ]
        end

        @children_box.add sym, node

        NIL
      end

      def __init_via_these_two mod, sym
        writable_module mod
        @name_symbol = sym
        NIL
      end

      def writable_module mod

        # to keep implementation simpler we create an instance methods
        # module before we need to know whether we will need it. this way,
        # any future methods we define at this level will inherit down to
        # any child branch nodes even if we define the methods after we
        # define the children.

        # ~
        _const = Next_const__[ mod, :CannonSandbox_ ]
        mod_ = ::Module.new
        mod.const_set _const, mod_
        @_my_writable_module = mod_
        # ~
        mod3 = ::Module.new
        mod_.const_set :InstanceMethods, mod3
        @_IM_module = mod3

        NIL
      end

      def add_test m, & p

        item = TestDefinition___.new p, m

        @children_box.add m, item

        @_IM_module.send :define_method, item.name_symbol do
          # hi.
          instance_exec( & item.proc )
        end

        __description_pool_class.send :define_method, m do

          @_controller.__tick_off_a_description_string_for m
          item.__name_as_description_string_for_test
        end

        NIL
      end

      def __description_pool_class
        send @_writable_description_pool_class
      end

      def __WDPC_initially
        mod = @_my_writable_module
        _const = Next_const__[ mod, :GeneratedDescPool_ ]
        x = ::Class.new DescriptionPool___
        mod.const_set _const, x
        @__description_pool_class = x
        @__read_DPC = :_read_DPC_normally
        @_writable_description_pool_class = :_read_DPC_normally
        send @_writable_description_pool_class
      end

      def description_pool_class
        send @__read_DPC
      end

      def _read_DPC_normally
        @__description_pool_class
      end

      def free_define & p
        @_IM_module.module_exec( & p ) ; nil
      end

      # ~ seq mem

      def add_sequential_memoization sym, & p
        send @_receive_sequential_memoization, p, sym
      end

      def __receive_first_sequential_memo p, sym
        @_has_memoizations = true
        @_memoizations_box = Common_::Box.new
        @_receive_sequential_memoization = :__receive_sequential_memo
        send @_receive_sequential_memoization, p, sym
        NIL
      end

      def __receive_sequential_memo p, sym
        @_memoizations_box.add sym, p
        NIL
      end

      # -- write into client

      def __write_definitions_into tcc

        if @_has_memoizations
          __write_memoizations_into tcc
        end

        tcc.include @_IM_module

        NIL
      end

      def __write_memoizations_into tcc

        st = @_memoizations_box.to_pair_stream

        node = st.gets
        -> node_ do
          Define_dangerous_memoizer.call tcc, node.name_symbol do
            # hi.
            instance_exec( & node_.value_x )
          end
        end.call node

        begin
          x = st.gets
          x || break
          prev_node_symbol = node.name_symbol
          node = x
          ( -> prev_sym, node_ do
            Define_dangerous_memoizer.call tcc, node_.name_symbol do

              # every non-first memoized item is passed the
              # previous (in code space) memoized item.

              _x = send prev_sym
              instance_exec _x, & node_.value_x
            end
          end )[ prev_node_symbol, node ]
          redo
        end while above
        NIL
      end

      # -- simple read

      attr_reader(
        :children_box,
        :name_symbol,
      )
    end

    # ==

    class DescriptionPool___

      def initialize con
        @_controller = con
      end
    end

    # ==

    fmt = '%02d'  # OK if over 99

    Next_const__ = -> mod, head do
      d = 0
      begin
        const = :"#{ head }#{ fmt % d }"
        mod.const_defined? const, false or break
        d += 1
        redo
      end while above
      const
    end

    # ==

    class TestDefinition___

      def initialize p, m
        @name_symbol = m
        @proc = p
      end

      def __name_as_description_string_for_test
        @___desc_string ||= @name_symbol.id2name.gsub( UNDERSCORE_, SPACE_ ).freeze
      end

      attr_reader(
        :name_symbol,
        :proc,
      )

      def is_branch
        false
      end
    end

    # ==
  end
end
