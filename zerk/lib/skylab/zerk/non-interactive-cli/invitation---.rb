module Skylab::Zerk

  class NonInteractiveCLI

    class Invitation___

      def initialize x_a, cli

        @CLI = cli
        @didactic_ARGV_string = nil
        @_for_what_kn = nil
        @method_name = :express_commonly

        if x_a.length.nonzero?
          @_st = Common_::Scanner.via_array x_a
          begin
            send @_st.gets_one
          end until @_st.no_unparsed_exists
          remove_instance_variable :@_st
        end
      end

      attr_writer(
        :didactic_ARGV_string,
      )

    private

      def as_compound_invite_to

        @invocation_reflection = @_st.gets_one
        @method_name = :express_as_compound ; nil
      end

      def because

        sym = @_st.gets_one
        if sym
          use_x = " for more about #{ sym }s"  # meh
        end

        @_for_what_kn = Common_::Known_Known[ use_x ] ; nil
      end

      def for_more
        @_for_what_kn = Common_::Known_Known[ " for more." ] ; nil
      end

    public

      def express
        send @method_name
      end

      def express_as_compound

        # (at writing, by default, this is byte-per-byte what [br] does.)
        # (otherwise we would probably DRY it w/ the other. might still.)

        o = @invocation_reflection
        prp = o.properties.fetch :action
        s = @didactic_ARGV_string
        if ! s
          s = "#{ o.subprogram_name_string } -h"
        end

        # --

        @CLI.section_expression_.express_section do |y|

          @CLI.expression_agent.calculate do

            y << "use #{ code "#{ s } #{
              }#{ par prp }" } for help on that action."
          end
        end
        NIL_
      end

      def express_commonly

        kn = remove_instance_variable :@_for_what_kn
        if kn
          for_what = kn.value_x
        else
          for_what = " for help"
        end

        s = @didactic_ARGV_string
        if ! s
          s_a = @CLI.expressable_stack_aware_program_name_string_array_.dup
          s_a.push SHORT_HELP_OPTION
          s = s_a.join SPACE_
        end

        @CLI.express_ do |y|
          y << "see #{ code s }#{ for_what }"
        end

        NOTHING_  # important
      end

      attr_reader(
        :CLI,
        :invocation_reflection,
        :method_name,
      )
    end
  end
end
# #history: broke out of niCLI core
