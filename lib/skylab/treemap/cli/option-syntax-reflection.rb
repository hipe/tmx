module Skylab::Treemap
  module CLI::OptionSyntaxReflection # # todo
  end

  module CLI::OptionSyntaxReflection::InstanceMethods
    def options
      @options_f ||= -> do
        seen_definition_length = 0
        is_current = false
        box = CLI::OptionSyntaxReflection::Option_Box.new
        on_definition_added_h[:option_syntax_reflection] = -> do
          is_current = false      # for the future, we must note we have more
          box.clear!              # options to process when more are aded
          nil
        end
        add_help = -> do          # #tracked by [#015]
          # the `help` option gets special treament because sometimes it's magic
          box.fetch_by_normalized_name :help do |k|
            o = CLI::OptionSyntaxReflection::Option_Metadata.build_from_args(
              ['-h', '--help'] ).validate
            box.add o
            nil
          end
        end
        -> do
          if ! is_current
            recorder =
              CLI::OptionSyntaxReflection::Recorders::OptionParser.new box
            while seen_definition_length < definitions.length
              defn = definitions[ seen_definition_length ]
              recorder.absorb defn
              seen_definition_length += 1
            end
            add_help[ ]           # (where? [#015])
            is_current = true
          end
          box
        end
      end.call
      @options_f.call
    end
  end

  class CLI::OptionSyntaxReflection::Option_Box

    def add opt
      if @hash.key? opt.normalized_name
        fail "haha no way - we are add-only, no clobber - #{
          }#{ opt.normalized_name }"
      end
      @order.push opt.normalized_name
      @hash[opt.normalized_name] = opt
      nil
    end

    def clear!
      # note it does not clear the hash itself!
      @by_switch_h = nil
      nil
    end

    def fetch_by_normalized_name normalized_name, &block
      @hash.fetch( normalized_name, &block )
    end

    alias_method :[], :fetch_by_normalized_name # not guaranteeed to stick

    def fetch_by_switch switch, &block
      @by_switch_h ||= begin
        @order.reduce( {} ) do |m, nn|
          opt = @hash[nn]
          m[ opt.render_short ] = nn if opt.has_short
          m[ opt.render_long_no_no  ] = nn if opt.has_long
          m[ opt.render_long ] = nn if opt.takes_no
          m
        end
      end
      res = nil
      nn = @by_switch_h.fetch switch do |k|
        if block
          res = block[ k ]
          nil
        else
          raise ::KeyError.new "key no found: #{ k.inspect }"
        end
      end
      if nn
        res = @hash.fetch nn
      end
      res
    end

    def fuzzy_fetch x, &block
      res = nil
      x = x.to_s
      if '-' == x[0]
        res = fetch_by_switch x, &block
      else
        res = fetch_by_normalized_name x.intern, &block
      end
      res
    end

  protected

    def initialize
      @order = [ ]
      @hash = { }
      @by_switch_h = nil
    end
  end

  class CLI::OptionSyntaxReflection::Option_Metadata
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

  module CLI::OptionSyntaxReflection::Recorders
  end

  class CLI::OptionSyntaxReflection::Recorders::OptionParser
    # a recorder for option parser definitions

    def on *a, &b
      @option_definition_queue << [ *a, b ]
    end

    empty_a = [ ].freeze

    define_method :more do |_|    # compat. with the experimental `more`
      empty_a                     # service that manages long option descs
    end                           # for now we /dev/null this

    def separator *a              # compat with the ::optionparser opt
    end

    # --*--

    def absorb option_syntax_block
      @param_h_recorder.mode = :defaults
      instance_exec @param_h_recorder, &option_syntax_block
      @param_h_recorder.mode = :arguments
      while parts = @option_definition_queue.shift
        option(* parts )
      end
      nil
    end

  protected

    def initialize option_box
                                  # (in the order they are used)
      @default_h = { }
      @param_h_recorder =
        CLI::OptionSyntaxReflection::Recorders::Param_H.new @default_h
      @option_definition_queue = [ ]
      @option_box = option_box
    end

    def error msg
      fail msg                    # we would likely want to soften some of these
      false
    end

    describe = -> a do
      aa = a.reduce( [] ) do |m, x|
        m << x if ::String === x && '-' == x[0]
        m
      end
      ( aa.length.nonzero? ? aa : a ).join ', '
    end

    define_method :option do |*args, block|
      res = false
      begin
        block or fail "option reflection not implemented for option #{
          }definitions without a block (#{ args.inspect })"

        # note we are calling the block as if the option were being parsed,
        # but all we really want to know is what key is used, so hopefully
        # the param_h is used in a straightforward manner there! HACK!!

        block[ * block.arity.abs.times.map{ nil } ]
        key = @param_h_recorder.last_key
        if ! key
          error "block did not set a value in options hash in definition #{
            }for #{ describe[ args ]}"
          break
        end
        if @default_h.key? key
          ::Hash === args.last and fail 'implement me'
          args.push default: @default_h[ key ]
        end
        opt = CLI::OptionSyntaxReflection::Option_Metadata.build_from_args(
          args, key, -> e { error e } )
        opt or break
        existing = @option_box.fetch_by_normalized_name(
          opt.normalized_name ) { }
        if existing
          if existing.render_long != opt.render_long
            break( error "redifinition of #{ opt.render } did not #{
              }match: #{ existing.render_long } vs. #{ opt.render_long }" )
          end
        else
          @option_box.add opt
        end
        res = true
      end while nil
      res
    end
  end

  class CLI::OptionSyntaxReflection::Recorders::Param_H
    # this is necessarily a modal recorder - we want to do different things
    # with the values we receive based on what mode we are in.

    def []= k, v
      @set[ k, v ]
    end

    def [] k
      @get[ k ]
    end

    attr_reader :last_key

    def mode= mode
      if mode != @mode
        @mode_h.fetch( mode ).call
        @mode = mode
      end
      mode
    end

  protected

    def initialize default_h
      default_set = -> k, v { default_h[k] = v }
      default_get = -> k    { default_h[k] }

      argument_set = -> k, v { @last_key = k ; v }
      argument_get = -> k { fail 'sanity - you could but do you want to?' }

      @mode = :initialized
      @mode_h = {                 # in order of operation
        defaults: -> do
          @set = default_set
          @get = default_get
          nil
        end,
        arguments: -> do
          @set = argument_set
          @get = argument_get
          nil
        end
      }
      @last_key = nil
    end
  end

  class CLI::OptionSyntaxReflection::Option_Scanner # for ::OptionParser hacks

    attr_reader :count

    def fetch query, otherwise=nil
      block_given? and fail 'no'
      while x = self.next
        break( found = x ) if query[ x ]
      end
      if found
        found
      else
        otherwise ||= -> { raise ::KeyError, 'item matching query not found.' }
        otherwise[]
      end
    end

    attr_reader :is_hot

    attr_reader :last

    def next
      if @is_hot
        r = @enum.next
        @count += 1
        @last = filter r
      end
    rescue ::StopIteration
      @is_hot = nil
    end

  protected

    def initialize enum
      @is_hot = true
      @count = 0
      @last = nil
      @enum = ::Enumerator.new do |y|
        enum.each { |x| y << x }
      end
      @fly = CLI::OptionSyntaxReflection::Option_Metadata.new(
        * 6.times.map { nil } ) # for now
    end

    unparse = -> sw do
      args = [ ] # this might alter the order of things, it is a hack
      x = sw.short.first and args << x
      x = sw.long.first and args << "#{ sw.long.first }#{ sw.arg }"
      args
    end

    define_method :filter do |sw|
      @fly.set_from_args unparse[ sw ]
      @fly
    end
  end
end
