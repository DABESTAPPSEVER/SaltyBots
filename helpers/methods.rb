def errorLogging(e)
	p "ERROR: #{e}"
	puts e.backtrace

	errorLog = 'ERRORS.txt'

	if(File.exist?(errorLog)===false)
		File.open(errorLog,'w')
	end

	File.open(errorLog,'a'){|f|
		[
			'====================',
			Time.now,
			e,
			e.backtrace
		].each{|err| 
			f.puts(err)
		}
	}
end


def signin(main_url, mech_agent, email, pass)
	signin = '/authenticate?signin=1'
	form_url = main_url+signin

	begin
		signin_form = mech_agent.get(form_url).forms[0]
	rescue Exception => e
		errorLogging(e)
		return false
	end

	signin_form['authenticate'] = 'signin'
	signin_form['email'] = email
	signin_form['pword'] = pass
	return signin_form
end

def winrate_getter(winrate_str)
	if(winrate_str.include?('/'))
		winrate_arr = winrate_str.split('/')
		w1 = winrate_arr[0].to_f
		w2 = winrate_arr[1].to_f
		return (w1+w2)/2
	else
		return winrate_str.to_f
	end			
end