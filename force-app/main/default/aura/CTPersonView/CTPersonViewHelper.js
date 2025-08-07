({
    showToast : function(title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": "success"
        });
        toastEvent.fire();
    },

    updateStatus : function(component, event, helper) {
        const action = component.get("c.UpdateHealthStatusToRed");
        const recordId = component.get("v.recordId");

        action.setParams({"personId" : recordId});

        action.setCallback(this, function(response){
            const state = response.getState();
            if (state === "SUCCESS") {
                this.showToast("Success!", "Person Health Status Updated");
            }});

        $A.enqueueAction(action);
    },
})