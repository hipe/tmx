module Skylab::Slicer

  Modality_Adapters_ = ::Module.new

  class Modality_Adapters_::CLI

    def initialize argv, _, o, e, a

      @argv = argv
      @stdout = o
      @stderr = e
    end

  private

    def express_usage
      @stderr.puts "usage: #{ ::File.basename $PROGRAM_NAME }#{ usage_suffix_ }"
      NIL_
    end

    def usage_suffix_
    end
  end
end
