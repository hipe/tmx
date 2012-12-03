require_relative '../test-support'

module Skylab::CovTree::TestSupport::CLI
  ::Skylab::CovTree::TestSupport[ self ] # #regret


  module InstanceMethods
    let :client do
      es = ___build_emit_spy!

      fsck = -> p do # so borked, waiting for [#003]
        p.on_error    { |e| es.emit :error, e.to_s }
        p.on_info     { |e| es.emit(:info, e.touch!.to_s) unless e.touched? }
        p.on_payload  { |e| es.emit(:payload, e.to_s) }
      end

      cli = CovTree::CLI.new do |rt|
        rt.invocation_slug = 'cov-tree' # this took me 20 minutes to figure out
        fsck[ rt ]
        rt.on_all do |e|
          unless e.touched?
            e.touch!
            es.emit e.type, e.payload
          end
        end
      end

      fsck[ cli ] # it's so bad

      cli
    end
  end
end
