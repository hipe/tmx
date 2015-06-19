module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    class Strategy_::Common < ::Skylab::Plugin::Pub_Sub::Subscriber   # assumes dispatcher has begun

      def dup

        # assume that caller calls this method with a block that
        # produces the *newer* dispatcher to be associated with the dup

        super.__finish_dup yield
      end

      def carry_over_dup_boundary_ ivar_a

        # used in conjunction with the next method in "whitelist-based duping"
        x_a = []
        ivar_a.each do | ivar |
          x_a.push remove_instance_variable ivar
        end
        yield
        ivar_a.length.times do | d |
          instance_variable_set ivar_a.fetch( d ), x_a.fetch( d )
        end
        NIL_
      end

      def initialize_dup _

        # for safety and future-proofing and early failure, the default
        # behavior is to remove all ivars across a dup boundary except
        # those explicitly handled. it is recommended that child classses
        # follow suit and implement their subject method around this.

        pu_ID = remove_instance_variable :@plugin_identifier
        instance_variables.each do | ivar |
          remove_instance_variable ivar
        end
        @plugin_identifier = pu_ID
      end

      def __finish_dup dsp

        @on_event_selectively = dsp.on_event_selectively
        @resources = dsp.resources
        self
      end
    end
  end
end
