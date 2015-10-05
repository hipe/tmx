module Skylab::Plugin

  module Delegation

    Actors_ = ::Module.new  # see [#010] #storypoint-505

    Actors_::Edit = -> mod, st do

      pi = Phrase_Interpreter__.new st, mod

      begin

        if st.no_unparsed_exists
          break
        end

        if pi
          _did = pi.absorb_any_sub_phrases_
          if _did && st.no_unparsed_exists
            break
          end
        end

        pi_ = Delegating_Phrase_Interpreter_.new st

        _did = pi_.interpret_any_delegating_phrase
        _did or break

        pi = nil

        bu = pi_.resolve_some_builder

        pi_.some_method_name_array.each do | sym |

          mod.send :define_method, sym, bu.build_method( sym )
        end

        redo
      end while nil

      if st.unparsed_exists
        raise ::ArgumentError, "unrecognized: #{ Strange_[ st ] }"
      end
    end

    class Phrase_Interpreter__ < Phrase_Interpreter_

      def initialize st, mod
        @mod = mod
        super st
      end

    private

      def employ_the_DSL_method_called_delegates_to=

        @mod.module_exec do
          define_singleton_method :delegates_to, DELEGATES_TO_METHOD___
          class << self
            private :delegates_to
          end
        end
        KEEP_PARSING_
      end
    end

    DELEGATES_TO_METHOD___ = -> dependency_method_name, * method_i_a do

      method_i_a.each do | m |

        define_method m do | * a, & p |

          send( dependency_method_name ).send m, * a, & p
        end
      end
    end

    class Actors_::Build_builder_with_if

      class << self
        alias_method :[], :new
      end

      def initialize if_p, up

        @_up = up
        @_p = if_p
      end

      def build_method m

        p = @_up.build_normal_proc m
        if_p = @_p

        -> *a, & x_p do

          _yes = instance_exec( & if_p )

          if _yes
            instance_exec a, x_p, & p
          end
        end
      end
    end
  end
end
