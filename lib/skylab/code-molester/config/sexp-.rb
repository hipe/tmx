module Skylab::CodeMolester

  module Config

    class Sexp_ < CM_::Sexp

      LIB_.delegating self, :employ_the_DSL_method_called_delegates_to

      CM_::Sexp::Registrar[ self ]

      def build_comment_line line
        line = "# #{line.gsub(/[[:space:]#]+/, SPACE_ ).strip}\n" # could be improved
        o = Config_::Sexp_
        o[ :whitespace_line, EMPTY_S_, o[ :comment, line ] ]
      end

      def lookup_three_indexes_via_scan_for_name scan, name_s, pass_p=MONADIC_TRUTH_
        index_into_sexp_of_current_item = 0  # the index of the symbol name
        index_of_least_greater = nil
        while x = scan.gets
          index_into_sexp_of_current_item += 1
          _b = pass_p[ x ]
          _b or next
          case x.item_name <=> name_s
          when -1
            greatest_lesser_index = index_into_sexp_of_current_item
          when 0
            index_of_target = index_into_sexp_of_current_item
            break
          when 1
            index_of_least_greater ||= index_into_sexp_of_current_item
          end
        end
        [ greatest_lesser_index, index_of_target, index_of_least_greater ]
      end

      private def say_not_string x
        _ = CM_.lib_.strange x
        "no implicit conversion of #{ _ } into String"
      end
    end

    Config_::Sexps.class  # you've got to load them now so they
      # register or it has a way of shutting this whole thing down

  end
end
