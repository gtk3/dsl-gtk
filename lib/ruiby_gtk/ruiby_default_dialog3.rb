# Creative Commons BY-SA :  Regis d'Aubarede <regis.aubarede@gmail.com>
# LGPL
#

module Ruiby_default_dialog
  def _gooooooooooo 
  end
  
  include ::Gtk

  # alert(txt): modal popup with text (as in html)
  def alert(*txt) message(:info,*txt) end
  # modal popup with text and/or ruby Exception.
  def error(*txt) 
    lt=txt.map { |o| 
      if Exception===o 
        puts o.to_s + " : \n  "+o.backtrace.join("\n  ")
        o.to_s + " : \n  "+o.backtrace[0..20].join("\n  ")
      else
        o.to_s
      end
    }
    message(:error,*lt) 
  end
  # show a modal dialog, asking question, active bloc closure with text response
  # in parameters
  # prompt("Age ?") { |n| alert("Your age is #{n-1}, bravo !")
  def prompt(txt,value="") 
     dialog = Dialog.new(
      title: "Message",
      parent: self,
      flags: [Dialog::DESTROY_WITH_PARENT],
      buttons: [ [Stock::OK,1], [:annulation,2] ]
    )

    label=Label.new(txt)
    entry=Entry.new().tap {|e| e.set_text(value) }
    dialog.vbox.add(label)
    dialog.vbox.add(entry)
    dialog.set_window_position(:center)

    dialog.signal_connect('response') do |w,e|
      rep=true
      rep=yield(entry.text) if block_given?
      dialog.destroy if rep
    end
    dialog.show_all	
    unless block_given?
        rep=dialog.run
        response=entry.text
        dialog.destroy
        rep==1 ? response : nil
    end
  end
  def promptSync(txt,value="") 
     dialog = Dialog.new(
      title: "Message",
      parent: self,
      flags: [Dialog::DESTROY_WITH_PARENT],
      buttons: [ [Stock::OK,1], [:annulation,2] ]
    )

    label=Label.new(txt)
    entry=Entry.new().tap {|e| e.set_text(value) }
    dialog.vbox.add(label)
    dialog.vbox.add(entry)
    dialog.set_window_position(:center)
    dialog.show_all	
    
    rep=dialog.run
    response=entry.text
    dialog.destroy
    if block_given? && rep==1
      yield(reponse)  
    else
      rep==1 ? response : nil
    end
  end


  # show a modal dialog, asking yes/no question, return boolean response
  def ask(*txt) 
    text=txt.join(" ")
    md = MessageDialog.new(
      :parent => self, 
      :flags => :destroy_with_parent, 
      :type => :question, 
      :buttons_type => :yes_no,
      :message => text
    )
    md.set_window_position(:center)
    rep=md.run
    md.destroy
    return( rep==-8 )
  end
  
  # travce() : like alert(), but with a  warning icone
  def trace(*txt) message(:warning,*txt) end

  def message(style,*txt)
    text=txt.join(" ")
    md = MessageDialog.new(
        parent: self,
        flags: :destroy_with_parent,
        type: style,
        buttons_type: :close, 
        message: text)
    md.set_window_position(:center)
    md.run
    md.destroy
  end
  
  # modal dialog asking a color
  def ask_color()
    cdia = ColorChooserDialog.new(title: "Select color")
    cdia.set_window_position(:center)
    response=cdia.run
    color=nil
    if response == Gtk::ResponseType::OK
        rgba = cdia.rgba
        color = Gdk::Color.new(rgba.red*65535, rgba.green*65535, rgba.blue*65535)
    end 		
    cdia.destroy
    p color
    color
  end

  ########## File Edit
  
  # dialog showing code editor, 
  # call back is called on exit button, 
  # edit("x.txt") { |content| compile(content) ? true : (alert("error!");false) }
  #
	def edit(filename,&blk)
		Editor.new(self,filename,350,&blk) 
	end
  
  ########## File dialog

  # ask a existent file name 
  def ask_file_to_read(dir,filter)
    dialog_chooser("Choose File (#{filter}) ...", Ruiby.gtk_version(3) ? :open : Gtk::FileChooser::ACTION_OPEN, Gtk::Stock::OPEN)
  end
  
  # ask a filename for creation/modification
  def ask_file_to_write(dir,filter)
   dialog_chooser("Save File (#{filter}) ...", Ruiby.gtk_version(3) ? :save : Gtk::FileChooser::ACTION_SAVE, Gtk::Stock::SAVE)
  end
  
  # ask a existent dir name
  def ask_dir_to_read(initial_dir=nil)
    dialog_chooser(
        "Select existing Folder ...",
        Gtk::FileChooser::ACTION_SELECT_FOLDER,
        Gtk::Stock::OPEN) {|d| 
      d.filename=initial_dir if initial_dir && File.exists?(initial_dir)
    }
  end
  
  # ask  a dir name 
  def ask_dir_to_write(initial_dir=nil)
    dialog_chooser(
      "Select Folder or create one ...", 
      Gtk::FileChooser::ACTION_SELECT_FOLDER ,
      Gtk::Stock::OPEN) {|d|
      d.filename=initial_dir if initial_dir 
    }
  end
  def dialog_chooser(title, action, button)
      if Ruiby.gtk_version(3)
        dialog = Gtk::FileChooserDialog.new(
            :title => title, 
            :parent => self, 
            :action => action, 
            :buttons => [ ##  ??
              [Gtk::Stock::CANCEL, Ruiby.gtk_version(3) ? :cancel : Gtk::Dialog::RESPONSE_CANCEL],
              [button, Gtk::Dialog::RESPONSE_ACCEPT]
            ])
      else
        dialog = Gtk::FileChooserDialog.new(
          title,
          self,
          action,
          nil,
          [Gtk::Stock::CANCEL, Ruiby.gtk_version(3) ? :cancel : Gtk::Dialog::RESPONSE_CANCEL],
          [button, Gtk::Dialog::RESPONSE_ACCEPT]
        )
    end
    dialog.set_window_position(:center)
    yield(dialog) if block_given?
      ret = ( dialog.run == Gtk::Dialog::RESPONSE_ACCEPT ? dialog.filename : nil )rescue false
      dialog.destroy
      ret ? ret.gsub('\\','/') : ""
  end
end

#  common dialog to be use for direct  call in none Ruiby context classe :
#  Message.alert("ddde",'eee')
class Message
  class Embbeded  < ::Gtk::Window
    include ::Ruiby_default_dialog
  end
  def self.alert(*txt) Embbeded.new.alert(*txt) end
  def self.error(*txt) Embbeded.new.error(*txt) end
  def self.ask(*txt)   Embbeded.new.ask(*txt)   end
  def self.prompt(txt,value="")  Embbeded.new.promptSync(txt,value) end
end
