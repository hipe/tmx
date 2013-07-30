module Skylab::MetaHell

  module FUN::Parse

    class Field_::Flag_ < Field_

      class << self ; alias_method :[], :new end

      VM_ = [ :moniker, :first_desc_line ].freeze

      def self.visible_members
        VM_
      end

      def initialize i=nil, predicate_x=nil, desc_line_x=nil
        super()
        @i = i
        @predicates = [ * predicate_x ]
        @desc_lines = [ * desc_line_x ]
      end

      def looks_like_particular_field
        true
      end

      attr_reader :i, :predicates, :desc_lines

      def visible_values
        self.class.visible_members.map { |i| send i }
      end

      def get_moniker
        @i.to_s
      end

      def first_desc_line
        @desc_lines.fetch 0
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

      def head_matches_token tok  # result is treated as true-ish
        ( @literal ||= @i.to_s ) == tok
      end

      def to_a
        a = [ ]
        s = get_moniker and a << :moniker << s
        a << :token_scanner << method( :scan_token )
        a
      end

    private

      def moniker a
        super
        @i ||= @moniker
        nil
      end

    FUN::Fields_::From_.methods do  # (borrow one indent)

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
      def predicate a
        @predicates.push a.fetch( 0 ) ; a.shift
        nil
      end

    end  # (pay one back)
    end
  end
end
