module Skylab::SubTree

  module Core::Action

    Anchored_Normal_Name_ = -> mod do  # ::Blah::Actions::Foo::X -> [:foo, :x]
      mod.module_exec do
        def anchored_normal_name
          self.class.anchored_normal_name
        end
        define_singleton_method :anchored_normal_name, & Anchored_normal_name__
      end
      nil
    end
    #
    Anchored_normal_name__ = -> do
      @anchored_normal_name ||= begin
        head_s = self::ACTIONS_ANCHOR_MODULE.name ; my_s = name
        0 == my_s.index( head_s ) or fail "sanity"
        my_s[ head_s.length + 2 .. -1 ].split( '::' ).
          map( & Autoloader::FUN.methodize ).freeze
      end
    end
  end
end
