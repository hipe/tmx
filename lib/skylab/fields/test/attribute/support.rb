module Skylab::Fields::TestSupport

  module Attribute::Support

    TS_::A_Subject_Module_ = Home_::Attribute

    class << self

      def [] tcm

        tcm.send :define_method, :one_such_class_, ONE_SUCH_CLASS_METHOD__
        tcm.send :define_singleton_method, :one_such_class_, ONE_SUCH_CLASS_METHOD__
      end
    end  # >>

    ONE_SUCH_CLASS_METHOD__ = -> do

      next_id = Build_next_integer_generator_starting_after[ 0 ]

      -> & def_p do

        _const = :"KLS_#{ next_id[] }"

        _cls = Me_.const_set _const, ::Class.new

        ( _cls.class_exec do
          A_Subject_Module_::DSL[ self ]
          class_exec( & def_p )
          self
        end )
      end
    end.call

    Me_ = self
  end
end
