# thanks nitay
require 'assess/code-builder/file-backup'
require 'assess/util/open2-str'
require 'pathname'
require 'shellwords'

module Hipe::Assess
  module Graphviz
    include Open2Str
    def generate out, opts, graph
      gv = GraphViz.new(:your_awesome_datamodel, :type=>:digraph)
      gv[:rankdir] = "LR" # no idea
      alter_gv_with_opts(gv, opts)
      models gv, graph
      edges gv, graph, opts
      begin
        return dot(out, opts, gv) if opts.dot?
        return cmd(out, opts, gv) if opts.cmd?
        return img(out, opts, gv)
      rescue StandardError=>e
        raise e # @todo temp debugging
        flail(e.message){no_help!.here!}
      end
      nil
    end
  private
    def models gv, graph
      graph.models.each do |m|
        label_rows = ["= #{m.name} ="]
        m.properties.each do |p|
          next if p.name == 'id'
          label_rows << "#{p.name} : #{p.type}"
        end
        label = ('{ '<< (label_rows*' | ') <<'  }')
        node = gv.add_node(m.name)
        node.shape = 'record'
        node.label = label
      end
    end
    def edges gv, graph, opts
      graph.models.each do |m|
        node = gv.get_node(m.name)
        m.relationships.each do |rel|
          to_name = rel.target_name
          to_node = gv.get_node(to_name)
          unless to_node
            flail(
            "Could not find model #{to_name}, referenced by #{m.name}.\n"<<
            "Run with -j to see a dump or -h for help."){no_help!.here!}
          end
          case rel.type
          when :one_to_one
            e = gv.add_edge(node, to_node)
            e.color = opts.oto_color
            e.label = " has_one"
          when :one_to_many
            e = gv.add_edge(node, to_node)
            e.color = opts.otm_color
            e.label = " has_many"
          when :many_to_one
            if opts.many_to_one?
              e = gv.add_edge(node, to_node)
              e.color = opts.e_color
              e.label = " belongs_to"
            end
          when :many_to_many
            e = gv.add_edge(node, to_node)
            e.color = opts.e_color
            e.label = " many_to_many"
          else
            flail("Sorry, we still need to implement this type: "<<
              "#{rel.type.inspect}"){ no_help!.here! }
          end
        end
      end
    end # def edges
    def dot out, opts, gv
      resp = gv.output( :none => String )
      out.write resp
      out.err.puts "#{Cmd.soft_name}: done outputting dot"
      nil
    end
    def cmd out, opts, gv
      cmd = cmd_struct gv, opts
      puts "#{Cmd.soft_name}: using ruby-graphviz: #{cmd.path}:#{cmd.ln}}"
      puts "#{Cmd.soft_name}: the generated dot command "<<
             "(note it won't work because of the tempfiles):\n\n"
      puts cmd.str
      puts "\n#{Cmd.soft_name}: done"
      nil
    end
    def img out, opts, gv
      cmd = cmd_struct gv, opts
      return cmd.tgt.prune_backups(out, opts) if opts.prune_backups?
      out_s, err = open2_str(cmd.str)
      flail("not expecting any output from "<<
         " command:\nhad:#{out_s.inspect}"){no_help!.here!} if ""!= out_s
      out.err.puts err
      post_process_tempfile(out, opts, cmd)
      puts "#{Cmd.soft_name}: done"
    end
    def cmd_struct gv, opts
      final_target = FileBackup[output_img_pathname(opts)]
      two = final_target.basename.to_s.split(Const::ExtRe)
      two[1][0,0] = '.'
      tempfile = Tempfile.new(two)
      temp_target = tempfile.path
      tempfile.close
      cmd_str, struct = cmd_orig_info gv, opts, temp_target
      use_cmd_str = cmd_enhance cmd_str, opts
      struct[:str] = use_cmd_str
      struct[:temp_target] = temp_target
      struct[:tgt] = final_target
      struct.keys_to_methods!
      struct
    end
    def cmd_enhance cmd, opts
      arr = cmd.shellsplit
      idx = arr.index{|x| /^-/ =~ x}
      if opts.verbose?
        arr.insert(idx,'-v')
      end
      cmd2 = arr.shelljoin
      cmd2
    end

    #
    # Hack GraphViz object to tell us the command it generates
    # ruby-graphviz doesn't have a "proper" api, it's just basically one
    # huge function so we totally hack it in a fragile way to give us the
    # command it generates at a certain point.   Will break when GraphViz
    # changes.  A better thing to do might be refactor it and send a patch.
    # @return [Array] [cmd_string, where_info_hash]
    #
    def cmd_orig_info gv, opts, temp_target
      class << gv; def output_from_command(cmd);throw(:haxxor,binding) end end
      binding = catch(:haxxor){ gv.output(opts.fmt=>temp_target) }
      cmd, where_str = eval('[cmd, caller[1]]', binding)
      where_info = HashExtra[Common.trace_parse(where_str)]
      [cmd,where_info]
    end
    def output_img_pathname opts
      path = Pathname.new(opts.outpath)
      prefix = (path.relative? && 0 != path.to_s.index('./')) ? './' : nil
      affix = path.extname.empty? ? ".#{opts.fmt}" : nil
      these = [prefix, path.to_s, affix].compact
      if these.size > 1
        path = Pathname.new(these.join('')) # not file join
      end
      path
    end
    def alter_gv_with_opts gv, opts
      ks = opts.keys - [:joins?, :struct?]
      re = /\A(?:(n)|(e))-(.+)\Z/
      ks.each do |k|
        next unless md = re.match(k.to_s)
        gv.send(md[2] ? :edge : :node)[md[3].intern] = opts[k]
      end
    end
    def post_process_tempfile out, opts, cmd
      flail("expecting temp target to exist after dot command: "<<
      "#{cmd.temp_target}"){no_help!.here!} unless
        File.exist?(cmd.temp_target)
      opts2 = {:verbose=>true, :noop=>opts.dry_run?}
      do_it = true
      if cmd.tgt.exists?
        if FileUtils.compare_file(cmd.temp_target, cmd.tgt.path)
          bytes = File.size(cmd.tgt.path)
          out.puts "#{Cmd.soft_name}: skipping -- no change in "<<
            "#{bytes} bytes of #{cmd.tgt.path}"
          do_it = false
        end
      end
      if do_it
        cmd.tgt.backup(out, opts) if cmd.tgt.exists? && opts.backup?
        FileUtils.mv(cmd.temp_target, cmd.tgt.path, opts2)
        puts "#{Cmd.soft_name}: wrote #{cmd.tgt.path}"
      end
      nil
    end
  end
end
