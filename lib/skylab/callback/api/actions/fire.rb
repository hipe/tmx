module Skylab::Callback

  class API::Actions::Fire < API::Action

    PARAMS = [ :do_show_backtrace,
               :files,
               :opendata,
               :modul,
               :stream_symbol
    ].each { |k| attr_writer k }

    def execute
      ok = resolve_params
      ok &&= resolve_infiles
      ok &&= resolve_mod
      ok && work
    end

  private

    def work
      _pay_x = produce_payload_x
        n = @mod.instance_method(:initialize).parameters.count{|a, _| :req == a}
        obj = @mod.new(* n.times.map { } )
        did_fire = false
        obj.send :"on_#{ @stream_symbol }" do |x|
          did_fire = true
          if x.instance_variable_defined? :@event_stream_graph
            x.instance_variable_set :@event_stream_graph, '[..]'  # pray
          end
          @infostream.puts "OK: #{ x.inspect }"
        end
        obj.send :call_digraph_listeners, @stream_symbol, _pay_x
        if ! did_fire
          @infostream.puts "(#{ prefix }did not see a #{ @stream_symbol } #{
            }event fire.)"
        end
        true
    end

    def produce_payload_x
      if @opendata
        OPENDATA_H__.fetch( @opendata.first )[ @opendata ]
      else
        'wizzle pazzle whatever'
      end
    end

    OPENDATA_H__ = {
      string: -> od { od[ 1 ] },
      box:    -> od { od[ 1 ].to_hash }
    }.freeze

  end
end
