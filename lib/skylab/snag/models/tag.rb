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
      tag_name_s = tag_name.to_s
      if valid_tag_rx =~ tag_name_s
        tag_name_s.intern
      else
        rs = error[ Models::Tag::Events::Invalid.new tag_name ]
        rs ? false : rs           # Our delegated result must be falseish,
      end                         # but whether it is nil or false is up
    end                           # to the caller. [#017]

    # --*--

    def render
      self.class.render name
    end

    alias_method :to_s, :render

  protected

    def initialize name
      super
      freeze
    end
  end

  module Models::Tag::Events
  end

  class Models::Tag::Events::Add < Snag::Model::Event.new :rendered, :verb
    build_message -> do
      "#{ Headless::NLP::EN::POS::Verb[ verb.to_s ].preterite } #{
        }#{ val rendered }"
    end
  end

  class Models::Tag::Events::Invalid < Snag::Model::Event.new :name
    build_message -> do
      "tag must be composed of 'a-z' - invalid tag name: #{ ick name }"
    end
  end

  class Models::Tag::Events::Rm < Snag::Model::Event.new :rendered
    build_message -> do
      "removed #{ val rendered }"
    end
  end

  class Models::Tag::Events::Tags < Snag::Model::Event.new :node, :tags
    build_message -> do
      "#{ val node.identifier } is tagged with #{
        }#{ and_ tags.map{ |t| val t } }."
    end
  end
end
