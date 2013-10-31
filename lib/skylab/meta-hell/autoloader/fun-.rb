module Skylab::MetaHell

  module Autoloader

    module Fun_

      Pathify_with_extension_ = -> ext, x do
        "#{ Autoloader::FUN.pathify[ x ] }#{ ext }"
      end

      As_code_file_ = Pathify_with_extension_.curry[ Autoloader::EXTNAME ]

    end
  end
end
