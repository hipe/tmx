x = nil

# -- method send and related

# this is just a call (`send`) with a block testpoint1.20
# (as seen in (at writing) common/test/fixture-directories/twlv-dli/glient.rb:7)

my_method do
  MY_CONST
end




# just a plain old proc arg (`procarg0`) #testpoint1.21
# (as seen in (at writing) common/lib/skylab/common/event/magnetics-.rb:11)

my_method do |q|
  my_other_method q
end




# list expansion in proc args (`mlhs`) #testpoint1.10
# (as seen in (at writing) basic/lib/skylab/basic/method.rb:146)

# DOES THIS NOT ALSO COVER? (#todo)

my_method do |q, (z, _)|
  my_other_method q, z
end




# -- method definition related



# `optarg` #testpoint1.41
# (as seen in (at writing) common/lib/skylab/common/event/makers-/hooks.rb:11)

x = -> p=nil do
  p && p[]
end




# `procarg0` #testpoint1.45
# (as seen in (at writing) common/lib/skylab/common/event/makers-/data-event.rb:92)

my_method do |(var1, var2)|
  my_other_method var1, var2
end




# take a proc or block as an arg (`blockarg`) #testpoint1.40
# (as seen in (at writing) common/test/box.rb:14)

def my_method_1 & p
  p[ my_other_method ]
end




# keyword args (`kwoptarg`) #testpoint1.49
# (as seen in (at writing) beauty_salon/lib/skylab/beauty_salon/crazy-town-magnetics-/semantic-tupling-via-node.rb:71)

def my_method_1_B offset: nil, type: nil, via: nil
  @offset = offset
  type and @type_symbol = type
  via and @_via_ = via
end




# `return` #testpoint1.31
# (as seen in (at writing) basic/lib/skylab/basic/number/en.rb:34)

def my_method_2 x
  if 1 == x
    return
  end
  2
end




# `super` with no args (a bit magic) #testpoint1.43
# (as seen in (at writing) common/lib/skylab/common/actor/curried--.rb:15)

def my_method_3_A
  super
end




# a `super` with two args #testpoint1.13
# (as seen in (at writing) common/lib/skylab/common/callback-tree.rb:354))

def my_method_3 x
  super my_method_3.guy, MY_CONST
end




# `super` with no args and a block #testpoint1.12
# (as seen in (at writing) basic/lib/skylab/basic/yielder.rb:90)

def my_method_4 x

  super() do |q|
    q << 1
  end
end




## `super` with yes args and a block #testpoint1.12.B

def my_method_4_B x

  super x do |q|
    q << 1
  end
end





# `yield` #testpoint1.42
# (as seen in (at writing) common/lib/skylab/common/stream/magnetics/each-pairable-via-stream.rb:25)

def my_method_5 var1
  yield my_method, var1
end




# `ensure` when it is at the toplevel of the method #testpoint1.11
# (as seen in (at writing) flex2treetop/lib/skylab/flex2treetop.rb:759)

def my_method_6
  my_method_1
ensure
  my_method_2
end




# -- defining singleton methods

#    NOTE - same

# `defs` #testpoint1.37
# common/test/fixture-directories/sxtn-boxstow/shimmy-jimmy/chumba-wumba.rb:7




# `defs` on self #testpoint1.38
# (as seen in (at writing) common/test/fixture-directories/sxtn-boxstow/shimmy-jimmy/chumba-wumba.rb:7)

def self.my_method
end




# `defs` on any arbitrary lvar or whatever #testpoint1.46
# (as seen in (at writing) common/lib/skylab/common/digraph.rb:359)

def x.my_method
end




# -- special/perlish



# `match_with_lvasgn` #testpoint1.48
# (as seen in (at writing) arc/lib/skylab/arc/magnetics/qualified-component-via-value-and-association.rb:425)

/xxx/ =~ x

# #born
