module Skylab::CodeMolester

  module Config

    class Actors__::Add_assignment

      Callback_::Actor.call self, :properties,

        :x, :name_s, :at_index, :value_items_sexp

      def execute
        @cls = Config_::Sexps::AssignmentLine
        resolve_template
        begin_sexp
        insert_sexp
      end

      def resolve_template
        # use the whitespace formatting of the previous item if you can
        @tmpl = @value_items_sexp.rchild :assignment_line
        @tmpl ||= [ nil, @cls.indent_string, nil, ' = ', nil ]
      end

      def begin_sexp
        o = Config_::Sexp_
        _name = o[ :name, @name_s ]
        _value = o [ :value, @x ]
        @sexp = @cls[ :assignment_line, @tmpl[ 1 ], _name, @tmpl[ 3 ], _value ]
        nil
      end

      def insert_sexp
        if @at_index
          at_index_insert_sexp
        else
          1 < @value_items_sexp.length and maybe_add_newline
          @value_items_sexp.push @sexp, NEWLINE_  # per the grammar
        end
      end

      def maybe_add_newline
        last = @value_items_sexp
        if last.respond_to?( :symbol_i ) && :assignment_line == last.symbol_i
          @value_items_sexp.push NEWLINE_
        end ; nil
      end

      def at_index_insert_sexp
        y = []
        # formatting hacks: sadly the templating won't catch this: add a
        # newline for the assignment to be preceded by IFF one does not
        # already exist in that position
        if 2 > @at_index || NEWLINE_ != @value_items_sexp[ @at_index - 1 ]
          y.push NEWLINE_
        end
        y.push @sexp
        if @at_index < @value_items_sexp.length - 1 &&
            NEWLINE_ != @value_items_sexp[ @at_index ]
          y.push NEWLINE_
        end
        @value_items_sexp[ @at_index, 0 ] = y ; nil
      end
    end
  end
end
