import { LightningElement, api, track } from "lwc";
import searchForClient_Suggested from "@salesforce/label/c.searchForClient_Suggested";
import searchForClient_Others from "@salesforce/label/c.searchForClient_Others";
import searchForClient_NoSuggested from "@salesforce/label/c.searchForClient_NoSuggested";
import searchForClient_Groups from "@salesforce/label/c.searchForClient_Groups";

export default class MultiSelectCombobox extends LightningElement {
	@api label;
	@api placeholder = "";
	@api options = [];
	@track selectedOptions = [];
	@track searchTerm =""
	@track search = true
	@track original = []
	@api multiple = false
	@api initital = ""
	@api splitContact = false;
	@api suggestedLength = 0;
	@api comboboxId;
	@track suggestedCallerflag = false;
	@api showSuggestedTemp = false;
	hasClickListener = false;

	@api
	clearSelectedOptions() {
		this.selectedOptions = [];
		this.options = this.options.map(option => {
			return { ...option, selected: false };
		}); 
	}

	labels = {
		searchForClient_Suggested,
		searchForClient_Others,
		searchForClient_NoSuggested,
		searchForClient_Groups
	};

	get isDisabled() {
        return !this.multiple && this.selectedOptions.length !== 0;
    }

	get firstSuggested() {
        return this.options.slice(0, this.suggestedLength);
	}

    get otherSuggested() {
        return this.options.slice(this.suggestedLength);
    }

	get groupedOptions() {
		const careCircleMembers = this.options.filter(option => option.category === "Care Circle");
		const groups = this.options.filter(option => option.category === "Groups");
		const contacts = this.options.filter(option => option.category === "Contacts");	
		return {
			careCircleMembers,
			contacts,
			groups,
		};
	}

	toggleDropdown(event) {
		event.preventDefault();
		event.stopPropagation();
		const comboboxIdEvent = new CustomEvent('comboboxtoggle', {
            detail: this.comboboxId
        });
        this.dispatchEvent(comboboxIdEvent);
		const dropdown = this.template.querySelector(".slds-dropdown");
		dropdown.classList.toggle("slds-hide");
		dropdown.classList.toggle("slds-show");
	}
	handleSearch(event) {
		try {
			if(this.search){
				this.original = [...this.options]
				this.search = false
			}
			this.searchTerm = event.target.value.toLowerCase();
			const searchKeywords = this.searchTerm.split(" ").filter(Boolean)
			if(this.comboboxId==='callerCombobox'){
				if(this.searchTerm){
					this.splitContact = false;
					this.search = false;
				}else{
					this.splitContact = true;
					this.search = true;
				}
			}
			this.options =
				this.searchTerm !== ""
					? this.original.filter((item) => {
							return searchKeywords.every(
								(keyword) =>
									item.label?.toLowerCase().includes(keyword) 
							);
					})
					: [...this.original];
			const dropdown = this.template.querySelector(".slds-dropdown");
			if (dropdown && dropdown.classList.contains("slds-hide")) {
				dropdown.classList.remove("slds-hide");
				dropdown.classList.add("slds-show");
			}
		} catch (error) {
			this.logException(error, "handleSearch");
		}
	}
	renderedCallback(){
		if (!this.hasClickListener) {
            document.addEventListener("click", this.handleOutsideClick.bind(this));
            this.hasClickListener = true;
        }

		if(this.initital && !this.selectedOptions?.length == 1) {
			let selectedId = null;
			selectedId = this.initital
			this.handleSelect(selectedId)
		}

		this.groupedOptions.careCircleMembers.length>0? this.suggestedCallerflag = true: this.suggestedCallerflag = false;
	}

	handleOutsideClick(event) {
		const dropdown = this.template.querySelector(".slds-dropdown");
		if (dropdown && !dropdown.contains(event.target)) {
			dropdown.classList.remove("slds-show");
			dropdown.classList.add("slds-hide");
		}
	}

	handleSelect(event) {
		if (!this.multiple && this.selectedOptions.length > 0){
			return;
		}
		let selectedValue = ""
		if(event?.target?.dataset?.id){
			event.stopPropagation();
			event.preventDefault();
			selectedValue =  event.target.dataset.id;
		}
		
	}
	
	handleSelect(event) {
		if (!this.multiple && this.selectedOptions.length > 0){
			return;
		}
		let selectedValue = ""
		if(event?.target?.dataset?.id){
			event.stopPropagation();
			event.preventDefault();
			selectedValue =  event.target.dataset.id;
			if (!isNaN(selectedValue)) {
				selectedValue = parseInt(selectedValue);
				}
		}
		else
		{
			selectedValue = event
		}
		const option = this.options.find((opt) => opt.value === selectedValue);

		if (!option) {
			return;
		}
		const updatedOption = { ...option, selected: !option.selected };

		this.options = this.options.map((opt) =>
			opt.value == selectedValue ? updatedOption : opt
		);

		if (updatedOption.selected) {
			this.selectedOptions = [...this.selectedOptions, updatedOption];
		} else {
			this.selectedOptions = this.selectedOptions.filter(
				(opt) => opt.value !== selectedValue
			);
		}
		this.updateOptions();
		this.notifyChange();
		const dropdown = this.template.querySelector(".slds-dropdown");
		if (dropdown) {
			dropdown.classList.add("slds-hide");
			dropdown.classList.remove("slds-show");
		}
	}

	removeOption(event) {
		this.initital =""
		event.stopPropagation();
		event.preventDefault();

		let valueToRemove = event.target.parentElement.dataset.value;

		if (!isNaN(valueToRemove)) {
		valueToRemove = parseInt(valueToRemove);
		}

		this.selectedOptions = this.selectedOptions.filter(
			(opt) => opt.value !== valueToRemove
		);
		const option = this.options.find((opt) => opt.value === valueToRemove);
		if (!option) {
			return;
		}
		const updatedOption = { ...option, selected: false };

		this.options = this.options.map((opt) =>
			opt.value == valueToRemove ? updatedOption : opt
		);

		this.updateOptions();
		this.notifyChange();
		this.notifyRemoval();
	}

	updateOptions() {
		this.options = [...this.options];
	}

	notifyChange() {
		const valueChangeEvent = new CustomEvent("valuechange", {
			detail: this.selectedOptions.map((option) => option.value)
		});
		this.dispatchEvent(valueChangeEvent);
	}
	notifyRemoval() {
		const valueChangeEvent = new CustomEvent("remove", {
			detail: this.selectedOptions.map((option) => option.value)
		});
		this.dispatchEvent(valueChangeEvent);
	}

	handleOutsideClick(event) {
        const dropdown = this.template.querySelector(".slds-dropdown");
        const combobox = this.template.querySelector(".slds-combobox");

        if (dropdown && combobox && !combobox.contains(event.target)) {
            dropdown.classList.add("slds-hide");
            dropdown.classList.remove("slds-show");
        }
    }

    disconnectedCallback() {
        document.removeEventListener("click", this.handleOutsideClick.bind(this));
        this.hasClickListener = false;
    }
	@api
	closeDropdown() {
        const dropdown = this.template.querySelector(".slds-dropdown");
        if (dropdown && !dropdown.classList.contains("slds-hide")) {
            dropdown.classList.add("slds-hide");
			dropdown.classList.remove("slds-show");
        }
    }
}
