module Skylab::Snag
  module Models::Tag

    rx = /\A[-a-z]+\z/

    define_singleton_method :normalize do |tag_name, error, info=nil|
      if rx =~ tag_name
        tag_name
      else
        rs = error[ Models::Tag::Events::Invalid.new tag_name ]
        rs ? false : rs           # Our delegated result must be falseish,
      end                         # but whether it is nil or false is up
    end                           # to the caller.
  end


  module Models::Tag::Events
  end

  class Models::Tag::Events::Invalid < Snag::Model::Event.new :name
    build_message -> do
      "tag must be composed of 'a-z' - invalid tag name: #{ ick name }"
    end
  end
end
