# Gem dependencies.
require "bundler"
Bundler.require

# Internal dependencies.
require "car"
require "car_text_renderer"

# stdlib dependencies.
require "net/http"

class Fetcher

  BASE_URL = URI("http://www.j-spec.com.au/auction/MAZDA/RX-7")

  def fetch
    cars = []
    next_path = BASE_URL.request_uri

    while next_path
      puts "Fetching #{next_path}"
      body = Net::HTTP.get(BASE_URL.host, next_path.to_s)
      doc = Nokogiri::HTML(body)
      doc.css(".kbox").each { |box| cars << parse_box(box, BASE_URL) }
      next_path = doc.xpath("//div[@class='pagination']//a[text()='>>']/@href").first
    end

    cars.each do |car|
      puts "_" * 80
      puts CarTextRenderer.new(car)
    end

    puts "_" * 80
    puts "Cars listed: #{cars.length}"
  end

  private

  # Create a Car instance based on the box HTML node.
  def parse_box(box, uri)
    text = box.text.gsub(/^\s+/, "").gsub(/\s+$/, "")
    year, model = box.css("span").text.match(/^\s*(\d{4})\s+(.*?)\s*$/)[1..2]

    Car.new(
      year: year,
      model: model,
      km: text.match(/(\d+,\d+) kms/)[1],
      auction_grade: text.match(/Condition\/Grade:\s+(.+)/i)[1],
      transmission: text.match(/5 speed/i) ? "Manual" : text.match(/automatic/i) ? "Automatic" : "Unknown",
      image: box.css("img").first.attr(:src).gsub(/^\s+|\s+$/, ""),
      link: uri.dup.tap{ |uri| uri.path = box.css("a[href]").first.attr(:href)}.to_s,
    )
  end

end
