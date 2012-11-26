# Gem dependencies.
require "bundler"
Bundler.require

# Internal dependencies.
require "alert_list"
require "car"

# stdlib dependencies.
require "net/http"

class Fetcher

  BASE_URL = URI("http://www.j-spec.com.au/auction/MAZDA/RX-7")
  MAX_PAGES = 10

  def fetch
    alert_list = AlertList.new(year_minimum: ENV["YEAR_MINIMUM"])

    next_path = BASE_URL.request_uri
    pages_fetched = 0

    while next_path && pages_fetched < MAX_PAGES
      puts "Fetching #{next_path}"
      body = Net::HTTP.get(BASE_URL.host, next_path.to_s)
      next_path = process_page(body, alert_list)
      pages_fetched += 1
    end

    alert_list.execute
  end

  private

  # Process the current page body.
  # Return the URL path of the next page, or null.
  def process_page(body, alert_list)
    doc = Nokogiri::HTML(body)
    doc.css(".kbox").each do |box|
      car = parse_box(box, BASE_URL)
      process_car(car, alert_list)
    end
    doc.xpath("//div[@class='pagination']//a[text()='>>']/@href").first
  end

  # Process an individual car listing.
  def process_car(car, alert_list)
    if Car.identifier_exists?(car.identifier)
      unless Car.digest_exists?(car.digest)
        car.insert
        alert_list.updated_cars << car
      end
    else
      car.insert
      alert_list.new_cars << car
    end
  end

  # Create a Car instance based on the box HTML node.
  def parse_box(box, uri)
    text = box.text.gsub(/^\s+/, "").gsub(/\s+$/, "")
    year, model = box.css("span").text.match(/^\s*(\d{4})\s+(.*?)\s*$/)[1..2]

    Car.new(
      year: year,
      model: model,
      km: text.match(/(\d+(?:,\d{3})*) kms?/)[1].gsub(",", "").to_i,
      auction_grade: text.match(/Condition\/Grade:\s+(.+)/i)[1],
      transmission: text.match(/5 speed/i) ? "Manual" : text.match(/automatic/i) ? "Automatic" : "Unknown",
      image: box.css("img").first.attr(:src).gsub(/^\s+|\s+$/, ""),
      link: uri.dup.tap{ |uri| uri.path = box.css("a[href]").first.attr(:href)}.to_s,
    )
  end

end
