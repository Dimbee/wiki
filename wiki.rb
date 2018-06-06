#the wiki was developed by using the codes from the CS1025 Practical Exercises and building on them

#Title: "Worksheet 1: Start development of a Wiki application"
#Author: Dr. Nigel Beacham
#Date: 21st August 2015
#Availability: https://abdn.blackboard.com/bbcswebdav/pid-1397794-dt-content-rid-3694121_1/courses/MGD_CS1025_CS1026_18/Ruby%20Using%20Cloud9%20IDE%20-%20Exercise%201_04%281%29.pdf

#Title: "Worksheet 2: Control Structures and Sinatra Views"
#Author: Dr. Nigel Beacham
#Date: 21st August 2015
#Availability: https://abdn.blackboard.com/bbcswebdav/pid-1397795-dt-content-rid-3694122_1/courses/MGD_CS1025_CS1026_18/Ruby%20Using%20Cloud9%20IDE%20-%20Exercise%202_02%281%29.pdf

#Title: "Worksheet 3: Sinatra View"
#Author: Dr. Nigel Beacham
#Date: 21st August 2015
#Availability: https://abdn.blackboard.com/bbcswebdav/pid-1397795-dt-content-rid-3694123_1/courses/MGD_CS1025_CS1026_18/Ruby%20Using%20Cloud9%20IDE%20-%20Exercise%203_01%283%29.pdf

#Title: "Worksheet 4: Data-driven Web Applications" 
#Author: Dr. Nigel Beacham
#Date: 21st August 2015
#Availability: https://abdn.blackboard.com/bbcswebdav/pid-1397796-dt-content-rid-4310996_1/courses/MGD_CS1025_CS1026_18/Ruby%20Using%20Cloud9%20IDE%20-%20Exercise%204_04.pdf

#Title: "Worksheet 5: User Authentication"
#Author: Dr. Nigel Beacham
#Date: 21st August 2015
#Availability: https://abdn.blackboard.com/bbcswebdav/pid-1397797-dt-content-rid-3694125_1/courses/MGD_CS1025_CS1026_18/Ruby%20Using%20Cloud9%20IDE%20-%20Exercise%205_03.pdf

require 'sinatra' #calls the framework Sinatra
require 'data_mapper' #calls the Data Mapper ORM, which we use for creating the database of users and the create, save, update and delete functionalities.

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/wiki.db") #creates the wiki.db file in the main folder

class User #sets a class with the properties we've given below; creates a User table in the database, where the propeties are columns
	include DataMapper::Resource
	property :id, Serial
	property :username, Text, :required => true
	property :password, Text, :required => true
	property :date_joined, DateTime
	property :edit, Boolean, :required =>true, :default =>false
end

DataMapper.finalize.auto_upgrade!
#checks to see if there's any changes made to the current database structure 
#in wiki.db; if doesn't exist or structure's changed it will update any 
#additional field

helpers do #allows to define two methods to restric access for unauthorized users
	def protected!
		if authorized? #if the method is true, it calls return and goes back to the page you are on
			return
		end
		redirect '/denied' #if false, it redirects to the Denied page 
	end

	def authorized? #called temporarily to check if someone is authorized or not
		if $credentials != nil
			@Userz = User.first(:username => $credentials[0])
			if @Userz
				if @Userz.edit == true
					return true
				else
					return false
				end
			else
				return false 
			end
		end
	end
end

$myinfo = ""
@info= ""

def readFile(wiki) #defining a method for reading a file and placigng information inside
	info = ""
	File.readlines(wiki).each do |line|
		info = info + line #this way we don't overwrite the original information, just adding new
	end
	$myinfo = info
end

#code adopted from:
#Title: Rubular - a Ruby regular expression editor
#Author: Michael Lovitt
#Availability: http://rubular.com/

get '/' do #opens the Homepage
	readFile("wiki.txt")
	splits = $myinfo.split(" ")
	@words = splits.length #counts the number of words
	@characters = $myinfo.gsub(" ","").gsub(/\s+/, '').size #regular expression - counts the number of characters, ommits counting white spaces and new lines
	@wrongsentencecount = $myinfo.split(/\.|\? |!/).size #regular expression, part of counting the number of sentences
	@sentence = @wrongsentencecount - 1 #counts the number of sentences 													
	erb :home
end

get '/about' do #opens the About page
	erb :about
end

get '/createaccount' do #opens the Create Account page
	erb :createaccount
end

post '/createaccount' do #takes the parameters from the form in the Create Account page and saves them in the database
						 #if the username and password credentials are Admin and Password respectively, allows the edit function	 
	n = User.new
	n.username = params[:username]
	n.password = params[:password]
	n.date_joined = Time.now
	if n.username == "Admin" and n.password == "Password"
		n.edit = true 
	end
	n.save
	redirect '/created'
end

get '/created' do #when a new account is created, it redirects to the Created page, where a link takes a user to the Login page
	erb :created
end

get '/edit' do #opens the Edit page
	protected! #if the user is not allowed access, they will not be able to access the page
	info = ""
	readFile("wiki.txt") 
	@info = $myinfo
	erb :edit
end

put '/edit' do #updates the message in the edit and home views, as well as the wiki.txt file 
	info = "#{params[:message]}"   
	@info = info
	file= File.open("wiki.txt", "w")
	file.puts @info
	file.close          
	
	file = File.open("log.txt", "a") #in log.txt records the name of the user and the time they've changed the message
	username = $credentials[0]		 #as well as what the new message says	
	timenow = Time.now.asctime
	message = "The user #{username} edited the homepage text on #{timenow}. The new text reads: #{params[:message]}" #this is what is displayed in log.txt
	file.puts message 
	file.close
	redirect '/edit'	
end

get '/backup' do #backs up the homepage message to the backup.txt file
	file = File.open("wiki.txt", "r")
	@data = file.read
	file.close
	file = File.open("backup.txt", "w")
	file.puts @data
	file.close
	redirect '/edit'
end

get '/reset' do #resets the texts back to the text written in reset.txt
	file = File.open("reset.txt")
	@data = file.read
	file.close
	file= File.open("wiki.txt", "w")
	file.puts @data
	file.close
	redirect '/edit'
end

get '/restore' do #reverts the text back to the text written in backup.txt, triggered by the backup button
	file = File.open("backup.txt", "r")
	@data = file.read
	file.close
	file= File.open("wiki.txt", "w")
	file.puts @data
	file.close
	redirect '/edit'
end

get '/video' do #opens the Video page
	erb :video
end

get '/map' do #opens the map Page
	erb :map
end

get '/questions' do #opens up the Questions view, where the form with the quiz questions lives
	erb :questions
end

get '/answers' do #records the User's answers to each of the questions in the questions form
	@birthday = params[:birthday]
	@joinufc = params[:joinufc]
	@championship = params[:championship]
	@record = params[:record]
	@move = params[:move]
	@job = params[:job]
	erb :answers
end

#code adopted from:
#Title: include? (Array)
#Author: API Dock
#Availability: https://apidock.com/ruby/Array/include%3F

def correctanswer?(answer) #this method defines the correct answers in an array; the values in the array are with the exact same wording 
						   #as those in the questions form, otherwise the method does not work 
	['14th July 1988' , 'February 2013' , 'Eddie Alvarez', 'True', 'Left Hand', 'A Plumber'].include? answer
end

get '/login' do # opens the Login page
	erb :login
end 

post '/login' do  
	$credentials = [params[:username],params[:password]] #records the input from the form inside the relevant parts of an array and saves it into a global variable 
	@Users = User.first(:username => $credentials[0]) 
	if @Users
		if @Users.password == $credentials[1] #if login is successful, records the user's username and the time they logged in at in log.txt
			file = File.open("log.txt", "a") 
			username = $credentials[0]
			timenow = Time.now.asctime
			message = "The user #{username} logged in on #{timenow}" #this is what is displayed in log.txt
			file.puts message
			file.close
			redirect '/'
		else
			$credentials =['','']  #if credentials are not in the database, redirects to the Wrong Account page
			redirect '/wrongaccount' 
		end
	else
		$credentials = ['','']
		redirect '/wrongaccount'
	end		
end

get '/wrongaccount' do #opens the Wrong Account page when necessary
	erb :wrongaccount
end

get '/admincontrols' do #in the Admin Controls page, the name of all registered users are displayed, with the ones registered most recently first 
	protected! 
	@list2 = User.all :order => :id.desc
	erb :admincontrols
end

put '/user/:uzer' do #allows for enabling or disabling the permissions to edit for each user, other than the Admin 
	n = User.first(:username => params[:uzer])
	if n.username == "Admin"
		redirect '/denied'
	else
	n.edit = params[:edit]? 1:0 
	n.save
	redirect '/admincontrols' 
	end
end

get '/user/:uzer' do #allows for displaying the Profile page if the user exists, otherwise redirects to the No Account page
	@Userz = User.first(:username =>params[:uzer]) 
	if @Userz != nil
		erb :profile
	else	
		redirect '/noaccount'
	end
end

get '/user/delete/:uzer' do #allows for deleting a user from database, if the username is Admin, the user cannot be deleted
	protected!
	n = User.first(:username => params[:uzer])
	if n.username == "Admin"
		erb :denied
	else
		n.destroy
		@list2 = User.all :order => :id.desc
		erb :admincontrols
	end
end

get '/user/edit/:uzer' do #allows for changing the username of a user, if the username is Admin, username cannot be changed
  protected!
  @user = User.first(:username => params[:uzer])
  if @user.username == "Admin"
    erb :denied
  else
    erb :changeusername
  end
end

get '/changeusername' do  #opens the Change Username page, where the user types in their new username
	erb :changeusername
end

put '/user/update/:uzer' do   #changes the username, again if username is Admin, username cannot be changed; otherwise saves the new username
  protected!
  @user = User.first(:username => params[:uzer])
  if @user.username == "Admin"
    erb :denied
  else
    @user.username = params[:new_username]
    @user.save
    redirect '/admincontrols'
  end
end

get '/logout' do #logs the user out, and reords the username and the time the username logged out at in log.txt
	file = File.open("log.txt", "a")
	username = $credentials[0]
	timenow = Time.now.asctime
	message = "The user #{username} logged out on #{timenow}." #this is what is displayed in log.txt
	file.puts message
	file.close
	$credentials = ['', '']			
	redirect '/'
end

get '/notfound' do #the notfound view handles instances where a page does not exist
	erb :notfound
end

get '/noaccount' do #the noaccount view handles instances where an account does not exist in the database
	erb :noaccount
end

get '/denied' do #opens the Denied view when necessary 
	erb :denied 
end

not_found do
	status 404
	redirect '/notfound'
end			