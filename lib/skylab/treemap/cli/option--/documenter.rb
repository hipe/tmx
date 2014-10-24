module Skylab::Treemap

  class CLI::Option__::Documenter

  public

    #         ~ #parameter-reflection-API ~

    # Kind of a big deal to the rest of the system, reflection on
    # all of the nerks. Note this frequently gets requested as the option
    # parser definition blocks are being run so care must be taken with
    # lazy-instantiation of the option documenter (singular!).

    Options = Lib_::Proxy_lib[].nice :fetch

    def options
      @options ||= Options.new fetch: method( :options_fetch )
    end

    def has_formal_parameter norm_name
      @option_box.has? norm_name
    end

    #         ~ mostly documenting hoooks ~

    def absorb_unseen_definition_blocks blocks, extension_blocks

      # extensions must be run before a true documenting pass (because. e.g
      # `more`s need to be read before they are written.)
      # However, the extensions (and possibly the normal definitions)
      # may want to be able to refer to the switches by normalized name
      # in their rendered strings. We hence try to save reading `mores`
      # till the very end somehow.

      if @blocks_a
        if ! blocks || @blocks_a.object_id != blocks.object_id
          fail "hack failed - blocks definition array changed?"
        end
      else
        @blocks_a = blocks
      end
      unseen :blocks, blocks do |block|
        @census_probe.instance_exec @model_probe, &block
      end
      unseen :extensions, extension_blocks do |block|
        block[ self ]
      end                                      # we process the normal blocks!
      nil
    end

    # (just a special accessor to be used from the i.m's typically just
    # for appending a -h option at the end of it.)

    def on *a, &b
      b and fail "you can't add a block to a documenting option"
      @model_probe.on(* a )
      nil
    end

    #  ~ a note about the proxies & probes: small internal classes/hacks ~
    #
    # They are for helping to inspect what happens inside blocks that
    # define option parsers and (separately) the blocks provided for
    # each option. This whole show is ridiculous, but the most ridiculous
    # of all of it lives here, with what we do with these proxies.
    #
    # The reason we make explicit classes for these instead of just making
    # dynamic proxies is party so that users see the class name during errors
    # of calling an e.g. method that is not yet supported on a probe.
    #
    # They are each placed in this file above their each first (and usu.
    # only) time being referenced, for the sake of semantic proximity.
    #

    module Pxy
      # usually we write out what is attempted to read from us
    end

    module Probe
      # usually we store what is written to us
    end

    Pxy::Smrz = Lib_::Proxy_lib[].function :summarize do
      def respond_to?  # :+[#057]
        true
      end
    end

    def summarize(* args, &block )  # receive a call from the f.w

      # OK HERE IS THE SUPREME HACK: we now have a bunch of options & one model
      # already built (the o.p). But note that we have not yet expanded out
      # the `more`'s or {{default}}'s etc (good reasons). We want to rely
      # on the native rendering (o.p) *with* the `summary_width`,
      # `summary_indent` that are present in the current model. The *only* way
      # to do this right is to re-run the definition blocks on a custom-made
      # o.p that we throw away. It's impossible to get the `more` to interpolate
      # right otherwise (although the rest could be hacked.) Trust me it is
      # what is right. Then in each switch we want to hook into its own native
      # rendering to filter the strings on a switch-by-switch basis.. FILTHY

      view_model = build_view_model
      current = view_model.top.list
      ( 0 .. current.length ).each do |idx|
        if current[idx].respond_to? :summarize
          sw = current[ idx ]  # (we used to store originals here..)
          current[idx] = Pxy::Smrz.new(
            :summarize => ->( *a, &b ) { summarize_switch sw, idx, a, b }
          )
        end
      end
      res = view_model.summarize(* args, &block )
      # view model is spent! discard..
      res
    end

    def summary_indent            # (raw value of actual o.p, f.w formats w/ it)
      @model.summary_indent
    end

    def summary_width             # (raw value of actual o.p, f.w formats w/ it)
      @model.summary_width
    end

    def summary_width= x
      @model.summary_width = x    # use it to hold it sure why not. f.w needs it
    end

    Pxy::Top = Lib_::Proxy_lib[].nice :list

    def top
      @top_pxy ||= Pxy::Top.new list: method( :top_list )
    end

    -> do  # `visit` - this is probably replacing above.  look like an o.p
      h = {
        each_option: -> blk do  # #todo this is not complete
          top_list.each(& blk )
        end
      }
      define_method :visit do |meth, &blk|
        instance_exec( blk, & h.fetch( meth ) )
      end
    end.call

  private

    # act like an action, but do 'census' style things

    Probe::Action = Lib_::Proxy_lib[].nice(
        :read_param_h, :write_param_h, :write_param_queue ) do

      # we don't style things during 'census' probe

      def hdr s
        s
      end

      def more _
        EMPTY_A_
      end

      def initialize read_param_h, write_param_h, write_param_queue
        @param_h = Probe::Hash.new read_param_h, write_param_h
        @param_queue = ::Enumerator::Yielder.new(& write_param_queue )
        nil
      end
    end

    Probe::Hash = Lib_::Proxy_lib[].nice :[], :[]= do
      class << self
        def new read, write
          super :[], read, :[]=, write
        end
      end
    end

    Probe::Model = Lib_::Proxy_lib[].nice :on, :separator do
      def respond_to?  # :+[#057]
        true
      end
    end

    def initialize host
      @blocks_a = nil  # last minute hack, for this new rendering step..
      @seen_length_h = { blocks: 0, extensions: 0 }
      @seen_blocks_length = @seen_extblocks_length = 0
      @fail = method :fail
      @host = host
      @model = ::OptionParser.new              # just for gathering data..
      @flip_box, @default_box, @option_box, @more_box = 4.times.map do
        MetaHell::Formal::Box.open_box.new
      end
      param_h = { } ; param_queue = [ ]
      @census_probe = Probe::Action.new(
        read_param_h: -> k do
          fail "test me - it's probably fine" ; param_h[ k ]
        end,
        write_param_h: -> k, v do
          @write_param_h[ k, v ]
          param_h[ k ] = v
        end,
        write_param_queue: -> v do
          @write_param_queue[ v ]
          param_queue << v
        end
      )
      @model_probe = Probe::Model.new(
        on:          method( :option_definition_added ),
        separator:   method( :option_separator )
      )
      @write_param_h_h = {
        probe_default: -> k, v { @default_box.add k, v },
        probe_name:    -> k, v { @param_key_mutex[ k ] }
      }
      @write_param_h = @write_param_h_h[ :probe_default ]
      @write_param_queue = -> x do
        ::Symbol === x or fail "hack failed - expecting symbol - #{ x.class }"
        @param_key_mutex[ x ]
      end
    end

    #         ~ support for the census pass (wired in above method) ~

    def option_definition_added *args, &block
      @model.on(* args, &block )
      opt = Lib_::CLI_lib[].via_args args, nil, @fail
      if opt
        if opt.weak_identifier
          if block  # no block iff cosmetic!
            norm_name = hack_infer_normalized_name block,
              -> e { @fail[ "#{ opt.weak_identifier } #{ e }" ] }
          else
            norm_name = opt.local_normal_name  # MY GOD BE CAREFUL
          end
        else
          opt = @fail[ "can't derive weak identifier for option" ]
        end
      end
      if opt && norm_name
        opt.local_normal_name = norm_name
        @flip_box.add opt.weak_identifier, norm_name
        @option_box.add norm_name, opt
      end
      nil
    end

    def hack_infer_normalized_name block, otherwise  # (called in above method)
      # this block was created in the context of the action probe, so when
      # you call `call` on the block, the probe is the self.
      prev = @write_param_h
      @write_param_h = @write_param_h_h[ :probe_name ]
      seen = nil
      @param_key_mutex = -> k do
        if seen && seen != k
          fail "hack failed - param key mismatch - #{ seen } to #{ k }"
        end
        seen = k
      end
      block.call( * block.arity.abs.times.map { } )
      @write_param_h = prev
      if seen
        seen
      else
        otherwise[ "block not set anything in @param_h" ]
        false
      end
    end

    # (experimentally we do "higher level" (albeit private) section higher)

    #        ~ The Option Reflection API (backend) ~

    def options_fetch norm_name, &otherwise
      option = @option_box.if? norm_name, -> opt do
        if ! opt.is_collapsed  # in flux..
          if @default_box.has? norm_name
            def_value = @default_box.fetch norm_name
            opt.send :default_value=, def_value  # confers familiarity
          end
          opt.is_collapsed = true
        end
        opt
      end, otherwise
      option
    end

    #         ~ defaults - inspecting & rendering  ~

    def default_added k, v
      @default_box.add k, v  # (for better or worse, borks on clobber)
      v
    end

    #         ~ the `more` facility ~

    empty_a = [ ].freeze

    define_method :do_not_read_more do |k|
      empty_a
    end

    def read_more k
      a = [ ]
      y = ::Enumerator::Yielder.new { |x| a << x }
      @more_box.fetch( k ).each do |blk|
        # be polite and give those sorry fucks a context..
        @host.instance_exec y, &blk
        nil
      end
      a  # (yes it is like a reduce)
    end

    def write_more k, &b
      a = @more_box.if?( k, IDENTITY_, -> box { a = [ ] ; box.add k, a ; a } )
      # (a = (h[k] ||= []))
      a << b
      nil
    end

    public :write_more  # accessed via proxy elsewhere

    #         ~ backend hookbacks into framework rendering ~

    # (see long note at `summarize`)

    Pxy::Action = Lib_::Proxy_lib[].nice :hdr, :more do
      def initialize h
        super
        @param_h = { }
      end
    end

    def build_view_model
      # carry-over old values to new and make a few prayers about some things..
      h = { }
      ks = [ :@summary_indent, :@summary_width ] # program_name? banner? think about it ..
      @model.instance_exec do
        ks.each { |k| h[k] = instance_variable_get k }
      end
      op = ::OptionParser.new
      op.instance_exec do
        h.each { |k, v| instance_variable_set k, v }
      end
      doc_ctx = Pxy::Action.new(
        hdr: @host.method( :hdr ),
        more: method( :read_more )        # only *NOW* do we read these!
      )
      @blocks_a.each do |blk|
        doc_ctx.instance_exec op, &blk
      end
      op
    end

    -> do

      # whatever strings the upstream gives us to represent this switch,
      # we do at least 2 things to it.. (this is from a call of `summarize`
      # from the frameworks)

      fun = Lib_::CLI_lib[].option.parser.scanner

      mustache_rx = Treemap_::Lib_::String_lib[].mustache_regexp

      define_method :summarize_switch do |sw, idx, args, blk|
        sw.summarize(* args ) do |line|  # (no how about *I'll* call it)
          use_line = line.gsub mustache_rx do
            stem = $~[1].strip
            meth = "render_#{ stem }_for_option" # e.g. render_default_for_option
            # (we used to put $~[0] back, now we are loud with failure..)
            wid = fun.weak_identifier_for_switch sw
            opt = options_fetch( @flip_box.fetch wid )
            s = @host.send meth, opt
            s ||= "(no #{ stem })"  # e.g "(no default)"  .. you could of course..
            s
          end
          blk[ use_line ]
        end
      end
    end.call

    Pxy::Switch = Lib_::Proxy_lib[].functional(
        :arg, :long, :object_id, :short, :send ) do
      def respond_to?  # i want it all
        true
      end
    end

                                  # (probaby being used to render option syn.)
    def top_list                  # (probably being called by `visible_options`)
      ::Enumerator.new do |y|
        @model.top.list.each do |sw|
          pxy = Pxy::Switch.new(
            :arg => -> { sw.arg },
            :long => -> { sw.long },
            :object_id => -> { sw.object_id }, # used to look up if visible ..
            :short => -> { sw.short },
            :send => -> x, *a { sw.send x, *a }  # used by hl o.p
          )
          y << pxy
        end
        nil
      end
    end

    #         ~ internal mechanics & hookbacks ~

    def option_separator *a
      # so .. we don't give it to the model, and we don't hook into it..
      # the only place we have to worry about it is in the view model..
    end

    def unseen which, ary, &each
      current_length = ary ? ary.length : 0
        # (atomicize length, in case of shenanigans)
      known_length = @seen_length_h.fetch which
      if known_length < current_length
        ( known_length ... current_length ).each do |idx|
          each[ ary[ idx ] ]
          @seen_length_h[ which ] += 1  # inc. progressively just in case
        end
        nil
      end
      nil
    end
  end
end
