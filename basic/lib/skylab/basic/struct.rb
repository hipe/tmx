module Skylab::Basic

  module Struct

    # (nothing.)

    module Definition_for_the_Method_Called_New  # :[#063]

      # 2x [co] 0x [here]. covered only by [#co-005.4].
      #
      # NOTE client must do its own alias of `orig_new`!

      _HM = -> sym do
        members.include? sym
      end

      _TAM = -> do
        members.map( & method( :send ) )
      end

      _MIM = -> do
        self.class.members
      end

      _MMM = -> do

        self::MEMBER_I_A__
      end

      define_singleton_method :via do |* x_a|

        o = Parameters___.new
        x_a.each_slice 2 do |k, x|
          o[ k ] = x
        end
        edit_class_p, args_notify_p = o.to_a

        -> * members, & user_edit_p do

          if args_notify_p
            args_notify_p[ members, & user_edit_p ]
          end

          members.freeze

          ::Class.new( self ).class_exec do

            class << self
              alias_method :new, :orig_new
              alias_method :[], :orig_new
            end

            define_method :has_member, _HM

            define_method :to_a, _TAM

            define_method :members, _MIM

            define_singleton_method :members, _MMM

            const_set :MEMBER_I_A__, members  # before next line

            if edit_class_p

              module_exec( * user_edit_p, & edit_class_p )

            end

            self
          end
        end
      end

      Parameters___ = ::Struct.new :edit_class, :on_args_to_method_called_new
    end

    # ==
    # ==
  end
end
# #history-A: moved here from [co]
