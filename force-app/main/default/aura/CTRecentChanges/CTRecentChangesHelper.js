({
    fetchHealthStatus : function(component) {
        const action = component.get("v.scope") === "person" ? component.get("c.getRecentPersonHealthChanges") : component.get("c.getRecentLocationHealthChanges");
        
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === "SUCCESS"){
                const resp = response.getReturnValue();
                component.set("v.data", resp);
                component.set("v.initialData", resp);
            }
        });
        $A.enqueueAction(action);
    },

    search : function(component, searchTerm) {
        const action = component.get("v.scope") === "person" ? component.get("c.searchPeople") : component.get("c.searchLocations");

        action.setParams({
            searchTerm : searchTerm
        });

        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === "SUCCESS"){
                const resp = response.getReturnValue();
                if(resp && resp.length >0){
                    component.set("v.data", resp);
                }   
                component.set('v.issearching', false);     
            }
        });
        $A.enqueueAction(action);
    },
})