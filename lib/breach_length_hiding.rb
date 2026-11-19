require 'securerandom'

# Pads HTML responses sent over SSL with a random-length comment, which makes BREACH attacks take longer
# (see section 3.1 of "BREACH: Reviving the CRIME attack").  It does not fully protect against them.
#
# Adapted from the breach-mitigation-rails gem's BreachMitigation::LengthHiding middleware, which is
# unmaintained and no longer works with Rails 5.1 (it inserts its middleware by string name).
# Original code (https://github.com/meldium/breach-mitigation-rails): Copyright (c) 2013 BBA, Inc., MIT License.
#
# The gem also replaced Rails' CSRF token masking with its own implementation of the same scheme.  Rails has
# masked CSRF tokens itself since 4.2, using the same session key and token format, so that part is dropped.
class BreachLengthHiding
  # The longer this is, the more effective the mitigation, but the more data goes over the wire
  MAX_LENGTH = 2048
  ALPHABET = ('a'..'z').to_a

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    # Only pad HTML/XHTML documents
    if headers['Content-Type'] =~ /text\/x?html/ && Rack::Request.new(env).ssl?
      # Copy the existing response to a new object
      response = Rack::Response.new(body, status, headers)

      # Append to that response
      response.write random_html_comment

      body.close if body.respond_to? :close
      response.finish
    else
      [status, headers, body]
    end
  end

  private

  def random_html_comment
    # The length of the padding should be strongly random, but the data itself doesn't need to be strongly
    # random; it just needs to be resistant to compression
    length = SecureRandom.random_number(MAX_LENGTH)
    junk = (0...length).inject("") { |text| text << ALPHABET[rand(ALPHABET.size)] }

    "\n<!-- This is a random-length HTML comment: #{junk} -->"
  end
end
