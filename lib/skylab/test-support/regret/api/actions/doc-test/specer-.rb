class Skylab::TestSupport::Regret::API::Actions::DocTest

  class Specer_

    def initialize tmpl, out, err, path, vtuple
      @tmpl_i, @out, @err, @path, @vtuple =
        tmpl, out, err, path, vtuple

      @a = [ ]
      @notice = -> x do
        @err.puts "(notice: #{ nil.instance_exec( & x.message_function )})"
        nil
      end
      nil
    end

    # `accept`
    -> do

      o = ::Struct.new :rx, :a

      state_h = {
        start: o[ nil, [ :nbcode, :blank, :other ] ],
        nbcode: o[ /\G[ ][ ][ ][ ](?<content>.+)/,
                       [ :bcode, :nbcode, :other ] ],
        bcode: o[ /\G[ ]{0,4}(?<content>[ ]*)$/,
                       [ :bcode, :nbcode, :other ] ],
        blank: o[ /\G[[:space:]]*$/, [ :nbcode, :blank, :other ] ],
        other: o[ /\G(?:|(?<content>.+))$/, [ :nbcode, :blank, :other ]]
      }
      # note in regexen above, use of '$' and not '\z' is intentional

      verbose_error = nil
      define_method :accept do |cblock|

        state = state_h.fetch( state_i = :start )
        sblock = Specer_::Block.new @notice
        cblock.a.each do |cl|
          nxt_i, md = state.a.reduce nil do |_, i|
            d = state_h.fetch( i ).rx.match cl.line, cl.col
            d and break i, d
          end
          nxt_i or fail verbose_error[ cl, state_i ]
          sblock.accept nxt_i, md
          state = state_h.fetch( state_i =  nxt_i )
        end
        sblock.flush
        if sblock.is_not_empty
          _accept sblock
        end
        nil
      end

      verbose_error = -> cl, s_i do
        "sanity - parse failure - expecting (#{
          }#{ state_h.fetch( s_i ).a * ' or ' }) - #{
          }#{ cl.line[ cl.col .. -1 ].inspect }"
      end
    end.call

    def flush
      begin
        t = resolve_templo or break
        t.render_to @out
      end while nil
      nil
    end

  private  # all narrative-esque

    def _accept sblock
      @a << sblock
    end

    def resolve_templo
      -> do
        @base_mod = ::Skylab
        @tail = resolve_tail or break
        c_a = resolve_c_a or break
        tconst = MetaHell::Boxxy::FUN.
          fuzzy_const_get[ DocTest::Templos_, @tmpl_i ]
        tconst.begin @base_mod, c_a, @a
      end.call
    end

    def resolve_c_a  # cork
      -> do
        c_a = resolve_raw_c_a or break
        const = c_a.reduce @base_mod do |m, c|
          MetaHell::Boxxy::FUN.fuzzy_const_get[ m, c ]
        end
        const.name[ @base_mod.name.length + 2 .. -1 ].split( '::' ).
          map( & :intern )
      end.call
    end

    -> do

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
        pn = ::Pathname.new( ::File.expand_path @path )
        pns = pn.to_s ; bms = @base_mod.dir_pathname.to_s
        idx = pns.index bms
        if ! idx || idx.nonzero?
          @notice[ Event_[ "expecting to find pathame #{ @path } under #{
          } base module `dir_pathname` - #{ @base_mod.dir_pathname }" ] ]
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
      @message_function = mf
    end

    attr_reader :message_function
  end
end
