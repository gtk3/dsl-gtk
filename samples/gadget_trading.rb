#!/usr/bin/ruby
# encoding: utf-8
# Creative Commons BY-SA :  Regis d'Aubarede <regis.aubarede@gmail.com>
# LGPL
###############################################################
#   BitCoin currency ; demo of gadget...
###############################################################

require 'open-uri'
require 'thread'
require 'json'
require 'Ruiby'
require 'pp'
#require_relative 'Ruiby/lib/Ruiby'

$per=(ARGV[0] && ARGV[0].to_i) || 20_000
$BG="#383848"
$tcol="#FFA"
$tcol_new="#FF3"
$max_prog=7

$url="https://www.lakebtc.com/api_v1/ticker"

$last={}
def get_data()
 start=Time.now
 data={}
 open($url) {|f| data=JSON.parse(f.read) }
 #p data
 lprog=[
   ["USD last",data['USD']['last']],
   ["CNY last",data['CNY']['last']]
 ]
 duration=(Time.now.to_f-start.to_f)*1000.0
 {duration: duration, data: lprog}
end


Ruiby.app width: 140,height: 10, title: "IpExtAccess" do
  chrome(false)
  @chrome=false
  set_resizable(true)
  move(1,100)
  @lv=[]
  @lv_last=[]
  stack do 
    @cv=canvas(140,300) do
      on_canvas_draw { |w,ctx| expose(w,ctx) } 
      on_canvas_button_press { |w,e| 
        @chrome=!@chrome
        chrome(@chrome)
        get_update
        false # event is not consume; do the popup...
      } 
    end		
  end
  @c=0
  @win=self
  @lcurve=[[0]*100,[0]*100,[0]*100,[0]*100]
  
  def expose(cv,ctx)
    ssize=cv.get_size_request()
    ############## Liste
    @cv.draw_rectangle(0,0,ssize.first,ssize.last,0,nil,"#888",0)
    @cv.draw_rectangle(2,2,ssize.first-4,ssize.last-4,15,"#555",$BG,3)
    y=0
    @lv[:data].each_with_index do |(name,qt),i| 
      x=4
      y=5+(i+1)*14
      moving=((@lv_last[i]||['e',0])[0]==name)
      @cv.draw_text(x,y,name,1.5, moving ? $tcol : $tcol_new) 
      @cv.draw_text_left(ssize.first-4,y,qt.to_s,1,$tcol) 
    end    
    y+=10
    
    ################# Curves
    @lcurve[0] = (@lcurve[0][1..-1]) << @lv[:data][1].last
    @lcurve[1] = (@lcurve[1][1..-1]) << @lv[:data][0].last
    @lcurve[2] = (@lcurve[2][1..-1]) << @lv[:duration]
    
    @cv.draw_rectangle(10,y,120,60,1,"#377","#033",2)
    @lcurve.each_with_index do |curve,i|
       next unless curve && curve.size>2
       min,max=curve.minmax
       next if min==max
       coul="##{%w{FF4 9F9 99F F9F F90 9AF}[i%6]}"
       coul2="#999"
       dx=120.0/curve.size
       lxy=curve.each_with_index.map {|v,i| [10+dx*i,y+2+60.0*(v-min)/(max-min)]}.flatten
       #@cv.draw_line(lxy,coul2,3)
       @cv.draw_line(lxy,coul,1)
       @cv.draw_text(10+2,y+10+i*12,"#{curve.last.to_i}/#{max.to_i}",0.8,coul)
    end
    y+=60
    
    @c=(@c+1) % 5
    @cv.draw_line([10+(@c*ssize.first-20)/5.0,y+4,10+(@c+1)*(ssize.first-20)/5.0,y+4],"#A44",5) 
    y+=10
    
    ################## Vertical resizing
    if y>ssize.last
      @cv.set_size_request(ssize.first,y)
      @win.resize(ssize.first,y)
    elsif y < ssize.last*3/2
      ys=[y,50].max
      @cv.set_size_request(ssize.first,ys)    
      @win.resize(ssize.first,ys)
    end
    y=ssize.last
    @lv_last=@lv[:data].clone
  end
  
  def get_update()
    Thread.new {
      begin
        @lv=get_data
        gui_invoke { @cv.redraw rescue p $!}
      rescue
        log($!) rescue nil
      end  
    }
  end
  @lv=get_data
  anim($per) {get_update }
  after(10) { get_update }
  anim(3000) { set_keep_above(true) } # maintan window visible
end

