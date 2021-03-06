# (see "caveat for these files" in sibling README file.)

# (in the spirit of "regression friendly" arrangement we go from
#  simplest (psychologically) to most complex.)

# -- "atomic" literals

a = [
  nil,
  false,
  true,
  2,
  2.3,
  1e2,
  1..2,
  3...5,
  :jumanji,
  'foo',
]




# -- string & string like


x = "#{ }"  # empty interopolation segment


x = :" foo #{ x } bee"  # symbol with interpolation



# backticks with interpolation #coverpoint1.2
# (from (at writing) git/test/test-support.rb:72)

x = `echo #{ a.length } && echo #{ a.class } 'again'`



# regex is superficially like string declaration

rx = //

rx = /\A
  qq
\z/xi

# (the regexp options above are #coverpoint1.53)

rx = /
  #{ x }
/




# -- simple "structured" literals (arrays and hashes)




# hash (classic style)
h = {
  :chooni2 => :fooni2
}




# hash (new style)
h = {
  chooni: :fooni
}




# -- assignment!

# of the below assignments that are "weird", probably they are part of
# #coverpoint1.54, i.e all the grammar symbols that have as an association
# `zero_or_one_right_hand_side_expression`

y = nil

x += y  # this is what we call op_asgn  (there are several other permutations)

x ||= y  # this is some kind of doo-hah boolean assignment thing

x &&= method_call  # #coverpoint1.25
  # (as in (at writing) common/lib/skylab/common/models-/event/actions/viz.rb:50)



# ~ ivars

@my_ivar = y



# ~ (looks like) assignment thru method sugar

# sugar sugar (note it calls *two* methods) #coverpoint1.22
# (as in (at writing) common/lib/skylab/common/bundles.rb:129)

x.my_getter_setter ||= y



# ~ const

Chimpelworthy::Dimpelworthy::Flimpelworthy = x  # const assign with a depe const



# ~ globals

$my_global = x
$my_global ||= x



# (magic) `gvar` #coverpoint1.44
# (as seen in (at writing) common/lib/skylab/common/name/conversion-functions.rb:57)

x, y, z = $~.captures



# nth_ref #coverpoint1.3

x = $1




# -- list assignment


# plain old lvar list assignment #coverpoint1.34
# (as in (at writing) basic/lib/skylab/basic/range/positive/union.rb:48)

x, y = []  # (sneak empty array parsing into it)





# the terms of your list assignment can be method calls (`send`) #coverpoint1.9
# (as seen in (at writing) human/lib/skylab/human/nlp/en/contextualization/magnetics-/line-contextualization-via-line.rb:90)


x.my_attr_1,
x.my_attr_2,
x.my_attr_3 =
  my_method





# subtly different form of above #coverpoint1.8
# (as in (at writing) arc/lib/skylab/arc/operation/when-not-available.rb:16)

( * x, y ) = [1,2,3]




# list assignment but it's two consts (`casgn`) #coverpoint1.6

# (as seen in (at writing) task/lib/skylab/task/magnetics/magnetics/function-stack-via-collection-and-parameters-and-target.rb:398)

MY_CONST_1, MY_CONST_2 = class MyClass1122
  [ self, singleton_class ]
end




# -- SPLAT
#
#    NOTE - this is more longwinded than it needs to be because of our
#    stubborn (and ultimately foolhardy) OCD desire to know *what* kind of
#    thing is followed by the splat. in fact, *any* expression can follow a
#    splat so we will have to alter our handling functions accordingly.


# you can splat on an lvar #coverpoint1.19
# (as seen in (at writing) basic/lib/skylab/basic/function/core.rb:88)

my_method( * x ).execute




# you can splat a plain old ivar #coverpoint1.18
# (as seen in (at writing) basic/lib/skylab/basic/proxy/makers/functional/core.rb:99)

x = [ y, * @my_ivar ]




# a splat can be used in the middle of an actual argument list (splat a const) #coverpoint1.15
# (as seen in (at writing) human/lib/skylab/human/nlp/en/phrase-structure-/models/irregular/core.rb:70)

my_method( x, * @my_ivar::MY_CONST )




# you can follow a splat star with an arbitrary expression `begin` #coverpoint1.14
# (as seen in (at writing) zerk/lib/skylab/zerk/non-interactive-cli/core.rb:194)

x[ * ( y if 1 == x ) ]




# splat a complex-ass expression (`send`) #coverpoint1.17
# (as seen in (at writing) basic/lib/skylab/basic/class/models-.rb:18)

x = my_method( * [x].compact )




# splat expand a deep-ass expression (`block`) #coverpoint1.16
# (as seen in (at writing) plugin/lib/skylab/plugin/bundle/enhance.rb:60)
# also #coverpoint1.20

my_proc = nil

my_method( * my_other_method( x ).map do |my_var_1|
  -> my_var_2 do
    x = y
    nil  # change it if needed
  end
end ).my_third_method( & my_proc )




# splat a literal array #coverpoint1.50
# (as seen in (at writing) human/test/270-NLP/010-EN/281-contextualization/150-against-subject-association-without-channel_spec.rb )

my_method( * [ 1, 2, 3] )




# splat a case statement (`case`) #coverpoint1.24
# (as seen in (at writing) common/lib/skylab/common/box/algorithms--.rb:39)

my_proc[ * case 1 <=> x
when  0 ; [x]
when -1 ; [x, y]
end ]

# #born
