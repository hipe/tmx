require File.expand_path('../../../skylab', __FILE__)

require 'strscan'

module Skylab
  module CovTree

    ROOT = Pathname.new(File.expand_path('..', __FILE__))

    TEST_DIR_NAMES = %w(test spec features)

    def TEST_DIR_NAMES.string ; "[#{join '|'}]" end

    GLOBS = {
      'features' => '*.feature',
      'spec' => '*_spec.rb',
      'test' => '*_spec.rb'
    }

    def self.glob_to_re glob
      scn = StringScanner.new(glob)
      out = []
      until scn.eos?
        if scn.scan(/\*/)
          out.push '(.*)'
        elsif s = scn.scan(/[^\*]+/)
          out.push "(#{Regexp.escape(s)})"
        else
          fail("Unexpected rest of string (don't use '**'): #{scn.rest}")
        end
      end
      out.join('')
    end

    TEST_BASENAME_RE = %r{^(?:#{GLOBS.values.uniq.map{ |x| glob_to_re(x) }.join('|')})$}
  end
end

