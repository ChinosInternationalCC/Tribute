"""clear all globals"""
for uniquevar in [var for var in globals().copy() if var[0] != "_" and var != 'clearall']:
    del globals()[uniquevar]

import xlrd
import random
import smtplib
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from datetime import datetime
import time
from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream
import tweepy 
import re
import unicodedata
#from numpy import genfromtxt

csvfile = 'database_mail2.csv'
#xls file configuration
xls_filename = 'database_mail2.xls'
sheet_name = 'Sheet1'
first_row = 2
NAME_col = 0
MAIL_col = 1
DISC_col = 2
DEP_col = 3
UNI_col = 4

#email configurations
SMTP_SERVER = 'smtp.gmail.com'
SMTP_PORT = 587
mail_sender = ''
password =''

email_filename = 'openteaching.html'

#tweeter auth
OAuthConsumerKey = ""
OAuthConsumerSecret = ""
AccessToken = ""
AccessTokenSecret = ""

global NAMES
global MAILS
global DISCIPLINES
global DEPARTMENTS
global UNIS
#define global lists for teachers data
NAMES = []
MAILS = []
DISCIPLINES = []
DEPARTMENTS = []
UNIS = []
MAIL_LINES = []

SENDERS = []

TweetsCount = 0
LastTweetCountReset = time.time()
TweetsTimeInterval = 3600 #val in seconds -> 1h
TweetsLimit = 90

#everytime someone send the hashtag, 
#the arm is moved towards the button and the mail bot send 1 email to 3 teachers.
def ImportTeachersXls():
	global NAMES
	global MAILS
	global DISCIPLINES
	global DEPARTMENTS
	global UNIS
	#open the workbook
	wb = xlrd.open_workbook(xls_filename)
	try:
		sh_Teachers = wb.sheet_by_name(sheet_name)
	except XLRDError:
		raise XLRDError
	for rowx in xrange(first_row, sh_Teachers.nrows):
		NAMES.append(sh_Teachers.cell(rowx,NAME_col).value)
		if sh_Teachers.cell(rowx,MAIL_col).value in MAILS:
			print 'Duplicated email!!!!!'+sh_Teachers.cell(rowx,MAIL_col).value
		MAILS.append(sh_Teachers.cell(rowx,MAIL_col).value)
		DISCIPLINES.append(sh_Teachers.cell(rowx,DISC_col).value)
		DEPARTMENTS.append(sh_Teachers.cell(rowx,DEP_col).value)
		UNIS.append(sh_Teachers.cell(rowx,UNI_col).value)

def ImportTeachersCsv():
	global NAMES
	global MAILS
	global DISCIPLINES
	global DEPARTMENTS
	global UNIS
	data = genfromtxt(csvfile, delimiter=',', names = True, dtype=None)
	NAMES = data['NAME'].tolist()
	MAILS = data['MAIL'].tolist()
	DISCIPLINES = data['discipline'].tolist()
	DEPARTMENTS = data['department'].tolist()
	UNIS = data['University'].tolist()
		
def GetRandomMails(NoOfMails):
	global MAILS
	#mails_list = random.sample(set(MAILS), NoOfMails)
	mails_list = []
	mails_list.append(MAILS.pop())
	print 'Mails will be sent to: ' + str(mails_list)
	return mails_list

def PopOneMail():
	global NAMES
	global MAILS
	global DISCIPLINES
	global DEPARTMENTS
	global UNIS
	NAMES.pop()
	DISCIPLINES.pop()
	DEPARTMENTS.pop()
	UNIS.pop()
	return MAILS.pop()
	
def ReadMailText():
	fi = open(email_filename)
	inputLines= fi.readlines()
	fi.close()
	return inputLines

def PollTweetEvent():
	return 0

def CheckForTweetLimit():
	global TweetsCount
	global LastTweetCountReset
	global TweetsTimeInterval
	global TweetsLimit
	
	interval = time.time() - LastTweetCountReset
	#check if interval elapsed to reset the counter
	if interval > TweetsTimeInterval:
		TweetsCount = 1
		LastTweetCountReset = time.time()
		return 1
	else:
		#the time didn't elapsed so I should check for the tweets limit
		if TweetsCount > TweetsLimit:
			return 0
		else:
			return 1


def SendMail(MailsList,MailLines,Sender):
	COMMASPACE = ', '

	"Sends an e-mail to the specified recipient."
	subject = 'OpenTeaching'
	body = ''
	for line in MailLines:
		body = body + '\n' + line
	
	adr = COMMASPACE.join(MailsList)
	unicodedata.normalize('NFKD', adr).encode('ascii','ignore')
	
	#print '\n#############################################\n'
	#print 'The following message will be sent:\n----------------------------\n'+body
	#print '\n#############################################\n'
	headers = ["From: " + mail_sender,
           "Subject: " + subject,
           "Bcc: " + str(adr),
           "MIME-Version: 1.0",
           "Content-Type: text/html"]
		   #"Content-Type: text"]
	headers = "\r\n".join(headers)
 
	session = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
 
	session.ehlo()
	session.starttls()
	session.ehlo
	session.login(mail_sender, password)
	
	print COMMASPACE.join(MailsList)


	session.sendmail(mail_sender, str(adr), headers + "\r\n\r\n" + body)

	session.quit()
	return 0

def UpdateUserName(MailText,UserName):
	for i in xrange(len(MailText)):
		if re.search('USERNAME',MailText[i]):
			MailText[i] = MailText[i].replace('USERNAME',UserName)
	return MailText


		
class StdOutListener(StreamListener):
	""" A listener handles tweets are the received from the stream. 
	This is a basic listener that just prints received tweets to stdout.

	"""
	def on_data(self, data):
		#get the Name that tweeted and the text tweeted
		global SENDERS
		SENDERS = ["ovicin@yahoo.com"]
		Name = ''
		Text = ''
		id = ''
		fields = data.split(',')
		for element in fields:
			if re.search('screen_name',element):
				if len(element.split(':')[0]) < 14:
					Name = element.split(':')[1][1:-1]
			if re.search('text',element):
				if len(element.split(':')[0]) < 7:
					Text = element.split(':')[1][1:-1]
			if re.search('id_str',element):
				if len(element.split(':')[0]) < 9:
					id = element.split(':')[1][1:-1]
  		print Name + ' say ' + Text + '\n'
		if Name not in SENDERS:
			SENDERS.append(Name)
			#post a new tweet
			if CheckForTweetLimit():
				print '\n Sending tweet to mention ' + Name
				
				stat = 'Thanks @'+Name+' for inviting more teachers to make their lectures public on web in Tribute for Aaron Swartz @'+ str(datetime.now().hour) + ' ' + str(datetime.now().minute)+ ' ' + str(datetime.now().second)
				stat = stat[:140]
				api.update_status(stat)
				#api.retweet(id)
				#send the emails if mails in the list
			if len(MAILS) > 0:
				print 'sending mail'
				SendMail(GetRandomMails(1),UpdateUserName(ReadMailText(),Name),'')
		
		else:
				
			#send the emails if mails in the list
			if len(MAILS) > 0:
				print 'sending mail'
				SendMail(GetRandomMails(1),UpdateUserName(ReadMailText(),Name),'')
		
		return True

	def on_error(self, status):
		print status	

#main starts here
if __name__ == '__main__': 	
	#Import the email addreses
	ImportTeachersXls()
	print MAILS
	#ImportTeachersCsv()
	#define the Tweet listener object
	l = StdOutListener()
	auth = OAuthHandler(OAuthConsumerKey, OAuthConsumerSecret)
	auth.set_access_token(AccessToken, AccessTokenSecret)
	
	api = tweepy.API(auth)
	print api.me().name
	
	#start listening to the tweeter stream
	stream = Stream(auth, l)	
	stream.filter(track=['#OpenTeaching'])
	#stream.filter(track=['basket'])

