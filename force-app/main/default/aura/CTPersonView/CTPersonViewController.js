({
    PersonSelectHandler : function(component, event, helper) {
        const recordId = event.getParam("recordId");
        const status = event.getParam("status");
        component.set("v.status", status);
        component.set("v.recordId", recordId);
    },

    UpdateHealthStatus : function(component, event, helper){
       helper.updateStatus(component);
    }
})