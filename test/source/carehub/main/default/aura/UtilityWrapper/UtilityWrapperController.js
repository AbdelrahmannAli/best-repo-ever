({
    handleInit: function(component, event, helper) {
        const utilityAPI = component.find("utilitybar");
        let firstClickHandled = false; 

        const checkUtilityIdInterval = setInterval(function() {
            utilityAPI.getEnclosingUtilityId().then(function(utilityId) {
                if (utilityId) {
                    utilityAPI.getUtilityInfo({ utilityId: utilityId }).then(function(utilityInfo) {
                        if (!firstClickHandled) {
                            handleCaseCreationAndMinimize(component, utilityAPI, utilityId);
                            firstClickHandled = true; 
                        }
                        utilityAPI.onUtilityClick({
                            utilityId: utilityId,
                            eventHandler: function() {
                                handleCaseCreationAndMinimize(component, utilityAPI, utilityId);
                            }
                        });
                        clearInterval(checkUtilityIdInterval);
                    }).catch(function(error) {
                        console.error("Error retrieving utility info: ", error);
                    });
                }
            }).catch(function(error) {
                console.error("Error retrieving utilityId: ", error);
            });
        }, 300); 

        function handleCaseCreationAndMinimize(component, utilityAPI, utilityId) {
            const lwcComponent = component.find("createCaseLWC");
            if (lwcComponent) {
                lwcComponent.createNewCase();
                utilityAPI.minimizeUtility({ utilityId: utilityId }).then(function() {
                }).catch(function(error) {
                    console.error("Error minimizing utility bar: ", error);
                });
            }
        }
    }
})