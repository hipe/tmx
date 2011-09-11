module Skylab;  end
module Skylab::Face
  class DependencyGraph::VersionRange
    class << self
      alias_method :build, :new
    end
    def initialize str
      @parts = str.split('.')
      @parts = @parts.map { |p| Part.build(p) }
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
        def build str
          if /\A(\d+)(\+)?\z/ =~ str
            $2 ? GreaterThanOrEqual.new($1.to_i) : Equal.new($1.to_i)
          else
            fail(<<-HERE.gsub("\n", " ").gsub(/  +/, ' ')
              Bad range assertion expresion for version component: #{str.inspect}.
              We need something more like "1.5+" or "1.2.3"
            HERE
            )
          end
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
