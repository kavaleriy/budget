class GmailApi
  # This class downloads an email from gmail and extracts a file out of a .zip attachment

  require 'google/apis/gmail_v1'
  require 'googleauth'
  require 'zip'
  # require 'signet/oauth_2/client'

  # These credentials come from creating an OAuth Web Application client ID
  # in the Google developer console
  #
  # refer: https://www.youtube.com/watch?v=hfWe1gPCnzc
  #
  # ie.
  # > activate Gmail API - https://console.developers.google.com/apis/library/gmail.googleapis.com/
  # > visit http://console.developers.google.com
  # > API Manager
  # > Credentials
  # > Create Credentials (OAuth client ID)
  # > Application type: Web Application
  # > Authorised redirect URIs: https://developers.google.com/oauthplayground
  # * the resultant client ID / client secret goes in the following GMAIL_CLIENT_KEY / GMAIL_CLIENT_SECRET variables
  # > visit: https://developers.google.com/oauthplayground/
  # > Click the settings icon to show the OAuth 2.0 configuration
  # > Tick 'Use your own OAuth credentials'
  # > Enter the OAuth Client ID and OAuth Client secret that you have just created
  # > Check the entry for 'Google Play Developer API v2' in the scopes field and click 'Authorize APIs'
  # > Click 'Allow'
  # > Click 'Exchange authorization code for tokens'
  # * the resultant Refresh token and Access token go in the following GMAIL_REFRESH_TOKEN / GMAIL_ACCESS_TOKEN variables

  GMAIL_CLIENT_KEY = ENV['GMAIL_CLIENT_KEY']
  GMAIL_CLIENT_SECRET = ENV['GMAIL_CLIENT_SECRET']

  GMAIL_ACCESS_TOKEN  = ENV['GMAIL_ACCESS_TOKEN']
  GMAIL_REFRESH_TOKEN = ENV['GMAIL_REFRESH_TOKEN']

  TMP_DIR = "#{Rails.root.to_s}/db/list" ###
  APPLICATION_NAME = 'openbudget-in-ua'
  EMAIL_ADDRESS = "openbudget.in.ua@gmail.com"
  # GMAIL_QUERY = "from:openbudget.in.ua@gmail.com has:attachment subject:Email+Subject"
  GMAIL_QUERY = "to:openbudget.in.ua+2@gmail.com" # test with appeal id 7
  Gmail = Google::Apis::GmailV1

  attr_reader :text

  def initialize
    # FileUtils.rm_r(TMP_DIR) if File.directory?(TMP_DIR)
    # FileUtils.mkdir_p(TMP_DIR)
    @email = email
    @text = @email.snippet
    @attachment_data = attachment_data
  end

  def email
    gmail.get_user_message(EMAIL_ADDRESS, message_id)
  end

  def fetch
    File.read(pdf_file_path)
  end

  def new_file
    # used for save file in db with carrierwave
    name_file = file_name
    # File.open(name_file, 'wb') { |f| f.puts attachment.data }
    file = StringIO.new(attachment.data)
    file.define_singleton_method(:original_filename) do
      name_file
    end
    file
  end

  def mail
    @email
  end

  def attachment
    gmail.get_user_message_attachment(EMAIL_ADDRESS, message_id, attachment_id)
  end

  def attachment_data
    @email.payload.parts.last
  end

  private

  # def file_path
  #   "#{TMP_DIR}/file.txt".tap do |path|
  #     Zip::File.open(zip_file_path) do |zip_file|
  #       # Match the required file
  #       entry = zip_file.glob('full_list/_reliable_list.txt').first
  #       entry.extract(path)
  #     end
  #   end
  # end

  # def zip_file_path
  #   "#{TMP_DIR}/archive.zip".tap do |path|
  #     File.open(path, "wb"){|f| f.puts attachment.data }
  #   end
  # end

  def file_name
    @attachment_data.filename
  end

  def pdf_file_path
    "#{TMP_DIR}/archive.pdf".tap do |path|
      File.open(path, "wb"){|f| f.puts attachment.data }
    end
  end

  # def attachments
  #   gmail.get_user_message_attachment(EMAIL_ADDRESS, message_id)
  # end

  def attachment_id
    # email.payload.parts.find{ |p| p.mime_type == 'text/plain' }.body.attachment_id
    # @email.payload.parts.find{ |p| p.mime_type == 'application/pdf' }.body.attachment_id

    @attachment_data.body.attachment_id
  end

  # def email
  #   gmail.get_user_message(EMAIL_ADDRESS, message_id)
  # end

  def message_id
    # Get the latest email that matches the query
    @message_id ||= gmail.list_user_messages(EMAIL_ADDRESS, q: GMAIL_QUERY).messages.last.id
  end

  def gmail
    @gmail ||= Gmail::GmailService.new.tap do |publisher|
      publisher.authorization = client
      publisher.client_options.application_name = APPLICATION_NAME
    end
  end

  def client
    Signet::OAuth2::Client.new(
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      client_id: GMAIL_CLIENT_KEY,
      client_secret: GMAIL_CLIENT_SECRET,
      access_token: GMAIL_ACCESS_TOKEN,
      refresh_token: GMAIL_REFRESH_TOKEN,
      scope: Google::Apis::GmailV1::AUTH_GMAIL_READONLY,
    )
  end
end
