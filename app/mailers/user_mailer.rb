class UserMailer < ApplicationMailer
  default from: 'noreply@cbimage.com'

  def welcome_email(user)
    @user = user
    @url = root_url
    mail(to: @user.email, subject: 'Welcome to CB Image!')
  end

  def subscription_activated(user, subscription)
    @user = user
    @subscription = subscription
    mail(to: @user.email, subject: 'Your subscription is now active!')
  end

  def subscription_expiring_soon(user, subscription)
    @user = user
    @subscription = subscription
    @days_left = (subscription.end_date.to_date - Date.today).to_i
    mail(to: @user.email, subject: 'Your subscription is expiring soon')
  end

  def subscription_expired(user, subscription)
    @user = user
    @subscription = subscription
    mail(to: @user.email, subject: 'Your subscription has expired')
  end

  def purchase_confirmation(user, purchase)
    @user = user
    @purchase = purchase
    mail(to: @user.email, subject: 'Purchase Confirmation')
  end
end
