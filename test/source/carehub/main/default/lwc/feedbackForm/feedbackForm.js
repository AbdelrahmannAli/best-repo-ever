import { LightningElement, api } from 'lwc';
import postFeedback from '@salesforce/apex/FeedbackController.postFeedback';
import generatePublicURL from '@salesforce/apex/FeedbackController.generatePublicURL';
import feedbackForm_WhatIsTheProblem from "@salesforce/label/c.feedbackForm_WhatIsTheProblem";
import feedbackForm_UrlLink from "@salesforce/label/c.feedbackForm_UrlLink";
import feedbackForm_StepsToReproduce from "@salesforce/label/c.feedbackForm_StepsToReproduce";
import feedbackForm_Expected from "@salesforce/label/c.feedbackForm_Expected";
import feedbackForm_Happened from "@salesforce/label/c.feedbackForm_Happened";
import feedbackForm_Problem from "@salesforce/label/c.feedbackForm_Problem";
import feedbackForm_AttachImage from "@salesforce/label/c.feedbackForm_AttachImage";
import USER_ID from '@salesforce/user/Id';

export default class FeedbackForm extends LightningElement {
    isConfirmationVisible = false;
    isSubmitDisabled = true;
    uploadedFilesIds = [];
    fields = { 
        feedbackType: "", 
        files: [], 
        problem: "",
        url: "",
        steps: "",
        expected: "",
        actual: "",
        severity: ""
    };

    labels = {
		feedbackForm_WhatIsTheProblem,
        feedbackForm_UrlLink,
        feedbackForm_StepsToReproduce,
        feedbackForm_Expected,
        feedbackForm_Happened,
        feedbackForm_Problem,
        feedbackForm_AttachImage
	};
    @api fileId;
    get acceptedFormats() {
        return ['.png', '.jpg', '.jpeg', '.gif', 'webp'];
    }    
    
    options = [
        { label: 'Bug', value: 'Bug' },
        { label: 'Idea', value: 'Idea' },
        { label: 'Other', value: 'Other' },
    ];
    
    severityOptions = [
        { label: 'Blocking', value: 'Blocking' },
        { label: 'High', value: 'High' },
        { label: 'Medium', value: 'Medium' },
        { label: 'Low', value: 'Low' }
    ];

    handleInputChange(event) {
        const fieldName = event.target.name; // Get the name attribute from the input
        const fieldValue = event.detail.value; // Get the value from the input
    
        // Update the corresponding field based on the name
        switch (fieldName) {
            case 'feedbackType':
                this.fields.feedbackType = fieldValue;
                break;
            case 'problem':
                this.fields.problem = fieldValue;
                break;
            case 'url':
                this.fields.url = fieldValue;
                break;
            case 'steps':
                this.fields.steps = fieldValue;
                break;
            case 'expected':
                this.fields.expected = fieldValue;
                break;
            case 'actual':
                this.fields.actual = fieldValue;
                break;
            case 'problemSeverity':
                this.fields.severity = fieldValue;
                break;
            default:
                console.warn(`Field name ${fieldName} is not recognized.`);
        }
    
        this.validateForm(); // Validate form after every input change
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;

        if (uploadedFiles?.length > 0) {
            this.uploadedFilesIds = uploadedFiles.map(file => file.documentId);

            uploadedFiles.map(fileId => {
                generatePublicURL({contentDocumentId: fileId.documentId})
                    .then((result) => {
                        this.fields.files.push(result);
                    })
                    .catch((error) => {
                        console.error('Error generating public URL:', error);
                    });
            });
        }
    }
    
    resetDefaults() {
        this.isConfirmationVisible = false;
        this.isSubmitDisabled = true;
        this.fields = { 
            feedbackType: "Bug", 
            files: [], 
            problem: "",
            url: "",
            steps: "",
            expected: "",
            actual: "",
            severity: ""
        };
        this.uploadedFilesIds = [];
        this.template.querySelectorAll('lightning-input, lightning-textarea, lightning-combobox, lightning-radio-group')
            .forEach(input => input.value = "");
        this.validateForm();
    }

    validateForm() {
        const { feedbackType, problem} = this.fields;
        this.isSubmitDisabled = !(feedbackType && problem);
    }

    handleSubmit() {
        const { feedbackType, problem, url, steps, expected, actual, severity, files } = this.fields;

        this.isConfirmationVisible = true;

        setTimeout(() => {
            this.resetDefaults();
        }, 3000);

        postFeedback({
            FeedbackType: feedbackType, 
            Problem: problem,
            URL: url,
            Steps: steps,
            Expected: expected,
            Actual: actual,
            Severity: severity,
            FileUrls: files
        });
    }
}