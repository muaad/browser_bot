class WolframAlpha
	def self.fetch query
		Wolfram.fetch(query)
	end

	def self.answer query
		result = Wolfram::HashPresenter.new(fetch(query)).to_hash
		ans = result[:pods]["Real solution"] || result[:pods]["Solution"] || result[:pods]["Result"] || result[:pods]["Definitions"] || result[:pods]["Date range"] || result[:pods]["Measurement devices"] || result[:pods]["Unit conversions"]
		# Rollbar.warning(result.to_s) if ans.blank?
		begin
			msg = ans[0]
		rescue Exception => e
			logger.info "Short answer >>>> #{e}"
			msg = long_answer(result)
		end
		msg.blank? ? "Sorry. I didn't understand that question. :( May be you misspelt something. Come again please." : msg
	end

	def self.long_answer result
		begin
			msg = result[:pods].values[1][0]
		rescue Exception => e
			logger.info "Long answer >>>> #{e}"
			msg = result[:pods].values.join('\n\n')
		end
		msg
	end

	def self.ans_hash query
		Wolfram::HashPresenter.new(fetch(query)).to_hash
	end
end
