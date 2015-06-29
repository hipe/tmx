module Skylab::Plugin

  module TestSupport

    module Dependencies::Support

      def self.[] tcc

        tcc.extend MM___
        tcc.include IM___
        NIL_
      end

      module MM___

        def dangerous_let_ m, & p

          define_method m, TS_::Dangerous_memoize_.call( & p )
          NIL_
        end
      end

      module IM___

        def subject_class_
          Home_::Dependencies
        end

        def argument_stream_via_ * args
          Callback_::Polymorphic_Stream.via_array args
        end
      end
    end
  end
end
