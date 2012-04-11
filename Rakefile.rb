NAME="Ruiby"
Rake.application.options.trace = false

def push_changelog(line)
  b=File.read('CHANGELOG.txt').split(/\r?\n/) 
  b.unshift(line)
  File.open('CHANGELOG.txt','w') {|f| f.write(b.join("\n")) }
end
def change_version()
  a=File.read('VERSION').strip.split('.')[0..2]
  yield(a)
  version=a.join('.') 
  File.open('VERSION','w') {|f| f.write(version) }
  version
end


######################## Comment each file modified ######################
SRC = FileList['**/*.rb']

rule '._' => '.rb' do |src|
  puts "\n\ncomment for #{src.source} : "
  comment=$stdin.gets.chomp
  if comment && comment.size>0
	  puts "Abort!" 	if comment=~/^a(b(o(r(t)?)?)?)?$/
	  exit! 			if comment=~/^a(b(o(r(t)?)?)?)?$/
	  sh "git commit #{src.source} -m \"#{comment.strip}\"" rescue 1
	  push_changelog("    #{src} : #{comment}")
	  $changed=true
  end
  touch src.name
end

COM=SRC.map do |src| 
  base=src.split('.').tap {|o| o.pop}.join('.')
  file "#{base}._" =>  src ; "#{base}._" 
end

desc "general dependency"
file "commit._" =>  COM

desc "job before xommitement"
task :pre_commit do
	puts <<EEND


--------------------------------------------------------------------
                 Commmit & push #{NAME}
--------------------------------------------------------------------
	
	sh "giti"
	$changed=false
EEND
end

desc "job after local commit done: push to git repo"
task :post_commit do
  raise "no changed!" unless $changed
  $version=change_version { |a| a[-1]=(a.last.to_i+1) }  
  sh "git commit VERSION -m update"
  sh "git commit CHANGELOG.txt -m update"
  sh "git push"
end
desc "commit local and then distant repo"
task :commit => [:pre_commit,"commit._",:post_commit]

