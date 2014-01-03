module Skylab::Snag

  class Models::Hashtag

    module Parse

      def self.[] listener, str
        Parse__.new( listener, str ).execute
      end

      class Parse__
        def initialize _listener, str
          @scn = Snag::Services::StringScanner.new str
        end
        def execute
          y = []
          while ! @scn.eos?
            str = @scn.scan RX___
            tag = @scn.scan RX__
            str or tag or fail "parse failure: #{ @str.rest.inspect }"
            str and y << bld_str( str )
            tag and y << bld_tag( tag )
          end
          y
        end
        rxs = '#[A-Za-z0-9]+(?:[-_:][A-Za-z0-9]+)*'
        RX__ = /#{ rxs }/
        RX___ = /(?:(?!#{ rxs }).)+/
        #API-private:after-merge
      private
        def bld_str str
          String__.new str
        end
        def bld_tag str
          Models::Hashtag.new str
        end
      end

      class String__
        def initialize str
          @to_s = str ; nil
        end
        attr_reader :to_s
        def type_i
          :string
        end
      end
    end

    def initialize s
      @is_complex = s.include? COLON__
      @to_s = s
      freeze
    end
    attr_reader :is_complex, :to_s
    def type_i
      :hashtag
    end
    def is_simple
      ! is_complex
    end
    def without_hash
      @to_s[ 1 .. -1 ]
    end

    def to_stem_and_value
      if @is_complex
        d = @to_s.index COLON__
        [ @to_s[ 1 .. d - 1 ], @to_s[ d + 1 .. -1 ] ]
      else
        [ without_hash, nil ]
      end
    end

    def get_stem
      if @is_complex
        d = @to_s.index COLON__
        @to_s[ 1 .. d - 1 ]
      else
        without_hash
      end
    end

    COLON__ = ':'.freeze
  end
end
