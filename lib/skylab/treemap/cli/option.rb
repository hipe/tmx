module Skylab::Treemap

  class CLI::Option
    # an abstract nerk for derking your gerks

    long_rx = /\A
      -- (?<no_part> \[no-\] )?
         (?<long_stem> [^\[\]=\s]{2,} )
         (?<long_rest> .+ )?
    \z/x

    short_rx = /\A
      -  (?<short_stem> [^-\[= ] )
         (?<short_rest> [-\[= ].* )?
    \z/x

    define_singleton_method :parse do |args| # a *function*'s args. cannot fail.
      if ::Hash === args.last
        opt_h = ( args = args.dup ).pop # for whacky newfangled etc
      end
      looking = [ long_rx, short_rx ]
      md_h = { }
      match = -> part do
        if ::String === part
          md, idx = looking.each_with_index.reduce( nil ) do |_, (rx, i)|
            m = rx.match( part ) and break [ m, i ]
          end
          if md
            looking[ idx, 1 ] = []
            md.names.each { |n| md_h[n.intern] = md[n] }
            true
          end
        end
      end
      args.each do |part|
        match[ part ] and looking.length.zero? and break
      end
      [ md_h, opt_h ]
    end

    arg_a = [ :long_stem, :short_stem, :no_part, :long_rest, :short_rest ]

    define_singleton_method :build_from_args do
      |args, normalized_key=nil, error=nil|

      new = self.new nil, * arg_a.length.times.map { }
      new.set_from_args args, normalized_key
      if error                    # you get a validation check iff you passed
        err = error               # an `error` handler
        error = -> e { "#{ e } in #{ args.inspect }" }
        new = new.validate error
      end
      new
    end

    # --*--

    def default
      @has_default or fail 'do not request default w/o checking `has_default`'
      @default
    end

    attr_reader :has_default

    def has_long
      @long_stem
    end

    def has_short
      @short_stem
    end

    attr_reader :normalized_name

    # a monumental hack to try and parse out *one* switch [arg] from an argv
    def parse argv
      res, = _parse argv
      res
    end

    def parse! argv  # like `parse` but mutates `argv`
      res, knock = _parse argv
      knock.each do |idx, inst, data=nil|
        case inst
        when :done ; argv[idx] = nil
        when :sub  ; argv[idx] = data
        end
      end
      if knock.length.nonzero?
        argv.compact!
      end
      res
    end

    def render                    # contrast with `rndr` and see what's missing
      render_long || render_short || normalized_name.inspect
    end

    def render_long
      "--#{ @no_part }#{ @long_stem }" if @long_stem
    end

    def render_long_no_no
      "--#{ @long_stem }" if @long_stem
    end

    def render_short
      "-#{ @short_stem }" if @short_stem
    end

    def rndr
      a = [ render_short || render_long || normalized_name.inspect ]
      a << argmnt_str if takes_argument
      a.join ''
    end

    def set normalized_name, long_stem, short_stem, no_part,
                  long_rest, short_rest, opt_h = nil

      @normalized_name, @long_stem, @short_stem, @no_part,
        @long_rest, @short_rest =
      normalized_name, long_stem, short_stem, no_part,
        long_rest, short_rest

      @has_default = @default = nil

      if opt_h
        opt_h_h = { default: -> v { self.default = v } }
        opt_h.each { |k, v| opt_h_h.fetch( k )[v] }
      end
    end

    define_method :set_from_args do |args, normalized_name=nil|
      md, opt_h = self.class.parse args
      if ! normalized_name && md[:long_stem]
        normalized_name = md[:long_stem].intern
      end
      set normalized_name, * arg_a.map { |k| md[k] }, *[opt_h].compact
      nil
    end

    def takes_no
      @no_part
    end

    def validate error=nil
      if @long_stem
        self
      else
        error ||= -> e { raise e }
        error[ "couldn't find a suitable long name" ]
        false
      end
    end

  protected

    alias_method :initialize, :set # expand if needed

    argument_is_optional_rx = /^ *\[.+\]$/

    define_method :argument_is_optional do
      if takes_argument
        argument_is_optional_rx =~ argument_string # asking for trouble!
      end
    end

    def argument_string
      @long_rest || @short_rest   # really really not robust
    end

    def argmnt_str
      @short_rest || @long_rest
    end

    alias_method :takes_argument, :argument_string

    public :takes_argument

    def build_regexp              # this is only for a hack. do not use this.
      a = [ ] ; aa = [ ]
      if has_long
        a << '\A--'
        a << '(?<no>no-)?' if takes_no
        a << "(?<long_stem>#{ ::Regexp.escape @long_stem })"
        a << '(?:=(?<long_arg>.*))?' if takes_argument
        aa << a.push( '\z' ).join( '' )
      end
      a.clear
      if has_short
        esc = ::Regexp.escape @short_stem
        a << "\\A(?<short_before>-(?:(?!-|#{ esc }).)*)#{ esc }"
        a << '(?<short_arg>.+)?\z' if takes_argument
        aa << a.join( '' )
      end
      ::Regexp.new aa.join( '|' )
    end

    def default= val
      @has_default = true
      @default = val
    end

    def _parse argv
      rx = build_regexp
      knock = []
      res = nil
      idx, md = argv.each_with_index.reduce nil do |_, (tok, i)|
        break [i, $~] if rx =~ tok
      end
      if idx
        ok = false
        if md[:long_stem]
          knock << [idx, :done]
        elsif '-' == md[:short_before]
          knock << [idx, :done]
        else
          knock << [idx, :sub, md[:short_before]]
        end
        if takes_argument
          if res = md[:long_arg] || md[:short_arg]
            # nothing
          elsif (idx+1) < argv.length and /^[^-]/ =~ argv[idx+1].to_s
            res = argv[idx+1]
            knock.push [idx+1, :done]
          elsif argument_is_optional
            ok = true
          else
            knock.pop # failed to match arg, rewind
          end
        else
          ok = true
        end
        ok and res = (takes_no and md[:no_part]) ? false : true
      end
      [ res, knock ]
    end
  end
end
