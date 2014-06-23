require 'csv'
require 'date'

class Report
        def initialize(filepath)
                @filePath = filepath
                @fileContents = CSV.read(filepath)
        end

        def file_path
                @filePath
        end

        def title
                @fileContents[1][1]
        end

        def send_date
                @fileContents[3][1]
        end

        def successful_deliveries
                @fileContents[7][1].gsub(",","")
        end

        def unique_clicks
                cell = @fileContents[14][1]
                field = cell.split(" ")
                field[0].gsub(",","")
        end

        def total_opens
                cell = @fileContents[12][1]
                cell.gsub(",","")
        end

        def unique_opens
                cell = @fileContents[11][1]
                field = cell.split(" ")
                field[0].gsub(",","")
        end

        def total_recipients
                @fileContents[6][1].gsub(",","")
        end


        def click_rate
                recips = total_recipients()
                clicks = unique_clicks()
                uc = clicks.to_f
                tr = recips.to_f
                uc/tr*100
        end

        def links
                #an array of arrays
                @fileContents[23..-1]
        end
end

class Stringdate
        def initialize(string)
                @string = string
                date = string.split("/")
                @month = date[0].to_i
                @day = date[1].to_i
                @year = date[2].to_i
        end

        def month
                @month
        end

        def day 
                @day
        end

        def year
                @year
        end

        def string
                @string
        end

        def is_valid
                # a leap year is divisible by 4, but not one hundred unless it is divisible by 400
                @leapYear = ""
                if @year % 4 == 0 
                        if @year % 100 != 0 || @year %400 == 0
                                @leapYear = true
                        else
                                @leapYear = false
                        end
                else
                        @leapYear = false
                end

                thirty_day_months = [4,6,9,11]
                thirtyone_day_months = [1,3,5,7,8,10,12]

                if @string == ""
                        return "is empty"
                end

                if @month < 1 || @month > 12
                        return "month is not valid"
                end

                if @month == 2 && @leapYear == true 
                        if @day < 1 || @day > 29
                                return "day is not valid"
                        else
                                return true
                        end
                elsif @month == 2 && @leapYear == false
                        if @day < 1 || @day > 28
                                return "day is not valid"
                        else
                                return true
                        end
                elsif thirtyone_day_months.include?(@month)
                        if @day < 1 || @day > 31
                                return "day is not valid"
                        else
                                return true
                        end
                elsif thirty_day_months.include?(@month)
                        if @day < 1 || @day > 30
                                return "day is not valid"
                        else
                                return true
                        end
                end
        end
end

def check_range(date1, date2)
        bMonth = date1.month
        bDay = date1.day
        bYear = date1.year

        eMonth = date2.month
        eDay = date2.day
        eYear = date2.year

        if bYear > eYear
                return "years"
        elsif bYear < eYear
                return "success"
        elsif bYear == eYear
                if bMonth > eMonth
                        return "months"
                elsif bMonth < eMonth
                        return "success"
                elsif bMonth == eMonth 
                        if bDay > eDay
                                return "days"
                        else
                                return "success"
                        end
                end
        end
end

def wave_the_magic_wand(path, date1, date2, path_out)
        major_array = Array.new
        
        #list files in current working directory
        file_list = Dir.glob("#{path}*.csv")

        #puts "File list: #{file_list}"

        start = Date.strptime(date1, '%m/%d/%Y')
        finish = Date.strptime(date2, '%m/%d/%Y')
        
        # for each file in list, make a new instance of the report class and print out its contents
        file_list.each do |f|
                #gather all this info as a hash and write it to a larger array
                report = Report.new(f)
                report_date = Date.parse(report.send_date)

                unless report_date < start || report_date > finish
                        @minor_hash = Hash.new
                        @minor_hash["title"] = report.title
                        @minor_hash["date"] = report.send_date
                        @minor_hash["opens"] = report.total_opens.to_f
                        @minor_hash["sd"] = report.successful_deliveries.to_f
                        @minor_hash["uc"] = report.unique_clicks.to_f
                        @minor_hash["uo"] = report.unique_opens.to_f
                        @minor_hash["cr"] = report.click_rate.to_f
                        @minor_hash["links"] = report.links
                        major_array << @minor_hash
                end
        end
       
        # major array is now built of all reports, time to process ita
        #puts "Major Array has been built."
        #puts major_array
        #puts "Processing output..."

        output = [
                [ "link",
                  " No. of Emails Sent in Date Range",
                  "No. Emails Ad Shown",
                  "No. Subscribers Sent Emails w/ Ad",
                  "Opens",
                  "Open Rate",
                  "Unique Opens",
                  "Unique Open Rate",
                  "Unique Clicks",
                  "Unique Click Rate",
				  "Total Clicks",
				  "Total Click Rate (total clicks/total opens)",
				  "Individual's Interest Rate (total clicks/unique opens)"
                ]
        
        ]

        major_array.each do |f|
                f["links"].each do |link|
                        linkArray = link[0].split("?")
                        value = linkArray[0]
                        exists = false
                        emails_shown = 1

                        output.each do |line|
                                if line.include?(value) == true
                                        exists = true
                                        # link text grabbed on init
                                        # no. emails in date range  only calculated on init                                        
                                        # ad to no. of emails ad shown
                                        line[2] += 1
                                        # add to no. subscribers sent emails w/add 
                                        line[3] += f["sd"]
                                        # add to opens
                                        line[4] += f["opens"]
                                        #open rate calculated after total
                                        #add to unique opens
                                        line[6] += f["uo"]
                                        #unique open rate calculated after total
                                        #add to unique clicks
                                        line[8] += link[2].to_f
                                        #unique click rate calculated after total
										#add to total clicks
										line[10] += link[1].to_f
										#total click rate calculated after total
										#IIR calc. after total
                                        break
                                end
                        end

                        if exists == false
                                output << [ 
                                            #link text
                                            value,
                                            # no. of emails in date range
                                            major_array.count,
                                            # no. of emails ad shown
                                            emails_shown,
                                            # no. of subscribers sent emails w/ add
                                            f["sd"],
                                            # no. of opens
                                            f["opens"],
                                            #open rate calculated after total
                                            "Open Rate",
                                            # unique opens
                                            f["uo"],
                                            #unique open rate calculated after total
                                            "Unique Open Rate",
                                            # Unique Clicks
                                            link[2].to_f,
                                            #unique click rate calculated after total
                                            "Unique Click Rate",
											link[1].to_f,
											#total open rate calculated after total
											"Total Open Rate",
											# IIR calculated after total
											"Individual's Interest Rate"
                                ]
                        end
                end
        end

        # calculate open rate
        output[1..-1].each do |array|
                d = (array[4] / array[3]) * 100

                array[5] = "%5.2f" % d
        end

        # calculate unique open rate
        output[1..-1].each do |array|
                d = (array[6] / array[3]) * 100

                array[7] = "%5.2f" % d
        end

        #calculate unique click rate
        output[1..-1].each do |array|
                d = (array[8] / array[6]) * 100

                array[9] = "%5.2f" % d
        end

		#calculate total click rate
        output[1..-1].each do |array|
                d = (array[10] / array[3]) * 100

                array[11] = "%5.2f" % d
        end
		
		#calculate Idividual's Interest Rate
        output[1..-1].each do |array|
                d = (array[10] / array[6]) * 100

                array[12] = "%5.2f" % d
        end
		
        #puts "Output:"
        #puts output

        CSV.open("#{path_out}","wb")  do |f|
                output.each do |array|
                        f << array
                end
        end
end

def os_type
        if ( RUBY_PLATFORM.downcase =~ /darwin/ ) != nil
                return "macos"
        elsif ( RUBY_PLATFORM.downcase =~ /win/ ) != nil
                return "windows"
        elsif ( RUBY_PLATFORM.downcase =~ /linux/ ) != nil
                return "linux"
        else
                return nil
        end
end

Shoes.app :title => "Report Wizzard", width: 1050, height: 750 do
        background "#08d"
        border("#0a3", strokewidth: 8)

        stack(margin: 20) do
                subtitle "So you want the help of a wizard, do you?"
                para  "(Oh blast it! Where did I put my magic wand?)"
        end

        stack(margin: 20) do
                para strong("First, point me in the right direction:")

                flow do
                        # this will return a path to the files to be examined
                        push = button "Be careful where you point to..."
                        note = para "No path set."
                        push.click do
                                @path = ask_open_folder
                                if @path != nil
										@path = @path + "/"
                                        note.replace "#{@path}"
                                end
                        end
                end

                para "\n"
                para strong "Now let's choose a date range: (MM/DD/YYYY)"

                flow do
                        para "Start date: "
                        @range_begin =  edit_line
                end

                flow do
                        para "End date:  "
                        @range_end =  edit_line
                end

                para "\n"
                para strong "Now let's choose where to save our creation:"
                flow do
                        #acquires path and filename to save our output
                        push = button "I name thee..."
                        note = para "No output path set."
                        push.click do
                                @output_path = ask_save_file
                                if @output_path != nil
										@output_path = "#{@output_path}.csv"
                                        note.replace "#{@output_path}"
                                end
                        end
                end
                
                para "\n"
                para strong "If you're all set, just say the magic words..."
        
                rangeButton = button "Sim sala bim!"
        
                message = para ""
                saved_to = para ""
                rangeButton.click do
                        start = Stringdate.new("#{@range_begin.text}")
                        finish = Stringdate.new("#{@range_end.text}")
        
                        if  start.is_valid == true && finish.is_valid == true
                                range_test = check_range(start, finish)
                                if range_test != "success"
                                        message.replace "Range error: #{range_test}"
                                else
                                        if @path == nil
                                                message.replace "No input path set!"
                                        else
                                                if @output_path == nil
                                                        message.replace "No file path selected for output!"
                                                else
                                                        #magic goes here
                                                        #if os_type == "linux"
                                                        #        @path = @path + "/"
                                                        #elsif os_type == "windows"
                                                        #        @path = @path + "\\"
                                                        #end
                                                        
														fList = Dir.glob("#{@path}*.csv")
                                                        wave_the_magic_wand(@path, start.string, finish.string, @output_path)
                                                        #alert "POOF! \n\n Input path: #{@path}\nFile saved to: \n #{@output_path}"
														alert "POOF! \n\nInput path: #{@path}\nOutput file: #{@output_path}\nFile list:\n#{fList}"
                                                end
                                        end
                                end
                        else
                                message.replace "Start date: #{start.is_valid}  End date: #{finish.is_valid}"
                        end
                end
        end
end
