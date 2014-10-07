module Skylab::TestSupport::Regret::API

  module API::Conf

    Verbosity = API::Support::Verbosity::Graded :notice, :medium, :murmur
    # NOTE the order of the symbols above corresponds to the number of "-v"'s !


    DOC_TEST_DIR_ = 'test/doc-test'

    DOC_TEST_FILES_FILE_ = 'data-documents/files'

    def self.[] i
      const_get "#{ i.upcase }_", false
    end

    rx = /\A([A-Z_]*[A-Z])_\z/
    constants.each do |i|
      if (( md = rx.match i ))
        define_singleton_method md[1].downcase do
          const_get i, false
        end
      end
    end
  end
end
