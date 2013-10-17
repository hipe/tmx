module Skylab::CodeMolester

  class Expression_Agent__

    include Headless::NLP::EN::Methods  # or_

    def initialize x_a
      @escape_path_p = nil
      send :"#{ x_a.shift }_iambic_notify", x_a.shift while x_a.length.nonzero?
      @escape_path_p ||= -> x { x and ::Pathname.new( x ).basename } ; nil
    end
  private
    def escape_path_iambic_notify p
      @escape_path_p = p ; nil
    end
    def escape_path pn
      @escape_path_p[ pn ]
    end
  end
end
