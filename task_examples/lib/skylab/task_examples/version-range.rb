module Skylab::TaskExamples

  class VersionRange

    class << self

      def build string, & x_p

        o_a = []
        ok = true

        _s_a = string.split '.'
        _s_a.each do |s|
          o = Part.build s, & x_p
          if o
            o_a.push o
            next
          end
          ok = o
          break
        end
        if ok
          new o_a
        else
          ok
        end
      end

      private :new
    end  # >>

    def initialize part_a
      @parts = part_a
    end

    def to_s
      @parts.map(&:to_s).join('.')
    end

    def match version_string
      _parts = version_string.split('.')[0, @parts.length]
      @parts.zip(_parts).map{ |a, b| a.match(b) }.detect{ |b| !b }.nil?
    end

    module Part

      class << self

        def build str, & x_p

          if /\A(\d+)(\+)?\z/ =~ str
            $2 ? GreaterThanOrEqual.new($1.to_i) : Equal.new($1.to_i)
          else
            When_bad_string___[ str, & x_p ]
          end
        end
      end  # >>

      When_bad_string___ = -> s, & oes_p do

        msg = "Bad range assertion expression for version component:#{
          }#{ s.inspect }. We need something more like \"1.5+\" or \"1.2.3\"."

        if oes_p
          oes_p.call :error, :expression do |y|
            y << msg
          end
          UNABLE_
        else
          raise ::ArgumentError, msg
        end
      end

      class GreaterThanOrEqual
        def initialize int
          @integer = int
        end
        def match part_str
          /\A\d+\z/ =~ part_str or return false
          part_str.to_i >= @integer
        end
        def to_s
          "#{@integer}+"
        end
      end
      class Equal < GreaterThanOrEqual
        def initialize int
          @integer_as_string = int.to_s
        end
        def match part_str
          @integer_as_string == part_str
        end
        def to_s
          @integer_as_string.to_s
        end
      end
    end
  end
end
