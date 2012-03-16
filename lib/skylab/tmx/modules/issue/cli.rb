require File.expand_path('../../../../issue/porcelain', __FILE__)

module Skylab
  module Tmx
    module Issue
      extend ::Skylab::Porcelain
      namespace :'issue', ::Skylab::Issue::Porcelain
    end
  end
end

