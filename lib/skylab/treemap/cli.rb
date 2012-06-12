require_relative 'actions'

module Skylab::Treemap
  class CLI < Skylab::Porcelain::Bleeding::Runtime
    extend Skylab::PubSub::Emitter

    emits Skylab::Porcelain::Bleeding::EVENT_GRAPH
    emits payload: :all, info: :all

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
      rt.on_error   { |e| stderr.puts "#{rt.program_name} error: #{e.message}" }
      rt.on_help    { |e| stderr.puts e.message }
      rt.on_info    { |e| stderr.puts "#{rt.program_name}: #{e.message}" }
      rt.on_payload { |e| stdout.puts e.message }
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
end

