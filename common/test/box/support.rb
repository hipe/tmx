module Skylab::Callback::TestSupport

  module Box::Support

    def self.[] ts_mod

      ts_mod.extend Module_Methods___
      ts_mod.include Instance_Methods___
      NIL_
    end

    module Module_Methods___

      def memoize_subject_ & p

        define_method :subject_, Home_.memoize( & p )

      end

      def subject_
        Home_::Box
      end
    end

    module Instance_Methods___

      def subject_with_entries_ * pairs
        bx = subject_.new
        pairs.each_slice 2 do | k, x |
          bx.add k, x
        end
        bx
      end

      def subject_
        self.class.subject_
      end
    end
  end
end
