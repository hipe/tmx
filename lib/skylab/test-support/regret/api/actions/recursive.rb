module Skylab::TestSupport::Regret::API

  class API::Actions::Recursive < API::Action

    v = API::Conf::Verbosity[ self ]

    services [ :out, :ivar ],
             [ :err, :ivar ],
             [ :pth, :ivar ]

    params [ :recursive ], v.param( :vtuple ),
      [ :do_force, :arity, :zero_or_one ]

    def execute
      if (( p = @recursive.from_path ))
        if (( p = ::Pathname.new p )).relative?
          p = p.expand_path
        end
      else
        p = ::Dir.getwd
      end
      ( @do_check = @recursive.do_check ) ; @recursive = nil

      wlk = API::Support::Tree::Walker.new :path, p,
        :vtuple, @vtuple, :listener, generic_listener

      conf = API::Conf
      a = -> do
        pn = wlk.expect_upwards( API::Conf.doc_test_dir ) or break bork
        pn = pn.join conf.doc_test_files_file
        wlk.expect_files_file pn or break bork
        money wlk
      end.call
      r = nil
      @wlk = wlk
      a and while (( pn = a.shift )) do
        false == (( r = go pn )) and break
      end
      r
    end

  private

    def pth
      @pth
    end

    def bork
      nil
    end

    def money wlk
      a = nil
      wlk.subtree_pathnames.each do |pn|
        pn.has_notes and next( note pn )
        ( a ||= [ ] ) << pn
      end
      a
    end

    def note pn
      pn.note_a.each do |severity, msg, type, * props|
        @err.puts "#{ severity }: #{ msg }. skipping - #{
          }#{ pn }#{ wat props }"
      end
      nil
    end

    def wat props
      if props.length.nonzero?
        TestSupport::Services.touch :JSON
        " #{ ::Hash[ * props ].to_json }"
      end
    end

    def go pn  # #todo:during:3
      @err.puts "--- #{ pn } ---"
      -> do
        a = [ @err, @pth, @vtuple ] ; c = @do_check
        if c
          o = @out
        else
          opn = out_pn( pn ) or break false
          io = o = TestSupport::Services::StringIO.new
        end
        omg = API::Actions::DocTest.new.instance_exec do
          @out = o
          @err, @pth, @vtuple = a
          @path = pn.to_s
          @template_options = nil
          self
        end
        false == (( r = omg.execute )) and break false
        if ! c
          bytes = nil
          io.rewind
          opn.open 'w+' do |fh|
            bytes = fh.write io.read
          end
          @err.puts "wrote #{ @pth[ opn ] } (#{ bytes } bytes)."
        end
        r
      end.call
    end

    TEST_DIR_DEPTH_ = 2
    RX_ = %r|\A(?:[^/]+/){#{ TEST_DIR_DEPTH_ }}[^/]+/?|
    SUBP_TEST_DIR_ = 'test'
    TEST_FILE_SUFFIX_ = '_spec'

    def out_pn pn
      relp = pn.relative_path_from( @wlk.top_pn ).to_s
      -> do
        md = RX_.match( relp ) or fail "sanity - #{ relp }"
        tailpn = ::Pathname.new md.post_match
        ext = tailpn.extname
        tail = "#{ tailpn.sub_ext( '' ) }#{ TEST_FILE_SUFFIX_ }#{ ext }"
        test_dir = @wlk.top_pn.join( md[0], SUBP_TEST_DIR_ )
        opn = test_dir.join tail
        if opn.exist?
          if ! @do_force
            @err.puts "won't overwrite without force - #{ @pth[ opn ] }"
            break false
          end
        end
        opn
      end.call
    end
  end
end
