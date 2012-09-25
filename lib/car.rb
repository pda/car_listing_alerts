require "openssl"
require "rdo-postgres"
require "virtus"

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
    link && link.match(/-(\d+).html/)[1].to_i
  end

  # A string hash digest of the attribute values.
  def digest
    OpenSSL::Digest::SHA1.hexdigest(attributes.values.join(":"))
  end

  def self.identifier_exists?(identifier)
    db.execute("SELECT id FROM cars WHERE identifier = ?", identifier).any?
  end

  def self.digest_exists?(digest)
    db.execute("SELECT id FROM cars WHERE digest = ?", digest).any?
  end

  def insert
    columns = [:identifier, :digest] + attributes.keys
    values = columns.map { |column| send(column) }
    placeholders = (["?"] * values.length)
    db.execute(<<-END, *values)
      INSERT INTO cars (#{columns.join(", ")})
      VALUES (#{placeholders.join(", ")})
    END
  end

  def self.db; @_db ||= RDO.connect(ENV["DATABASE_URL"]) end
  def db; self.class.db end

end
