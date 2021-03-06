#!/usr/bin/ruby
# Creative Commons BY-SA :  Regis d'Aubarede <regis.aubarede@gmail.com>
# LGPL

#####################################################################
#  editor.rb : simple text (ruby) editor in Ruiby
#####################################################################
# encoding: utf-8
require_relative '../lib/Ruiby'


class RubyApp < Ruiby_gtk
  def initialize
      super("Testing Ruiby editor",700,600)
      load(__FILE__)
  end
  def component()
    stack do
      htoolbar do
        toolbar_button("open","ouvrir fichier") {
          load(ask_file_to_read(".","*.rb"))
        }
        toolbar_button("Save","sauvegarder le fichier") {
          content=@edit.buffer.text
          File.open(@file,"wb") { |f| f.write(content) } if @file && content && content.size>2
        }
        toolbar_button("save_as","sauvegarder le fichier") {
          file=ask_file_to_write(".","*.rb")
          if file
            @file=file
            content=@edit.buffer.text
            File.open(@file,"w") { |f| f.write(content) } if @file && content && content.size>2
          end
        }
      end
      @edit=source_editor(:width=>200,:height=>50,:lang=> "ruby", :font=> "Courier new 12",:on_change=> proc { change }).editor
      sloti( button("Exit") { exit! })	
      after(20)   { rposition(-3,3) }
      anim(500) do
        if @file && File.exists?(@file) && File.mtime(@file)>@mtime
          @mtime=File.mtime(@file)
          if ask("File #{@file} have change on disk, reload it ?")
            load(@file)
          else
            alert("not updated")
          end
        end
      end
    end
  end
  
  def change(*t)
    puts "changer #{t.inspect}"
  end    
  
  def load(file)
    return unless file
    return unless File.exists?(file)
    @file=file
    @mtime=File.mtime(@file)
    @edit.buffer.text=File.read(@file)
  end
end
Ruiby.start { window = RubyApp.new }
