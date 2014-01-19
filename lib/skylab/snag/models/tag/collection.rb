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
      info[ Models::Tag::Events::Add.new tag_str,
            ( do_append ? :append : :prepend ) ]
      true
    end

    def rm! fly, error, info
      message = @scn.string
      pos_a = fly.begin
      pos_b = fly.end
      if pos_a > 0 && ' ' == message[ pos_a - 1 ]
        pos_a -= 1
      elsif pos_b < ( message.length - 1 ) && ' ' == message[ pos_b + 1 ]
        pos_b += 1
      end
      pos_a = nil if 0 == pos_a
      pos_b = nil if pos_b == ( message.length - 1 )
      new = "#{ message[ 0 .. ( pos_a - 1 ) ] if pos_a }#{
        }#{ message[ ( pos_b + 1 ) .. -1 ] if pos_b }"
      rendered = fly.render
      fly.reset
      @scn.string.replace new
      info[ Models::Tag::Events::Rm.new rendered ]
      true
    end

  private

    def initialize body_string
      @fly = Snag::Models::Tag::Flyweight.new body_string
      @scn = Snag::Library_::StringScanner.new body_string
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
        beg = @scn.pos
        len = @scn.skip( rx ) or fail 'sanity'
        @fly.set beg, ( beg + len - 1 )
        y << @fly
      end
      nil
    end
  end
end
