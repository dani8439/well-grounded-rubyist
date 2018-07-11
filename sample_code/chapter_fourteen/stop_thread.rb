puts "Trying to read in some files..."
t = Thread.new do
  (0..2).each do |n|
    begin
      File.open("part0#{n}") do |f|
        text << f.readlines
      end
    rescue Errno::ENOENT
      puts "Message from thread: Failed on n=#{n}"
      Thread.exit
    end
  end
end
t.join
puts "Finished!"

# Trying to read in some files...
# Message from thread: Failed on n=0
# Finished!


t = Thread.new do
  puts "[Starting thread]"
  Thread.stop
  puts "[Resuming thread]"
end
puts "Status of thread: #{t.status}"
puts "Is thread stopped? #{t.stop?}"
puts "Is thread alive? #{t.alive?}"
puts
puts "Waking up thread and joining it..."
t.wakeup
t.join
puts
puts "Is thread alive? #{t.alive?}"
puts "Inspect string for thread: #{t.inspect}"

# Status of thread: run
# Is thread stopped? true
# Is thread alive? true
# [Starting thread]
# Waking up thread and joining it...
# [Resuming thread]
# Is thread alive? false
# Inspect string for thread: #<Thread:0x00000001ad95e8@thread.rb:22 dead>
