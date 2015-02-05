module Skylab::Callback

      class Stream__ < ::Proc  # see [#044]

        alias_method :gets, :call

        class << self

          def concat scan, scan_
            active = scan
            subsequent = scan_
            new do
              while true
                x = active.gets
                x and break
                subsequent or break
                active = subsequent
                subsequent = nil
              end
              x
            end
          end

          def the_empty_stream
            @tes ||= new do end
          end

          def expand scn, p
            scn_ = nil
            new do
              begin
                if ! scn_
                  x = scn.gets
                  x or break( scn = nil )
                  scn_ = p[ x ]
                  scn_ or redo  # can reduce too
                end
                x_ = scn_.gets
                x_ and break
                scn_ = nil
                redo
              end while nil
              x_
            end
          end

          def immutable_with_random_access
            Stream_::Immutable_with_Random_Access__
          end

          def map scn, p
            new do
              x = scn.gets
              x and x_ = p[ x ]
              x_
            end
          end

          def map_reduce scn, p
            new do
              while true
                x = scn.gets
                x or break
                x_ = p[ x ]
                x_ and break
              end
              x_
            end
          end

          def mutable_with_random_access
            Stream_::Mutable_with_Random_Access__
          end

          def ordered st
            Stream_::Ordered__[ st ]
          end

          def pair
            Pair_
          end

          def reduce scn, p
            new do
              begin
                x = scn.gets
                x or break
                _ok = p[ x ]
                _ok and break
                redo
              end while nil
              x
            end
          end

          def stream_class
            self
          end

          def via_item x, & p
            p_ = -> do
              p_ = EMPTY_P_
              x
            end
            scan = new do
              p_[]
            end
            p and scan = scan.map_reduce_by( & p )
            scan
          end

          def via_nonsparse_array a, & p
            d = -1 ; last = a.length - 1
            scan = new do
              if d < last
                a.fetch d += 1
              end
            end
            p and scan = scan.map_reduce_by( & p )
            scan
          end

          def via_times num_times, & p
            d = -1 ; last = num_times - 1
            scan = new do
              if d < last
                d += 1
              end
            end
            p and scan = scan.map_reduce_by( & p )
            scan
          end

          def with_random_access
            Stream_::With_Random_Access__
          end

        end  # >>

        def length_exceeds d
          does_exceed = false
          known_length = 0
          begin
            if known_length > d
              does_exceed = true
              break
            end
            gets or break
            known_length += 1
            redo
          end while nil
          does_exceed
        end

        def count
          d = 0
          d +=1 while gets
          d
        end

        def concat_by scan
          active = self
          self.class.new do
            while true
              x = active.gets
              x and break
              scan or break
              active = scan
              scan = nil
            end
            x
          end
        end

        def detect & p
          while x = gets
            p[ x ] and break
          end
          x
        end

        def flush_to_immutable_with_random_access_keyed_to_method i, * x_a
          Stream_::Immutable_with_Random_Access__.new self, i, x_a
        end

        def flush_to_mutable_box_like_proxy_keyed_to_method sym
          Stream_::Mutable_Box_Like_Proxy.via_flushable_stream__ self, sym
        end

        def map_detect & p
          while x = gets
            x_ = p[ x ] and break
          end
          x_
        end

        def expand_by & p
          self.class.expand self, p
        end

        def last
          begin
            x = gets
            x or break
            y = x
            redo
          end while nil
          y
        end

        def map & p
          to_enum.map( & p )
        end

        def map_reduce_by & p
          self.class.map_reduce self, p
        end

        def map_by & p
          self.class.map self, p
        end

        def push_by * x_a
          concat_by Stream_.via_nonsparse_array x_a
        end

        def reduce_by & p
          self.class.reduce self, p
        end

        def take d, & p
          a = []
          count = 0
          while count < d
            x = gets
            x or break
            if p
              x = p[ x ]
              x or break
            end
            count += 1
            x and a.push x
          end
          a
        end

        def to_a
          each.to_a
        end

        def each
          if block_given?
            x = nil
            yield x while x = gets
            nil
          else
            to_enum
          end
        end

        def with_signal_handlers * pairs
          Stream_::With_Signal_Processing__[ self, pairs ]
        end

        Stream_ = self
      end
end
