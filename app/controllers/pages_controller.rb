class PagesController < ApplicationController
  def index
  end

  def string_test
  	@text = "Mwai Kibaki, in full Emilio Mwai Kibaki, (born November 15, 1931, Gatuyaini, Kenya), Kenyan politician who served as president of Kenya (2002–13).

Kibaki, a member of the Kikuyu people, attended Makerere University (B.A., 1955) in Uganda and the London School of Economics (B.Sc., 1959). He then worked as a teacher before becoming active in the Kenyan struggle for independence from Great Britain. After Kenya became independent in 1963, he won a seat in the National Assembly as a member of the Kenya African National Union (KANU) party. He later served as minister of finance (1969–82) and vice president (1978–88) but increasingly found himself at odds with President Daniel arap Moi, who headed KANU. In 1991 Kibaki resigned his membership in KANU to form the Democratic Party.

Kibaki unsuccessfully challenged Moi in the presidential elections of 1992 and 1997, though in 1998 he became the official head of the opposition. With Moi constitutionally barred from seeking another presidential term, Kibaki sought the presidency for a third time. In September 2002 he helped create the National Rainbow Coalition (NARC), a multiparty alliance that nominated Kibaki as its presidential candidate. A few weeks before the election, Kibaki was involved in a car accident and suffered serious injuries. Although he was confined to a wheelchair, he continued his campaign and easily defeated Moi’s chosen successor, Uhuru Kenyatta (a son of Jomo Kenyatta, Kenya’s first president). In parliamentary elections NARC routed the ruling KANU, which had dominated Kenya since the country’s independence.

As president, Kibaki pledged to eliminate the government corruption that had ruined the country’s economy and had resulted in the withdrawal of foreign aid. Although he established anticorruption courts, his attempts to pass anticorruption bills were largely unsuccessful. In 2003 legislators voted themselves large raises, which they said would discourage bribe taking. The move, however, was met with public criticism. Kibaki’s government also suffered from power struggles among the ruling coalition’s various constituent parties. This tension increased as lawmakers struggled to draft a new constitution, which Kibaki had promised during his campaign. Disagreements concerning reforms, especially the creation of a prime ministership, further divided NARC and delayed enactment of a new constitution, leading to public unrest. Members of his administration were mired in corruption in 2005, which further fueled public discontent. A new constitution, backed by Kibaki, was finally put to referendum in November 2005, but it was rejected by voters; the rejection was viewed by many as a public indictment of Kibaki’s administration.

In preparation for the December 2007 elections, Kibaki formed a new coalition, the Party of National Unity (PNU), which, surprisingly, included KANU. Several candidates stood in the presidential election, which was one of the closest in Kenya’s history and boasted a record-high voter turnout. After a delay in the release of the final election results, Kibaki was declared the winner, narrowly defeating Raila Odinga of the Orange Democratic Movement (ODM). Odinga immediately disputed the outcome, and international observers questioned the validity of the final results. Widespread protests ensued throughout the country and degenerated into horrific acts of violence involving some of Kenya’s many ethnic groups, most notable of which were the Kikuyu (Kibaki’s group) and the Luo (Odinga’s group); both groups were victims as well as perpetrators. More than 1,000 people were killed and more than 600,000 were displaced in the election’s violent aftermath as efforts to resolve the political impasse between Kibaki and Odinga were not immediately successful.

On February 28, 2008, Kibaki and Odinga signed a power-sharing plan brokered by former UN secretary-general Kofi Annan and Jakaya Kikwete, president of Tanzania and chairman of the African Union. The plan called for the formation of a coalition government between PNU and ODM and the creation of several new positions, with Kibaki to remain president and Odinga to hold the newly created post of prime minister. Despite the agreement, however, conflict persisted over the distribution of posts. After several weeks of talks, the allocation of cabinet positions between PNU and ODM members was settled, and on April 13, 2008, Kibaki named a coalition government in which he retained the presidency. The coalition, however, was often fraught with tension.

A new constitution finally materialized during Kibaki’s second term. Designed to address the sources of ethnic and political tensions that had fueled the violence that followed the December 2007 election, the new constitution featured a decentralization of power and was supported by both Kibaki and Odinga. It was approved by voters in a referendum, and Kibaki signed it into law on August 27, 2010.

Barred from holding a third term as president, Kibaki stepped down at the end of his term in April 2013. He was succeeded by Kenyatta, who had defeated Odinga in an election held the previous month."
  end

  def break_text
  	case params[:solution]
  	when '1'
  		chunks = params[:text].gsub(/\s+/, ' ').scan(/.{1,2000}(?: |$)/).map(&:strip)
  	when '2'
  		text = params[:text].gsub("\n", "(br)")
  		chunks = text.gsub(/s+/, ' ').scan(/.{1,2000}(?: |$)/).map(&:strip)
  		chunks.each{|chunk| chunk.gsub!('(br)', "\n")}
  	when '3'
  		chunks = params[:text].scan(/(?:((?>.{1,32}(?:(?<=[^\S\r\n])[^\S\r\n]?|(?=\r?\n)|$|[^\S\r\n]))|.{1,32})(?:\r?\n)?|(?:\r?\n|$))/).flatten.compact.map(&:strip)
  	when '4'
  		chunks = max_groups(params[:text], 2000)
  	end
  	render json: { strings: chunks, counts: chunks.count }
  end

  def privacy
  	
  end

  private
  	def max_groups(str, n)
  	  arr = []
  	  pos = 0     
  	  loop do
  	    break (arr << str[pos..-1]) if str.size - pos <= n
  	    m = str.match(/.{#{n}}(?=[ ])|.{,#{n-1}}[ ]/, pos)
  	    return nil if m.nil?
  	    arr << m[0]
  	    pos += m[0].size
  	  end
  	end


end
