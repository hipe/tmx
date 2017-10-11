# (see "caveat for these files" in sibling README file.)


# `module` #testpoint1.35
# while #open [#022.E2] the above is DETATCHED
# (as seen in (at writing) common/test/fixture-directories/five/core.rb:1)

module MyModule1::MyModule2::MyModule3

end




# -- MODULE EXPRESSION
#
#    NOTE this is a foolhardly and ultimately failed OCD thing. the `::`
#    operator is almost like a method that is special - the only type of
#    object that can receive it is a module. it is not resolved whether the
#    receiver is a module until runtime. so really any expression can be
#    "sent" the `::` message. but just for now:

x = nil
y = nil




# an `lvar` as module #testpoint1.27
# (as seen in (at writing) common/lib/skylab/common/callback-tree.rb:380)

x::MyClass.my_method




# `ivar` as module #testpoint1.30
# (as seen in (at writing) fields/lib/skylab/fields/entity/core.rb:276)

@my_ivar::MyClass.my_method




# an arbitrary expression as a module #testpoint1.4
# (as seen in (at writing) human/lib/skylab/human.rb:22)

Attributes_actor_ = -> cls, * a do
  ( x || y [] )::Actor.via cls, a
end





# remember these don't have to run, they just have to compile

class MyClass333

  # an expression (or anything) for the singleton class argument #testpoint1.1
  # (as seen in (at writing) snag/lib/skylab/snag/models-/node-identifier/core.rb:7)

  ChuMani = ::Module.new

  class << ( ChuMani::FooFani = ::Module.new )

    def xx
    end
  end  # >>
end




# -- SUBCLASSING
#
#    NOTE - the term that acts as the "argument" to the `<` operator
#    is evaluated at run time so really it can be any expression and
#    currently we try to parse for it too strictly (foolhardy)
#



# subclass self #testpoint1.5
# (as seen in (at writing) common/test/fixture-directories/seven-son/parent/core.rb)

class MyClass666

  class Child < self

  end
end




# subclass crazy expression #testpoint1.39
# (as seen in (at writing) common/lib/skylab/common/cli.rb:3)

class MyClass777 < MyModule.my_method.my_other_method::MyClass

end




# -- OPENING UP SINGLETON CLASS
#
#    NOTE - same

# #testpoint1.47
# (as seen in (at writing) fields/lib/skylab/fields/events/ambiguous.rb:26)

class << MyModule::MyClass

  def my_method
  end
end  # >>

# #broke-out of file removed in this selfsame commit
