require "nokogiri"
require "open-uri"
require "xpath"

$base_url = "https://www.ruby-lang.org/"
$filecount = 0
def visiting_management(url,visitedarray)
	f = File
		if f.zero?("C:/Users/mbala/Desktop/visitedurl.txt")
				f.open("C:/Users/mbala/Desktop/visitedurl.txt","a+") do |i|
					i.write(url)
					i.write("\n")
				end	
				visitedarray.push(url)
		else
					f.open("C:/Users/mbala/Desktop/visitedurl.txt","r+") do |i|
						visitedarray.push( i.read())
					end		
					visitedarray = visitedarray[0].split("\n",1000)
				if visitedarray.include?(url)
					visitedarray.delete(url)
					puts "the visitedarray......................."
					visitedarray = visitedarray.uniq
					puts "the visitedarray.......................",visitedarray.uniq
					
				else
					f.open("C:/Users/mbala/Desktop/visitedurl.txt","a+") do |i|
						i.write(url)
						i.write("\n")
					end
					visitedarray.insert(0,url)
				end
		end
		return url,visitedarray
end


def url_validation(url,myarray)
		f = File
		registryarray = Array.new()
		visitedarray = Array.new()
		puts "traversing the ..............................................:",url

		vsmt1 = visiting_management(url,visitedarray)
		url = vsmt1[0]
		visitedarray = vsmt1[1]
		
		myarray = myarray - visitedarray 
		
		if f.zero?("C:/Users/mbala/Desktop/registry.txt")
			
			if myarray.include?(url)
				myarray = myarray.uniq
			else
				myarray.push(url)
			end
			myarray = myarray - visitedarray 
			f.open("C:/Users/mbala/Desktop/registry.txt","w+") do |i|
				i.puts(myarray)
			end
		else
			f.open("C:/Users/mbala/Desktop/registry.txt","r+") do |i|
				registryarray.push( i.read())
			end
			
			myarray.delete(url)
			registryarray = myarray - registryarray
			myarray = myarray | registryarray
			puts myarray,"registry array contents.................................. ..........."
			

			myarray = myarray.uniq
			myarray = myarray - visitedarray
			puts myarray,"uniq array contents.... ............ ........... ............. .........."
			
			f.open("C:/Users/mbala/Desktop/registry.txt","w+") do |i|
				i.puts(myarray)
			end
		end
		return myarray,visitedarray
end

def scraper(url)
		url1 = $base_url + url

		begin
			$urldata = URI.open(url1)
		rescue
			nil
		end
		file = $urldata.read
		htmldoc = Nokogiri::HTML.parse(file)
		tags_content = htmldoc.xpath("//body")
		myarray_content = Array.new()
		tags_content.each do |tag|
			File.open("C:/Users/mbala/Desktop/contentfolder/content%d.txt"%[$filecount+=1], "a+") { |f| f.write "#{tag.text}" }
		end
		
		tags = htmldoc.xpath("//a")
		myarray = Array.new()
		fullurlarray = Array.new()
		tags.each do |tag|
			myarray.push("#{tag[:href]}")
		end
		
		myarray.each do |myarr|
			if myarr.match("https") || myarr.match("http")
				fullurlarray.push( myarr)
			end

		end	
		myarray = myarray - fullurlarray

		myarr = url_validation(url,myarray)
		myarray = myarr[0]
		visitedlist = myarr[1]

		puts "visitedlist is.............::::",visitedlist
	
		myarray.each do |arrval|
			if visitedlist.include?(arrval) || visitedlist.include?("")
				myarray.delete(arrval)
				puts "yes arrval",arrval,"no visit",visitedlist
				nil
			else 
				puts "no arrval",arrval,"yes visit",visitedlist
				scraper(arrval)
			end
		end
end

scraper("/en/")