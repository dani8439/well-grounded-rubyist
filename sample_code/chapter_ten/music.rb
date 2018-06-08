module Music
  class Scale
    NOTES = %w{ c c# d d# e e# f f# g a a# b}
    def play
      NOTES.each {|note| yield note }
    end
  end
end

scale = Music::Scale.new
# scale.play {|note| puts "Next note is #{note}" }


# Next note is c
# Next note is c#
# Next note is d
# Next note is d#
# Next note is e
# Next note is e#
# Next note is f
# Next note is f#
# Next note is g
# Next note is a
# Next note is a#
# Next note is b

# scale.map {|note| note.upcase }

# music.rb:27:in `<main>': undefined method `map' for #<Music::Scale:0x0000000169b698> (NoMethodError)
# Did you mean?  tap

enum = scale.enum_for(:play)

p enum.map {|note| note.upcase }
p enum.select {|note| note.include?('f') }

# ["C", "C#", "D", "D#", "E", "E#", "F", "F#", "G", "A", "A#", "B"]
# ["f", "f#"]
