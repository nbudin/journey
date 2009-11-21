Journey::UserOptions.add_logged_out_option("Log in", {:controller => "auth", :action => "login" })

Journey::UserOptions.add_logged_in_option("Profile", {:controller => "account", :action => "edit_profile" })
Journey::UserOptions.add_logged_in_option("Log out", {:controller => "auth", :action => "logout" })