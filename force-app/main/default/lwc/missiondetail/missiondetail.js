import { LightningElement, track, wire} from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import emptyMessage from "@salesforce/label/c.emptyMessage";
import getMission from "@salesforce/apex/MissionDeailCtrl.getMissionDetail";
import acceptMission from "@salesforce/apex/MissionDeailCtrl.acceptMission";
import completeMission from "@salesforce/apex/MissionDeailCtrl.completeMission";

import {
    APPLICATION_SCOPE,
    createMessageContext,
    MessageContext,
    publish,
    releaseMessageContext,
    subscribe,
    unsubscribe,
} from 'lightning/messageService';
import missionDetailChannel from '@salesforce/messageChannel/MissionDetail__c';

const RANKS = ['S', 'A', 'B', 'C', 'D'];

export default class Missiondetail extends LightningElement {

    @wire(MessageContext)
    messageContext;

    @track missionDetail; 
    
    @track isShowDetail = false;
    @track isShowAccept = false;
    @track isShowComplete = false;

    heroRank;
    isOwner;

    label = { emptyMessage };

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                missionDetailChannel,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    // Handler for message received by component
    handleMessage(message) {
        if(message.recordData.type === '1'){
            let Id = message.Id;
            let status = message.recordData.status;
            this.heroRank = message.recordData.heroRank;
            this.isOwner = message.recordData.isowner;
            console.log('this.heroRank => ',this.heroRank);
            this.getData(Id, status);
        }
    }

    // Standard lifecycle hooks used to subscribe and unsubsubscribe to the message channel
    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    getData(Id, status) {
        getMission({Id : Id})
          .then((result) => {
            console.log('result => ',result);
            this.missionDetail = result;
            this.isButtonsVisible(status);
            this.isShowDetail = true;
          })
          .catch((error) => {
            this.error = error;
          });
      }

      isButtonsVisible(status){
        let isShowAcceptTemp = false;
        let isShowCompleteTemp = false;
        if(this.missionDetail.Mission_Assignments__r == null){
            isShowAcceptTemp = true;
        } else if(this.missionDetail.Mission_Assignments__r[0].Status__c != 'Completed'){
            isShowCompleteTemp = true;
        }
        if(status === 'Completed'){
            this.isShowAccept = false;
            this.isShowComplete = false;
        } else if(status === 'In Progress' && isShowCompleteTemp === true){
            this.isShowAccept = false;
            this.isShowComplete = true;
        } else if(status === 'In Progress' && isShowAcceptTemp === true){
            this.isShowAccept = true;
            this.isShowComplete = false;
        } else if(status === 'Available' && isShowAcceptTemp === true){
            this.isShowAccept = true;
            this.isShowComplete = false;
        }
        
      }

      handleAcceptMission(){

        let rankIndex = RANKS.indexOf(this.heroRank);
        let missionRank = this.missionDetail.Complexity_Rank__c;
        
        if(rankIndex != RANKS.indexOf(missionRank) &&
            rankIndex != (RANKS.indexOf(missionRank) - 1) &&
            rankIndex != (RANKS.indexOf(missionRank) + 1)
        ){
            let messageTxt = 'Unfortunately, you are too weak at the moment to take on this work. Come back when you reach rank ';
            if(RANKS.indexOf(missionRank) === 0){
                messageTxt += missionRank +', '+(RANKS.indexOf(missionRank) + 1);
            } else {
                messageTxt += (RANKS.indexOf(missionRank) - 1) +', '+ missionRank +', '+(RANKS.indexOf(missionRank) + 1);
            }
            let messageObj = {
                message : messageTxt,
                title : "RANK ERROR",
                variant: "error"
            };

            this.showToast(messageObj);
            return;

        }
        
        acceptMission({Id : this.missionDetail.Id})
              .then((result) => {
                const payload = { recordData: {type: '0'} };
                publish(this.messageContext, missionDetailChannel, payload);
                this.isShowAccept = false;
                this.isShowComplete = true;
              })
              .catch((error) => {
                console.log(error);
                let messageObj = {
                    message : error,
                    title : "ERROR",
                    variant: "error"
                };
    
                this.showToast(messageObj);
                
              });
          

      }

      handleCompleteMission(){
        completeMission({Id : this.missionDetail.Id})
              .then((result) => {
                console.log('result => ',result);
                const payload = { recordData: {type: '0'} };
                publish(this.messageContext, missionDetailChannel, payload);
                this.isShowAccept = false;
                this.isShowComplete = false;
              })
              .catch((error) => {
                this.error = error;
              });

      }

      showToast(messageObj){
        const evt = new ShowToastEvent({
            title: messageObj.title,
            message: messageObj.message,
            variant: messageObj.variant,
          });
          this.dispatchEvent(evt);
      }

}