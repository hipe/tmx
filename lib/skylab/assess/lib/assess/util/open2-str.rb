require 'open3'
module Hipe
  module Assess
    module Open2Str
      def open2_str cmd
        Open3.popen3(cmd) do |sin,sout,serr|
          out_str = sout.read
          err_str = serr.read
          [out_str, err_str]
        end
      end
    end
  end
end
