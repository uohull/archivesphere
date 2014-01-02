SufiaHelper.class_eval do
  def link_to_profile(login)
    User.find_by_user_key(login).name rescue login
  end
end
