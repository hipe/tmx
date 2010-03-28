module Hipe
  module Assess
    module Commands

      listing_index 500

      o "#{app} graphviz [OPTIONS] [MODEL_PATH]"
      x 'Debugging support for the backend graph-viz interface.'
      x 'Can be used to generate dotfiles from a DM model, or pngs.'
      x
      x 'Arguments:'
      x '  MODEL_PATH         for now your model must load itself from this'
      x '                     one file.  If the argument is not provided,'
      x '                     heuristics will be used to guess the model'
      x '                     location (recommended - make the borg' <<
                              ' stronger).'
      x
      x( GraphVizOpts = lambda{|o|

          TestedFormatTypes = %w(png)

          o.x 'Assess Options:'

          o.x FileBackupOptions

          o.on('--[no-]bt',:many_to_one?,
            'skip belongs to (covered by has many)',
            :default => false
          )

          # o.on('--[no-]join', :joins?,
          #   'for what appear to be join tables, whether',
          #   'or not to show them individually', :default => false)

          o.x
          o.x 'Debugging Commands (as options):'
          o.on('-s, --struct',  :struct?,
            'just show the generated ruby datastructures',
            'and exit (just for debugging)')
          o.on('-j, --json', :json?, 'as above but json')
          o.on('-t, --dot',  :dot?,  'as above but dotfile')
          o.on('-c, --cmd',  :cmd?,
                        'as above but show the generated dot command')

          o.x
          o.x 'GraphViz (dot) Options:'
          o.on('-v',:verbose?, 'Enable verbose mode')
          o.on('-T=EXT', :fmt,
                'a tested subset of output formats supported by GraphViz',
                :default => 'png'
          ) do
            if ! TestedFormatTypes.include?(o.fmt)
              is, the, s = TestedFormatTypes.size == 1 ?
                ['is','The only currently s', ''] : ['are', 'S', 's']
              flail(
              "#{o.fmt.inspect} is an unknown or untested format type."<<
              "\nIt might work but we need to write tests for new formats."<<
              "\n#{the}upported format type#{s} #{is}: "<<
               Common.oxford_comma(TestedFormatTypes)
              ){ no_help!.here! }
            end
          end
          o.on('-o=OUTFILE',:outpath,'output filename',
            :default => begin
              name = Graphviz.app.name.dup
              # 'current app' => 'current-model.png'
              name.sub!(/\b ?app(?:lication)? ?\b/,' model')
              name.concat(' model') unless /\bmodel\b/i =~ name
              name = underscore_lossy(name).gsub('_','-')+'.'+o.fmt
              name
            end
          )

          Beige = '#ffeecc'
          LtBlu = "#58faf4"
          Perri = "#58ACFA"
          Violt = "#AC58FA"
          Darck = "#1C1C1C"
          Feint = "#999999"
          Neutr = "#696969"
          Grrey = "#444444"
          Slate = "#045FB4"
          # old font color "#775500"
          # old color '#ddaa66'

          o.x
          o.x 'ruby-graphviz Options:'
          o.x
          o.on('--rankdir',         :g_rankdir   ,:default=>'LR')
          o.x '  Global Node Options:'
          o.on('--style=ARG',       :n_style     ,:default => 'filled')
          o.on('--shape=ARG',       :n_shape     ,:default => "box" )
          o.on('--penwidth=ARG',    :n_penwidth  ,:default => "1" )
          o.on('--fontname=ARG',    :n_fontname  ,:default => "Trebuchet MS")
          o.on('--fontsize=ARG',    :n_fontsize  ,:default => "8" )
          o.on('--margin=ARG',      :n_margin    ,:default => "0.25" )
          o.on('--color=ARG',       :n_color     ,:default => Grrey)
          o.on('--fillcolor=ARG',   :n_fillcolor ,:default => Perri )
          o.on('--fontcolor=ARG',   :n_fontcolor ,:default => Darck )

          o.x
          o.x '  Global Edge Options:'
          o.on('--e-color=ARG',     :e_color      ,:default => Feint)
          o.on('--e-weight=ARG',    :e_weight     ,:default => "1" )
          o.on('--e-fontsize=ARG',  :e_fontsize   ,:default => "6" )
          o.on('--e-fontcolor=ARG', :e_fontcolor  ,:default => Grrey)
          o.on('--e-fontname=ARG',  :e_fontname   ,:default => "Verdana" )
          o.on('--e-dir=ARG',       :e_dir        ,:default => "forward" )
          o.on('--e-arrowsize=ARG', :e_arrowsize  ,:default => "0.7" )
          o.on('--mtm-color=ARG',   :mtm_color    ,:default => Slate)
          o.on('--mto-color=ARG',   :mto_color    ,:default => "pink")
          o.on('--otm-color=ARG',   :otm_color    ,:default => Neutr )
          o.on('--oto-color=ARG',   :oto_color    ,:default => "red")

        })

      def graphviz opts, model_file=nil
        require 'assess/code-adapter/graphviz'
        return help if opts[:h]
        return short_help unless opts.valid?(&GraphVizOpts)
        Graphviz.process_generate_dotfile_request ui, opts, model_file
      end
    end
  end
end
