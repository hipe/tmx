module Skylab::Basic

  class Sexp

    class Stream < Callback_::Stream

      class << self

        def new * a
          k = Kernel__.new
          if a.length.nonzero?
            k.set_identity_via_args a
          end
          super k do
            k.gets
          end
        end
      end

      Callback_::Memoization::Pool[ self ].
        instances_can_be_accessed_through_instance_sessions

      def initialize k
        @k = k
      end

      def kernel
        @k
      end

      def set_identity * a
        @k.set_identity_via_args a ; nil
      end

      def clear_for_pool
        @k.clear_for_pool
      end

      def pos
        @k.position
      end

      def scan i
        @k.scan i
      end

      def last
        @k.last
      end

      class Kernel__

        # taking everything you know make a counting mapping peeking reducing reversable scanner

        def initialize
          @map_reduce_p = nil
        end

        def set_identity_via_args a
          @sexp, @i = a
          init_via_identity
        end

      private

        def init_via_identity
          @d = 0 ; @last = @sexp.length - 1
          if @i
            init_pass_p_for_matching
          else
            @pass_p_is_for_matching = false
            @pass_p = MONADIC_TRUTH_
          end
        end

      public

        def position
          @d
        end

        def scan i
          if ! @pass_p_is_for_matching
            init_pass_p_for_matching
          end
          @i = i
          gets
        end

      private

        def init_pass_p_for_matching
          @pass_p_is_for_matching = true
          @pass_p = -> x do
            if x.respond_to? :symbol_i
              @i == x.symbol_i
            end
          end ; nil
        end

      public

        def gets
          while @d < @last
            @d += 1
            _b = @pass_p[ @sexp.fetch @d ]
            if _b
              x = @sexp.fetch @d
              if @map_reduce_p
                x = @map_reduce_p[ x ]
                x or next
              end
              break
            end
          end
          x
        end

        def last
          d = @last + 1
          while d.nonzero?
            d -= 1
            _b = @pass_p[ @sexp.fetch d ]
            if _b
              x = @sexp.fetch d
              if @map_reduce_p
                x = @map_reduce_p[ x ]
                x or next
              end
              break
            end
          end
          x
        end

        def clear_for_pool
          @sexp = nil
        end
      end
    end
  end
end
