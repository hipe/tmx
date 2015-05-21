module Skylab::TanMan

  module Models_::DotFile

    Events_ = ::Module.new

    Events_::Invalid_Characters = Callback_::Event.

        prototype_with :invalid_characters, :chars, nil, :ok, false do |y, o|

      _s_a = o.chars.map { |s| "#{ s.inspect } (#{ '%03d' % [ s.ord ] })" }

      y << "html-escaping support is currently very limited - #{
            }#{ sp_ :subject, 'character', :subject, _s_a,
               :negative, :later_is_expected,
               :object, :adjectivial, 'supported' }"

      # eg. "the following characters are not yet suported:"
    end
  end
end
