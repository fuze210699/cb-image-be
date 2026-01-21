# Session configuration
Rails.application.config.session_store :cookie_store, 
  key: '_cb_image_be_session',
  expire_after: 24.hours,
  same_site: :lax,
  secure: Rails.env.production?
