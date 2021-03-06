#!/usr/bin/ruby
# Creative Commons BY-SA :  Regis d'Aubarede <regis.aubarede@gmail.com>
# LGPL

#####################################################################
#  sketchi.rb : edit/test component() methods
#               not an IDE....
#####################################################################
# encoding: utf-8
require_relative '../lib/Ruiby'

class RubyApp < Ruiby_gtk
    def initialize
      super("Skechi",1200,0)
      @filedef=Dir.tmpdir+"/sketchi_default.rb"
      if File.exists?(@filedef)
        load(@filedef,nil)
      else
        load("new.rb",<<EEND)
def b()
  w=button(Time.now.to_i.to_s)
  w.sensitive=true
  w
end

stack {
   stacki { b ; b ; b}
   stack { flow { 
    stacki { b;b;b}; 
    f=frame("Eeedddddddd") { b;b;w=b ; } ; 
    f.set_border_width(30)
   } } 
   buttoni("eeeeeeeee")
}
EEND
      end
    end
  def component()
    stack do
      htoolbar_with_icon_text do
        button_icon_text "open","Open file..." do
          load(ask_file_to_read(".","*.rb"),nil)
        end
        button_icon_text "Save","Save buffer to file..." do
          @file=ask_file_to_write(".","*.rb") unless File.exists?(@file)
          @title.text=@file
          content=@edit.buffer.text
          File.open(@file,"wb") { |f| f.write(content) } if @file && content && content.size>2
        end
        separator
        button_icon_text("about","Predefined icons"){ dialog_icones }
        button_icon_text("select_font","Show font")  { dialog_font }
      end 
      separator
      stack_paned(600,0.7) do
        flow_paned(1200,0.5) do 
          stack {
            @title=sloti(label("Edit"))
            @edit=(source_editor(:lang=> "ruby", :font=> "Courier new 12") {|w,t| source_changed(t) }).editor
            @bt=buttoni("Test...") { execute() }
          }
          stack { @demo=stack {label("empty...")} }
        end
        notebook do 
          page("Error") { @error_log=text_area(600,100,{:font=>"Courier new 10"}) }
          page("Help") { make_help(text_area(600,100,{:font=>"Courier new 10"})) }
          page("API") { make_api(text_area(600,100,{:font=>"Courier new 10"})) }
          #page("Example") { make_example(text_area(:font=> "Courier new 10")) }
        end
      end
    end
    @last_text_changed=false
    anim(10) {
      if Array===@last_text_changed && @last_text_changed.last<Time.now-0.3
          @last_text_changed=false
          old=@content
          ok=execute(false)
          execute(false,old) unless ok
          @bt.options(bg: ok ?  "#C0C0C0" : "#FFAAAA") 
          @bt.label= ok ? "Test" : "Test (currently, error)"
      end
    } 
  end
  
  def dialog_icones
    dialog "Ruiby Predefined icones" do
        stack do
          scrolled(400,500) { 
            Gtk::IconTheme.default.icons.sort.map { |name|  
              (flow { labeli "#"+name.to_s ; entry(name.to_s)  } rescue nil) if name.to_s !~ /symbolic/
            } 
            Gtk::IconTheme.default.icons.sort.map { |name|  
              (flow { labeli "#"+name.to_s ; entry(name.to_s)  } rescue nil) if name.to_s =~ /symbolic/ 
            } 
         }
        end
    end
  end
  def dialog_font
    dialog "Ruiby Predefined icones" do
        conf={typo: "Arial", type: "bold", size: 12}
        we=entry("text...",30)
        properties("attributes",conf,edit: true) { |confpp|
          apply_options(we,font: confpp.values.join(" "))
        }
    end
  end
  def source_changed(t) @last_text_changed=[t,Time.now] end
  def execute(err=true,text=nil)
    @content= text ? text : @edit.buffer.text
    clear_append_to(@demo) {
      frame { stack {
      eval(@content,binding() ,"<script>",1) 
      @error_log.text="ok." 
      } }
    }
    File.open(@filedef,"w") {|f| f.write(@content)} if @content.size>30 && ! text
    true
  rescue Exception => e
    trace(e) if err
    false
  end
  def trace(e)
    @error_log.text=e.to_s + " : \n   "+ e.backtrace[0..3].join("\n   ")
  end
  def make_api(ta)
    ta.text=::Ruiby.make_doc_api().join("\n")
  end
  def make_help(ta)
    src=File.dirname(__FILE__)+"/../lib/ruiby_gtk/ruiby_dsl.rb"
    content=File.read(src)
    comment=""
    hdoc=content.split(/\r?\n\s*/).inject({}) {|h,line|
      ret=nil
      if a=/^def[\s]+([^_].*)/.match(line)
        name=a[1].split('(')[0]
        ret="#{a[1].split(')')[0]+")"} :\n\n#{comment.gsub('#',"")}\n#{'-'*50}\n"
        comment=""
      elsif a=/^\s*#\s*(.*)/.match(line)
        comment+="   "+a[1]+"\n"
      end
      h[name]=ret if ret
      h
    }
    ta.text=hdoc.keys.sort.map {|k| hdoc[k]}.join("\n")
  end
  def make_example(ta)
    src=File.dirname(__FILE__)+"/test.rb"
    content=File.read(src)
    ta.text=content.split(/(def component)|(end # endcomponent)/)[2]
  end
  def load(file,content)
    if File.exists?(file) && content==nil
      content=File.read(file)
    end
    return unless content!=nil 
    @file=file
    @mtime=File.exists?(file) ? File.mtime(@file) : 0
    @content=content
    @edit.buffer.text=content
  end
end

Ruiby.start_secure { RubyApp.new }


