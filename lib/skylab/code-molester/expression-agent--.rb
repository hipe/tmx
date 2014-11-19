module Skylab::CodeMolester

  class Expression_Agent__

    LIB_.NLP_EN_methods self  # or_

    def initialize x_a
      @escape_path_p = nil
      send :"#{ x_a.shift }_iambic_notify", x_a.shift while x_a.length.nonzero?
      @escape_path_p ||= -> x { x and ::Pathname.new( x ).basename } ; nil
    end
  private
    def escape_path_iambic_notify p
      @escape_path_p = p ; nil
    end
    def pth pn
      @escape_path_p[ pn ]
    end
  end
end
