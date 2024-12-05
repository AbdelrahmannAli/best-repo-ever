import { LightningElement, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getRefreshInterval from "@salesforce/apex/ClientCasesController.getListViewAutoRefreshDuration";

export default class AutoRefreshUtilityComponent extends NavigationMixin(LightningElement) {
    
    currentPageRef = null; // Stores the current page reference
    isListView = false; // Tracks whether the page is a list view
    autoRefreshIntervalID = null; // Stores the interval ID for auto-refresh
    autoRefreshInterval = null; // Stores the auto-refresh interval from the custom meta-data

    SELECTORS = {
        UTILITY_BAR_DIV: '.oneUtilityBar.slds-utility-bar_container.oneUtilityBarContent',
        PAGE_HEADER: '.slds-page-header_object-home',
        REFRESH_BUTTON: 'button[name="refreshButton"]',
        AUTO_REFRESH_COMPONENT: 'div[data-component-id="Syntilio_autoRefreshUtilityComponent"]',
        };

    renderedCallback() {
        //optionally add a metadata item to signify the presence of
        //the feedback form to enable/disble visibility
        const utilityBarDiv = document.querySelector(this.SELECTORS.UTILITY_BAR_DIV);
        const utilityUL = utilityBarDiv.querySelector('ul');
        const utilityLIs =  utilityUL.querySelectorAll('li');
        let autoRefreshDiv = null;
        utilityLIs.forEach(li => {
            let currentDiv = li.querySelector(this.SELECTORS.AUTO_REFRESH_COMPONENT);
            if (currentDiv) {
                autoRefreshDiv = currentDiv;
            }
        });
        if(autoRefreshDiv)
        {
            const autoRefreshButton = autoRefreshDiv.querySelector('button')
            if(autoRefreshButton){
                autoRefreshButton.style.color = 'transparent';
                autoRefreshButton.style.pointerEvents = 'none';
                autoRefreshButton.disabled = true;
            }
            else{
                console.warn('Auto-Refresh button not found');
            }
    }
    else{
        console.warn('Auto-Refresh div not found');
    }
    }

    @wire(CurrentPageReference)
    async handlePageReferenceChange(pageRef) {
        // Detect page navigation
        this.currentPageRef = pageRef;
        if (this.isListViewPage()) {
            this.autoRefreshInterval = await getRefreshInterval();
            if(this.autoRefreshInterval)
                if(this.autoRefreshInterval>0.99)
                    {
                    this.startAutoRefresh();
                }
                else{
                    console.error("Minimum auto-refresh duration is 1000 milliseconds (1 second)")
                }
        } else {
            this.stopAutoRefresh();
        }
    }

    isListViewPage() {
        // Check if the page is a list view based on attributes
        return (
            this.currentPageRef &&
            this.currentPageRef.attributes &&
            this.currentPageRef.attributes.objectApiName &&
            this.currentPageRef.attributes.actionName === 'list'
        );
    }

    startAutoRefresh() {
        // Clear any existing interval to avoid duplicates
        if (this.autoRefreshIntervalID) {
            clearInterval(this.autoRefreshIntervalID);
        }

        this.autoRefreshIntervalID = setInterval(() => {
            this.refreshPage();
        }, this.autoRefreshInterval*1000); 
    }

    stopAutoRefresh() {
        // Clear the interval to stop auto-refresh
        if (this.autoRefreshIntervalID) {
            clearInterval(this.autoRefreshIntervalID);
            this.autoRefreshIntervalID = null;
        }
    }

    refreshPage() {
        // Trigger the refresh logic associated with the button
        const div = document.querySelector(this.SELECTORS.PAGE_HEADER);
        // there must be a button with this name in the header
        const refreshButton =div.querySelector(this.SELECTORS.REFRESH_BUTTON) ;

        if (refreshButton) {
            refreshButton.click(); 
        } else {
            console.warn('Refresh button not found!');
        }
    }

    disconnectedCallback() {
        this.stopAutoRefresh();
    }
    
    



}