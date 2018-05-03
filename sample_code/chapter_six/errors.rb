print "Enter a number: "
n = gets.to_i
begin
  result = 100 / n
rescue
  puts "Your number didn't work. Was it zero???"
  exit
end
puts "100/#{n} is #{result}."

# Enter a number: 0
# Your number didn't work. Was it zero???

def open_user_file
  print "File to open: "
  filename = gets.chomp
  begin                               #1
    fh = File.open(filename)
  rescue                              #2
    puts "Couldn't open your file!"
    return                            #3
  end
  yield fh
  fh.close
end
open_user_file
