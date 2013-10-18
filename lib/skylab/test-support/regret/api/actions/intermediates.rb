module Skylab::TestSupport::Regret::API

  class API::Actions::Intermediates < API::Action

    # we can access the API
    # through the `invoke` method
    #
    #     TestSupport::Regret::API.respond_to?( :invoke )  # => true
    #
    #     HOME_ = TestSupport::Regret.dir_pathname
    #
    #     # ( ignore this ENTIRE TEST SUPPORT INSIDE YOUR DOC-TEST )
    #     Intr_ = -> *a do
    #       io = TestSupport::IO::Spy::Triad.new nil
    #       # io.debug!
    #       h = { out: io.outstream, err: io.errstream }
    #       0.step(a.length-1, 2).each { |d| h[a[d]] = a[d+1] }
    #       r = TestSupport::Regret::API.invoke :intermediates, h
    #       out_a = io.outstream.string.split "\n"
    #       err_a = io.errstream.string.split "\n"
    #       [ r, out_a, err_a ]
    #     end
    #
    # when the (absolute) path is not found:
    #
    #     in_pn = HOME_.join( 'nope' )  # abspaths
    #     r, o, e = Intr_[ :path, in_pn ]
    #     o.length  # => 0
    #     e.shift  # => "not found: #{ in_pn }"
    #     e.shift  # => "can't make intermediate test files without a start node."
    #     r  # => false
    #
    # when it is not an absoulte path, borkage
    #
    #     Intr_[ :path, 'nope' ]  # => RuntimeError: we don't want to mess with relpaths..
    #
    # when it is an existant absolute path - works (dry run):
    #
    #     in_pn = HOME_.join( 'api/actions/doc-test/templos-/quickie/context-' )
    #     r, o, e = Intr_[ :path, in_pn, :vtuple, 4, :is_dry_run, true ]
    #     s = e * "\n"
    #     matches = -> rx do
    #       rx =~ s or fail "string did not contain #{ rx }"
    #       true
    #     end
    #     o.length  # => 0
    #     r  # => true
    #     yes = e.include?(
    #       "(verbosity level 3 is the highest. ignoring 1 of the verboses.)" )
    #     yes  # => true
    #     matches[ /yep i see it there.+context-$/ ]  # => true
    #     s.scan( /^exists - / ).length  # => 5
    #     big_rx =  %r|^\(writing .+templos-/quickie/test-support\.rb #{
    #       }\.\. done \(\d+ fake bytes\)\)$|
    #     matches[ big_rx ]  # => true
    #     matches[ %r|^mkdir .+templos-/quickie/context-| ]  # => true
    #     e.pop  # => 'ok.'
    #
    # content looks ok:
    #     opn =  TestSupport::TestSupport.dir_pathname.
    #       join( 'regret/code-fixtures-' )
    #     remove_entry_secure = -> do
    #       TestSupport::Services::FileUtils.remove_entry_secure opn.to_s
    #     end
    #     opn.exist? and remove_entry_secure[]
    #     in_pn = HOME_.join( 'code-fixtures-/asap/whootenany.rb' )
    #     r, o, e = Intr_[ :path, in_pn ]
    #     r  # => true
    #     o.length  # => 0
    #     these = e.grep( /\A\(writing/ )
    #     rx = /\A\(writing #{ ::Regexp.escape opn.to_s }/
    #     same = e.grep rx
    #     these.length.nonzero? or fail "sanity - no match?"
    #     these.length  # => same.length
    #     contents = opn.join( 'asap/whootenany/test-support.rb' ).read
    #     ok = contents.include?(
    #       'TestSupport::Regret::Code_Fixtures_::ASAP::Whootenany' )
    #     ok # => true
    #     remove_entry_secure[]

    services [ :out, :ivar ],
             [ :err, :ivar ],
             [ :pth, :ivar ],
             [ :invitation ]

    params :path,
           [ :top, :arity, :zero_or_one ],
           [ :is_dry_run, :arity, :zero_or_one ],
           [ :do_preview, :arity, :zero_or_one ],
           API::Conf::Verbosity[ self ].param( :vtuple )

    def absorb_any_services_from_parameters_notify param_h
      SVC_AS_PARAM_I_A_.each do |i|
        x = param_h.delete( i ) or next
        accept_value_as_service x, i
      end
    end
    SVC_AS_PARAM_I_A_ = %i( out err ).freeze

    def execute
      begin ; w = @wlk = build_walker ; r = false
        walk_to_test_dir or break
        test_dir = w.dir_pn
        lpn = w.class.subtract w.xpn, test_dir.dirname
        part_a = lpn.sub_ext( '' ).to_s.split ::Pathname::SEPARATOR_LIST
        curr_d = test_dir
        build_down curr_d, part_a or break
        @err.puts "ok."
        r = true
      end while nil
      r
    end

  private

    def build_walker
      Regret::Services::Walker.new :path, @path, :top, @top, :vtuple,
        @vtuple, :listener, generic_listener
    end

    def walk_to_test_dir
      begin ; r = false ; w = @wlk
        w.current_path_exists or break bork "can't make intermediate #{
          }test files without a start node."
        w.find_toplevel_module or break
        w.load_downwards or break
        w.find_first_dir 'test' or break
        r = true
      end while nil
      r
    end

    def build_down d, a
      @buff = TestSupport::Services::StringIO.new
      r = true ; begin
        p = d.join TS_
        if p.exist?
          say :medium, -> { "exists - #{ p }" }
        else
          r = make( d ) or break
        end
        a.length.zero? and break
        d = d.join a.shift
      end while true
      r
    end
    TS_ = 'test-support.rb'.freeze

    def make dpn
      io = @buff ; pn = dpn.join TS_
      dpn.exist? or make_dir dpn
      tmpl = self.class.const_get( :Templo, false ).begin @wlk, pn
      tmpl.render_to io
      pn.exist? and fail "sanity - existed #{ pn }"
      io.pos.zero? and fail "strange - template rendered nothing for #{ pn }"
      write pn, io
    end

    def make_dir dpn
      pth = @pth
      say :medium, -> { "mkdir #{ pth[ dpn ] }" }
      @is_dry_run or ::Dir.mkdir dpn.to_s
      nil
    end

    def write pn, io
      io.rewind
      if @do_preview
        @err.write io.read
      else
        @err.write "(writing #{ @pth[ pn ] } .." ; bytes = nil
        ( @is_dry_run ? DEV_NULL_ : pn ).open WRITEMODE_ do |fh|
          bytes = fh.write io.read
        end
        @err.puts " done (#{ bytes }#{ ' fake' if @is_dry_run } bytes))"
      end
      io.rewind ; io.truncate 0
      true
    end
    DEV_NULL_ = TestSupport::Services::Headless::IO::DRY_STUB
    WRITEMODE_ = Headless::WRITEMODE_

    def say volume, msg_p
      snitch.say volume, msg_p
      nil
    end

    def bork msg
      @err.puts msg
      false
    end
  end
end
