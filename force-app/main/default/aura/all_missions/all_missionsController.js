({
    init: function (cmp, event, helper) {
        helper.getData(cmp, helper);
    },

    showDetail: function(cmp, event, helper){
        helper.showMissionDetail(cmp, event, helper);
    },

    handleMessage: function(cmp, message, helper){
        console.log('message = ',message);
        if (message != null && message.getParam("recordData") != null &&  message.getParam("recordData").type === '0') {
            helper.getData(cmp, helper);
        }
    }
})