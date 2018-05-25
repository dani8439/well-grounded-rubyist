
h1 = {"Smith" => "John",
      "Jones" => "Jane" }
h2 = {"Smith" => "Jim"}
h3 = h1.update(h2)
puts h1["Smith"]

# Jim


h1 = {"Smith" => "John",
      "Jones" => "Jane" }
h2 = {"Smith" => "Jim"}
h3 = h1.merge(h2)
p h1["Smith"]

# "John"
