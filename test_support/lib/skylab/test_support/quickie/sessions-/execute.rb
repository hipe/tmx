module Skylab::TestSupport

  module Quickie

    class Sessions_::Execute

      def initialize y, test_file_path_a, pn_s_a
        @ctx_class_a = []
        @ok = true
        @_pn_s_a = pn_s_a
        @tag_shell = nil
        @tag_filter_p = MONADIC_TRUTH_
        @test_file_path_a = test_file_path_a
        @be_verbose = nil
        @y = y
        block_given? and yield self
      end

      attr_accessor :be_verbose

      def with_iambic_phrase x_a
        @x_a = x_a
        send :"#{ x_a.fetch 0 }="
        @x_a = nil
        self
      end

      def produce_bound_call
        ok = @ok
        ok &&= load_test_files
        ok &&= resolve_client
        ok && via_client_produce_bound_call
      end

      def receive_test_context_class___ ctx_class
        @ctx_class_a << ctx_class
        nil
      end

    private

      def tag=

        ts = tag_shell

        1.upto( @x_a.length - 1 ).each do |d|
          ts.receive_tag_argument @x_a.fetch d
        end

        NIL_
      end

      def tag_shell
        @tag_shell ||= bld_tag_shell
      end

      def bld_tag_shell
        @excluded_count = 0
        wt_p_a = bk_p_a = nil
        @tag_filter_p = -> tagset do
          do_allow = true
          if bk_p_a
            bk_p_a.each do |p|
              _ok = p[ tagset ]
              if ! _ok
                do_allow = false
                break
              end
            end
          end
          if wt_p_a && do_allow
            do_allow = false
            wt_p_a.each do |p|
              _ok = p[ tagset ]
              if _ok
                do_allow = true
                break
              end
            end
          end
          if ! do_allow
            @excluded_count += 1
          end
          do_allow
        end

        Tags_Receiver_.new(

          :on_error, -> x do
            @ok = false
            @y << "#{ x }" ; nil
          end,

          :on_pass_filter_proc, -> p do
            ( wt_p_a ||= [] ).push p ; nil
          end,

          :on_no_pass_filter_proc, -> p do
            ( bk_p_a ||= [] ).push p ; nil
          end,

          :on_info_qualified_knownness, method( :report_tag ),
        )
      end

      def report_tag i, i_, x
        send :"report_#{ i }_tag", i_, x ; nil
      end

      def report_include_tag i, x
        @did_report_include_tag_once ||= begin
          @y << "(iff included then the test is run)" ; nil
        end
        @y << "(if not excluded and #{ i }:#{ x } then the test is included)" ; nil
      end

      def report_exclude_tag i, x
        @y << "(if #{ i }:#{ x } then the test is excluded)" ; nil
      end

      def load_test_files
        if ! (( a = @test_file_path_a )) then a else
          a.each do |path_s|
            @y << "(loading : #{ path_s })" if @be_verbose
            load path_s  # these attach context classes to the hookback above
          end
          true
        end
      end

      def resolve_client
        @client = build_client
        if @tag_shell
          @client.at_end_of_run do
            if @excluded_count.nonzero?
              @y << "(#{ @excluded_count } tests were excluded because tags)"
            end
          end
        end
        true
      end

      def via_client_produce_bound_call
        Common_::Bound_Call[ nil, @client, :execute_ ]
      end

      def build_client

        a = @ctx_class_a ; @ctx_class_a = nil

        cli = Run_.new @y, :no_root_context, @_pn_s_a

        cli.filter_by_tags_by__( & @tag_filter_p )

        cli.produce_examples_by__ do | branch, leaf |
          p = nil
          pp = -> do
            if p
              true
            elsif a.length.nonzero?
              p = Build_example_stream_proc_[ a.shift, branch, leaf ]
              true
            end
          end
          none = get_saw_none_p
          -> do
            res = catch :res do
              while true
                pp[] or throw :res
                r = p[] and throw :res, r
                p = nil
              end
            end
            none[ res ]
          end
        end
        cli
      end

      def get_saw_none_p
        saw_none = true
        -> res do
          if saw_none
            if res
              saw_none = false
            else
              @y << "(no examples found by recursive runner)"
            end
          end
          res
        end
      end
    end
  end
end
