
module Skylab::GitViz::Tasks

  class Build_RBX::Curl_version__

    def initialize y
      @y = y ; yield self
      @attempt_prototype = Attempt__.curry y do |at|
        at.url_head = @url_head ; at.url_tail = @url_tail
      end ; @did_change = nil
    end
    attr_accessor :url_head, :url_tail

    def most_recent_known_version_s= s
      @version = ::Gem::Version.new s ; s
    end

    def execute
      ok = synchronously_find_greatest_minor_version
      ok &&= synchronously_find_greatest_patch_version
      ok && build_result
    end
  private
    def synchronously_find_greatest_minor_version
      synchronously_find_greatest_version_at_digit 1
    end
    def synchronously_find_greatest_patch_version
      synchronously_find_greatest_version_at_digit 2
    end
    def synchronously_find_greatest_version_at_digit d
      curr_a = @version.segments
      ( d + 1 ).upto( curr_a.length - 1 ) do |d_|
        curr_a[ d_ ] = 0
      end
      ok = stay = true ; last_positive_attempt = nil
      begin
        curr_a[ d ] += 1
        attempt = @attempt_prototype.curry do |at|
          at.version_string = curr_a * '.'
        end
        ok = attempt.execute -> two_hundred_line do
          @y << "(version #{ curr_a * '.' } #{ two_hundred_line })"
          last_positive_attempt = attempt
        end, -> four_o_four_line do
          @y << "(no #{ curr_a * '.' } yet (#{ four_o_four_line }))"
          stay = false
        end
        ok or stay = false
      end while stay
      ok and mutate_version last_positive_attempt
    end
    def mutate_version attempt
      if attempt
        v2 = attempt.get_version
        @y << "(bumping greatest known version from #{ @version } to #{ v2 })"
        @version = v2 ; @did_change = true
        @last_attempt_with_change = attempt
      end
      true
    end
    def build_result
      x = @did_change && @last_attempt_with_change.get_url
      Result__.new @did_change, @version, x
    end
    Result__ = ::Struct.new :did_change, :version, :url

    class Attempt__
      class << self
        alias_method :curry, :new
      end
      def initialize y
        @connect_timeout = 5 ; @y = y ; yield self
      end
      attr_writer :url_head, :url_tail, :version_string
      def initialize_copy otr
        @y = otr.y ; @url_head = otr.url_head ; @url_tail = otr.url_tail
        @version_string = otr.version_string
      end
    public
      def get_url
        @url_head && @url_tail && @version_string or
          raise ::ArgumentError, "cannot resolve url, missing parts"
        "#{ @url_head }#{ @version_string }#{ @url_tail }"
      end
      def get_version
        @version_string or raise "no argument string"
        ::Gem::Version.new @version_string
      end
      attr_reader :version_string
    protected
      attr_reader :y, :url_head, :url_tail
    public
      def curry & p
        p[ otr = dup ] ; otr
      end
      def execute yes_p, no_p
        _, @o, @e, @w = Build_RBX::Open3[].
            popen3 'curl', '--head', '--connect-timeout',
          @connect_timeout.to_s, get_url
        ok = synchronous_read
        if ok
          case @first_out_line
          when FOUR_O_FOUR_RX__ ; no_p[ @first_out_line ]
          when TWO_HUNDRED_OK__ ; yes_p[ @first_out_line ]
          else
            @y << "this is a hack, not a spider. we aren't prepared #{
              }for this response header: #{ @first_out_line.inspect }"
            ok = false
          end
        end
        ok
      end
      http_rxs = 'HTTP/\d+(?:\.\d+)*'
      FOUR_O_FOUR_RX__ = %r(\A#{ http_rxs } 404\b(?: NOT FOUND\b)?)i
      TWO_HUNDRED_OK__ = %r(\A#{ http_rxs } 200\b(?: OK\b)?)i
    private
      def synchronous_read
        line = @o.gets ; @o.close
        line && line.chomp!
        @first_out_line = line
        ok = true
        while (( s = @e.gets ))
          if ! @first_out_line
            @y << "(#{ s.chomp })"
          end
        end
        if ! (( es = @w.value.exitstatus )).zero?
          ok &&= false
          @y << "(existatus from curl was #{ es })"
        end
        ok
      end
    end
  end
end
