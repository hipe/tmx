module Skylab::Callback

  class API::Action

    class << self
      def formal_parameters
        @formal_parameters ||= bld_formal_params
      end
    private
      def bld_formal_params
        const_get( :PARAMS, false ).map( & API::Formal_Parameter.method( :new ) )
      end
    public
      def name_function
        @name_function ||= bld_name_function
      end
    private
      def bld_name_function
        Home_::Name.via_module self
      end
    end

    def initialize prefix, paystream, infostream
      @error_count = 0 ; @infostream = infostream ; @paystream = paystream
      @request_client_prefix = prefix
      formal_parameters.each do |p|
        instance_variable_set p.ivar, nil
      end ; nil
    end

    def absorb_param_h_fully param_h
      param_h_h = ::Hash[ formal_parameters.map { |p| [ p.sym, p ] } ]
      param_h.each do |k, v|
        instance_variable_set param_h_h.fetch( k ).ivar, v
      end
      nil
    end

  private

    #         ~ housekeeping & basic ui ~

    def formal_parameters
      self.class.formal_parameters
    end

    # --*--

    def puts_to_channel_line stream, line
      ( :pay == stream ? @paystream : @infostream ).puts line
      nil
    end

    def send_error_string msg
      @error_count += 1
      puts_to_channel_line :err, msg  # it looks nicer to have these be w/o prefix
      false
    end

    def send_info_string msg
      a, m, b = ( /\A\((.+)\)\z/ =~ msg ) ? ['(', $~[1], ')'] : [nil, msg, nil]
      puts_to_channel_line :send_info_string, "#{ a }#{ prefix }#{ m }#{ b }"
      nil
    end

    def pay data
      puts_to_channel_line :pay, data
      nil
    end

    def prefix
      "#{ @request_client_prefix } #{ self.class.name_function.as_slug } "
    end

    #         ~ in order of typical use ~

    def resolve_params
      missing = formal_parameters.reduce [] do |m, p|
        if instance_variable_get( p.ivar ).nil?
          m << p.label
        end
        m
      end
      if missing.length.zero? then true else
        send_error_string "#{ prefix }missing required paramer(s): (#{ missing.join ', ' })"
        nil
      end
    end

    def resolve_infiles
      if @files
        res = true
        @files.each do |file|
          pn = ::Pathname.new file
          if pn.exist?
            if pn.relative?
              pn = pn.expand_path
            end
            pn = pn.sub_ext ''
            rs = require "#{ pn }"
            if false == rs
              send_info_string "(using loaded - #{ file })"
            else
              send_info_string "(loaded - #{ file })"
            end
          else
            break( res = send_error_string "file not found: #{ pn }" )
          end
        end
      else
        send_error_string "required - `files`"
      end
    end

    -> do

      const = '[A-Z][A-Za-z0-9_]*'

      modul_rx = /\A (?:::)?
        (?<inner>
          (?: #{ const } )
          (?: ::  #{ const } )*
        )
      \z/x

      define_method :resolve_mod do
        if @modul
          md = modul_rx.match( @modul )
          if md
            const_a = md[ :inner ].split CONST_SEP_
            load_module const_a
          else
            send_error_string "doesn't look like a class or module constant - #{ @modul }"
          end
        else
          send_error_string "required - `modul`"
        end
      end
    end.call


    def load_module const_a
      ok = true
      cls = Home_.lib_.module_lib.value_via_parts const_a do |const, mod|
        send_info_string "(tries to load #{ mod }::#{ const } with `const_get`..)"
        if @do_show_backtrace
          mod.const_get const, false
        else
          begin
            mod.const_get const, false
          rescue ::NameError => e
            ok = false
            load_module_fancy_error mod, const, e
          end
        end
      end
      if ok
        @mod = cls
      end
      ok
    end

    -> do

      max_line_width =  120

      define_method :load_module_fancy_error do |m, c, e|
        send_info_string "failed to load the constant with const_get:"
        @infostream.puts "  #{ e }"
        a = m.constants
        if a.length.zero?
          @infostream.puts "  #{ m } has no constants"
        else
          line = "  loaded constants of #{ m } include ("
          s = a.join ', '
          avail = max_line_width - line.length - 1 # ')'
          if s.length > avail
            avail -= ( ellipsis = '[..]' ).length
            s = avail < 1 ? '' : "#{ s[ 0, avail ] }#{ ellipsis }"
          end
          @infostream.puts "#{ line }#{ s })"
        end
      end
    end.call
  end
end
