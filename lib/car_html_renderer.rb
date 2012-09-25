##
# Render a Car as HTML.
class CarHtmlRenderer

  def initialize(car)
    @car = car
  end

  def to_s
    [
      "<p>",
        "<strong><a href=\"#{car.link}\">#{car.year} #{car.model}</a></strong><br>",
        "#{format_integer(car.km)} km<br>",
        "#{car.transmission} transmission<br>",
        "Auction grade: #{car.auction_grade}<br>",
        "<a href=\"#{car.link}\"><img src=\"#{car.image}\"></a>",
      "</p>",
    ].join("\n")
  end

  private

  attr_reader :car

  # Based on Rails number_with_delimiter
  def format_integer(integer)
    integer.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
  end

end
