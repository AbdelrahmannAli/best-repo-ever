/* 
    This file is used for building the minified version (.min.js file) of the FormBuilder component
    Webpack detects any imports used and automatically adds them to the build.
*/
import FormBuilder from "./components/formBuilder/formBuilder";

// This line is used to expose the FormBuilder component to be globally accessible through "window."
(window as any).FormBuilder = FormBuilder;
