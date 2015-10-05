module Skylab::CodeMolester

  module Config

    class Actors__::Set_section_via_hash

      Callback_::Actor.call self, :properties,

        :pairs, :s, :lesser, :secs

      def execute
        resolve_any_section
        if @sec
          update_section_with_values
        else
          begin_section
          update_section_with_values
          insert_section
        end ; nil
      end

    private

      def resolve_any_section
        @index_of_greatest_lesser, @index_of_target, @index_of_least_greater =
          @secs.lookup_three_indexes @s

        @sec = if @index_of_target
          @secs[ @index_of_target ]
        end ; nil
      end

      def begin_section
        resolve_spacers
        o = Config_::Sexp_
        _name = o[ :name, @s ]
        @sec = o[ :section,
          o[ :header,
             o[ :section_line, @s0, _name, o[ :n_3, @s1 ] ] ],
          o[ :items, NEWLINE_ ] ] ; nil
      end

      def resolve_spacers
        @tmpl = @secs.rchild :section
        if @tmpl
          via_section_as_template_resolve_spacers
        else
          @s0 = '[' ; @s1 = ']'
        end
      end

      def via_section_as_template_resolve_spacers
        sl = @tmpl.child( :header ).child( :section_line )
        @s0 = sl[ 1 ] ; @s1 = sl[ 3 ][ 1 ]
      end

      def update_section_with_values
        @pairs.each_pair do |k, x|
          @sec.set_mixed_at_name x, k
        end ; nil
      end

      def insert_section
        _insertion_index = if @index_of_greatest_lesser
          @index_of_greatest_lesser + 1
        elsif @index_of_least_greater
          @index_of_least_greater
        else
          1
        end
        @secs[ _insertion_index, 0 ] = [ @sec ] ; nil
      end
    end
  end
end
