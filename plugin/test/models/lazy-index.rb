module Skylab::Plugin::TestSupport
  # ->
    module Dependencies

      def self.[] tcc

        tcc.extend MM___
        tcc.include IM___
        NIL_
      end

      module MM___

        def dangerous_memoize m, & p

          TestSupport_::Define_dangerous_memoizer[ self, m, & p ]

          NIL_
        end

        alias_method :share_subject, :dangerous_memoize  # when read-only
      end

      module IM___

        def subject_class_
          Home_::Dependencies
        end

        def argument_stream_via_ * args
          Common_::Scanner.via_array args
        end
      end
    end
  # -
end
