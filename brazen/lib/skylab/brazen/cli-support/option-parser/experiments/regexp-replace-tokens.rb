module Skylab::Brazen

  module CLI_Support

    Option_Parser::Experiments = ::Module.new  # :+#stowaway

    class Option_Parser::Experiments::Regexp_Replace_Tokens  # see [#074]

      def initialize op, * pairs

        a = []
        pairs.each_slice 2 do | rx, p |
          a.push RX_Filter___[ rx, p ]
        end

        @_op = op
        @_regexp_filters = a
      end

      RX_Filter___ = ::Struct.new :rx, :p

      def parse! argv
        __replace_tokens argv
        @_op.parse! argv
      end

      def __replace_tokens argv

        begin
          _again = __replace_tokens_once argv
          if _again
            redo
          end
          break
        end while nil
        NIL_
      end

      def __replace_tokens_once argv

        do_again = false

        @_regexp_filters.each_with_index do | filter, filter_idx |

          md = nil
          token, idx = argv.each.with_index.detect do | s, d |
            md = filter.rx.match s
          end

          idx or next

          orig_token = token.dup

          a = filter.p.call md  # , argv, idx

          if ! a.respond_to? :each_with_index
            raise ::TypeError, __say_type_error( a )
          end

          if orig_token == a.first
            raise __say_did_not_change orig_token
          end

          argv[ idx, 1 ] = a

          do_again = true

          break  # stop processing the rest of the filters, run all filters
          # again on the new argv!
        end

        do_again
      end

      def __say_type_error x
        "filter blocks must result in Array, not #{ x.class }"
      end

      def __say_did_not_change orig_token
        "filter would infinite loop; token did not change: #{ orig_token.inspect }"
      end

      # ~

      def summarize * a, & p
        @_op.summarize( * a, & p )
      end

      def summary_indent
        @_op.summary_indent
      end

      def summary_width
        @_op.summary_width
      end

      def top
        @_op.top
      end
    end
  end
end
