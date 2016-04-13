module Skylab::Zerk

  class NonInteractiveCLI

    class Invitation___

      def initialize x_a, cli

        @didactic_ARGV_string = nil
        @_for_what_kn = nil
        @CLI = cli

        if x_a.length.nonzero?
          @_st = Callback_::Polymorphic_Stream.via_array x_a
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

      def because

        sym = @_st.gets_one
        if sym
          use_x = " for more about #{ sym }s"  # meh
        end

        @_for_what_kn = Callback_::Known_Known[ use_x ] ; nil
      end

      def for_more
        @_for_what_kn = Callback_::Known_Known[ " for more." ] ; nil
      end

    public

      def express

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
      )
    end
  end
end
# #history: broke out of niCLI core
