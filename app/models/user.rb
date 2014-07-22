class User < ActiveRecord::Base
	searchkick autocomplete: ["patreon"], operator: "or"
	has_many :projects

	before_save { self.twitter  = twitter.downcase unless twitter.nil?
				  self.facebook = facebook.downcase unless facebook.nil?
				  self.youtube  = youtube.downcase unless youtube.nil?
				  self.patreon  = patreon.downcase unless patreon.nil? }

end
