module Skylab::Snag

  module CLI::Option
  end

  class CLI::Option::Parser < Snag_::Library_::OptionParser

    # off the chain [#030] custom parsing of e.g -1, -2 just because

    def initialize( * )
      @regexp_filters = nil
      super
    end

    def parse! argv
      if @regexp_filters
        loop do
          again = false
          @regexp_filters.each_with_index do |filter, filter_idx|
            token, idx = argv.each.with_index.detect { |t, i| filter.rx =~ t }
            next if ! idx
            orig_token = token.dup
            res_a = filter.block.call $~, argv, idx
            raise ::TypeError.new "filter blocks must result in Array, #{
              }not #{ res_a.class }" unless ::Array === res_a
            if orig_token == res_a.first
              raise ::RuntimeError.new "filter would infinite loop, it #{
              }did not change: #{ orig_token.inspect }"
            end
            argv[ idx, 1 ] = res_a
            again = true
            break # stop processing the rest of the filters, run all filters
            # again on the new argv!
          end
          break if ! again
        end
      end
      super
    end

    rx_filter_struct = ::Struct.new :rx, :block

    define_method :regexp_replace_tokens do |rx, &block|
      o = rx_filter_struct.new rx, block
      ( @regexp_filters ||= [] ) << o
      o
    end
  end
end
