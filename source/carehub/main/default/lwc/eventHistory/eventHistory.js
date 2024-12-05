import UtilityLWC from "c/utils";
import { track, api } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import ChartJs from "@salesforce/resourceUrl/ChartJs";
import getCaseEventCode from "@salesforce/apex/ClientCasesController.getCaseEventCode";
import getContactEvents from "@salesforce/apex/ClientCasesController.getContactEvents";
import general_LastMonths from "@salesforce/label/c.general_LastMonths";
import general_LastDays from "@salesforce/label/c.general_LastDays";
import general_LastWeeks from "@salesforce/label/c.general_LastWeeks";
import general_January from "@salesforce/label/c.general_January";
import general_February from "@salesforce/label/c.general_February";
import general_March from "@salesforce/label/c.general_March";
import general_April from "@salesforce/label/c.general_April";
import general_May from "@salesforce/label/c.general_May";
import general_June from "@salesforce/label/c.general_June";
import general_July from "@salesforce/label/c.general_July";
import general_August from "@salesforce/label/c.general_August";
import general_September from "@salesforce/label/c.general_September";
import general_October from "@salesforce/label/c.general_October";
import general_November from "@salesforce/label/c.general_November";
import general_December from "@salesforce/label/c.general_December";
export default class DynamicChart extends UtilityLWC {
	constructor() {
		super("eventHistory");
	}

	lastNumber = 7;
	@api recordId;
	@track refresh = true;
	@track firstRender = true;
	@track selectedEventCode;
	@track selectedView = "daily";
	@track loading = true;
	@track allEvents = [];
	@track eventCodeToName = {};
	@track options = [];
	@track viewOptions = [
		{
			label: general_LastDays.replace("{number}", `${this.lastNumber}`),
			value: "daily"
		},
		{
			label: general_LastWeeks.replace("{number}", `${this.lastNumber}`),
			value: "weekly"
		},
		{
			label: general_LastMonths.replace("{number}", `${this.lastNumber}`),
			value: "monthly"
		}
	];
	@track chart;

	labels = {
		general_January,
		general_February,
		general_March,
		general_April,
		general_May,
		general_June,
		general_July,
		general_August,
		general_September,
		general_October,
		general_November,
		general_December
	};

	day = 24 * 60 * 60 * 1000;

	async setDefaultEventCode() {
		this.selectedEventCode = await getCaseEventCode({ caseId: this.recordId });
	}

	async setupData() {
		try {
			if (!this.selectedEventCode) {
				await this.setDefaultEventCode();
			}
			if (this.allEvents.length > 0) {
				return;
			}
			this.allEvents = await getContactEvents({ recordId: this.recordId });
			if (!this.selectedEventCode && this.allEvents.length !== 0) {
				this.selectedEventCode = `${this.allEvents[0].Syntilio__EventCode__c}`;
			}
			let optionsList = [];
			this.allEvents.forEach((event) => {
				if (!this.eventCodeToName[`${event.Syntilio__EventCode__c}`]) {
					this.eventCodeToName[`${event.Syntilio__EventCode__c}`] = event.Name;
					optionsList.push({
						label: event.Name,
						value: `${event.Syntilio__EventCode__c}`
					});
				}
			});
			if (
				this.allEvents.length > 0 &&
				this.selectedEventCode &&
				!this.eventCodeToName[this.selectedEventCode]
			) {
				this.selectedEventCode = `${this.allEvents[0].Syntilio__EventCode__c}`;
			}
			this.options = optionsList;
		} catch (error) {
			this.logException(error, "setupData");
		}
	}

	renderedCallback() {
		if (!this.refresh) {
			return;
		}
		this.refresh = false;
		if (!this.firstRender) {
			this.initializeChart();
			return;
		}
		this.loading = true;
		this.firstLoad();
	}

	async firstLoad() {
		try {
			await loadScript(this, ChartJs);
			await this.setupData();
			this.initializeChart();
		} catch (error) {
			this.logException(error, "firstLoad");
		} finally {
			this.loading = false;
			this.firstRender = false;
		}
	}

	handleChangeSelectedEvent(event) {
		this.selectedEventCode = event.detail.value;
		this.refresh = true;
	}

	handleChangeSelectedView(event) {
		this.selectedView = event.detail.value;
		this.refresh = true;
	}

	formatDayMonth(date) {
		let month = (1 + date.getMonth()).toString();
		month = month.length > 1 ? month : "0" + month;
		let day = date.getDate().toString();
		day = day.length > 1 ? day : "0" + day;
		return `${day}/${month}`;
	}

	setupDaily(fromDate) {
		let datesToCounts = {};
		for (let i = 0; i < this.lastNumber; i++) {
			let date = new Date(fromDate.getTime() + i * this.day);
			let dateFormatted = this.formatDayMonth(date);
			datesToCounts[dateFormatted] = 0;
		}
		return datesToCounts;
	}

	setupWeekly(fromDate) {
		let datesToCounts = {};
		for (let i = 0; i < this.lastNumber; i++) {
			let weekStart = new Date(fromDate.getTime() + i * 7 * this.day);
			let weekEnd = new Date(weekStart.getTime() + 6 * this.day);
			let dateFormatted = `${this.formatDayMonth(weekStart)} - ${this.formatDayMonth(
				weekEnd
			)}`;
			datesToCounts[dateFormatted] = 0;
		}
		return datesToCounts;
	}

	setupMonthly(fromDate) {
		let datesToCounts = {};
		for (let i = 0; i < this.lastNumber; i++) {
			let date = new Date(fromDate);
			date.setMonth(fromDate.getMonth() + i);
			let dateFormatted = date.toLocaleString("default", { month: "long" });
			datesToCounts[this.labels[`general_${dateFormatted}`]] = 0;
		}
		return datesToCounts;
	}

	getDatesToCountsKey(date, datesToCounts) {
		switch (this.selectedView) {
			case "daily":
				return this.formatDayMonth(date);
			case "weekly":
				for (let week of Object.keys(datesToCounts)) {
					let weekSplit = week.split(" - ");
					let fromDate = new Date(
						date.getFullYear(),
						parseInt(weekSplit[0].split("/")[1], 10) - 1,
						parseInt(weekSplit[0].split("/")[0], 10)
					);
					let toDate = new Date(
						date.getFullYear(),
						parseInt(weekSplit[1].split("/")[1], 10) - 1,
						parseInt(weekSplit[1].split("/")[0], 10)
					);
					if (date >= fromDate && date <= toDate) {
						return week;
					}
				}
				return null;
			case "monthly":
				return this.labels[
					`general_${date.toLocaleString("default", { month: "long" })}`
				];
			default:
				return null;
		}
	}

	initializeChart() {
		try {
			if (this.chart) {
				this.chart.destroy();
			}
			const ctx = this.template.querySelector('[data-id="chart"]').getContext("2d");

			let toDate = new Date(new Date().toISOString().split("T")[0]);
			let fromDate;

			let datesToCounts = {};

			switch (this.selectedView) {
				case "daily":
					fromDate = new Date(toDate.getTime() - (this.lastNumber - 1) * this.day);
					datesToCounts = this.setupDaily(fromDate);
					break;
				case "weekly":
					fromDate = new Date(
						toDate.getTime() - 7 * this.lastNumber * this.day + this.day
					);
					datesToCounts = this.setupWeekly(fromDate);
					break;
				case "monthly":
					fromDate = new Date(toDate);
					fromDate.setMonth(toDate.getMonth() - (this.lastNumber - 1));
					datesToCounts = this.setupMonthly(fromDate);
					break;
				default:
			}

			const eventsFiltered = this.allEvents.filter((event) => {
				let timestamp = new Date(event.CreatedDate);
				let eventDate = new Date(timestamp.toISOString().split("T")[0]);
				return (
					`${event.Syntilio__EventCode__c}` === this.selectedEventCode &&
					eventDate >= fromDate &&
					eventDate <= toDate
				);
			});

			eventsFiltered.forEach((event) => {
				let timestamp = new Date(event.CreatedDate);
				timestamp.setHours(0, 0, 0, 0);
				let key = this.getDatesToCountsKey(timestamp, datesToCounts);
				if (!key) {
					return;
				}
				let count = datesToCounts[key];
				if (!count) {
					count = 0;
				}
				datesToCounts[key] = count + 1;
			});

			const data = [];
			Object.entries(datesToCounts).forEach(([key, value]) => {
				data.push({ date: key, count: value });
			});

			const dates = data.map((record) => record.date);
			const counts = data.map((record) => record.count);

			// eslint-disable-next-line no-new
			this.chart = new window.Chart(ctx, {
				type: "line",
				data: {
					labels: dates,
					datasets: [
						{
							label: this.eventCodeToName[this.selectedEventCode],
							data: counts,
							fill: false,
							borderColor: "#7a439f",
							borderWidth: 2,
							pointRadius: 5,
							pointBackgroundColor: "#7a439f",
							pointBorderColor: "#7a439f",
							pointHoverRadius: 8,
							pointHoverBackgroundColor: "#7a439f"
						}
					]
				},
				options: {
					legend: {
						display: false
					},
					scales: {
						yAxes: [
							{
								display: true,
								ticks: {
									suggestedMin: 0,
									callback: function (value) {
										if (value % 1 === 0) {
											return value;
										}
										return null;
									}
								}
							}
						]
					}
				}
			});
		} catch (error) {
			this.logException(error, "initializeChart");
		}
	}
}
