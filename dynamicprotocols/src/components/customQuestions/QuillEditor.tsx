import React from "react";
import { ElementFactory, Question, Serializer } from "survey-core";
import Quill from "quill";
import "quill/dist/quill.snow.css";
import { SurveyQuestionElementBase, ReactQuestionFactory } from "survey-react-ui";

const CUSTOM_TYPE = "quill-editor";

export class QuestionQuillModel extends Question {
    getType() {
        return CUSTOM_TYPE;
    }
    get height() {
        return this.getPropertyValue("height");
    }
    set height(val) {
        this.setPropertyValue("height", val);
    }
}

export function registerQuillQuestion() {
    ElementFactory.Instance.registerElement(CUSTOM_TYPE, (name) => {
        return new QuestionQuillModel(name);
    });
}

export class SurveyQuestionQuill extends SurveyQuestionElementBase {
    constructor(props) {
        super(props);
        console.log("SurveyQuestionQuill component initialized", props);
    }

    get question() {
        return this.questionBase;
    }

    get value() {
        return this.question.value || "";
    }

    handleValueChange = (content) => {
        this.question.value = content;
    };

    get style() {
        return { height: this.question.height || "200px" };
    }

    renderQuillEditor() {
        const isReadOnly = this.question.isReadOnly || this.question.isDesignMode;
        console.log(`SurveyQuestionQuill renderQuillEditor: readOnly = ${isReadOnly}, value = ${this.value}`);

        return (
            <div style={this.style}>
                <QuillEditor value={this.value} onChange={this.handleValueChange} readOnly={isReadOnly} />
            </div>
        );
    }

    renderElement() {
        return <div>{this.renderQuillEditor()}</div>;
    }
}

const QuillEditor = ({ value, onChange, readOnly }) => {
    const editorRef = React.useRef(null);

    React.useEffect(() => {
        if (editorRef.current && !editorRef.current.__quill) {
            const quill = new Quill(editorRef.current, {
                theme: "snow",
                modules: {
                    toolbar: [
                        [{ 'header': [1, 2, false] }],
                        ['bold', 'italic', 'underline', 'strike'],
                        ['link', 'image', 'code-block'],
                        [{ 'list': 'ordered' }, { 'list': 'bullet' }],
                        ['clean']
                    ]
                },
                readOnly: readOnly
            });
            quill.on('text-change', () => {
                const content = quill.root.innerHTML;
                onChange(content);
            });

        
            editorRef.current.__quill = quill;
        }
    }, [onChange, readOnly]);


    React.useEffect(() => {
        const quill = editorRef.current?.__quill;
        if (quill && quill.root.innerHTML !== value) {
            quill.root.innerHTML = value;
        }
    }, [value]);

    return <div ref={editorRef} />;
};

ReactQuestionFactory.Instance.registerQuestion(CUSTOM_TYPE, (props) => {
    return React.createElement(SurveyQuestionQuill, props);
});


Serializer.addClass(
    CUSTOM_TYPE,
    [{ name: "height", default: "200px", category: "layout" }],
    function () {
        return new QuestionQuillModel("");
    },
    "question"
);