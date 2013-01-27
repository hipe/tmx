module Skylab::Treemap
  module Plugins::R # [#049] - adapters need a core.rb
    extend Autoloader
    module CLI
      module Actions
        extend MetaHell::Autoloader::Autovivifying
        extend Bleeding::Stubs
      end
    end
  end

  class Plugins::R::Client
    # gotchas: + pattern of emitting a path: everywhere as metadata

    def load_attributes_into o                 # called by the api action
      o.attribute :r_script_stream, enum: [:payload],
        stops_after: :r_script, stop_implied: true
      o.attribute :default_outpath, default: pdf_outpath
      nil
    end

    def load_options_into cli_action           # [#014.4] k.i.w.f
      cli_action.option_syntax.define! do |o|
        s = cli_action.send :stylus  # [#050] - - stylus wiring is bad and wrong
        separator ''
        separator s.hdr 'r-specific options:'
        on '--r-script', 'output to stdout the generated r script, stop.' do
          o[:r_script_stream] = :payload
        end
      end
      nil
    end

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
      o[:pathname] = -> k, v do
        k2 = k.to_s.gsub( /(?<=_)(in|out)path\z/ ) { "#{ $1 }_pathname" }.intern
        set[ self, k2, ( v ? ::Pathname.new( v ) : v ) ]
      end
      o[:required] = -> k, v do
        v or raise ::ArgumentError, "required - #{ k }"
      end
      o[:set] = -> k, v do
        set[ self, k, v]
      end
      o
    end.call

    param_h_h = {
      csv_inpath:          [:required, :pathname],
      failure:             [:required, :hook],
      info:                [:hook],
      rscript:             [:hook],
      stop_after_script:   [:set],
      success:             [:hook],
      title:               [:set],
      tmpdir:              [:required, :set],
    }

    define_method :render_treemap do |param_h|
      res = false
      begin
        forml, actul = param_h_h.keys, param_h.keys
        ( bad = actul - forml ).any? and raise ::NameError, "no: #{ bad * ' ' }"
        ( mis = forml - actul ).any? and raise ::ArgumentError, "missing:#{mis}"
        param_h.each do |k, v|
          param_h_h.fetch( k ).each do |kk|
            instance_exec k, v, &param_h_h_h.fetch( kk )
          end
          nil
        end
        @title ||= 'Treemap'
        res = execute
      end while nil
      res
    end                           # (will need to think about re-wiring if we
                                  # ever invoke the same client twice!)
  protected

    def initialize _ # adapter_box
      block_given? and fail "no wiring here"
      @infostream = $stderr # meh
    end

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
        @stop_after_script and break
        pipe_the_script
      end while nil
    end

    deny_rx = /[^- a-z0-9]+/i

    esc = -> str do
      str.to_s.gsub deny_rx, ''
    end

    define_method :generate_script do
      if @csv_in_pathname && @title
        y = ( @script ||= [] ).clear
        y << %|# install.packages("portfolio") # install it, necessary one once|
        y << %|library(portfolio)|
        y << %|data <- read.csv("#{ @csv_in_pathname }")|
        y << %|map.market(id=data$id, area=data$area, group=data$group, #{
          }color=data$color, main="#{ esc[ @title ] }")|
        y << %|# end of generated script|
        y.each { |s| @on_script[ s ] } if @on_rscript
        true
      else
        @script = false
      end
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
        @script or break # one last little sanity check
        bridge.is_active || @bridge.activate || break
        mtime1 = pdf_outpath.exist? && @pdf_outpath.stat.mtime
        upstream = API::MemoryLinesEnumerator.new @script
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
