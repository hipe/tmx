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

  private

    def initialize name
      super
      freeze
    end
  end

  Models::Tag::Events = ::Module.new

  ev = Snag_::Model_::Event.method :new

  Models::Tag::Events::Add = ev.call :rendered, :verb do
    message_proc do |y, o|
      y << "#{ Snag_::Lib_::NLP[]::EN::POS::Verb[ o.verb.to_s ].preterite } #{
       }#{ val o.rendered }"
    end
  end

  Models::Tag::Events::Invalid = ev.call :name do
    message_proc do |y, o|
      y << "tag must be composed of 'a-z' - invalid tag name: #{ ick o.name }"
    end
  end

  Models::Tag::Events::Rm = ev.call :rendered do
    message_proc do |y, o|
      y << "removed #{ val o.rendered }"
    end
  end

  Models::Tag::Events::Tags = ev.call :node, :tags do
    message_proc do |y, o|
      y << "#{ val o.node.identifier } is tagged with #{
       }#{ and_ o.tags.map{ |t| val t } }."
    end
  end
end
