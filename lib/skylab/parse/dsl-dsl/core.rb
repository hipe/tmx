module Skylab::Parse

  module DSL_DSL  # #borrow-one-indent

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
  #     class Foo
  #       Home_::DSL_DSL.enhance self do
  #         atom :wiz                     # make an atomic (basic) field
  #       end                             # called `wiz`
  #
  #       wiz :fiz                        # set a default here if you like
  #     end
  #
  #     class Bar < Foo                   # subclass..
  #       wiz :piz                        # then set the value of `wiz`
  #     end
  #
  #
  # you can read this value on the pertinent classes with `wiz_value`:
  #
  #     Bar.wiz_value  # => :piz
  #
  #
  # these setter module methods are by default private:
  #
  #     Bar.wiz :other  # => NoMethodError: private method `wiz' called..
  #
  #
  # because this DSL generates only readers and not writers for your instances,
  # you get a public instance getter of the same name (no `_value` suffix):
  #
  #     Bar.new.wiz  # => :piz
  #
  #
  # happy hacking!


  def self.enhance host, &def_blk
    Story.new( host.singleton_class, host, ENHANCE_ADAPTER__ ).
      instance_exec( & def_blk )
    nil
  end

  class Enhance_Adapter
    def add_field mm, im, fs
      Add_field__[ mm, im, fs ]
      nil
    end

    def add_or_change_value host, fs, x
      Add_or_change_value__[ host.singleton_class, fs, x ]
      nil
    end
  end
  ENHANCE_ADAPTER__ = Enhance_Adapter.new

  Add_field__ = -> mm, im, fs do
    mm.send :private, fs.w1  # make the writer private
    mm.send :define_method, fs.r1 do end  # if it is never set
    mg = fs.r1
    if fs.r2
      im.send :define_method, fs.r2 do  # one of these
        self.class.send mg
      end
    end
    nil
  end

  Add_or_change_value__ = -> mm, fs, x do
    mm.send :undef_method, fs.r1
    mm.send :define_method, fs.r1 do x end
    nil
  end

  Story = Callback_::Session::Ivars_with_Procs_as_Methods.new(
    :atom, :atom_accessor, :list, :block )

  class Story

    # (the implementation of the DSL DSL)

    def initialize mm, im, box

      @atom, @atom_accessor, @list, @block = mm.module_exec do

        atom = -> i do
          fs = Fstory__[ i, :atom ]
          define_method i do |x|
            box.add_or_change_value self, fs, x
            nil
          end
          box.add_field self, im, fs
          nil
        end

        atom_accessor = -> i do
          ivar = "@#{ i }".intern
          im.class_exec do
            swi_a = [
              -> { instance_variable_get ivar },
              -> x { instance_variable_set ivar, x }
            ]
            define_method i do |*a|
              instance_exec( *a, & swi_a.fetch( a.length ) )
            end
          end
          nil
        end

        list = -> i do
          fs = Fstory__[ i, :list ]
          define_method i do | * x_a |
            x_a.freeze  # at both instance and mod-level don't accid. mutate.
            box.add_or_change_value self, fs, x_a
            nil
          end
          box.add_field self, im, fs
          nil
        end

        block = -> i do
          fs = Fstory__[ i, :block ]
          define_method i do |&blk|
            blk or raise ::ArgumentError, "block required"
            box.add_or_change_value self, fs, blk
            nil
          end
          box.add_field self, im, fs
          nil
        end

        [ atom, atom_accessor, list, block ]
      end
      nil
    end

    Fstory__ = ::Struct.new :nn, :type, :r1, :w1, :r2 do
    # `nn` = normalize name ; `r1` = read 1 (the module) ; `w1` = write 1 (
    # the module) ; `r2` = read 2 (the instance)
      def initialize nn, type, r1="#{ nn }_value".intern, w1=nn, r2=nn
        super
      end
    end

    # a `block` field called 'zinger' gives you an eponymous proc writer:
    #
    #     class Fob
    #       Home_::DSL_DSL.enhance self do
    #         block :zinger
    #       end
    #     end
    #
    #     class Bab < Fob
    #       ohai = 0
    #       zinger do
    #         ohai += 1
    #       end
    #     end
    #
    #
    # you must use `zinger.call` on the instance:
    #
    #     bar = Bab.new
    #     bar.zinger.call  # => 1
    #     bar.zinger.call  # => 2
    #

    # if you define an `atom_accessor` field 'with_name'
    #
    #     class Foc
    #       Home_::DSL_DSL.enhance self do
    #         atom_accessor :with_name
    #       end
    #     end
    #
    #
    # in the instance you can write to the field in the same DSL-y way
    #
    #     foo = Foc.new
    #     foo.with_name :x
    #     foo.with_name  # => :x
    #

  end



  # if you must, use a module and not a class to encapsulate reusability:
  #
  #     module Fod
  #       Home_::DSL_DSL.enhance_module self do
  #         atom :pik
  #       end
  #     end
  #
  #     class Badd
  #       extend Fod::ModuleMethods
  #       include Fod::InstanceMethods
  #       pik :nic
  #     end
  #
  #
  # then you can enhance a class with your module with the above two steps:
  #
  #     Badd.pik_value # => :nic
  #     Badd.new.pik # => :nic

  def self.enhance_module amod, &def_blk
    mm, im = %i| ModuleMethods InstanceMethods |.map do |i|
      if amod.const_defined? i, false
        amod.const_get i, false
      else
        amod.const_set i, ::Module.new
      end
    end
    Story.new( mm, im, ENHANCE_MODULE_ADAPTER__ ).instance_exec( & def_blk )
    nil
  end

  Enhance_Module_Adapter__ = Callback_::Session::Ivars_with_Procs_as_Methods.new(

    :add_field, :add_or_change_value )

  class Enhance_Module_Adapter__
    def initialize
      @add_field = -> mm, im, fs do
        Add_field__[ mm, im, fs ]
        nil
      end
      @add_or_change_value = -> host, fs, x do
        # imagine a child class that extended a module methods is changing
        # the defn for a field.
        Add_or_change_value__[ host.singleton_class, fs, x ]
        nil
      end
      nil
    end
  end

  ENHANCE_MODULE_ADAPTER__ = Enhance_Module_Adapter__.new

  end  # #pay-one-back
end
