require "mail"
require "stringio"

require "car_text_renderer"
require "car_html_renderer"

class AlertList

  def initialize
    @new_cars = []
    @updated_cars = []
  end

  attr_reader :new_cars
  attr_reader :updated_cars

  def any?
    new_cars.any? || updated_cars.any?
  end

  def execute
    puts count_message
    return unless any?

    if (address = ENV["MAIL_RECIPIENT"])
      send_email(address)
    else
      puts "MAIL_RECIPIENT not present in environment."
    end
  end

  private

  def count_message
    "#{new_cars.length} new, #{updated_cars.length} updated."
  end

  def send_email(address)
    puts "Sending AlertList to #{address}"
    Mail.new.tap do |message|
      message.to address
      message.from address
      message.subject "J-Spec: #{count_message}"

      message.text_part = Mail::Part.new.tap do |text|
        text.body text_report
        text.content_type "text/plain; charset=UTF-8"
      end

      message.html_part = Mail::Part.new.tap do |html|
        html.body html_report
        html.content_type "text/html; charset=UTF-8"
      end

      message.delivery_method :sendmail
      message.deliver!
    end
  end

  def html_report
    b = StringIO.new

    b.puts <<-END
    <style type="text/css">
    img { max-width: 800px }
    </style>
    END

    b.puts "<h2>#{new_cars.length} new cars listed.</h2>"
    b.puts "<br>"

    new_cars.each do |car|
      b.puts "<hr>"
      b.puts CarHtmlRenderer.new(car)
    end

    b.puts "<br>" if new_cars.any?

    b.puts "<h2>#{updated_cars.length} car listings updated.</h2>"
    b.puts "<br>"

    updated_cars.each do |car|
      b.puts "<hr>"
      b.puts CarHtmlRenderer.new(car)
    end

    b.tap(&:rewind).read
  end

  def text_report
    b = StringIO.new

    b.puts "#{new_cars.length} new cars listed."
    b.puts

    new_cars.each do |car|
      b.puts "_" * 40
      b.puts CarTextRenderer.new(car)
    end

    b.puts "\n\n" if new_cars.any?

    b.puts "#{updated_cars.length} car listings updated."
    b.puts

    updated_cars.each do |car|
      b.puts "_" * 40
      b.puts CarTextRenderer.new(car)
    end

    b.tap(&:rewind).read
  end

end
