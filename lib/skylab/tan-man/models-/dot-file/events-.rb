module Skylab::TanMan

  module Models_::DotFile

    Events_ = ::Module.new

    Events_::Invalid_Characters = Callback_::Event.

        prototype_with :invalid_characters, :chars, nil, :ok, false do |y, o|

      s_a = o.chars
      d = s_a.length
      _s_a_ = s_a.map { |s| "#{ s.inspect } (#{ '%03d' % [ s.ord ] })" } * ', '

      y << "html-escaping support is currently very limited. the following #{
       }character#{ s d } #{ s d, :is } not yet supported: #{ _s_a_ }"

    end
  end
end
