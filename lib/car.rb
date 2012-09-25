require "openssl"

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

  # The numeric identifier J-Spec seems to allocate.
  def identifier
    link.match(/-(\d+).html/)[1].to_i
  end

  # A string hash digest of the attribute values.
  def digest
    OpenSSL::Digest::SHA1.hexdigest(attributes.values.join(":"))
  end

end
