module Skylab::TestSupport

  module Quickie

    class Multi_::Run_

      def initialize svc, path_a
        @svc = svc ; @y = @svc.y
        @path_a = path_a
        @context_class_a = [ ]
      end

      def resolve argv
        @svc.attach_client_notify self
        load_paths
        cli = build_client
        if argv.length.nonzero?
          @svc.argument_error argv
        else
          cli.method :execute
        end
      end

      def add_context_class_and_resolve ctx
        @context_class_a << ctx
        nil
      end

    private

      def load_paths
        a = @path_a ; @path_a = nil
        while path = a.shift
          load path
        end
        nil
      end

      def build_client
        cli = Quickie::Client.new @svc.y, :no_root_context
        cli.tag_filter_p = MetaHell::MONADIC_TRUTH_
        cli.example_producer_p = -> branch, leaf do
          p = nil ; a = @context_class_a ; @context_class_a = nil
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
