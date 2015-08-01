module Skylab::Callback

  class Event

    class Makers_::Structured_Expressive

      # :[#005.C] (see). (splintered from [#005.B]; more history there)

      _ = Event_::Actors_::Build_struct_like_constructor_method.call(

        :on_args_to_method_called_new, -> x_a, & p do

          if x_a.length.zero? && p

            i_a = p.parameters.map( & :last )
            if i_a.length.nonzero?
              x_a.concat i_a
            end
          end
          NIL_
        end,

        :edit_class, -> x_p=nil do

          members = send :members

          const_set :IVAR_A__, members.map { | sym | :"@#{ sym }" }

          attr_reader( * members )

          if x_p
            if x_p.arity.zero?
              class_exec( & x_p )
            else
              const_set :MESSAGE_P__, x_p
            end
          end
          NIL_
        end )

      class << self
        alias_method :orig_new, :new
      end

      define_singleton_method :new, _

      class << self
        alias_method :[], :new
      end

      def initialize * x_a

        ivar_a = self.class::IVAR_A__

        if x_a.length > ivar_a.length
          raise __say_too_long x_a
        end

        ivar_a.each_with_index do | ivar, d |

          instance_variable_set ivar, x_a[ d ]  # defaults to nil
        end
        NIL_
      end

      def __say_too_long x_a

        "too many args #( #{ x_a.length } for #{
          }#{ 0 .. self.class::IVAR_A__.length } )"
      end

      # ~ if you have a message proc:

      def express_into_under y, expag

        s = expag.calculate( * to_a, & some_message_proc )
        s or self._COVER_ME  # (could allow the behavior of skipping this)
        y << s
      end

      def some_message_proc
        any_message_proc or fail __say_no_message_proc
      end

      def any_message_proc

        if self.class.const_defined? :MESSAGE_P__
          self.class::MESSAGE_P__
        end
      end

      def message_proc
        self.class::MESSAGE_P__
      end

      def __say_no_message_proc
        "no message proc defined for #{ self.class }"
      end
    end
  end
end
