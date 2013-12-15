module Skylab::Headless

  module CLI::Action

    class Queue__  # part of [#143] (but the main logic is in action base i.m)

      def initialize a
        a or raise ::ArgumentError, "queue must be build by now"
        @a = a ; nil
      end

      def enqueue_with_args_notify meth_i, arg_a
        @a << Frame__.new( meth_i, arg_a ) ; nil
      end
      Frame__ = ::Struct.new :meth_i, :arg_a

      def peek_some_element_x
        @a.length.zero? and raise say_empty
        @a.first or raise say_corrupt
      end

      def peek_any_some_element_i  # #storypoint-120
        pk_some_i_when_nonzero if @a.length.nonzero?
      end

      def peek_any_element_i
        @a.first if @a.length.nonzero? and @a.first.respond_to? :id2name
      end

      def is_on_last_frame
        1 == @a.length
      end

    private

      def pk_some_i_when_nonzero
        (( i = @a.first )).respond_to?( :id2name ) or raise say_not_i
        i
      end

      def say_corrupt
        "queue had a false-ish element in the front: #{ @a[ 0 ].inspect }"
      end

      def say_empty
        "expected at least one frame, but queue is empty"
      end

      def say_not_i
        "expected symbol had #{ Headless::FUN::Inspect[ @a[ 0 ] ] }"
      end

    public

      def begin_dequeue client  # resolve call tuple
        Dequeue.new( client, self ).execute
      end

      class Dequeue

        def initialize client, queue
          @client = client ; @frame_x = queue.peek_some_element_x
          @queue = queue
        end

        def execute
          if @frame_x.respond_to? :call
            resolve_for_proc
          else
            resolve_for_frame
          end
        end
      private
        def resolve_for_proc
          if @queue.is_on_last_frame
            resolve_for_proc_when_on_last_frame
          else
            resolve_for_proc_when_not_on_last_frame
          end
        end

        def resolve_for_proc_when_on_last_frame
          use_client_to_validate_proc_syntax_against @client.release_argv
        end

        def resolve_for_proc_when_not_on_last_frame
          use_client_to_validate_proc_syntax_against MetaHell::EMPTY_A_
        end

        def use_client_to_validate_proc_syntax_against actual_x_a
          stx = CLI::Argument::Syntax::Isomorphic.new @frame_x.parameters
          r = @client.with_arg_stx_prcss_args stx, actual_x_a
          r and [ OK_, @frame_x.method( :call ), actual_x_a ]
        end

        def resolve_for_frame
          arg_a = @frame_x.arg_a ; bound_meth = @client.method @frame_x.meth_i
          stx = CLI::Argument::Syntax::Isomorphic.new bound_meth.parameters
          r = @client.with_arg_stx_prcss_args stx, arg_a
          r and [ OK_, bound_meth, arg_a ]
        end
      end
    end
  end
end
