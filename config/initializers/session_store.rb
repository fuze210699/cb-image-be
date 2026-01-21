# Session configuration for cross-origin requests
# SameSite=None is REQUIRED for cookies to work across different domains
Rails.application.config.session_store :cookie_store, 
  key: '_cb_image_be_session',
  expire_after: 24.hours,
  same_site: :none,  # CRITICAL: Must be :none for cross-origin
  secure: true,      # REQUIRED when same_site is :none
  httponly: true     # Security: prevent JavaScript access
