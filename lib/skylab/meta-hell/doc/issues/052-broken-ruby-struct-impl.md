# to_struct caveat

for boxen that you plan to `to_struct`, it is recommended that you avoid using
constituent names that end in '=' because of what is arguably broken-esque
behavior on the part of ruby's ::Struct -- it apparently lets you use any
symbol name as a member name, but if you create a struct with a member named
`foo=`, in any such a struct instance, ruby will weirdly let you send the
struct a `foo=` message to set that member value.

    A = ::Struct.new :"foo="
    a = A.new :one
    a.foo = :two  # i would expect this to error - there is no `foo` member.
    A.members [:foo=]

this can cause weird problems when you are using the struct as a key-value
store for method names and you have both forms in the same struct:

    A = ::Struct.new :"foo=", :foo
    B = ::Struct.new :foo, :"foo="
    a = A.new :one, :two
    b = B.new :one, :two
    a.foo = :x
    b.foo = :x
    a  # => #<struct A :foo==:x, foo=:two>
    b  # => #<struct B foo=:x, :foo==:two>

    # in both `a` and `b`, calling `foo=` set the first member value.
