module Skylab::TestSupport::Regret::API

  class API::Actions::Intermediates < Face::API::Action

    v = API::Conf::Verbosity[ self ]

    services [ :out, :ingest ],
             [ :err, :ingest ],
             [ :pth, :ingest ],
             [ :invitation ]

    params :path, v.param( :vtuple ),
           [ :is_dry_run, :arity, :zero_or_one ],
           [ :do_preview, :arity, :zero_or_one ]

    def execute
      host.invitation
      $stderr.puts "HAPPY EXIT?" ; exit 0


      r = -> do
        wlk = @wlk = API::Support::Tree::Walker.new @path, -> e do
          if @vtuple[ e.volume ]
            @err.puts instance_exec( & e.message_function )
            true  # we might do this .. callee chains progressively less
          end  # detailed nerks.
        end
        if ! wlk.current_path_exists
          @err.puts "can't make intermediate test files without start node."
          break
        end
        wlk.find_toplevel_module or break
        wlk.load_downwards or break
        wlk.find_first_dir 'test' or break
        test_dir = wlk.dir_pn
        pn = wlk.class.subtract wlk.xpn, test_dir.dirname
        part_a = pn.sub_ext( '' ).to_s.split ::Pathname::SEPARATOR_LIST
        curr_d = test_dir
        build_down curr_d, part_a or break
        @err.puts "ok."
        true
      end.call
      if ! r
        host.invitation
        r
      end
    end

    def build_down curr_d, part_a
      ok = true
      begin
        curr_f = curr_d.join TS_
        if curr_f.exist?
          say :medium, -> { "exists - #{ curr_f }" }
        else
          ok = make curr_d
          ok or break
        end
        part_a.length.zero? and break
        curr_d = curr_d.join part_a.shift
      end while true
      ok
    end
    private :build_down

    TS_ = 'test-support.rb'

    def make dpn
      pn = dpn.join TS_
      if ! dpn.exist?
        say :medium, -> { "mkdir #{ @pth[ dpn ] }" }
        ::Dir.mkdir( dpn.to_s ) if ! @is_dry_run
      end
      @buff ||= Face::Services::Headless::Services::StringIO.new
      tmpl = self.class.const_get( :Templo, false ).begin @wlk, pn
      tmpl.render_to @buff
      if pn.exist?
        fail "sanity - existed: #{ pn }"
      elsif @buff.pos.zero?
        say :notice, -> do
          "strange - template rendered nothing for #{ @pth[ pn ] }"
        end
        false
      else
        @buff.rewind
        if @do_preview
          @err.write @buff.read
        elsif ! @is_dry_run
          bytes = nil
          @err.write "(writing #{ @pth[ pn ] } .."
          pn.open 'w' do |fh|
            bytes = fh.write @buff.read
          end
          @err.puts " .. done (#{ bytes } bytes)"
        end
        @buff.rewind ; @buff.truncate 0
        true
      end
    end
    private :make

    def say volume, msg_f
      if @vtuple[ volume ]
        @err.puts msg_f.call
      end
      nil
    end
    private :say
  end
end
