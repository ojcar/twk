class UserNotifier < ActionMailer::Base
  def reset_notification(user)
    setup_email(user)
    @subject += 'Link to reset your password'
    @body[:url] = "http://www.thisweknow.net/reset/#{user.reset_code}"
  end
  
  protected
    def setup_email(user)
      @recipients = "#{user.email}"
      @from = "twk@thisweknow.net"
      @subject = "[thisweknow.net]"
      @sent_on = Time.now
      @body[:user] = user
    end
  
end
