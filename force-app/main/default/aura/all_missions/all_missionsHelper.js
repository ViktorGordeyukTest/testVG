({
    getData: function(cmp, helper){
        var action = cmp.get('c.getAllMissions');
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            console.log('state = ',state);
            if (state === "SUCCESS") {
                let data = JSON.parse(response.getReturnValue());
                console.log('data = ',data);
                cmp.set('v.mydata', data);
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },

    showMissionDetail: function(cmp, event, helper){
        let selectedItem = event.currentTarget;
        let recordId = selectedItem.dataset.recordid;
        let status = selectedItem.dataset.status;
        let heroRank = selectedItem.dataset.herorank;
        let isOwner = selectedItem.dataset.isowner;
        console.log('recordId => ',recordId);
        let payload = {
            Id: recordId,
            recordData: {
                type: '1',
                status: status,
                heroRank: heroRank,
                isowner: isOwner
            }
        };

        cmp.find("sampleMissionDetail").publish(payload);
    }
})