$(function() {
	$('#breakString').click(function(e) {
		e.preventDefault()
		$.ajax({
		  type: "POST",
		  url: '/break_strings',
		  dataType: 'json',
		  data: {solution: $('#solutions').val(), text: $('#stringToBreak').val()},
		  success: function(data, textStatus, jqXhr) {
		  	var h = ''
		  	for (var i = 0; i < data.strings.length; i++) {
		  		h += data.strings[i] + '<hr>'
		  	}
		  	$("#results").html(h)
		  	$("#counts").html(data.counts)
		  }
		});
	})

	$('#solutions').change(function() {
		var solution = $(this).val()
		var code = ""
		if (solution === '1') {
			code = "<code>text.gsub(/\s+/, ' ').scan(/.{1,2000}(?: |$)/).map(&:strip)</code>"
		}
		else if (solution === '2') {
			code = "<code>text.gsub('\\n', \"(br)\")<br>chunks = text.gsub(/\s+/, ' ').scan(/.{1,2000}(?: |$)/).map(&:strip)<br>chunks.each{|chunk| chunk.gsub!('(br)', \"\\n\")}</code>"
		}
		else if (solution === '3') {
			code = "<code>(?:((?>.{1,32}(?:(?<=[^\S\r\n])[^\S\r\n]?|(?=\r?\n)|$|[^\S\r\n]))|.{1,32})(?:\r?\n)?|(?:\r?\n|$))</code>"
		}
		else if (solution === '4') {
			code = "<pre><code>"
			code += "def max_groups(str, n)<br>"
			code += "	arr = []<br>"
			code += "	pos = 0  <br>"
			code += "	loop do<br>"
			code += "		break (arr << str[pos..-1]) if str.size - pos <= n<br>"
			code += "		m = str.match(/.{#{n}}(?=[ ])|.{,#{n-1}}[ ]/, pos)<br>"
			code += "		return nil if m.nil?<br>"
			code += "		arr << m[0]<br>"
			code += "		pos += m[0].size<br>"
			code += "	end<br>"
			code += "end<br>"
			code += "<br>max_groups(text, 2000)<br>"
			code += "</code></pre>"
		}
		$('#solution').html(code)
	})
})