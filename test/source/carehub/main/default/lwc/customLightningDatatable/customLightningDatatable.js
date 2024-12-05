import LightningDatatable from "lightning/datatable";
import customTypePhone from "./customTypePhone.html";

export default class CustomLightningDatatable extends LightningDatatable {
	static customTypes = {
		customTypePhone: {
			template: customTypePhone,
			typeAttributes: ["phone"]
		}
	};
}
