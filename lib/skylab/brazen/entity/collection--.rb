module Skylab::Brazen

  module Entity

    module Collection__

      class Scan < ::Proc

        alias_method :gets, :call

        class << self

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

          def nonsparse_array a
            d = -1 ; last = a.length - 1
            new do
              if d < last
                a.fetch d += 1
              end
            end
          end

          def reduce scn, p
            new do
              while true
                x = scn.gets
                x or break
                ok_ = p[ x ]
                ok_ and break
              end
              x
            end
          end
        end  # >>

        def concat_by scn
          active = self
          self.class.new do
            while true
              x = active.gets
              x and break
              scn or break
              active = scn
              scn = nil
            end
            x
          end
        end

        def map_reduce_by & p
          self.class.map_reduce self, p
        end

        def map_by & p
          self.class.map self, p
        end

        def push_by * x_a
          concat_by Scan.nonsparse_array x_a
        end

        def reduce_by & p
          self.class.reduce self, p
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
      end
    end
  end
end
