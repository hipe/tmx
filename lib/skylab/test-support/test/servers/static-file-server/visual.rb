#!/usr/bin/env ruby -w

require_relative '../../core'

clas = ::Skylab::TestSupport::Servers::Static_File_Server

doc_root = ::Skylab::dir_pathname.join( 'dependency/test/fixtures' ).to_s

server = clas.new doc_root, pid_path: '.', log_level_i: :info

server.run
