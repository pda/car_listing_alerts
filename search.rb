#!/usr/bin/env ruby

# Gem dependencies (see Gemfile)
require "bundler"
Bundler.require

# Standard Library dependencies.
require "net/http"
require "openssl"
require "ostruct"

uri = URI("http://www.j-spec.com.au/auction/MAZDA/RX-7")

##
# Representation of a Car listed for auction.
class Car
  include Virtus

  attribute :year, Integer
  attribute :model, String
  attribute :km, Integer
  attribute :auction_grade, String
  attribute :transmission, String
  attribute :image, String
  attribute :link, String

  DIGEST = OpenSSL::Digest::SHA1

  # The numeric identifier J-Spec seems to allocate.
  def identifier
    link.match(/-(\d+).html/)[1].to_i
  end

  # A string hash digest of the attribute values.
  def digest
    DIGEST.hexdigest(attributes.values.join(":"))
  end

end

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

cars = []
next_path = uri.request_uri

while next_path
  body = Net::HTTP.get(uri.host, next_path.to_s)
  doc = Nokogiri::HTML(body)
  doc.css(".kbox").each { |box| cars << parse_box(box, uri) }
  next_path = doc.xpath("//div[@class='pagination']//a[text()='>>']/@href").first
end

cars.each do |car|
  puts "_" * 80
  puts CarTextRenderer.new(car)
end

puts "_" * 80
puts "Cars listed: #{cars.length}"
