##
# Render a Car as text.
class CarTextRenderer

  def initialize(car)
    @car = car
  end

  def to_s
    [
      "#{car.year} #{car.model}",
      "#{car.km} km",
      "#{car.transmission} transmission",
      "Auction grade: #{car.auction_grade}",
      "Image: #{car.image}",
      "Link: #{car.link}",
      "Identifier: #{car.identifier}",
      "Digest: #{car.digest}",
    ].join("\n")
  end

  private

  attr_reader :car

end
