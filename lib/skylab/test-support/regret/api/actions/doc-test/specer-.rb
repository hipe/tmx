class Skylab::TestSupport::Regret::API::Actions::DocTest

  class Specer_

    # the specer accepts a sequence of Comment_::Block-s one by one and for
    # for each one it parses it line-by-line, chunking it into runs of 'code'
    # and 'other'. it always holds on to the last 0 to 2 contiguous lines of
    # 'other' so that they can be associated with 'code' runs, for possible
    # use in their example and description strings.
    #
    # when it encounters a blank comment line, it associates it with the
    # preceding run of 'code' or 'other' as appropriate.
    #
    # for now, this is where the logic is seated the you need 4 (four)
    # blank lines (more is ok) to look like a 'code' line; and for now this
    # is hard-coded but etc.
    #
    # (a second pass of parsing happens in the child nodes from this file.)
    #

    MetaHell::FUN::Fields_[ :client, self, :method, :absorb, :field_i_a,
      %i( core_basename load_file load_module
        outstream path snitch templo_name ) ]

    def initialize *a
      absorb( *a )
      @base_mod = nil
      @block_a = [ ]
    end

    def set_template_options option_a
      @templo_opt_a = option_a
      true
    end

    # this is the first line of a comment block, to become a context desc:
    # this second line of the comment block you will not see.
    # this third line will become the desc for this example:
    #
    #     # this comment gets included in the output because it is indented
    #     # with four or more spaces, and its containing "SNIPPET" has the
    #     # magic equals predicate symbol in it somewhere.
    #
    #     THIS_FILE_ = TestSupport::This_File[ __FILE__ ]
    #     THIS_FILE_.contains( 'this comment gets included' )       # => true
    #
    #     THIS_FILE_.contains( '"this is the first line of a co' )  # => true
    #     THIS_FILE_.contains( "you will #{ } not see" )            # => false
    #     THIS_FILE_.contains( '"this is the first line of a co' )  # => true
    #
    # note that we now strip trailing colons on these lines:
    #
    #     THIS_FILE_.contains( 'iling colons on these lines"' ) # => true

    # `accept( cblock )`

    class State_
      def initialize rx, a
        @rx, @a = rx, a
      end
      attr_reader :rx, :a
    end

    class State_::Machine_
      class << self ; alias_method :orig_new, :new ; end
      def self.new h
        ::Class.new( self ).class_exec do
          class << self ; alias_method :new, :orig_new end
          const_set :H_, h
          self
        end
      end

      def initialize
        @h = self.class::H_
        @state_i = :start
        @history_a = [ ]
      end

      def move cl  # comment line. a custom class instance
        state = @h.fetch @state_i
        nxt_i, md = state.a.reduce nil do |_, i|
          d = @h.fetch( i ).rx.match cl.line, cl.col
          d and break i, d
        end
        nxt_i or fail verbose_errmsg( cl )
        change_state_to nxt_i
        Transition_[ nxt_i, md, cl ]
      end

      def unmove
        @history_a.length.zero? and fail "sanity - history buffer is empty."
        @state_i = @history_a.pop
        nil
      end

    private

      def change_state_to nxt_i
        @history_a[ 0 ] = @state_i
        @state_i = nxt_i
        nil
      end

      def verbose_errmsg cl
        "sanity - parse failure - expecting (#{
          }#{ @h.fetch( @state_i ).a * ' or ' }) - #{
          }#{ cl.line[ cl.col .. -1 ].inspect }"
      end
    end

    Transition_ = ::Struct.new :i, :md, :comment_line

    -> do

      o = State_.method :new

      Machine_ = State_::Machine_.new(
        start: o[ nil, [ :nbcode, :blank, :other ] ],
        nbcode: o[ /\G[ ][ ][ ][ ](?<content>.+)/,
                       [ :bcode, :nbcode, :other ] ],
        bcode: o[ /\G[ ]{0,4}(?<content>[ ]*)$/,
                       [ :bcode, :nbcode, :other ] ],
        blank: o[ /\G[[:space:]]*$/, [ :nbcode, :blank, :other ] ],
        other: o[ /\G(?:|(?<content>.+))$/, [ :nbcode, :blank, :other ]]
      )
      # note in regexen above, use of '$' and not '\z' is intentional

      define_method :accept do |cblock|
        machine = Machine_.new
        sblock = Specer_::Block.new @snitch
        comment_lines = Basic::List::Scanner[ cblock.a ]
        while cl = comment_lines.gets
          sblock.accept machine.move( cl )
        end
        sblock.flush
        if sblock.is_not_empty
          _accept sblock
        end
        nil
      end
    end.call

    def flush
      -> do
        t = resolve_templo or break t
        r = t.set_options( @templo_opt_a ) or break r
        if @path
          t.render_to @outstream
        end
      end.call
    end

  private  # all narrative-esque

    def _accept sblock
      @block_a << sblock
    end

    def resolve_templo
      -> do
        if @path
          r = resolve_base_mod or break r
          @tail_path = resolve_tail_path or break
          c_a = resolve_loaded_anchorized_const_a or break c_a
        end
        tmod = MetaHell::Boxxy::Fuzzy_const_get[ DocTest::Templos_, @templo_name ]
        tmod.begin @snitch, @base_mod, c_a, @block_a
      end.call
    end

    def resolve_base_mod
      @base_mod = ::Skylab  # #etc
      if @load_file
        path = ::File.expand_path @load_file
        require path  # or load it..
      end
      true
    end

    def resolve_loaded_anchorized_const_a

      # the `const_a` looks something like [ :Foo, "Bar", :Baz ] (it is
      # indiscriminate of strings vs. symbols), to stand for the value
      # represented by the constant ::Foo::Bar::Baz (or perhaps Foo::BAR::BaZ,
      # etc). at this point, that value hasn't necessarity been 'loaded' yet..

      -> do
        c_a = infer_unloaded_anchorized_const_a_from_tail_path or break
        make_any_name_corrections c_a
        const = reduce_const_array_down_to_some_value c_a
        const or break const
        if const.respond_to? :name
          r = const.name[ @base_mod.name.length + 2 .. -1 ].
            split( SEP_ ).map( & :intern )
        else
          @snitch.notice do
            "had const that was not a class or module #{
              }(~\"#{ c_a.fetch( -1  ) }\"). just taking best guess at its #{
              }name. we could do better.."
          end
          r = c_a
        end
        r
      end.call
    end

    SEP_ = '::'.freeze

    def infer_unloaded_anchorized_const_a_from_tail_path
      Regret::FUN::Const_inferer__[
        :tail_path, @tail_path, :notice_p, -> s { @snitch.notice { s } } ]
    end

    def make_any_name_corrections c_a
      @load_module and make_any_name_corrections_via_load_module c_a
    end

    def make_any_name_corrections_via_load_module c_a
      c_a_ = get_another_correct_anchorized_name_via_the_load_module
      c_a_.length.times do |idx|
        ths = c_a[ idx ].intern
        otr = c_a_[ idx ].intern
        if ths != otr
          c_a[ idx ] = otr
        end
      end
      nil
    end

    def get_another_correct_anchorized_name_via_the_load_module
      c_a = @load_module.split SEP_
      top = ::Object.const_get c_a.shift
      name, _ = MetaHell::Boxxy::Resolve_name_and_value[ :from_module, top, :path_x, c_a ]
      c_a[ -1 ] = name  # any correction to last part only
      c_a
    end

    def reduce_const_array_down_to_some_value c_a
      c_a.reduce @base_mod do |m, c|
        name, value = MetaHell::Boxxy::Resolve_name_and_value[
          :from_module, m, :path_x, c,
            :core_basename, @core_basename,
              :else_p, -> err do
                say_no_such_constant m, c, err
              end ]
        name or break false
        value
      end
    end

    def say_no_such_constant m, c, err
      a = m.constants ; sac = say_any_constants a
      @snitch.notice do
        "'#{ m }' does not have #{ err.name } loaded (or loadable?) as #{
          }#{ s a, :one_of }its #{ a.length } constant#{ s }#{ sac }"
      end
      @snitch.notice do
        "try passing a second #{ par :load_file } argument that loads it."
      end
      false
    end

    def say_any_constants a
      if A_REASONABLE_LENGTH_FOR_A_FEW_ITEMS_ >= a.length && a.length.nonzero?
        " (#{ a * ' ' })"
      end
    end
    #
    A_REASONABLE_LENGTH_FOR_A_FEW_ITEMS_ = 3


    def resolve_tail_path  # local, normalized path
      -> do
        pn = ::Pathname.new ::File.expand_path( @path )
        pns = pn.to_s ; bms = @base_mod.dir_pathname.to_s
        idx = pns.index bms
        if ! idx || idx.nonzero?
          p = @path ; bm = @base_module
          @snitch.notice { "expecting to find pathname #{
            }#{ p } under base module `dir_pathnname` - #{
            }#{ bm.dir_pathname }" }
          break
        end
        pns[ bms.length + 1 .. -1 ]
      end.call
    end
    private :resolve_tail_path

  end

  class Specer_::Event_

    def self.[] msg
      new -> { msg }
    end

    def initialize mp
      @message_proc = mp
    end

    attr_reader :message_proc
  end
end
