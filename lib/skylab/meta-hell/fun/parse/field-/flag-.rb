module Skylab::MetaHell

  module FUN::Parse

    class Field_::Flag_ < Field_

      class << self ; alias_method :[], :new end

      VM_ = [ :moniker, :first_desc_line ].freeze

      def self.visible_members
        VM_
      end

      def initialize i, predicate_x=nil, desc_line_x=nil
        @i = i
        @predicates = [ * predicate_x ]
        @desc_lines = [ * desc_line_x ]
      end

      attr_reader :i, :predicates, :desc_lines

      def visible_values
        self.class.visible_members.map { |i| send i }
      end

      def moniker
        @i.to_s
      end

      def first_desc_line
        @desc_lines.fetch 0
      end

      def parse memo, argv
        if head_matches argv
          argv.shift
          memo[ @predicates.fetch 0 ] = true
          [ true, true ]
        end
      end

      def scan_token token  # result must be true or nil
        true if head_matches_token token
      end

      def head_matches_token tok  # result is treated as true-ish
        ( @literal ||= @i.to_s ) == tok
      end

      def to_a
        a = [ ]
        s = moniker and a << :moniker << s
        a << :token_scanner << method( :scan_token )
        a
      end

    private

      def head_matches argv
        argv.length.nonzero? && head_matches_token( argv.fetch 0 )
      end

      def head_fuzzy_matches argv
        if argv.length.nonzero?
          @fuzzy ||= Parse::Fuzzy_Matcher_[
            moniker, self.class.const_get( :FUZZY_MIN_, false ) ]
          @fuzzy[ argv.fetch 0 ]
        end
      end
    end
  end
end
