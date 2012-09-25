##
# Render a Car as text.
class CarTextRenderer

  def initialize(car)
    @car = car
  end

  def to_s
    [
      "#{car.year} #{car.model}",
      "#{format_integer(car.km)} km",
      "#{car.transmission} transmission",
      "Auction grade: #{car.auction_grade}",
      "Link: #{car.link}",
    ].join("\n")
  end

  private

  attr_reader :car

  # Based on Rails number_with_delimiter
  def format_integer(integer)
    integer.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
  end

end
