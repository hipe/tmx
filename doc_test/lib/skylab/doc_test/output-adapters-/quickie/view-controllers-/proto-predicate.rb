module Skylab::DocTest

  module DocTest

    class Output_Adapters_::Quickie

      class View_Controllers_::Proto_Predicate < View_Controller_

        def render line_downstream, _doc_context, fat_comma_line

          @line_downstream = line_downstream
          @lhs = fat_comma_line.lhs  # left hand side :"lhs"
          @rhs = fat_comma_line.rhs  # right hand side :"rhs"

          @md = SHOULD_RAISE_ERROR_MAGIC_PATTERN_RX__.match @rhs

          if @md
            when_raise_error_magic_pattern
          else
            when_literal_equals_predicate
          end
        end

        # ~ literal equals predicate

        def when_literal_equals_predicate

          _parens_or_not_parens = if false
            "( #{ @rhs } )"
          else
            " #{ @rhs }"
          end

          @line_downstream.puts "#{ @lhs }.should eql#{ _parens_or_not_parens }"

          nil
        end

        # ~ magic raise error predicate pattern

        SHOULD_RAISE_ERROR_MAGIC_PATTERN_RX__ = -> do

          # e.g "NoMethodError: undefined method `wat` ..", i.e
          # the ".." (literally those two characters) is part of the pattern

          cnst = '[A-Z][A-Za-z0-9_]'
          /\A[ ]*
            (?<const> #{ cnst }*(?:::#{ cnst }*)* ) [ ]* : [ ]+
            (?:
              (?<fullmsg> .+ [^.] \.? ) |
              (?: (?<msgfrag> .* [^. ] ) [ ]* \.{2,} )
            ) \z
          /x
        end.call


        def when_raise_error_magic_pattern

          _const, fullmsg, msgfrag = @md.captures

          _rx = if fullmsg
            "\\A#{ ::Regexp.escape fullmsg }\\z".inspect
          else
            "\\A#{ ::Regexp.escape msgfrag }".inspect
          end

          o = @line_downstream
          o.puts "-> do"
          o.puts "  #{ @lhs }"
          o.puts "end.should raise_error( #{ _const },"
          o.puts "             ::Regexp.new( #{ _rx } ) )"

          nil
        end
      end
    end
  end
end
