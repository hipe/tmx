module Skylab::TestSupport::Regret::API

  class API::Actions::DocTest < API::Action

    # probably no one will ever find a reason to call our API directly
    # to generate doc-test output. but for the purposes of testing and
    # in the interest of system design, we have made an API anyway.
    #
    # our handle on the whole regret API is the 'API' module itself,
    # which you can call `invoke` on:
    #
    #     API = Skylab::TestSupport::Regret::API
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
    #     here = API::Actions::DocTest.pathname
    #     output = TestSupport.dir_pathname.
    #       join( 'test/regret/api/actions/doc-test_spec.rb')
    #     stat = output.stat ; size1 = stat.size ; ctime1 = stat.ctime
    #       # (this test assumes one such file already exists)
    #
    #     exitstatus = API.invoke :doc_test, path: here, output_path: output
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
    # it should fail only the first time it is re-run. see [#ts-015])

    services [ :out, :ivar ],
             [ :err, :ivar ],
             [ :pth, :ivar ]

    params [ :core_basename, :arity, :zero_or_one ],
      [ :do_close_output_stream, :arity, :zero_or_one, :default, -> { true } ],
      [ :load_file, :arity, :zero_or_one ],
      [ :load_module, :arity, :zero_or_one ],
      [ :path, :arity, :zero_or_one ],
      [ :template_option_a, :arity, :zero_or_one ],
      API::Conf::Verbosity[ self ].param( :vtuple )

    def initialize( * )
      @core_basename = nil  # until we figure out something
      super
    end

    def absorb_any_services_from_parameters_notify param_h
      if (( outpath_x = param_h.delete :output_path ))
        fh = ::File.open "#{ outpath_x }", WRITEMODE_
        accept_value_as_service fh, :out
      end
    end

    def execute
      res = -> do  # (we jump through hoops to allow the system to go through all
        # of its motions without a @path just so that the template options
        # can display without there needing to be a valid input stream.)
        snitch
        r = validate_appearances or break r
        ok, up = resolve_upstream_status_tuple
        ok or break up
        up and bs = DocTest::Comment_::Block::Scanner[ @sn, up ]
        sp = build_specer @sn
        sp.set_template_options @template_option_a or break( false )
        if bs
          while cblock = bs.gets
            @vtuple.do_murmur and cblock.describe_to @err
            cblock.does_look_testy and sp.accept cblock
          end
        end
        r = sp.flush or break r
        say_done
        0
      end.call
      @do_close_output_stream and ( @out.closed? || @out.tty? or @out.close )
      res
    end

  private

    def validate_appearances
      begin
        if @load_module
          r = models::Constant_.validate( @sn, @load_module ) or break
        end
        r = true
      end while nil
      r
    end

    def models
      DocTest::Models_
    end

    def resolve_upstream_status_tuple
      if ! @path then [ true, nil ] else
        up, e = get_up_or_error
        if up then [ true, up ]
        else
          @sn.puts "#{ e }"
          @sn.puts "aborting."
          [ false, nil ]
        end
      end
    end

    def get_up_or_error
      begin
        up = ::File.open @path, 'r'
      rescue ::Errno::ENOENT => e
      end
      [ up, e ]
    end

    def build_specer snitch
      DocTest::Specer_.new :core_basename, @core_basename,
        :load_file, @load_file, :load_module, @load_module,
        :outstream, @out, :snitch, snitch, :templo_name, :quickie,
        :path, @path
    end

    def say_done
      if @vtuple.do_medium
        @sn.puts "finished generated output for #{ @path }"
      elsif @vtuple.do_notice
        @sn.puts 'done.'
      end
    end

    # we have a hefty branch node - this is used by our many children

    API = API
    Basic = Basic
    DocTest = self ; Face = Face
    MetaHell = MetaHell
    Regret = ::Skylab::TestSupport::Regret
    SEP = '# =>'.freeze

  end
end
