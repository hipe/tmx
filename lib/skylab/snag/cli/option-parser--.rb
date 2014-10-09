module Skylab::Snag

  module CLI::Option
  end

  class CLI::Option::Parser < Snag_::Library_::OptionParser

    # off the chain [#030] custom parsing of e.g -1, -2 just because

    def initialize( * )
      @regexp_filters = nil
      super
    end

    def regexp_replace_tokens rx, & p
      ( @regexp_filters ||= [] ).push RX_Filter__.new rx, p ; nil
    end
    RX_Filter__ = ::Struct.new :rx, :block

    def parse! argv
      @regexp_filters and do_regexp_replace_tokens argv
      super
    end
  private
    def do_regexp_replace_tokens argv
      begin
        again = do_regexp_replace_tokens_once argv
      end while again ; nil
    end

    def do_regexp_replace_tokens_once argv
      do_again = false
      @regexp_filters.each_with_index do |filter, filter_idx|
        token, idx = argv.each.with_index.detect { |t, i| filter.rx =~ t }
        idx or next
        orig_token = token.dup
        res_a = filter.block.call $~, argv, idx
        res_a.respond_to?( :each_with_index ) or raise ::TypeError, say_not( a )
        orig_token == res_a.first and raise say_did_not_change( orig_token )
        argv[ idx, 1 ] = res_a
        do_again = true
        break # stop processing the rest of the filters, run all filters
        # again on the new argv!
      end
      do_again
    end

    def say_not a
      "filter blocks must result in Array, not #{ a.class }"
    end

    def say_did_not_change orig_token
      "filter would infinite loop, it did not change: #{ orig_token.inspect }"
    end
  end
end
