module M
  def report
    puts "'report' method in module M"
    # Instance method report is defined in module M
  end
end
class C
  include M
  # Module M is mixed into class C
end
class D < C
  # Class D is a subclass of class C, and obj is an instance of class D
  # through this cascade, the object(obj) gets access to the report method.
end

obj = D.new
obj.report
