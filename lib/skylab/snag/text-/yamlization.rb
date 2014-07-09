module Skylab::Snag

  class Text_::Yamlization

    Callback_[ self, :employ_DSL_for_digraph_emitter ]

    listeners_digraph  :text_line

    event_factory Snag_::API::Events::Datapoint

    def << record

      @y << '---'

      record.yaml_data_pairs.each do |field_name, string_value|
        @y << "#{ @fmt % field_name } : #{ string_value }"
      end

      nil
    end

    # (hack to fail loudly when nothing is listening|)

    m = instance_method :on_text_line

    define_method :on_text_line do |*a, &b|
      @y ||= ::Enumerator::Yielder.new do |txt|
        call_digraph_listeners :text_line, txt
        nil
      end
      m.bind( self ).call( *a, &b )
    end

  private

    def initialize field_names
      maxlen = field_names.reduce( 0 ) do |m, sym|
        x = sym.to_s.length
        m > x ? m : x
      end
      @fmt = "%-#{ maxlen }s"
      nil
    end
  end
end
