module Skylab::Git

  class Models::Rebase

    # semi-one-off .. more like a session than a proper model

    def initialize
      @_line_box = Common_::Box.new
    end

    # ~ writing data into it:

    def read_from_rebase_file path
      __will_parse_for_rebase
      _read_from_file path
    end

    def read_from_log_file path
      __will_parse_for_log
      _read_from_file path
    end

    def will_add_manually
      _init_rx_for_log
    end

    def _read_from_file path

      @_identifier = path
      _io = ::File.open path, ::File::RDONLY
      __read_from_io _io
    end

    def __read_from_io io
      ok = true
      while line = io.gets
        line.chomp!
        ok = __add_line line
        ok or break
      end
      ok
    end

    def add_pick line
      _add_manually :pick, line
    end

    def add_fixup line
      _add_manually :fixup, line
    end

    def __will_parse_for_rebase

      @_is_rebase = true

      @_rx = /\A
        (?<verb> [fprs][a-z]* )
        (?<s0>[ ]+)
        (?<sha> #{ _sha_rxs } )
        (?<s1>[ ]+)
        (?<rest>.+)
      \z/x

      @_add_match = -> md do

        _accept Line__.new(
          md[ :verb ],
          md[ :s0 ],
          md[ :sha ],
          md[ :s1 ],
          md[ :rest ],
          md[ 0 ] )
      end

      NIL_
    end

    def __will_parse_for_log

      @_is_rebase = false

      _init_rx_for_log

      @_add_match = -> md do

        _accept Line__.new(
          NIL_,
          NIL_,
          md[ :sha ],
          md[ :s1 ],
          md[ :rest ],
          md[ 0 ] )
      end
      NIL_
    end

    def _add_manually sym, line

      md = @_rx.match line

      sp = Space_for___[ sym ]

      _accept Line__.new(
        sym.id2name,
        sp,
        md[ :sha ],
        md[ :s1 ],
        md[ :rest ],
        "#{ sym }#{ sp }#{ md[ :sha ] }#{ md[ :s1 ] }#{ md[ :rest ] }" )
    end

    def _init_rx_for_log

      @_rx = /\A
        (?<sha> #{ _sha_rxs } )
        (?<s1>[ ]+)
        (?<rest>.+)
      \z/x
      NIL_
    end

    def __add_line line

      md = @_rx.match line
      md or fail __say_no_match line
      @_add_match[ md ]
    end

    def _accept line

      @_line_box.add line.sha, line
      ACHIEVED_
    end

    def __say_no_match line
      "failed to match #{ @_rx } against #{ line.inspect }"
    end

    # ~ hacky mutation

    def reverse!
      @_line_box.a_.reverse!
      NIL_
    end

    # ~ doing something with it:

    def express_comparison_against_into other, io

      diff = -> ary, hash do
        rs = []
        ary.each do | x |
          hash.key? x or rs.push x
        end
        rs
      end

      display = -> msg, a do
        io.puts "#{ msg }: #{ a.inspect }"
      end

      bx = @_line_box
      bx_ = other._line_box

      a = bx.a_ ; h = bx.h_  # mine
      a_ = bx_.a_ ; h_ = bx.h_  # theirs

      distinct_to_me = diff[ a, h_ ]
      distinct_to_them = diff[ a_, h ]

      d = distinct_to_me.length
      d_ = distinct_to_them.length

      if d.zero? && d_.zero?
        io.puts "all #{ a.length } SHA's exist in both lists."
      else

        if d.nonzero?
          display[ "only in #{ @_identifier }", distinct_to_me ]
        end

        if d_.nonzero?
          display[ "only in #{ other._identifier }", distinct_to_them ]
        end
      end
      NIL_
    end

    attr_reader :_line_box, :_identifier
    protected :_line_box, :_identifier

    def to_item_stream
      @_line_box.to_value_stream
    end

    # ~ support

    def _sha_rxs
      SHORT_SHA_RXS___
    end

    Space_for___ = -> do

      # make it so that "pick  " and "fixup " line up, but all others meh

      cache_h = {}
      -> sym do
        cache_h.fetch sym do
          _d = case sym.id2name.length
            when 5 ; 1
            when 4 ; 2
            else   ; 1
          end
          cache_h[ sym ] = SPACE_ * _d
        end
      end
    end.call

    Line__ = ::Struct.new( :verb, :s0, :sha, :s1, :rest, :string )

    SHORT_SHA_RXS___ = '[0-9a-f]{7}'.freeze
  end
end
