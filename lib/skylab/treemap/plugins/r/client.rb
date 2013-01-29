module Skylab::Treemap
  class Plugins::R::Client
    # gotchas: + pattern of emitting a path: everywhere as metadata
    # [#049] plugin arch: client *actions* are the ones that need to
    # populate the f.a's and opts

    def default_outpath           # request client requires this (the adapter
      pdf_outpath                 # chooses the name, see!?)
    end

    def invoke action_ref, param_h # this logic will get split up.. [#049]
      kls = Plugins::R::API::Actions.const_fetch action_ref
      sym = kls.normalized_local_action_name_as_method_name
      send sym, param_h
    end

    def load_attributes_into o                 # called by the api action
      o.attribute :the_rscript_is_the_payload, stop_at: :script_eventpoint,
        stop_is_induced: true, is_adapter_parameter: true
      nil
    end

    def load_options_into cli_action           # [#014.4] k.i.w.f
      cli_action.option_syntax.define! do |o|  # #todo near [#014] rename to add_definition
        s = cli_action.send :stylus  # [#050] - - stylus wiring is bad and wrong - this will be fixed when `self` is fixed
        separator ''
        separator s.hdr 'r-specific options:'
        on '--r-script', 'output to stdout the generated r script, stop.' do
          o[:the_rscript_is_the_payload] = true
        end
      end
      nil
    end

  protected

    def initialize _ # adapter_box
      @infostream = $stderr # meh
      @lines = nil
    end

    # --*--

    param_h_h_h = -> do
      o = { }
      set = -> me, k, v do
        me.instance_variable_set "@#{ k }", v
      end
      o[:hook] = -> k, v do
        v && ! v.respond_to?( :call ) and
          raise ::ArgumentError, "expecting function - #{ v }"
        set[ self, "on_#{ k }".intern, v ]
      end
      o[:trueish] = -> k, v do
        v or raise ::ArgumentError, "required - #{ k }"
      end
      o[:pathname] = -> k, v do
        k2 = k.to_s.gsub( /(?<=_)(in|out)path\z/ ) { "#{ $1 }_pathname" }.intern
        set[ self, k2, ( v ? ::Pathname.new( v ) : v ) ]
      end
      o[:set] = -> k, v do
        set[ self, k, v]
      end
      o
    end.call

    param_h_h = {
      csv_inpath:          [:trueish, :pathname],
      failure:             [:trueish, :hook],
      info:                [:hook],
      payline:             [:trueish, :hook],
      stop_at:          [:set],
      success:             [:hook],
      the_rscript_is_the_payload: [:set],
      title:               [:set],
      tmpdir:              [:trueish, :set],
    }

    define_method :render do |param_h|
      res = false
      begin
        forml, actul = param_h_h.keys, param_h.keys
        ( bad = actul - forml ).any? and raise ::NameError, "no: #{ bad * ' ' }"
        ( mis = forml - actul ).any? and raise ::ArgumentError, "missing:#{mis}"
        param_h.each do |k, v|                 # (tained order)
          param_h_h.fetch( k ).each do |kk|
            instance_exec k, v, &param_h_h_h.fetch( kk )
          end
          nil
        end
        @title ||= 'Treemap'      # #todo you know you want it
        res = execute
      end while nil
      res
    end                           # (will need to think about re-wiring if we
                                  # ever invoke the same client twice!)

    def bridge
      @bridge ||= Plugins::R::Bridge.new do |o|
        o.on_info(& method(:info) )
        o.on_error(& method(:error))
      end
    end

    def error msg, metadata=nil
      @on_failure[ msg, metadata ]
      false
    end

    def execute
      begin
        normalize_tmpdir or break
        normalize_csv_path or break
        generate_script or break
        pipe_the_script
      end while nil
    end

    deny_rx = /[^- a-z0-9]+/i

    esc = -> str do
      str.to_s.gsub deny_rx, ''
    end

    Plugins::R::Client::Tees_LTLT = MetaHell::Proxy::Tee.new :<<

    define_method :generate_script do         # just as a fun excercize we
                                              # separate how the lines are used
      if @csv_in_pathname && @title           # from where they are made:
        @lines ? @lines.clear : ( @lines = [] ) # run all operations thru
        y = Plugins::R::Client::Tees_LTLT.new # a tee for fun and flexibility.
        y[:lines] = @lines                   # (mostly fun.)
        on_payline = @on_payline
        if @the_rscript_is_the_payload        # if the remote host wants to
          y[:downstream] = MetaHell::Proxy::Dynamic[ # see every line of the
            :<< => -> s { on_payline[ s ] } ] # script to do whatever with
                                              # as it is made, we way-over
        end                                   # engineered this for that purpose
        y << %|# install.packages("portfolio") # install it, necessary one once|
        y << %|library(portfolio)|
        y << %|data <- read.csv("#{ @csv_in_pathname }")|
        y << %|map.market(id=data$id, area=data$area, group=data$group, #{
          }color=data$color, main="#{ esc[ @title ] }")|
        y << %|# end of generated script|
        res = :script_eventpoint == @stop_at ? nil : true
      else
        res = @lines = false
      end
      res
    end

    def info msg
      @on_info[ msg ] if @on_info
      nil
    end

    def msg_res mtime1
      mtime2 = @pdf_outpath.exist? && @pdf_outpath.stat.mtime
      msg, ok = if mtime1
        if mtime2
          if mtime1 == mtime2
            [ "failed to create new file, old file intact (?)", false ]
          else
            [ "overwrote file", true ] end
        else
          [ "was there before and isnt't now!?", false ] end
      elsif mtime2
        [ "wrote new file", true ]
      else
        [ "failed to generate file or generated file not found", false ]
      end
      [ msg, ok ]
    end

    def normalize_csv_path
      @csv_in_pathname.exist? or begin
        error "couldn't find csv", path: @csv_in_pathname
      end
    end

    def normalize_tmpdir
      if @tmpdir.is_normalized
        info "tmpdir already normalized."
        true
      elsif @tmpdir.normalize # emits events to upstream client
        true
      else
        error "failed to normalized tmpdir", path: @tmpdir
        false
      end
    end

    pdf_pathname_guess = -> do
      x = ::Pathname.pwd.join 'Rplots.pdf'
      pdf_pathname_guess = -> { x }
      x
    end

    define_method :pdf_outpath do
      @pdf_outpath ||= pdf_pathname_guess[] # the issue is .. uh ..
    end

    def pipe_the_script
      res = false
      begin
        @lines or break # one last little sanity check
        bridge.is_active || @bridge.activate || break
        mtime1 = pdf_outpath.exist? && @pdf_outpath.stat.mtime
        upstream = Services::File::Lines::Enumerator::From::Array.new @lines
        inf = -> s { @infostream.write s }
        select = Headless::IO::Upstream::Select.new
        select.timeout_seconds = 0.3
        select.line[:sout] = -> s { inf[ "OUT-->#{ s }" ] }
        select.line[:serr] = -> s { inf[ "ERR-->#{ s }" ] }
        argv = [ @bridge.executable_path, '--vanilla' ] # wat
        Headless::Services::Open3.popen3( *argv ) do |sin, sout, serr|
          select.stream[:sout] = sout
          select.stream[:serr] = serr
          upline = true
          loop do
            bytes = select.select
            if upline &&= upstream.gets
              inf[ "MINE-->#{ upline }" ]
              sin.puts upline     # YOU WRITE THAT LINE TO THAT PROCESS
            end
            break if 0 == bytes || ! upline
          end
        end
        msg, res = msg_res mtime1
        f = res ? @on_success : @on_failure
        f[ msg, path: @pdf_outpath ] if f
      end while nil
      res
    end
  end
end
