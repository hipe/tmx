module Skylab::TanMan::TestSupport::CLI

  module InstanceMethods

    remove_method :expect_section
    def expect_section *a, &p
      Expect_Section__.new( self, a, p ).flush
    end
  end

  class Expect_Section__

    def initialize ctx, a, p
      @a = a ; @p = p
      @one_line_regex = nil
      @test_context = ctx
    end

    def flush
      parse
      begin
        @section_label_string_stem and ( expect_section_label or break )
        @one_line_regex and ( expect_one_line_with_regex or break )
        @p and instance_exec( & @p )
        (( s = peek )) and BLANK_RX__ =~ s and skip_line
          # always skip any blank line at the end of a section
      end while nil
      nil
    end
    #
    BLANK_RX__ = /\A\z/

  private

    def parse
      (( s = @a.shift )).respond_to?( :ascii_only? ) or
        raise ::TypeError, "need string had #{ s.class } for section label"
      @section_label_string_stem = s
      if @a.length.nonzero?
        @p and raise ::ArgumentError, "can't have iambic and block"
        send OP_H__.fetch( @a.shift )
      end
      nil
    end
    #
    OP_H__ = { one_line: :parse_one_line }.freeze
    #
    def parse_one_line
      @one_line_regex = @a.shift
      @a.length.zero? or raise ::ArgumentError, "unexpected iambic - #{ @a[0].class }"
      nil
    end

    def expect_section_label
      line = styled_line
      len = (( str = "#{ @section_label_string_stem }:" )).length
      left = line[ 0, len ] ; r = nil
      in_test_context do
        left.should eql( str )
        if line.length > len
          line[ len, 1 ].should eql( ' ' )
          r = line[ len + 1 .. -1 ]
        end
      end
      @any_first_line_remainder_string = r
      left == str
    end

    def expect_one_line_with_regex
      rx = @one_line_regex ; s = @any_first_line_remainder_string
      in_test_context do
        s.should match( rx )
      end
      rx =~ s
    end

    def peek
      @test_context.peek_any_next_info_line
    end
    #
    def styled_line
      @test_context.styled_info_line
    end
    #
    def skip_line
      @test_context.some_info_line
      nil
    end

    def in_test_context &p
      @test_context.instance_exec( & p )
    end

    #  ~ these happen within the blocks - note the change in result meaning ~

    def expect_exactly_one_line
      in_test_context do
        line = some_info_line
        ( line !~ BLANK_RX__ ).should eql( true )
      end
      expect_no_more_lines_in_section
      nil
    end
    #
    def expect_no_more_lines_in_section
      in_test_context do
        if (( s = peek_any_next_info_line ))
          s.should match( BLANK_RX__ )
          some_info_line
        end
      end
      nil
    end

    def expect_item item_label, content_rx
      in_test_context do
        line = styled_info_line
        md = ITEM_RX__.match( line ) or fail "sanity - item line? - #{ line }"
        lbl, desc_line_1 = md.captures
        lbl.should eql( item_label )
        desc_line_1.should match( content_rx )
      end
      nil
    end
    #
    ITEM_RX__ =
      /\A[ ]{2,}(?<item_name>(?:(?![ ]{2}).)+)(?:[ ]{2,}(?<rest>.+))?\z/

    def expect_no_more_items
      expect_no_more_lines_in_section
    end
  end
end
