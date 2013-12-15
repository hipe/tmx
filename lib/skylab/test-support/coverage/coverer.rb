module Skylab::TestSupport

  class Coverage::Coverer

    def initialize y, path_prefix_p
      @y = y
      @path_prefix_p = path_prefix_p
      @stat_a = a = [ ]
      @stat_h = ::Hash.new { |hh, k| a << k ; hh[ k ] = Stat__.new( k ) }
    end

    class Stat__
      def initialize i
        @count = 1 ; @normal = i
      end
      attr_reader :count, :normal
      def touch
        @count += 1 ; nil
      end
    end

    def cover
      ::Kernel.at_exit( & method( :report ) )
      p = $VERBOSE ; $VERBOSE = nil ; require 'simplecov' ; $VERBOSE = p
      sc = ::SimpleCov
      sc.start or raise "simplecov was not usaable."
      sc.command_name get_command_name
      path_prefix = @path_prefix_p.call
      len = path_prefix.length
      h = ::Hash.new do |hh, fn|
        hh[ fn ] = fn[ 0, len ] != path_prefix
      end
      sc.add_filter do |x|
        fn = x.filename
        @stat_h[ fn ].touch
        h[ fn ]
      end
      nil
    end

  private

    def get_command_name
      @cn ||= begin
        path = ::Pathname.new( @path_prefix_p.call ).
          relative_path_from( ::Skylab.dir_pathname ).to_s
        "#{ path } c/o #{ me }"
      end
    end

    def me
      @me ||= begin
        n = self.class.name
        n[ 0 .. ( n.rindex( ':' ) - 2 ) ]
      end
    end

    def report
      y = @y ; a = @stat_a ; h = @stat_h
      y << "( summary for number of times each file #{
        }touched for coverage by #{ me }: )"
      if a.length.zero?
        y << "( no results? )"
      else
        a.each do |i|
          x = h[ i ]
          y << "( #{ x.count } times: #{ x.normal } )"
        end
      end
      nil
    end
  end
end
