require 'skylab/porcelain/bleeding'

module Skylab::Treemap
  Bleeding = Skylab::Porcelain::Bleeding
  class CLI < Bleeding::Runtime
    extend Skylab::PubSub::Emitter

    emits Bleeding::EVENT_GRAPH
    emits payload: :all

    desc "experiments with R."

    def porcelain # @todo:not here
      self.class
    end
  end
  class << CLI
    def build_client_instance _, opts=nil
      stdout = opts[:out_stream] or fail('need an out_stream')
      stderr = opts[:err_stream] or fail('need an err_stream')
      slug   = opts[:invocation_slug] or fail('no an invocation_slug')
      $VERBOSE = true
      rt = new
      rt.on_payload { |e| stdout.puts e.message }
      rt.on_error   { |e| stderr.puts "#{rt.program_name} error: #{e.message}" }
      rt.on_help    { |e| stderr.puts e.message }
      rt.program_name = slug
      if runtime_instance_settings
        runtime_instance_settings.call rt
      end
      rt
    end
    def porcelain # @todo:not here
      self
    end
    attr_accessor :runtime_instance_settings
  end
  class Action
    extend Bleeding::Action
  end
  module Actions
  end
  class Actions::Install < Action
    URL_BASE = 'http://cran.stat.ucla.edu/'
    def execute
      emit :payload, "To install R, please download the package for your OS from #{URL_BASE}"
    end
  end
end

