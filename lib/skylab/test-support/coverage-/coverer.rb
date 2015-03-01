module Skylab::TestSupport

  class Coverage::Coverer

    def initialize y, path_prefix_p
      @path_prefix_p = path_prefix_p
      @stat_a = a = [ ]
      @stat_h = ::Hash.new { |hh, k| a << k ; hh[ k ] = Stat__.new( k ) }
      @y = y
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
      @sc = ::SimpleCov
      @sc_result = @sc.start
      if @sc_result
        cover_when_sc_OK
      else
        cover_when_sc_not_OK
      end ; nil
    end

  private

    def cover_when_sc_not_OK
      @y << "(#{ me } assuming s.c was ok, even though #{
        }had #{ @sc_result.inspect })"
      cover_when_sc_OK
    end

    def cover_when_sc_OK
      @sc_was_OK = true
      @sc.command_name get_command_name
      path_prefix = @path_prefix_p.call
      len = path_prefix.length
      h = ::Hash.new do |hh, fn|
        hh[ fn ] = fn[ 0, len ] != path_prefix
      end
      @sc.add_filter do |x|
        fn = x.filename
        @stat_h[ fn ].touch
        h[ fn ]
      end
      nil
    end

    def get_command_name
      @cn ||= begin
        path = ::Pathname.new( @path_prefix_p.call ).
          relative_path_from( ::Skylab.dir_pathname ).to_s
        "#{ path } c/o #{ me }"
      end
    end


    def report
      if @sc_was_OK
        report_when_sc_OK
      else
        report_when_sc_not_OK
      end
    end

    def report_when_sc_OK
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

    def report_when_sc_not_OK
      @y << "#{ me } hasn nothing to report because s.c was not ok." ; nil
    end

    def me
      @me ||= infer_name
    end

    def infer_name
      n = self.class.name
      n[ 0 .. ( n.rindex( ':' ) - 2 ) ]
    end
  end
end
