module Skylab::MetaHell

  module Parse

    class Fields__::Flag < Parse::Field_

      class << self

        def [] * a
          new( * a )
        end

        def via_arglist a
          new( * a )
        end
      end

      VM_ = [ :moniker, :first_desc_line ].freeze

      def self.visible_members
        VM_
      end

      def initialize i=nil, predicate_x=nil, desc_line_x=nil
        super()
        @i = i
        @predicates = [ * predicate_x ]
        @dsc_line_a = [ * desc_line_x ]
      end

      def get_desc_line_a
        @dsc_line_a && @desc_line_a.dup
      end

      def looks_like_particular_field
        true
      end

      attr_reader :i, :predicates, :short_s, :long_s, :fuzzy_min_d

      def visible_values
        self.class.visible_members.map { |i| send i }
      end

      def get_moniker
        @i.to_s
      end

      def first_desc_line
        @dsc_line_a.fetch 0
      end

      def normal_parse memo, argv
        if @normal_parse_p then super else
          if head_matches argv
            argv.shift
            memo[ @predicates.fetch 0 ] = true
            [ true, true ]
          end
        end
      end

      def pool_proc
        @pool_proc ||= method( :normal_parse )
      end

      def scan_token token  # result must be true or nil
        true if head_matches_token token
      end

      def any_index_of_consumed_token_anywhere_in_argv argv
        if (( idx = any_index_of_token_anywhere_in_argv argv ))
          argv[ idx, 1 ] = EMPTY_A_
          idx
        end
      end

      def any_index_of_token_anywhere_in_argv argv
        argv.index( & method( :head_matches_token ) )
      end

      def head_matches argv
        argv.length.nonzero? && head_matches_token( argv.fetch 0 )
      end

      def head_fuzzy_matches argv
        if argv.length.nonzero?
          @fuzzy ||= Parse::Fuzzy_matcher_[
            self.class.const_get( :FUZZY_MIN_, false ), moniker ]
          @fuzzy[ argv.fetch 0 ]
        end
      end

      def head_matches_token tok  # result is treated as true-ish
        r = true
        begin
          ( @literal ||= @i.to_s ) == tok and break
          short_s and @short_s == tok and break
          long_s and @long_s == tok and break
          fuzzy_min_d or break( r = false )
          Fuzzy_matcher_[ @fuzzy_min_d, get_moniker ][ tok ] and break
          long_s and  # kind of ridiculous
            Fuzzy_matcher_[ @fuzzy_min_d + 2, @long_s ][ tok ] and break
          r = false
        end while nil
        r
      end

      def to_a
        a = [ ]
        s = get_moniker and a << :moniker << s
        a << :token_stream << method( :scan_token )
        a
      end

    private

      def moniker  # this is how we override a field defined in parent
        super
        @i ||= @moniker ; nil
      end

    MetaHell_::Fields::From.methods do  # #borrow-one-indent

      def predicate
        @predicates.push iambic_property ; nil
      end

      def short
        iambic_property_set_only_once :@short_s
      end

      def long
        iambic_property_set_only_once :@long_s
      end

      def fuzzy_min
        iambic_property_set_only_once :@fuzzy_min_d
      end

    end  # #pay-one-back
    end
  end
end
