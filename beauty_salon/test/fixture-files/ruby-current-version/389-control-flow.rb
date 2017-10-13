# (see caveats at sibling README)

x = nil
y = nil



# `if` and related


# `and` / `or` (seen as a bit like an `if-then`)

# #testpoint1.36
# (as seen in (at this writing) common/test/fixture-trees-volatile/three/level-1/level-2/leaf-3.rb:4)




# -- { while | until } [post]


# `while` (next section)


# `while_post` (next section)




# `until` #testpoint1.26
# (as seen in (at writing) common/lib/skylab/common/ordered-dictionary.rb:106)

last = nil

until last == x
  my_method
end




# `until_post` testpoint1.29
# (as seen in (at writing) common/lib/skylab/common.rb:552)

begin
  x = my_method
  x || break
  x_ = my_other_method
end until x_




# -- control flow in while loops & related

# `break` (above)

# `next`, `while`

while ( x += 1 ) != 10
  if my_method x
    next
  end
  my_other_method x
end




# `redo`, `while_post`

begin
  my_method
  if x
    redo
  end
end while above








# common jump with one arg #testpoint1.28
# (as seen in (at writing) common/lib/skylab/common/autoloader/value-via-const-path.rb:63)


y = nil
x = while my_method
  if ! y
    break my_other_method
  end
end




# -- case statement

y = case x
when ::NilClass ;
when ::PhilClass, ::ChillClass ; my_method
else
end





# -- keywords



# `defined?` #testpoint1.33
# (as seen in (at writing) test_support/lib/skylab/test_support/slowie/core.rb:374)

defined? x

# #born
