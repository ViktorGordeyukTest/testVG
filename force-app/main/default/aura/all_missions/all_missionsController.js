({
    init: function (cmp, event, helper) {
        helper.getData(cmp, helper);
    },

    showDetail: function(cmp, event, helper){
        helper.showMissionDetail(cmp, event, helper);
    },

    handleMessage: function(cmp, message, helper){
        console.log('message = ',message);
        console.log('message get = ',message.getParam("recordData"));
        if (message != null && message.getParam("recordData") != null &&  message.getParam("recordData").type === '0') {
           cmp.set('v.mydata', []); 
           helper.getData(cmp, helper);
            
        }
    }
})