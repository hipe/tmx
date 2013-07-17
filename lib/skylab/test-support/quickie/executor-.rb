module Skylab::TestSupport

  module Quickie

    class Executor_

      def initialize y, test_file_path_a
        @y = y
        @test_file_path_a = test_file_path_a
        @ctx_class_a = []
        @be_verbose = nil
      end

      attr_accessor :be_verbose

      def resolve
        begin
          r = load_test_files or break
          r = build_client or break
          r = r.method :execute
        end while nil
        r
      end

      def add_context_class_and_resolve_notify ctx_class
        @ctx_class_a << ctx_class
        nil
      end

    private

      def load_test_files
        if ! (( a = @test_file_path_a )) then a else
          a.each do |path_s|
            @y << "(loading : #{ path_s })" if @be_verbose
            load path_s  # these attach context classes to the hookback above
          end
          true
        end
      end

      def build_client
        a = @ctx_class_a ; @ctx_class_a = nil
        cli = Quickie::Client.new @y, :no_root_context
        cli.tag_filter_p = MetaHell::MONADIC_TRUTH_
        cli.example_producer_p = -> branch, leaf do
          p = nil
          pp = -> do
            if p
              true
            elsif a.length.nonzero?
              p = Quickie::FUN.example_producer[ a.shift, branch, leaf ]
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
