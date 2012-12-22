module Skylab::TanMan
  class Models::DotFile::Meaning < ::Struct.new :name, :value
    # include Core::SubClient::InstanceMethods

    def duplicate_spacing! o                   # meh
      o_x = o.line_start
      its_width_to_colon = o.colon_pos - o_x
      its_e2_width = o.colon_pos - (o.name_index.end + 1)
      its_e0 = o.whole_string[ o_x .. o.name_index.begin - 1 ]
      its_e0.gsub!( /[ \t]+\z/, '' )
      @e0 = "#{ its_e0 }#{
        ' ' * [ 0,
      (its_width_to_colon - its_e2_width - name.length - its_e0.length)
               ].max
      }"
      @e2 = ' ' * its_e2_width
      @e4 = ' ' * ( o.value_index.begin - 1 - o.colon_pos )
      nil
    end

    def line
      "#{ @e0 }#{ name }#{ @e2 }:#{ @e4 }#{ value }\n"
    end

  protected

    def initialize name, value
      super
      @e0 = @e2 = @e4 = nil
    end
  end
end
