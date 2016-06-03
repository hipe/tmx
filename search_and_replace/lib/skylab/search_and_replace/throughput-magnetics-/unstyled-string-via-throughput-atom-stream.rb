module Skylab::SearchAndReplace

  class Throughput_Magnetics_::Unstyled_String_via_Throughput_Atom_Stream

    def initialize st
      @stream = st
    end

    def execute
      @y = ""
      st = @stream
      begin
        x = st.gets
        x or break
        send x
        redo
      end while nil
      @y
    end

  private

    def match_continuing  # #tracked by [#033]
      send @stream.gets
    end

    def match
      @stream.gets
      @stream.gets
      send @stream.gets
    end

    def static_continuing
      send @stream.gets
    end

    def static
      send @stream.gets
    end

    def content
      @y << @stream.gets
    end

    def LTS_begin
      @y << @stream.gets
    end

    def LTS_continuing
      @y << @stream.gets
    end

    def LTS_end
      NOTHING_
    end
  end
end
