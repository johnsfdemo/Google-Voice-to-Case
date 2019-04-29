//  Flow component to parse a Google voice mail message, saved as a Google mail entry and forwarded to
//  Salesforce in an email-to-case.
//  
//  The code checks to make sure that only one case is entered at a time.  To provide updates to multiple
//  cases, place this component inside a loop in flow builder.
//  
//  Returns a status string of either 'SUCCESS' or 'FAILURE'.  In case of FAILURE, a more detailed message
//  detailing the reason for failure is provided.
//
//  This code is provided AS IS, with no warranty or guarantee of suitability for use.
//  Contact: john.meyer@salesforce.com


global without sharing class GoogleVoicemailProcessor {
    
    private static final String SUCCESS = 'SUCCESS';
    private static final String FAILURE = 'FAILURE';
    
    global class Requests {
        @InvocableVariable
        global Id caseId;				// The record ID of the case
    }
    
    global class Results {
        @InvocableVariable
        global String status;				// Either 'SUCCESS' or 'FAILURE'
        
        @InvocableVariable
        global String message;				// In the case of FAILURE, a more detailed message
    }    
    
    @InvocableMethod(label='Process Google Voicemail' description='Strips out the fluff of a Google voice mail and leaves the text in the description. Also assigns the contact to the case based on the phone number.')
    
    public static List<Results> processGoogleVoicemail (List<Requests> cases) {
        
        List<Results> resultList = new List<Results>();
        Results result = new Results();
        
        if (cases.size() != 1) {
            result.status = FAILURE;
            result.message = 'You must supply exactly one case to use this action.';
            System.debug(result.message);
        } else {
            Case theCase = [SELECT ContactId, Description, Subject FROM Case WHERE Id = :cases[0].caseId LIMIT 1];
            if (theCase.Subject.contains('New voicemail from')) {
                findContact(theCase);															// Do this first before we clean up the voice mail
                cleanUpVoiceMail(theCase);
                try {
                    update theCase;
                    result.status = 'SUCCESS';
                } catch (DMLException e) {
                    result.status = 'FAILURE';
                    result.message = 'Could not update case ' + theCase.Id + ' after parsing Google voice mail: ' + e.getMessage();
                    System.debug(result.message);
                }
            } else {																			// Sometimes other messages like 'New missed call from' show up
                result.status = 'FAILURE';
                result.message = 'Not a valid Google Voice message: could not find "New voicemail from" in email subject line.';
                System.debug(result.message);
            }
        }
        
        resultList.add(result);
        return resultList;
    }
    
    
    // Modify the case subject and description to strip out the Google voice fluff.
    
    private static void cleanUpVoiceMail (Case theCase) {
        theCase.Subject = theCase.Subject.replace('New voicemail', 'New case');					// Change 'New voicemail' to 'New case'        
        String description = theCase.Description.remove('<https://voice.google.com>');				// Delete first line
        description = description.left(description.indexOf('play message'));					// Delete 'play message' and following text        
        description = description.replace('\r\n', ' ').replace('\r', ' ').replace('\n', ' ');	// Clean up newlines and extraneous junk
        description = description.replace(',,', ',');
        description = description.replace('..', '.');
        theCase.Description = description;
    }
    
    
    // Parse the case subject from the Google Voice transcription to find a match with the telephone number.
    
    private static void findContact (Case theCase) {
        String phone = theCase.Subject.substring(19,33);										// "New voicemail from (xxx) xxx-xxxx"
        List<Contact> c = [SELECT Id, Name FROM Contact WHERE Phone = :phone OR HomePhone = :phone OR MobilePhone = :phone OR OtherPhone = :phone LIMIT 1];
        if (!c.IsEmpty()) {
            theCase.ContactId = c[0].Id;
            theCase.Subject = 'New case from ' + c[0].Name;
        }
    }
    
}
