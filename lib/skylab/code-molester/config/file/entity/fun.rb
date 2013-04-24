module Skylab::CodeMolester

  Config::File::Entity::FUN = -> do

    o = { }

    o[:hack_model_name_from_constant] = -> do

      str = '::Models::'.freeze

      len = str.length

      -> mod do
        n = mod.name
        a = ( n[ ( n.rindex str ) + len .. -1 ] ).split( '::' )
        a.length.nonzero? or fail "sanity - hack failed (#{ n })"
        Headless::Name::Function::Full.new(
          a.map do |s|
            Headless::Name::Function::From::Constant.new s.intern
          end
        )
      end
    end.call

    ::Struct.new( * o.keys ).new( * o.values )
  end.call
end
