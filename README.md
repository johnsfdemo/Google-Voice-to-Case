# Google Voice to Case

This package contains an invocable Apex class and a sample Salesforce Process Builder process to parse an incoming email-to-case record that was generated by leaving a Google Voice message and then forwarding the transcribed voice message to Salesforce. The parser (1) cleans up all of the GMail boilerplate to find the text of the voicemail and deposit it in the `Description` field of a new Salesforce `Case` record; and (2) attempts to match the caller's phone number with a `Contact` in the Salesforce org, associate that contact with case, and set the `Subject` field of the case to a more descriptive message that includes the contact's name.

![Animation](/images/Google_Voicemail_Animated.gif)


## Installation and Setup

### Step 1

[Create a free Google Voice account](https://support.google.com/voice/answer/7207482?hl=en&ref_topic=1707989). As part of the account creation, you will get a Gmail address related to the account.

### Step 2

[Set up email-to-case in Salesforce](https://help.salesforce.com/articleView?id=customizesupport_enabling_email_to_case.htm). The easiest way to do this is to select the **Service Setup** menu item from the gear icon in the upper right-hand corner of the Salesforce page and stepping through the **Email Setup** wizard. On the first page of the wizard, enter the Gmail address you got in **Step 1**:

![Email-to-Case Wizard](/images/Email_to_Case_Dialog.png)

Finish all the steps in the wizard and your email-to-case should be ready to go. *Make sure you test this setup before proceeding further*. If you use the wizard, a test case is generated automatically for you. Just check your incoming cases in the appropriate list view.

### Step 3

Go back to your `voice.google.com` page and click the Settings (gear) icon in the upper right-hand-corner. Select the option to forward your messages to the Gmail address:

![Forward Messages](/images/Forward_Messages.png)

Scroll down the page and select the **Do not disturb** option. This will automatically make any voice call go directly to voicemail:

![Do Not Disturb](/images/Do_Not_Disturb.png)

### Step 4

[Deploy this package](#how-to-deploy-this-package-to-your-org) to your Salesforce org using the button below.

### Step 5

You are now ready to use the contents of this package in your Process Builder processes and Flow Builder flows. Simply call the `Process Google Voicemail` Apex action and pass in the record ID of the current case. I include a sample Process Builder process called `Sample Google Voice Process` (inactive by default) that includes the action. You may use it, modify it, or simply use it as a reference for your own processes and flows:

![Process Google Voicemail Action](/images/Process_Google_Voicemail.png)

If you are using `Process Google Voicemail` in a flow rather than a process, you can check the return values as well: `status` will be set to either `SUCCESS` or `FAILURE`, and in the case of the latter, `message` will include a more detailed error message.

### Step 6

Add the Google Voice number from **Step 1** to your mobile phone's address book and dress it up for the demo by adding your customer's logo and using the name of your customer as the contact. Then, go into your Salesforce org and select the record of the contact you wish to use as the initiator of the case in your demo. Add your own mobile phone number to any of the standard phone fields (`Phone`, `MobilePhone`, `HomePhone`, or `OtherPhone`) of that contact. Make sure you enter your mobile phone number in the form `(###) ###-####`, *including the parentheses, space, and dash exactly as shown*, or this package will not find it.


## How to Demo

Show your mobile phone's screen using Quicktime or [Reflector](https://www.airsquirrels.com/reflector/features/mac-and-windows) from your laptop. Make sure that the process or flow that references the parser is activated. If you are demonstrating OmniChannel, make sure you are logged into OmniChannel so that it will chime when the case is created.

Then, simply call the Google Voice number from your mobile phone and leave a message, being sure to speak clearly. In a few moments, you should have a new case that contains "New case from *contact*" as the `Subject` and the transcription of your voice mail message in the `Description` field. You can also see the original Google mail in the Feed section of the case record.


## How to Deploy This Package to Your Org

I am a pre-sales Solutions Engineer for [Salesforce](https://www.salesforce.com) and I develop solutions for my customers to demonstrate the capabilities of the amazing Salesforce platform. *This package represents functionality that I have used for demonstration purposes  and the content herein is definitely not ready for actual production use; specifically, it has not been tested extensively nor has it been written with security and access controls in mind. By installing this package, you assume all risk for any consequences and agree not to hold me or my company liable.*  If you are OK with that ...

Simply click the button below and log into your org:

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>


## Troubleshooting

- Before trying anything else, make sure your email-to-case setup is working properly. A test case should have been generated by the wizard in **Step 2**.
- If the contact cannot be identified by your mobile phone number, make sure the number is of the form `(###) ###-####`, *including the parentheses, space, and dash exactly as shown*, since this is how Google Voice stores the number in the `Subject:` field of the email it generates and this is how I find it. Other forms, like `###-###-####`, or `##########` will not be found.
- If the wrong contact is associated with the case, check your phone numbers. The Apex class searches all four standard phone fields on the `Contact` object and returns the first one it finds. If more than one contact has your mobile phone number in any of those four fields, the first one will be returned as the contact.
- The `Sample Google Voice Process` that I include is shipped inactive since it triggers on every new case that is created. If you are using or modifying it, make sure it is activated or it will not work.