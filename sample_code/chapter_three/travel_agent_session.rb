class TravelAgentSession
  def year=(y)
    @year = year.to_i
    if @year < 100  #<-- Handle one or two-digit number by adding century to it.
      @year = @year + 2000
    end
  end
end

# month, day, year = date.split('/')
# self.year
