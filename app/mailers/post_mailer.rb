class PostMailer < ActionMailer::Base
  helper :application

  def send_to_all(post, addresses, standup_id)
    @post = post
    @standup_id = standup_id
    from_address = addresses.split(',').shift
    mail  :to => Array(addresses),
          :subject => post.title_for_email,
          :from => "#{post.from} <#{from_address}>"
  end
end
