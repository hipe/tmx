module Skylab::Parse

  module DSL_DSL  # :[#011].

  # this DSL_DSL is a simple DSL for making simple DSL's.
  #
  # you declare fields associated with your module by giving them a name
  # and picking their simple type - e.g { `atom` | `list` | `block` }.
  #
  # the feeling of declaring a DSL is like having an `attr_accessor`
  # "macro" that is sligtly richer. the feeling of using the DSL on your
  # domain modules is a lot like using RSpec's `let`, except it makes
  # sugar for you. I WILL CALL IT SUGAR FACTORY
  #
  # it's important to appreciate that like RSpec's `let`, this operates by
  # creating methods that store your values memoized in method definitions.
  # the benefit of this is that the values inherit through class and module
  # inheritance as would be expected.
  #
  # a disadvantage (from one perspective) of this approach is that you don't
  # get a writer instance method out of the box. but you can actually pass
  # a "container proxy" adapter to take arbitrary actions when the DSL
  # is engaged if you like.
  #
  # if you define an `atom` field called 'wiz':
  #
  #     module Foo
  #       class Base
  #
  #         Home_::DSL_DSL.enhance self do
  #           atom :wiz                     # make an atomic (basic) field
  #         end                             # called `wiz`
  #
  #         wiz :fiz                        # set a default here if you like
  #       end
  #
  #       class Bar < Base                  # subclass..
  #         wiz :piz                        # then set the value of `wiz`
  #       end
  #     end
  #
  # you can read this value on the pertinent classes with `wiz_value`:
  #
  #     Foo::Bar.wiz_value  # => :piz
  #
  # these setter module methods are by default private:
  #
  #     Foo::Bar.wiz :other  # => NoMethodError: private method `wiz' called..
  #
  # because this DSL generates only readers and not writers for your instances,
  # you get a public instance getter of the same name (no `_value` suffix):
  #
  #     Foo::Bar.new.wiz  # => :piz
  #
  # happy hacking!

    class << self

      def enhance subj, & edit
        o = Session__.new
        o.edit_block = edit
        o.instance_methods = subj
        o.module_methods = subj.singleton_class
        o.execute
      end
    end  # >>

    class Session__

      attr_writer(
        :edit_block,
        :instance_methods,
        :module_methods,
      )

      def execute

        _shell = Shell__.new self
        _shell.instance_exec( & @edit_block )
        NIL_
      end
    end

    class Shell__ < ::BasicObject

      def initialize sess
        @_session = sess
      end

      def atom sym
        @_session.__receive_atom sym
      end
    end

    class Session__

      def __receive_atom sym

        reader_method_name = :"#{ sym }_value"

        @module_methods.send :define_method, sym do | x |

          define_singleton_method reader_method_name do
            x
          end

          define_method sym do
            x
          end
        end

        @module_methods.send :private, sym

        NIL_
      end
    end

    # a `block` field called 'zinger' gives you an eponymous proc writer:
    #
    #     module Fob
    #       class Base
    #         Home_::DSL_DSL.enhance self do
    #           block :zinger
    #         end
    #       end
    #
    #       class Bar < Base
    #         ohai = 0
    #         zinger do
    #           ohai += 1
    #         end
    #       end
    #     end
    #
    # you must use `zinger.call` on the instance:
    #
    #     bar = Fob::Bar.new
    #     bar.zinger.call  # => 1
    #     bar.zinger.call  # => 2
    #

    class Shell__

      def block sym
        @_session.__receive_block sym
      end
    end

    class Session__

      def __receive_block sym

        @module_methods.send :define_method, sym do | & blk |

          define_method sym do
            blk
          end
        end
      end
    end

    # if you define an `atom_accessor` field 'with_name'
    #
    #     class Foc
    #       Home_::DSL_DSL.enhance self do
    #         atom_accessor :with_name
    #       end
    #     end
    #
    # in the instance you can write to the field in the same DSL-y way
    #
    #     foo = Foc.new
    #     foo.with_name :x
    #     foo.with_name  # => :x
    #

    class Shell__

      def atom_accessor sym
        @_session.__receive_atom_accessor sym
      end
    end

    class Session__

      def __receive_atom_accessor sym

        ivar = :"@#{ sym }"

        @instance_methods.send :define_method, sym do | * a |
          case a.length
          when 0
            instance_variable_get ivar
          when 1
            instance_variable_set ivar, a.fetch( 0 )
          else
            raise ::ArgumentError, Say___[ a ]
          end
        end
      end
    end

    Say___ = -> a do
      "wrong number of arguments (#{ a.length } for 0..1)"
    end

    # (list)

    class Shell__
      def list sym
        @_session.__receive_list sym
      end
    end

    class Session__

      def __receive_list sym

        @module_methods.send :define_method, sym do | * x_a |

          x_a.freeze
          define_method sym do
            x_a
          end
        end
      end
    end

    # (memoize)

    class Shell__
      def memoize writer_meth_name, reader_meth_name
        @_session.__receive_memo writer_meth_name, reader_meth_name
      end
    end

    class Session__

      def __receive_memo writer_meth_name, reader_meth_name

        @module_methods.send :define_method, writer_meth_name do | & user_p |

          current_p = -> do
            x = user_p[]
            current_p = -> do
              x
            end
            x
          end

          send :define_method, reader_meth_name do
            current_p[]
          end
        end
      end
    end

  # if you must, use a module and not a class to encapsulate reusability:
  #
  #     module Fod
  #       module ExtensionModule
  #         Home_::DSL_DSL.enhance_module self do
  #           atom :pik
  #         end
  #       end
  #
  #       class Bar
  #         extend ExtensionModule::ModuleMethods
  #         include ExtensionModule::InstanceMethods
  #         pik :nic
  #       end
  #     end
  #
  # then you can enhance a class with your module with the above two steps:
  #
  #     Fod::Bar.pik_value  # => :nic
  #     Fod::Bar.new.pik  # => :nic

    class << self

      def enhance_module extmod, & edit

        o = Session__.new
        o.edit_block = edit
        o.instance_methods = Touch_mod__[ :InstanceMethods, extmod ]
        o.module_methods = Touch_mod__[ :ModuleMethods, extmod ]
        o.execute
      end
    end  # >>

    Touch_mod__ = -> const, extmod do
      if extmod.const_defined? const, false
        extmod.const_get const
      else
        x = ::Module.new
        extmod.const_set const, x
        x
      end
    end
  end
end
