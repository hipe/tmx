module Skylab::TestSupport

  module Quickie

    class Execute__

      def initialize y, test_file_path_a
        @ctx_class_a = []
        @ok = true
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

      def add_context_class_and_resolve_notify ctx_class
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
        Tag_Shell_.new :on_error, -> x do
          @ok = false
          @y << "#{ x }" ; nil
        end,
        :on_pass_filter_proc, -> p do
          ( wt_p_a ||= [] ).push p ; nil
        end, :on_no_pass_filter_proc, -> p do
          ( bk_p_a ||= [] ).push p ; nil
        end,
        :on_info_trio, method( :report_tag )
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
        Bound_Call__.new @client, :execute
      end
      Bound_Call__ = ::Struct.new :receiver, :method_name, :args

      def build_client
        a = @ctx_class_a ; @ctx_class_a = nil
        cli = Client_.new @y, :no_root_context
        cli.tag_filter_p = @tag_filter_p
        cli.example_producer_p = -> branch, leaf do
          p = nil
          pp = -> do
            if p
              true
            elsif a.length.nonzero?
              p = Example_producer_[ a.shift, branch, leaf ]
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
