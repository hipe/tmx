module Skylab::TanMan
  module Sexp::Auto::Recursive
    # this is a placeholder for the idea of it.  it may be just a more
    # explicit alias of the thing.
  end
  module Sexp::Auto::Recursive::BuildMethods ; include Sexp::Auto::BuildMethods
  end
  Sexp::Auto::Recursive.extend Sexp::Auto::Recursive::BuildMethods
end
