# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_wikitracker_session',
  :secret      => 'a48aeaa45054386544d8cfbd571dd4277477cd1421227d6c04c7085780d9d9cc8a41a5da794f5b6b8edd03ab8b06c1963784ef61ec7cbbc020c815fff8f6ef09'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
