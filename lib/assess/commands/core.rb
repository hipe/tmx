module Hipe
  module Assess
    module Commands
      x 'Prints the current version and exits.'
      def boobric(options = {}, *args)
        ui.puts "#{app} #{Assess::Version}"
      end
    end
  end
end
