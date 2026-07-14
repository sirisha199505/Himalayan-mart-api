class App::Models::User < Sequel::Model
  include BCrypt

  # Role constants
  ROLES = {
    super_admin: 1,
    admin: 2
  }.freeze

  def super_admin?
    role == ROLES[:super_admin]
  end

  def admin?
    role == ROLES[:admin]
  end

  # Anyone allowed into the admin console.
  def staff?
    super_admin? || admin?
  end

  def validate
    super
    validates_presence [:full_name, :email]
    validates_unique(:email) { |ds| ds.where(active: true) }
  end

  def password
    @password ||= Password.new(encoded_password)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.encoded_password = @password
  end

  def name
    full_name
  end

  def role_name
    case role
    when ROLES[:super_admin] then "Super Admin"
    when ROLES[:admin]       then "Admin"
    else "Unknown"
    end
  end

  def generate_reset_token!
    self.reset_token = SecureRandom.urlsafe_base64
    self.reset_sent_at = Time.now
    save
  end

  def send_password_reset_email(base_url)
    generate_reset_token!

    user_email = self.email
    user_name = self.full_name
    reset_url = "#{base_url}/reset_password?token=#{CGI.escape(reset_token)}"

    mail = Mail.new do
      from    ENV.fetch('EMAIL_FROM', 'noreply@example.com')
      to      user_email
      subject 'Reset your password'
      html_part do
        content_type 'text/html; charset=UTF-8'
        body <<-HTML
          <html>
          <body>
            <h1>Reset your password</h1>
            <p>Hello #{user_name},</p>
            <p>We received a request to reset your password. Click the link below to reset your password:</p>
            <p><a href="#{reset_url}">Reset your password</a></p>
            <p>If you did not request a password reset, please ignore this email.</p>
            <p>Thank you,<br/>Support Team</p>
          </body>
          </html>
        HTML
      end
    end

    mail.deliver!
  end

  def as_pos
    as_json(only:
      [:email, :full_name, :phone_number, :role, :id, :active, :created_at, :updated_at, :last_logged_in_at]
    ).merge!(role_name: role_name)
  end
end
