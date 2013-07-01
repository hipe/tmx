class Skylab::TestSupport::Regret::API::Actions::DocTest

  class Specer_

    def initialize snitch, out, tmpl_i, path
      @snitch, @out, @tmpl_i, @path = snitch, out, tmpl_i, path
      @block_a = [ ]
      nil
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
        t.render_to @out
      end.call
    end

  private  # all narrative-esque

    def _accept sblock
      @block_a << sblock
    end

    def resolve_templo
      -> do
        @base_mod = ::Skylab
        @tail = resolve_tail or break
        c_a = resolve_c_a or break
        tconst = MetaHell::Boxxy::FUN.
          fuzzy_const_get[ DocTest::Templos_, @tmpl_i ]
        tconst.begin @snitch, @base_mod, c_a, @block_a
      end.call
    end

    def resolve_c_a
      -> do
        c_a = resolve_raw_c_a or break
        const = c_a.reduce @base_mod do |m, c|
          MetaHell::Boxxy::FUN.fuzzy_const_get[ m, c ]
        end
        if const.respond_to? :name
          const.name[ @base_mod.name.length + 2 .. -1 ].split( '::' ).
            map( & :intern )
        else
          @snitch.say :notice, -> do
            "had const that was not a class or module #{
              }(~\"#{ c_a.fetch( -1  ) }\"). just taking best guess at its #{
              }name. we could do better.."
          end
          c_a
        end
      end.call
    end

    -> do  # `resolve_raw_c_a`

      rx = %r{[^/]+(?=/)}

      file_rx = /\A (?<noext> [-_a-z0-9]+ ) #{
        }#{ ::Regexp.escape ::Skylab::Autoloader::EXTNAME } \z/x

      constantify = Face::Services::Headless::Name::FUN.constantify
      define_method :resolve_raw_c_a do
        -> do
          scn = Face::Services::Headless::Services::StringScanner.new @tail
          c_a = [ ]
          while tok = scn.scan( rx )
            scn.pos = scn.pos + 1
            c_a << constantify[ tok ].intern
          end
          md = file_rx.match scn.rest
          if ! md
            @notice[ Event_[ "sanity - expecting ruby file - #{ scn.rest }"]]
            break
          end
          c_a << constantify[ md[:noext] ].intern
        end.call
      end
      private :resolve_raw_c_a
    end.call

    def resolve_tail  # local, normalized path
      -> do
        pn = ::Pathname.new ::File.expand_path( @path )
        pns = pn.to_s ; bms = @base_mod.dir_pathname.to_s
        idx = pns.index bms
        if ! idx || idx.nonzero?
          @snitch.event :notice, Event[ "expecting to find pathname #{
            }#{ @path } under base module `dir_pathnname` - #{
            }#{ @base_module.dir_pathname }" ]
          break
        end
        pns[ bms.length + 1 .. -1 ]
      end.call
    end
    private :resolve_tail

  end

  class Specer_::Event_

    def self.[] msg
      new -> { msg }
    end

    def initialize mf
      @message_proc = mf
    end

    attr_reader :message_proc
  end
end
