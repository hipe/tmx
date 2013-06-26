module Skylab::MetaHell::DSL_DSL

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
  # introductory example:
  #
  #     class Foo
  #       MetaHell::DSL_DSL.enhance self do
  #         atom :wiz                     # make an atomic (basic) field
  #       end                             # called `wiz`
  #
  #       wiz :fiz                        # set a default here if you like
  #     end
  #
  #     class Bar < Foo                   # subclass..
  #       wiz :piz                        # then set the value of `wiz`
  #     end
  #                                       # read the value:
  #     Bar.wiz_value # => :piz
  #
  #     # but setters are private by default:
  #
  #     Bar.wiz :other  # => NoMethodError: private method `wiz' called..
  #
  #     # because this DSL generates only readers and not writers for your
  #     # instances, you get a public reader of the same name in your
  #     # instances (not suffixed with "_value").
  #
  #                                        # read the value in an instance:
  #     Bar.new.wiz # => :piz
  #
  # happy hacking!

  MetaHell = ::Skylab::MetaHell

  def self.enhance host, &def_blk
    Story_.new( host.singleton_class, host, ENHANCE_ADAPTER_ ).
      instance_exec( & def_blk )
    nil
  end

  class Enhance_Adapter
    def add_field mm, im, fs
      Add_field_[ mm, im, fs ]
      nil
    end

    def add_or_change_value host, fs, x
      Add_or_change_value_[ host.singleton_class, fs, x ]
      nil
    end
  end
  ENHANCE_ADAPTER_ = Enhance_Adapter.new

  Add_field_ = -> mm, im, fs do
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

  Add_or_change_value_ = -> mm, fs, x do
    mm.send :undef_method, fs.r1
    mm.send :define_method, fs.r1 do x end
    nil
  end

  Story_ = MetaHell::Function::Class.new( :atom, :atom_accessor,
                                          :list, :block )
  class Story_

    # (the implementation of the DSL DSL)

    def initialize mm, im, box

      @atom, @atom_accessor, @list, @block = mm.module_exec do

        atom = -> i do
          fs = Fstory_[ i, :atom ]
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
          fs = Fstory_[ i, :list ]
          define_method i do | * x_a |
            x_a.freeze  # at both instance and mod-level don't accid. mutate.
            box.add_or_change_value self, fs, x_a
            nil
          end
          box.add_field self, im, fs
          nil
        end

        block = -> i do
          fs = Fstory_[ i, :block ]
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

    Fstory_ = ::Struct.new :nn, :type, :r1, :w1, :r2
    # `nn` = normalize name ; `r1` = read 1 (the module) ; `w1` = write 1 (
    # the module) ; `r2` = read 2 (the instance)
    class Fstory_
      def initialize nn, type, r1="#{ nn }_value".intern, w1=nn, r2=nn
        super
      end
    end
  end

  # can we use a module to hold and share an entire DSL?
  # you can attempt to make a DSL reusable and inheritable like so:
  #
  #     module Foo
  #       MetaHell::DSL_DSL.enhance_module self do
  #         atom :pik
  #       end
  #     end
  #
  #     class Bar
  #       extend Foo::ModuleMethods
  #       include Foo::InstanceMethods
  #       pik :nic
  #     end
  #
  #     Bar.pik_value # => :nic
  #     Bar.new.pik # => :nic

  def self.enhance_module amod, &def_blk
    mm, im = %i| ModuleMethods InstanceMethods |.map do |i|
      if amod.const_defined? i, false
        amod.const_get i, false
      else
        amod.const_set i, ::Module.new
      end
    end
    Story_.new( mm, im, ENHANCE_MODULE_ADAPTER_ ).instance_exec( & def_blk )
    nil
  end

  Enhance_Module_Adapter_ = MetaHell::Function::Class.new(
    :add_field, :add_or_change_value )
  class Enhance_Module_Adapter_
    def initialize
      @add_field = -> mm, im, fs do
        Add_field_[ mm, im, fs ]
        nil
      end
      @add_or_change_value = -> host, fs, x do
        # imagine a child class that extended a module methods is changing
        # the defn for a field.
        Add_or_change_value_[ host.singleton_class, fs, x ]
        nil
      end
      nil
    end
  end

  ENHANCE_MODULE_ADAPTER_ = Enhance_Module_Adapter_.new

end
