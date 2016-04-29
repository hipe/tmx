module Skylab::MyTerm::TestSupport

  module Stubs::Filesystem_01 ; class << self

    # this is #[#sy-032] an alternative implementation of [#sy-027]
    # (rough sketch)

    def produce_new_instance
      self
    end

    def glob path
      if path.include? '/image-output-adapters-'
        ::Dir.glob path
      else
        [ '/zoopie/doopie/fontible.dfont', '/zooper/dooper/lucida-font.dfont' ]
      end
    end

  end ; end
end
