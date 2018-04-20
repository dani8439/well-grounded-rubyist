class Cake
  def initialize(batter)
    @batter = batter
    @baked = true
  end
end
class Egg
end
class Flour
end
class Baker
  def bake_cake
    @batter = []   #<---- Implements @batter as array of objects (ingredients)
    pour_flour
    add_egg
    stir_batter
    return Cake.new(@batter)      #<---- Returns new Cake object
  end
  def pour_flour
    @batter.push(Flour.new)       #<---- Adds element (ingredient) to @batter
  end
  def add_egg
    @batter.push(Egg.new)
  end
  def stir_batter
  end
  private :pour_flour, :add_egg, :stir_batter           #1.
end

b = Baker.new
b.add_egg

# baker.rb:31:in `<main>': private method `add_egg' called for #<Baker:0x00000000867360> (NoMethodError)
