module Skylab::Slicer

  class Modality_Adapters_::CLI

    def initialize argv, _, o, e, a

      @argv = argv
      @program_name_string_array = a
      @stdout = o
      @stderr = e
    end

  private

    def express_usage
      _ = @program_name_string_array.join SPACE_
      @stderr.puts "usage: #{ _ }#{ usage_suffix_ }"
      0
    end

    def usage_suffix_
    end
  end
end
