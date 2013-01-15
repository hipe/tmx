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

    def self.render body_string
      "##{ body_string }"
    end

    tag_body_rx = /[-a-z]+/

    valid_tag_rx = /\A#{ tag_body_rx.source }\z/

    rendered_tag_rx = /(?<!\w)#(?<tag_body>#{ tag_body_rx.source })(?!\w)/

    define_singleton_method :rendered_tag_rx do rendered_tag_rx end

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
      self.class.render name
    end

  protected

    def initialize name
      super
      freeze
    end
  end


  module Models::Tag::Events
  end

  class Models::Tag::Events::Added < Snag::Model::Event.new :rendered, :verb
    build_message -> do
      "#{ verb } #{ val rendered }"
    end
  end

  class Models::Tag::Events::Invalid < Snag::Model::Event.new :name
    build_message -> do
      "tag must be composed of 'a-z' - invalid tag name: #{ ick name }"
    end
  end
end
