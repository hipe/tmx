# (see "caveat for these files" in sibling README file.)

begin
end

begin
  thingA_1
end

begin
  thingA_1
  thingA_2
end

begin
  thing_1
ensure
  thing_3
end

begin
  thing_1
rescue ::Xx => e
  thing_2
end

begin
  thing_1
rescue ::SyntaxError, ::LoadError => e
  thing_2
ensure
  thing_3
end

begin
  thing_1
  thing_2
rescue ::SyntaxError, ::LoadError => e
  thing_3
  thing_4
ensure
  thing_5
  thing_6
end


# this used to be in "150-control-flow.rb" but was anemic:

x = nil
case x
when ::NilClass ;
when ::PhilClass ; bill_class
else
end
