puts "This is the first (master) program file."
require "./loadee.rb"
# changed from load "loadee.rb" -- require if called more than once with the same arguments
# doesn't reload files it's already loaded.
# can also do require_relative "loadee" -- require_relative is convenient when you want to navigate
# a local directory hierarchy. 
puts "And back again to the first file."
