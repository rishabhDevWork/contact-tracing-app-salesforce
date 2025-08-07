({
    fetchStatusCount : function(component) {
       const scope = component.get("v.scope");
       let action = scope === "person" ? component.get("c.getPersonHealthStatusCount") : component.get("c.getLocationHealthStatusCount");

       action.setCallback(this, function(response){
        const state = response.getState();
        if(state === "SUCCESS"){
           // component.set("count", response.getReturnValue());
           let countMap = response.getReturnValue();
           if(!countMap.Green){
            component.set("v.Green", 0);
           } else {
            component.set("v.Green", countMap.Green);
           }
           if(!countMap.Orange){
            component.set("v.Orange", 0);
           } else {
            component.set("v.Orange", countMap.Orange);
           }
           if(!countMap.Yellow){
            component.set("v.Yellow", 0);
           } else {
            component.set("v.Yellow", countMap.Yellow);
           }
           if(!countMap.Red){
            component.set("v.Red", 0);
           } else {
            component.set("v.Red", countMap.Red);
           }
           
        }
          
       })
       $A.enqueueAction(action);
    },
})