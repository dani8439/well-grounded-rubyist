module M
  def report
    # 4. The next match for report, in this case, is the report method defined in module M
    puts "'report' method in module M"
  end
end
class C
  include M


  def report
    # 2. The method-lookup process starts with c's class (C) and sure enough, there's a report method.
    # That method is then executed on c
    puts "'report' method in class C"
    puts "About to trigger the next higher-up report method..."
    super
    # 3. inside of this method is a call to super. That means even though the object found a method corresponding
    # to the message ('report'), it must keep looking and find the next match.
    puts "Back from the 'super' call."
  end
end

c = C.new
c.report
# 1. An instance of C (namely c) receives the 'report' message.

# go back to notes in prepend to see analysis...  
