module Foo
  Struct_Class = ::Struct.new :x, :y do
    def ok
      "yes: #{ y }"
    end
  end
  st = Struct_Class.new :a, :b
  puts st.ok
end
