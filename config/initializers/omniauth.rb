OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '1861143660809553', 'b1e945be2faae1c011feca3e295ff3ad', scope: 'user_friends, user_posts'
end