module Skylab::Basic

  module Pathname

    class << self

      def normalization
        Pathname::Normalization__
      end

      def try_convert x
        x and begin
          if x.respond_to? :relative_path_from
            x
          elsif x.respond_to? :to_path
            ::Pathname.new x.to_path
          else
            ::Pathname.new x
          end
        end
      end
    end

    Pathname_ = self
  end
end
