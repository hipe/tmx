module Skylab::TestSupport::Regret::API

  class API::Actions::Recursive < API::Action

    v = API::Conf::Verbosity[ self ]

    services [ :out, :ivar ],
             [ :err, :ivar ],
             [ :pth, :ivar ]

    params [ :mode, :set, [ :do_list, :do_check, :is_dry_run, :do_execute ] ],
      [ :path, :arity, :zero_or_one ],
      [ :do_force, :arity, :zero_or_one ],
      v.param( :vtuple )

    def execute
      @do_list = @do_check = @is_dry_run = @do_execute = nil
      instance_variable_set :"@#{ @mode }", true
      @normalized_argument_path = get_normalized_argument_path
      @wlk = build_walker
      a = get_leaf_pathname_a
      a and process_leaf_pathname_a a
    end

    def normalization_failure_line_notify msg
      @err.puts msg  # no snitch yet - snitch comes from params!
    end

  private

    def bork msg=nil
      msg and @err.puts msg
      false
    end

    def get_normalized_argument_path
      if (( p = @path ))
        if (( p = ::Pathname.new p )).relative?
          p = p.expand_path.to_s
        end
      else
        p = ::Dir.getwd
      end
      p
    end

    def build_walker
      API::Support::Tree::Walker.new :path, @normalized_argument_path,
        :vtuple, @vtuple, :listener, generic_listener
    end

    def get_leaf_pathname_a
      paths = API::Conf
      -> do
        dpn = @wlk.expect_upwards( paths.doc_test_dir ) or break bork
        fpn = dpn.join paths.doc_test_files_file
        @wlk.expect_files_file fpn or break bork
        get_leaf_pn_a_from_walker @wlk
      end.call
    end

    def get_leaf_pn_a_from_walker wlk
      a = nil
      wlk.subtree_pathnames.each do |pn|
        pn.has_notes and next( note pn )
        ( a ||= [ ] ) << pn
      end
      a
    end

    def process_leaf_pathname_a a
      if a.length.zero?
        bork "no input files to process"
      else
        before_all
        while (( pn = a.shift )) do
          false == (( r = process_walker_pathname pn )) and break
        end
        r
      end
    end

    def before_all
      if @do_check
        @o = @out
      else
        @io = @o = TestSupport::Services::StringIO.new
      end
      nil
    end

    def process_walker_pathname pn
      -> do
        if @do_list
          @out.puts @pth[ pn ]
          break true
        elsif @do_check
          @err.puts "--- #{ @pth[ pn ] } ---"
        else
          @err.write "<<< #{ @pth[ pn ] } .. "
        end
        r = prepare_pathname( pn ) or break r
        ex = build_doc_test_action( pn ) or break ex
        r = ex.execute or break r
        @do_check or ( r = flush or break r )
        true
      end.call
    end

    def prepare_pathname pn
      if @do_check then true else
        if (( r = @opn = get_valid_output_pathname pn ))
          r = true
        end
        r
      end
    end

    def get_valid_output_pathname pn
      -> do
        opn = get_output_pathname( pn ) or break opn
        opn.exist? && ! @do_force and break bork( "won't overwrite #{
          }without force - #{ @pth[ opn ] }" )
        opn
      end.call
    end

    def get_output_pathname pn
      relp = pn.relative_path_from( @wlk.top_pn ).to_s
      md = RX_.match( relp ) or fail "sanity - #{ relp }"
      tailpn = ::Pathname.new md.post_match ; ext = tailpn.extname
      tail = "#{ tailpn.sub_ext( '' ) }#{ TEST_FILE_SUFFIX_ }#{ ext }"
      test_dir = @wlk.top_pn.join( md[0], SUBP_TEST_DIR_ )
      test_dir.join tail
    end

    TEST_DIR_DEPTH_ = 2
    RX_ = %r|\A(?:[^/]+/){#{ TEST_DIR_DEPTH_ }}[^/]+/?|
    SUBP_TEST_DIR_ = 'test'.freeze
    TEST_FILE_SUFFIX_ = '_spec'.freeze

    def build_doc_test_action pn
      ex = API::Actions::DocTest.new
      ex.set_expression_agent @expression_agent
      ex.set_vtuple @vtuple
      ex.absorb_services :out, @o, :err, @err, :pth, @pth
        # NOTE this litte `o` above is e.g our selfsame @out *OR* a
        # handle on the little `@io` nerklette (depending on 'check')
      r = ex.absorb_params_using_message_yielder snitch.y, :path, pn,
        :load_module, nil, :load_file, nil, :template_option_a, nil,
        :do_close_output_stream, false
      r&&= ex
      r
    end

    # --*--

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

    def flush
      bytes = nil
      @io.rewind
      opener = @is_dry_run ? DEV_NULL_ : @opn
      opener.open 'w+' do |fh|
        bytes = fh.write @io.read
      end
      @err.puts ">>> #{ @pth[ @opn ] } written (#{ bytes }#{
        }#{ ' fake' if @is_dry_run } bytes)."
      @io.truncate 0
      @io.rewind
      true
    end

    DEV_NULL_ = API::Face::Services::Headless::IO::DRY_STUB
  end
end
