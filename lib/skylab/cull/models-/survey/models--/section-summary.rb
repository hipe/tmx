module Skylab::Cull

  class Models_::Survey

    class Models__::Section_Summary

      # #hook-in [#br-021]

      class << self
        def name_function
          @nf ||= Callback_::Name.via_variegated_symbol :section
        end
      end

      def name_function
        self.class.name_function
      end

      def initialize sect
        @sect = sect
      end

      def render_all_lines_into_under y, expag

        lhs_s = @sect.internal_normal_name_string
        rhs_x = @sect.subsect_name_s

        if ! rhs_x
          if @sect.assignments && 1 == @sect.assignments.length
            ast = @sect.assignments.first
            _lhs_s_ = ast.internal_normal_name_string
            lhs_s = "#{ lhs_s } #{ _lhs_s_ }"  # le meh
            rhs_x = ast.value_x
          end
        end

        expag.calculate do

          if rhs_x.nil?
            y << lhs_s
          else
            y << "#{ lhs_s } #{ val rhs_x }"
          end
        end

        ACHIEVED_
      end
    end
  end
end
