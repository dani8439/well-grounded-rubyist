record = File.open("/tmp/record", "w")
old_stdout = $stdout
$stdout = record
$stderr = $stdout
puts "This is a record"
z = 10/0


# This is a record
# outputs.rb:6:in `/': divided by 0 (ZeroDivisionError)
#  from outputs.rb:6:in `<main>'
