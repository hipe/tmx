module Skylab::Slake::TestSupport
  class Tee < ::Hash
    %w(puts write).each do |meth|
      define_method meth do |*a|
        each do |k, v|
          v.send meth, *a
        end
      end
    end
  protected
    def initialize hash
      hash.each do |k, v|
        self[k] = v
      end
    end
  end
end
