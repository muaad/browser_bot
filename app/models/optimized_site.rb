# == Schema Information
#
# Table name: optimized_sites
#
#  id             :integer          not null, primary key
#  name           :string
#  root_url       :string
#  action         :string
#  enabled        :boolean          default(FALSE)
#  implementation :string           default("Internal")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class OptimizedSite < ApplicationRecord
	def self.get_host url
	  uri = URI.parse(url)
	  uri = URI.parse("http://#{url}") if uri.scheme.nil?
	  host = uri.host.downcase
	  host.start_with?('www.') ? host[4..-1] : host
	end

	def self.optimized_site url
		self.where('root_url like ? and enabled = ?', "%#{self.get_host(url)}%", true).first
	end

	def self.optimized? url
		!optimized_site(url).nil?
	end

	def self.optimize url, page
		if optimized_site(url).root_url.include?('stackoverflow')
			stack_overflow(page)
		else
			
		end
	end

	def self.stack_overflow page
		text = ''
		text += page.search('.question-hyperlink').first.try(:text)
		divs = page.search('.post-text')
		q = divs.shift
		text += "*Question:*(br)#{q.try(:text)}(br)*Answers:*(br)"
		divs.collect { |p| text += p.text }.join("(br)")
		text
	end
end
