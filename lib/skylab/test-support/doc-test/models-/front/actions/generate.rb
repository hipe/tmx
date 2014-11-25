module Skylab::TestSupport

  module Regret::API

  class Actions::DocTest < API_::Action  # #read [#015] the narrative

    # probably no one will ever find a reason to call our API directly
    # to generate doc-test output. but for the purposes of testing and
    # in the interest of system design, we have made an API anyway.
    #
    # our handle on the whole regret API is the 'API' module itself,
    # which you can call `invoke` on:
    #
    #     API = TestSupport_::Regret::API
    #     # API.debug!
    #     API.invoke( :ping )  # => :hello_from_regret
    #
    # we just pinged the API. if you uncomment the debug! line above, you
    # may see additional output. Note how we used "# =>" to indicate the
    # expected output from the line in our snippet. Note too that the snippet
    # is indented with four (4) spaces from the "normal" text.
    #
    # `ping` is one of several API actions (and the most boring, stable one at
    # that). the action we are interested in seeing is the `doc_test` action:
    #
    # let's write a comment that has a usage snippet showing how to generate
    # test code programmatically for this file you are reading,
    # from these comments you are reading:
    #
    #     here = API::Actions::DocTest.dir_pathname.sub_ext '.rb'
    #     output = TestSupport_.dir_pathname.
    #       join( 'test/regret/api/actions/doc-test_spec.rb')
    #     stat = output.stat ; size1 = stat.size ; ctime1 = stat.ctime
    #       # (this test assumes one such file already exists)
    #
    #     exitstatus = API.invoke :doc_test, pathname: here, output_path: output
    #       # the moneyshot. did it work?
    #
    #     exitstatus  # => 0
    #       # exit status zero means success. it's the 1970's
    #     stat = output.stat
    #     stat.size  # => size1
    #       # the size should have stayed the same
    #     ( stat.ctime == ctime1 )  # => false
    #       # but the ctimes should be different
    #
    # (if that worked, that's just ridiculous. to see that this is working,
    # add e.g a blank like to the generated test file and re-run it again.
    # it should fail only the first time it is re-run.  #storypoint-15

    services [ :out, :ivar ],
             [ :err, :ivar ],
             [ :pth, :ivar ]

    params [ :core_basename, :arity, :zero_or_one ],
      [ :do_close_output_stream, :arity, :zero_or_one, :default, -> { true } ],
      [ :do_force, :arity, :zero_or_one ],
      [ :load_file, :arity, :zero_or_one ],
      [ :load_module, :arity, :zero_or_one ],
      [ :pathname, :arity, :zero_or_one ],
      [ :template_option_s_a, :arity, :zero_or_more ],
      API_::Conf::Verbosity[ self ].param( :vtuple )

    def initialize( * )
      @core_basename = nil  # until we figure out something
      super
    end

    def absorb_any_services_from_parameters_notify param_h
      if (( outpath_x = param_h.delete :output_path ))
        fh = ::File.open "#{ outpath_x }", WRITE_MODE_
        accept_value_as_service fh, :out
      end
    end

    def execute
      snitch
      ok = rslv_load_module
      ok &&= rslv_upstream
      ok &&= rslv_specer
      ok &&= exec_scan_each_block_if_appropriate
      ok &&= exec_flush
      finally
      @result
    end

  private

    def rslv_load_module
      if @load_module
        ok = mdls_module::Constant_.validate @sn, @load_module
        if ok
          PROCEDE_
        else
          @result = ok
        end
      else
        PROCEDE_
      end
    end

    def mdls_module
      DocTest_::Models_
    end

    def rslv_upstream
      ok, up = prcr_upstream_status_tuple
      if ok
        @upstream = up
      else
        @result = ok
      end
      ok
    end

    def prcr_upstream_status_tuple
      if ! @pathname then [ true, nil ] else # #storypoint-115
        up, e = rslv_upstream_status_tuple
        if up then [ true, up ]
        else
          @sn.puts "#{ e }"
          @sn.puts "aborting."
          [ false, nil ]
        end
      end
    end

    def rslv_upstream_status_tuple
      begin
        up = ::File.open @pathname.to_path, 'r'
      rescue ::Errno::ENOENT => e
      end
      [ up, e ]
    end

    def rslv_specer
      sp = bld_specer @sn
      ok = sp.set_template_options @template_option_s_a
      if ok
        @specer = sp ; PROCEDE_
      else
        @result = ok
      end
    end

    def bld_specer snitch
      _path = @pathname && @pathname.to_path
      DocTest_::Specer__.new :snitch, @sn,
        :core_basename, @core_basename, :load_file, @load_file,
        :load_module, @load_module, :outstream, @out,
        :path, _path, :templo_name, :quickie
    end

    def exec_scan_each_block_if_appropriate
      if @upstream
        exec_scan_each_block
      else
        PROCEDE_
      end
    end

    def exec_scan_each_block
      bs = DocTest_::Comment_::Block::Stream[ @sn, @upstream ]
      cblock = bs.gets
      while cblock
        if @vtuple.do_murmur
          cblock.describe_to @err
        end
        if cblock.does_look_testy
          @specer.accept cblock
        end
        cblock = bs.gets
      end
      PROCEDE_
    end

    def exec_flush
      ok = @specer.flush
      if ok
        emit_done_message
        @result = SUCCESS_EXITSTATUS__
        PROCEDE_
      else
        @result = ok
      end
    end

    def emit_done_message
      if @vtuple.do_medium
        @sn.puts "finished generated output for #{ @pathname }"
      elsif @vtuple.do_notice
        @sn.puts 'done.'
      end ; nil
    end

    def finally
      @do_close_output_stream and ( @out.closed? || @out.tty? or @out.close )
      nil
    end

    DocTest_ = self
    SEP_ = '# =>'.freeze
    SUCCESS_EXITSTATUS__ = 0
    Autoloader_[ Templos__ = ::Module.new, :boxxy ]

  end
  end
end
