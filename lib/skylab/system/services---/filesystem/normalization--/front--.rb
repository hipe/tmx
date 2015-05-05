fail 'NO' # this is just old scraps that will possibly be used for [#022]
require 'skylab/slake/muxer'

module Skylab::CodeMolester
  module FileServices; end
  class FileServices::WriteEventKnob
    extend ::Skylab::Slake::Muxer
    listeners_digraph  :all,
      :skipped             => :all,
      :failed              => :all,
      :contents_empty      => :skipped,
      :no_change           => :skipped,
      :invalid             => :failed,
      :not_writable        => :failed,
      :write_rewrite_start => :all,
      :write_start         => :write_rewrite_start,
      :rewrite_start       => :write_rewrite_start,
      :write_rewrite_end   => :all

    alias_method :[], :call_digraph_listeners
  end
end
