module Skylab::Snag
  class Models::Tag < ::Struct.new :name


    canonical = -> do
      h = {
        open: new( :open )
      }
      -> sym do
        h.fetch( sym ) do |k|
          raise ::KeyError.new "\"#{ k }\" is not a canonical tag."
        end
      end
    end.call

    define_singleton_method :canonical do canonical end

    valid_tag_rx = /\A[-a-z]+\z/

    define_singleton_method :normalize do |tag_name, error, info=nil|
      if valid_tag_rx =~ tag_name
        tag_name
      else
        rs = error[ Models::Tag::Events::Invalid.new tag_name ]
        rs ? false : rs           # Our delegated result must be falseish,
      end                         # but whether it is nil or false is up
    end                           # to the caller. [#017]

    # --*--

    def to_s
      "##{ name }"
    end

  protected

    def initialize name
      super
      freeze
    end
  end


  module Models::Tag::Events
  end

  class Models::Tag::Events::Invalid < Snag::Model::Event.new :name
    build_message -> do
      "tag must be composed of 'a-z' - invalid tag name: #{ ick name }"
    end
  end
end
