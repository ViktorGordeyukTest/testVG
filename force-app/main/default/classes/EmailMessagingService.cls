/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-15-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class EmailMessagingService {
    
    public static void sendEmails(List<String> contactEmailList, String emailBody, String Subject){

        /* Sending of email */
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = contactEmailList;
        message.htmlBody = 'TEST: '+emailBody;
        message.subject = Subject;

        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

    }
}