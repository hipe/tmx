require_relative '..'

require 'skylab/face/core'
require 'skylab/meta-hell/core'
require 'skylab/porcelain/all' # special, annoying

module Skylab; end

module Skylab::Tmx
  extend ::Skylab::MetaHell::Autoloader::Autovivifying::Recursive

  module Modules; end

  class Cli < ::Skylab::Face::Cli

    version { File.read(File.expand_path('../../../../VERSION', __FILE__)) }

    # @todo: @after:#100 unhack the below rediculous mess
    face_namespaces = ::Skylab::Face::Command::Namespace.namespaces
    porc_namespaces = ::Skylab::Porcelain.namespaces
    both = [face_namespaces, porc_namespaces]

    o = { }
    o[:jshint] = false
    o[:nginx] = false
    o[:pnp] = false
    o[:schema] = false
    o[:'team-city'] = false
    o[:xpdf] = false

    Dir["#{File.dirname(__FILE__)}/modules/*/cli.rb"].each do |cli_path|
      pn = ::Pathname.new cli_path
      norm = pn.dirname.basename.sub_ext('').to_s.intern
      if false == o[norm]
        # skip
      else
        f1, p1 = both.map(&:length)
        require cli_path
        f2, p2 = both.map(&:length)
        ns = nil
        if p2 > p1
          ns = porc_namespaces[p1]
        elsif f2 > f1
          ns = face_namespaces[f1]
        else
          fail "Must add a namespace, did not: #{ cli_path }"
        end
        namespace ns
      end
    end

    # @todo during #100.100
    def emit type, e
      if @map[type]
        @map[type].call.puts e.to_s
      else
        @err.puts "BERKS: ->#{type.inspect}<->#{e.to_s}<-"
      end
    end

    def initialize *a
      block_given? and raise ArgumentError.new("this crap gets settled in #100")
      # temp hack (see emit above)
      outs = ->{ out }
      errs = ->{ err }
      @map = {
        payload: outs,
        help:    errs,
        info:    errs,
        error:   errs
      }
      super
    end
  end
end

