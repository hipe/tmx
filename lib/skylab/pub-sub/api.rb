module Skylab::PubSub
  module API
  end

  module API::Actions
  end

  class API::Actions::GraphViz
    PARAMS = [ :default_outfile_name,
               :do_digraph,
               :do_open,
               :do_show_backtrace,
               :files,
               :klass,
               :outfile_is_payload,
               :outfile_name,
               :use_force
    ].each { |k| attr_writer k }

    def execute
      res = nil
      begin
        res = resolve_params or break
        res = resolve_infiles or break
        res = resolve_klass or break
        res = resolve_graph or break
        res = resolve_paystream or break
        res = render_graph or break
        res = open_file or break
      end while nil
      res
    end

  protected

    #         ~ housekeeping ~

    def initialize outstream, errstream
      @outstream, @errstream = outstream, errstream
    end

    def emit stream, line
      ( :pay == stream ? @outstream : @errstream ).puts line
      nil
    end

    def error msg
      emit :err, msg  # it looks nicer to have these be w/o prefix
      false
    end

    def info msg
      a, m, b = ( /\A\((.+)\)\z/ =~ msg ) ? ['(', $~[1], ')'] : [nil, msg, nil]
      emit :info, "#{ a }#{ prefix }#{ m }#{ b }"
      nil
    end

    def pay data
      emit :pay, data
      nil
    end

    prefix = 'pub-sub-viz '  # looks better w/o

    define_method :prefix do prefix end

    #         ~ implementation in order ~

    def resolve_params
      missing = PARAMS.reduce [] do |m, k|
        if instance_variable_defined? :"@#{ k }"
          if instance_variable_get(:"@#{ k }").nil?
            m << k
          end
        else
          m << k
        end
        m
      end
      if missing.length.zero? then true else
        error "missing required paramer(s): (#{ missing.join ', ' })"
        nil
      end
    end

    def resolve_infiles
      if @files
        res = true
        @files.each do |file|
          pn = ::Pathname.new file
          if pn.exist?
            load pn.to_s
          else
            break( res = error "file not found: #{ pn }" )
          end
        end
      else
        error "required - `files`"
      end
    end

    const = '[A-Z][A-Za-z0-9_]*'

    klass_rx = /\A (?:::)?
      (?<inner>
        (?: #{ const } )
        (?: ::  #{ const } )*
      )
    \z/x

    define_method :resolve_klass do ||
      if @klass
        md = klass_rx.match( @klass )
        if md
          const_a = md[:inner].split '::'
          load_module const_a
        else
          error "doesn't look like a class or module constant - #{ @klass }"
        end
      else
        error "required - `klass`"
      end
    end

    def load_module const_a
      res = true
      kls = const_a.reduce ::Object do |m, c|
        if ! m.const_defined? c, false
          info "(tries to load #{ m }::#{ c } with `const_get`..)"
        end
        if @do_show_backtrace
          m.const_get c, false
        else
          begin
            m.const_get c, false
          rescue ::NameError => e
            break( res = load_module_fancy_error m, c, e )
          end
        end
      end
      if res
        @mod = kls
      end
      res
    end

    max_line_width =  120

    define_method :load_module_fancy_error do |m, c, e|
      info "failed to load the constant with const_get:"
      @errstream.puts "  #{ e }"
      a = m.constants
      if a.length.zero?
        @errstream.puts "  #{ m } has no constants"
      else
        line = "  loaded constants of #{ m } include ("
        s = a.join ', '
        avail = max_line_width - line.length - 1 # ')'
        if s.length > avail
          avail -= ( ellipsis = '[..]' ).length
          s = avail < 1 ? '' : "#{ s[ 0, avail ] }#{ ellipsis }"
        end
        @errstream.puts "#{ line }#{ s })"
      end
      break( res = nil )
    end

    meth = :event_graph # #todo this changes to :event_stream_graph in a stash

    define_method :resolve_graph do  # assumes @mod
      if @mod.respond_to? meth
        @event_stream_graph = @mod.send meth
        true  # (in the off chance that we let the above result in falseish)
      else
        error "expected #{ @mod } to respond_to? #{ meth }"
      end
    end

    def resolve_paystream
      res = true  # important
      if @outfile_is_payload
        @outfile_name or fail 'sanity'
        @outpn = ::Pathname.new @outfile_name
        if @outpn.exist?
          if @default_outfile_name != @outfile_name
            if ! @use_force
              error "exists, won't overwrite without force - #{ @outpn }"
              res = nil  # prettier not to dump all the ui here
            end
          end
        end
        if res
          @errstream.write "(#{ prefix }writing #{ @outpn } .."
          @paystream = @outpn.open 'w+'
        end
      else
        @paystream = @outstream
      end
      res
    end

    define_method :render_graph do  # assumes @event_stream_graph
      raw = @event_stream_graph.describe
      if raw
        require 'strscan'  # just for fun ..
        scn = ::StringScanner.new raw ; num = 0 ; line = nil
        gets = -> do
          s = scn.scan( /[^\r\n]*\r?\n|[^\r\n]+/ )
          s and num += 1
          s
        end
        if @do_digraph
          @paystream.puts "digraph {"
          @paystream.puts "  node [shape=\"Mrecord\"]"
          @paystream.puts "  label=\"event stream graph for #{ @mod }\""
          _gets = gets
          gets = -> { x = _gets[] and "  #{ x }" }
        end
        @paystream.puts( line ) while line = gets[]
        @paystream.write "}" if @do_digraph
        if @paystream.tty?
          @errstream.write "\n" if @do_digraph  # eew - digraph wo trailing nl
        else
          @paystream.close
          @errstream.puts "done.)"
        end
        info "(got #{ num } lines from #{ @mod }##{ meth }#describe)"
        res = true
      else
        error "`#{ @event_stream_graph.class }#describe` was falseish"
        res = nil
      end
      res
    end

    def open_file
      if @outfile_is_payload
        exec 'open', @outpn.to_s  # goodbye self
      else
        true
      end
    end
  end
end
