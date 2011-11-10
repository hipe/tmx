#!/usr/bin/env ruby

require 'ncurses'

module Skylab; end

module Skylab::Kurse
  module BuilderMethods; end
  extend BuilderMethods
  module BuilderMethods
    def run_progress_bar(*a, &b)
      ProgressBar.new(*a, &b).run
    end
  end
  class DefaultUi < Struct.new(:out, :err)
    def self.singleton
      @singleton ||= new($stdout, $stderr)
    end
  end
  class ProgressBar
    def initialize(ui = nil, &b)
      ui ||= DefaultUi.singleton
      @out, @err = [ui.out, ui.err]
    end
    attr_reader :out, :err
    def run
      err.puts "------------------>98%"
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  include Skylab
  Kurse.run_progress_bar
end

