module Skylab::Test

  module Field_

    class Flag_

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
          @fuzzy ||= Fuzzy_Matcher_[
            moniker, self.class.const_get( :FUZZY_MIN_, false ) ]
          @fuzzy[ argv.fetch 0 ]
        end
      end
    end

    Fuzzy_Matcher_ = -> moniker, min do
      len = moniker.length
      -> tok do
        (( tlen = tok.length )) > len and break
        moniker[ 0, tlen ] == tok
      end
    end

    class Int_ < Flag_

      RX_ = /\A\d+\z/

      Scan_token = -> tok do
        RX_ =~ tok and tok.to_i
      end

      SCAN_INT_ = -> argv do
        if argv.length.nonzero? and RX_ =~ argv.fetch( 0 )
          argv.shift.to_i
        end
      end

      def parse memo, argv
        if (( int = SCAN_INT_[ argv ] ))
          memo[ @predicates.fetch 0 ] = int
          [ true, true ]
        end
      end
    end

    class Box_ < Headless::Plugin::Box_
      def << fld
        add fld.i, fld
        nil
      end
      def map &blk
        if blk
          @a.map { |i| blk[ @h.fetch i ] }
        else
          @a.map { |i| @h.fetch i }
        end
      end
      def reduce *a, &b
        map.reduce( *a, &b )
      end
    end

    class Values_ < ::Struct

      class << self
        alias_method :orig_new, :new
      end

      def self.new box
        a = box.reduce [] do |m, fld|
          m.concat fld.predicates
        end
        orig_new( *a )
      end

      def []= first_name, *other_names, val_x
        if other_names.length.zero? then super else
          if ( other_names.unshift first_name ).length < val_x.length
            raise ::ArgumentError, "too many arguments (#{ val_x.length })#{
              } for #{ other_names.length })"
          end
          other_names.each_with_index do |i, idx|
            super i, val_x.fetch( idx )
          end
          val_x
        end
      end

      def [] key, *rest
        if rest.length.zero? then super else
          ( rest.unshift key ).map { |k| super( k ) }
        end
      end
    end
  end
end
