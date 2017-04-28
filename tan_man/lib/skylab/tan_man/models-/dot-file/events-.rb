module Skylab::TanMan

  module Models_::DotFile

    Events_ = ::Module.new

    Events_::Invalid_Characters = Common_::Event.prototype_with(
      :invalid_characters,
      :chars, nil,
      :ok, false,

    ) do |y, o|

      # quite ridiculous - the below produces something like
      #     'the following characters are not yet supported:  "\t" (009), [..]'

      _s_a = o.chars.map { |s| "#{ s.inspect } (#{ '%03d' % [ s.ord ] })" }

      _egads = sentence_phrase__(
        :subject, "character",
        :subject, _s_a,
        :negative,
        :later_is_expected,
        :object, :adjectivial, "supported",
      )

      y << "html-escaping support is currently very limited - #{ _egads }"
    end

    # ==
    # ==
  end
end
