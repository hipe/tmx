module Skylab::Snag
  class Models::Tag::Collection < ::Enumerator # #EXPERIMENTAL

    def add! body_string, do_append, error, info
      @scn.pos = 0 # #hacklund
      sep = @scn.string.length.zero? ? '' : ' '
      tag_str = Models::Tag.render body_string
      if do_append
        @scn.string.concat "#{ sep }#{ tag_str }"
      else
        @scn.string.replace "#{ tag_str }#{ sep }#{ @scn.string }"
      end
      info[ Models::Tag::Events::Added.new tag_str,
              ( do_append ? :append : :prepend ) ]
      true
    end

  protected

    def initialize body_string
      @fly = Snag::Models::Tag.allocate # not frozen
      @scn = Snag::Services::StringScanner.new body_string
      super( ) { |y| visit y }
    end

    rx_ = nil
    rx = Models::Tag.rendered_tag_rx

    define_method :visit do |y|
      @scn.pos = 0
      rx_ ||= /((?!#{ rx }).)*/
      loop do
        @scn.skip rx_
        @scn.eos? and break
        rendered = @scn.scan( rx ) or fail 'sanity'
        md = rx.match rendered # inorite
        @fly.name = md[:tag_body]
        y << @fly
      end
      nil
    end
  end
end
