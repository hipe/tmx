module Skylab::TestSupport::Regret::API

  class API::Actions::Recursive < API::Action

    v = API::Conf::Verbosity[ self ]

    services [ :out, :ivar ],
             [ :err, :ivar ],
             [ :pth, :ivar ]

    params [ :core_basename, :arity, :zero_or_one ],
      [ :do_force, :arity, :zero_or_one ],
      [ :load_file, :arity, :zero_or_one ],  # for now only cosmetic
      [ :mode, :set, [ :do_list, :do_check, :is_dry_run, :do_execute ] ],
      [ :path, :arity, :zero_or_one ],
      v.param( :vtuple )

    def absorb_any_services_from_parameters_notify h
      x = h.delete( :out ) and accept_value_as_service x, :out
      x = h.delete( :err ) and accept_value_as_service x, :err ; nil
    end

    def execute
      @do_list = @do_check = @is_dry_run = @do_execute = nil
      instance_variable_set :"@#{ @mode }", true
      @normalized_argument_path = get_normalized_argument_path
      @wlk = build_walker
      a = get_nonzero_leaf_pathname_a
      a and prcss_nonzero_leaf_pathname_a a
    end

    def normalization_failure_line_notify msg
      @err.puts msg  # no snitch yet - snitch comes from params!
    end

  private

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
      RegretLib_::Tree_walker[ :path, @normalized_argument_path,
        :vtuple, @vtuple, :listener, generic_listener ]
    end

    def get_nonzero_leaf_pathname_a
      @paths = API::Conf
      dpn = @wlk.expect_upwards @paths.doc_test_dir
      dpn and gt_nonzero_pn_a_from_doctest_dir_pn dpn
    end

    def gt_nonzero_pn_a_from_doctest_dir_pn dpn
      fpn = dpn.join @paths.doc_test_files_file
      ok = @wlk.expect_files_file fpn
      ok and gt_nonzero_leaf_pn_a_from_walker @wlk
    end

    def gt_nonzero_leaf_pn_a_from_walker wlk
      a = nil
      wlk.subtree_pathnames.each do |pn|
        pn = map_rdc_the_pn pn
        pn or next
        ( a ||= [] ) << pn
      end
      a ? a : when_no_paths
    end

    def when_no_paths
      bork "no \"code-node\" files found matching path from here - #{ @path }"
    end

    def map_rdc_the_pn pn
      if pn.has_notes
        procure_any_pn_w_notes pn
      else
        pn
      end
    end

    def procure_any_pn_w_notes pn
      a = pn.note_a
      if 1 == a.length and :line_had_space == a.first.type_i
        map_rdc_when_line_had_space pn
      else
        rprt_notes pn ; nil
      end
    end

    def map_rdc_when_line_had_space pn
      _listener = spcl_path_listener
      pn_ = Special_Path__[ _listener, pn, pn.note_a.first.x_a ]
      if pn_.is_valid then pn_ else
        rprt_notes pn ; nil
      end
    end

    def spcl_path_listener
      @spl ||= bld_special_path_listener
    end

    def bld_special_path_listener
      TestSupport_::Callback_::Listener::Suffixed[ :from_special, self ]
    end

    Special_Path__ = -> * x_a do
      API::Actions::Recursive__::Special_Path.new( * x_a )
    end

    def error_string_from_special s
      @err.puts "(special path says: #{ s })" ; nil
    end

    def rprt_notes pn
      pn.note_a.each do |note|
        chan_i, msg_s, _type_i, x_a = note.to_a
        _xtra = rndr_note_x_a x_a
        @err.puts "#{ chan_i }: #{ msg_s }. skipping - #{ pn }#{ _xtra }"
      end ; nil
    end

    def rndr_note_x_a x_a
      if x_a.length.nonzero?
        TestSupport_::Library_.touch :JSON
        " #{ ::Hash[ * x_a ].to_json }"
      end
    end

    def prcss_nonzero_leaf_pathname_a a
      before_all
      while (( pn = a.shift )) do
        false == (( r = process_walker_pathname pn )) and break
      end
      r
    end

    def before_all
      if @do_check
        @o = @out
      else
        @io = @o = TestSupport_::Library_::StringIO.new
      end ; nil
    end

    def process_walker_pathname pn
      @pn = pn
      if @do_list
        prcss_pn_when_list
      else
        prcss_pn_as_file
      end
    end

    def prcss_pn_when_list
      @out.puts @pth[ @pn ]
      SUCCEEDED__
    end

    def prcss_pn_as_file
      wrt_opener_glyphs
      ok = rslv_open_pathname
      ok &&= bld_doc_test_action
      ok &&= ok.execute
      ok and after_execute ok
    end

    def wrt_opener_glyphs
      if @do_check
        @err.puts "--- #{ @pth[ @pn ] } ---"
      else
        @err.write "<<< #{ @pth[ @pn ] } .. "
      end ; nil
    end

    def rslv_open_pathname
      if @do_check then SUCCEEDED__ else
        @opn = rslv_some_ouput_pathname
        @opn and SUCCEEDED__
      end
    end

    def rslv_some_ouput_pathname
      opn = get_output_pathname @pn
      opn and gt_valid_opn_from_opn opn
    end

    def gt_valid_opn_from_opn opn
      if opn.exist? && ! @do_force
         bork say_wont_overwrite_without_force opn
      else
        opn
      end
    end

    def say_wont_overwrite_without_force opn
      "won't overwrite without force - #{ @pth[ opn ] }"
    end

    def get_output_pathname pn_x
      pn = ::Pathname.new pn_x.to_path
      relp = pn.relative_path_from( @wlk.top_pn ).to_s
      md = TEST_RX__.match( relp ) or fail "sanity - #{ relp }"
      op = Output_Path__.new
      op.test_dir_pn = @wlk.top_pn.join md[ 0 ], SUBP_TEST_DIR__
      op.tail_pn = ::Pathname.new md.post_match
      if pn_x.respond_to? :construct_output_pathname
        pn_x.construct_output_pathname op
      else
        cnstrct_output_pathname op
      end
    end

    Output_Path__ = ::Struct.new :test_dir_pn, :tail_pn

    def cnstrct_output_pathname op
      tailpn = op.tail_pn
      _ext = tailpn.extname
      _tail = "#{ tailpn.sub_ext( '' ) }#{ TEST_FILE_SUFFIX }#{ _ext }"
      op.test_dir_pn.join _tail
    end

    def bld_doc_test_action
      bnd = API::Actions::DocTest.new
      bnd.set_expression_agent @expression_agent
      bnd.set_vtuple @vtuple
      bnd.absorb_services :out, @o, :err, @err, :pth, @pth
      _toa = rslv_any_template_option_a
      _r = bnd.absorb_params_using_message_yielder snitch.y,
        :core_basename, @core_basename,
        :do_close_output_stream, false,
        :load_file, nil,
        :load_module, nil,
        :pathname, @pn,
        :template_option_s_a, _toa
      _r && bnd
    end

    def rslv_any_template_option_a
      r = nil
      y_p = -> x do
        ( r ||= [] ) << x.to_s ; nil
      end
      if @pn.respond_to? :do_regret_setup
        if ! @pn.do_regret_setup
          y_p[ :exclude_regret_setup ]
        end
      end
      r
    end

    def after_execute ok
      if @do_check
        ok
      else
        flush
      end
    end

    def flush
      if @opn.dirname.exist?
        do_flush
      else
        dn = @opn.dirname
        @sn.say :notice, -> do
          ">>> directory does not exist - you must create it yourself: #{
            }#{ escape_path dn }"
        end
        false
      end
    end

    def do_flush
      bytes = nil
      @io.rewind
      opener = @is_dry_run ? RegretLib_::Dev_null[] : @opn
      opener.open WRITEMODE_ do |fh|
        bytes = fh.write @io.read
      end
      @err.puts ">>> #{ @pth[ @opn ] } written (#{ bytes }#{
        }#{ ' fake' if @is_dry_run } bytes)."
      @io.truncate 0
      @io.rewind
      SUCCEEDED__
    end

    # ~

    def bork msg
      @err.puts msg
      FAILED__
    end

    FAILED__ = false
    SUBP_TEST_DIR__ = 'test'.freeze
    SUCCEEDED__ = true
    TEST_DIR_DEPTH__ = 2
      TEST_RX__ = %r|\A(?:[^/]+/){#{ TEST_DIR_DEPTH__ }}[^/]+/?|
    TEST_FILE_SUFFIX = '_spec'.freeze
  end
end
