require File.expand_path('../test-support', __FILE__)
require File.expand_path('../../file-services', __FILE__)


module Skylab::CodeMolester
  describe FileServices do
    include TestSupport
    let(:mock_file_writer_class) do
      Class.new(Pathname).class_eval do
        include FileServices
        attr_writer :content
        self
      end
    end

    TABLE = <<-TABLE
    | content | valid?  | dir? | exist? |
    |  empty  | valid   |  no  |        |
    |         | invalid |  no  |        |
    |         |   no    |  yes |  no    |
    |         | invalid |  yes |  yes   |
    |   some  |  valid  | dir  |  exist |
    |         |         |      |        |
    |         |         |      |        |
    |         |         |      |        |
    TABLE
  end
end
